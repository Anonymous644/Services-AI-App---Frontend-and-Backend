import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { PrismaService } from '../../utils/services/prisma.service';
import { ChatService } from './chat.service';
import { ToolExecutor } from '../tools/tool-executor';
import { toolDefinitions } from '../tools/tool-definitions';
import { AIMemoryStep } from '@prisma/client';
import { ChatAction } from '../types/actions.types';
import { GoogleGenAI } from '@google/genai';
import { GlobalConstants } from '../../utils/GlobalConstants';

const SYSTEM_PROMPT = `You are the AI assistant for "Services AI" — a professional services booking platform. You help customers find and book home services like AC repair, plumbing, electrical work, cleaning, painting, etc.

## Your Personality
- Be friendly, professional, and efficient
- Act as a human-like service agent, not a generic chatbot
- Be proactive in gathering information
- Provide clear reasoning when recommending providers
- CRITICAL: ALWAYS respond in the exact same language as the user's MOST RECENT message. If the user speaks in Roman Urdu / Hinglish, you MUST reply in natural Roman Urdu / Hinglish. If they speak in English, reply in English. Match their tone and language seamlessly.

## Booking Flow
When a customer wants a service:
1. Understand what service they need
2. Use search_services tool to find the matching service category
3. Use request_location tool to ask the user to confirm or update their location on the map.
4. Once location is confirmed, ask for missing details: preferred date/time
5. Use search_providers tool to find nearby providers (30km radius)
5. You will receive 10 providers. Compare them based on: ratings, distance, availability for the requested time, experience, and price range. Factor in distance and complexity to determine a fair price per provider.
6. Present the TOP 3 providers to the customer with your reasoning and pricing
7. When customer selects a provider, create the booking with create_booking tool
8. After booking is created, prompt for payment
9. Process payment when customer confirms

## Job Completion Flow
When a provider marks a job as completed:
- Ask the customer to confirm the job is done
- If customer confirms → use confirm_completion tool
- If customer says the job wasn't properly done → use create_dispute tool with their reason
- After completion, ask for a review (rating 1-5 and optional comment)

## Review Flow
After booking completion:
- Ask the customer to rate the provider (1-5 stars)
- Gather an optional comment
- Use submit_review tool to submit

## Important Rules
- Always infer a subcategory name from context (e.g., "AC Repair", "Pipe Leak Fix")
- Set per-provider pricing based on: service complexity, provider's min/max price range, and distance
- Different providers should have different prices
- Only use credits for payment if they cover the FULL booking amount
- Use find_booking tool when customer asks about existing bookings
- Never make up provider or service data — always use the tools
- When the step is AWAITING_SELECTION and Ranked Providers data is in context, do NOT call search_services or search_providers again. Use the existing provider data to call create_booking directly when the customer selects one.
- After search_providers returns providers, you MUST call rank_providers to submit your top picks with reasoning and pricing. Include only real provider IDs from the results — omit secondPick/thirdPick if fewer than 2/3 providers exist. Never use placeholder IDs like "0". Never skip rank_providers.

## Conversation
- Keep responses concise but helpful
- Use the customer's first name when you know it
- Format currency as "PKR X,XXX"
- Be transparent about pricing reasoning
- When presenting the top 3 providers, DO NOT list all their details (name, rating, experience, price) in your text response. The UI already shows this in the provider cards. Instead, keep your text extremely short (1-2 sentences): just give a brief overview and explain why your #1 pick is the best choice.

## Formatting Rules
- NEVER use markdown formatting in your responses. No asterisks, no bold, no italic, no bullet points, no headers.
- Write everything as plain text sentences and paragraphs.
- Use line breaks to separate ideas, not bullet lists.
- For emphasis, use CAPS sparingly or just phrase things clearly.

## Starting a New Booking
When the user requests a new service — even if there is an active or recently completed booking — always treat it as a completely fresh booking. NEVER reuse or assume the same date, time, location, or any other detail from a previous booking. For every new booking you MUST:
1. Confirm the new service they need
2. Use request_location tool to get their location
3. Ask for the preferred date and time
4. Ask for any special notes or requirements
There are NO exceptions to this rule. Even if the previous booking had a location and time, you must ask again.`;

/**
 * Core AI service integrating Gemini 3.0 Flash with tool calling and streaming.
 */
@Injectable()
export class AIService {
  private readonly logger = new Logger(AIService.name);
  private readonly genAI: GoogleGenAI;

  constructor(
    private readonly prisma: PrismaService,
    private readonly chatService: ChatService,
    private readonly toolExecutor: ToolExecutor,
  ) {
    this.genAI = new GoogleGenAI({
      enterprise: true,
      apiKey: process.env.GOOGLE_AGENT_PLATFORM_API_KEY,
    });
  }

  /**
   * Process a user message through the AI pipeline.
   * Handles streaming, tool calls, and response generation.
   *
   * @param userId - The customer's user ID
   * @param message - The user's message text
   * @param emitThinking - Callback to emit thinking status events
   * @param emitAiThinking - Callback to emit AI reasoning
   * @param emitStream - Callback to emit response text chunks
   * @returns The final complete message (text + actions)
   */
  async processMessage(
    userId: string,
    message: string,
    emitThinking: (msg: string) => void,
    emitAiThinking: (content: string) => void,
    emitStream: (content: string) => void,
  ): Promise<{
    content: string;
    actions?: ChatAction[];
    toolCalls?: any[];
    toolResults?: any[];
  }> {
    this.logger.debug(`📩 Processing message for user ${userId}: "${message}"`);
    emitThinking('Understanding your request...');

    // Get user details for context
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        location: true,
        creditBalance: true,
      },
    });

    this.logger.debug(
      `👤 User: ${user?.firstName} ${user?.lastName}, Credits: ${user?.creditBalance}`,
    );

    // Get active AIMemory (if any)
    const activeMemory = await this.prisma.aIMemory.findFirst({
      where: { userId, isActive: true },
    });

    this.logger.debug(
      `🧠 Active memory: ${activeMemory ? `step=${activeMemory.currentStep}, bookingId=${activeMemory.bookingId}` : 'none'}`,
    );

    // Build context
    const now = new Date();
    const dayNames = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    const contextParts: string[] = [
      `Current Date: ${now.toISOString().split('T')[0]} (${dayNames[now.getDay()]})`,
      `Current Time: ${now.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: true })}`,
      `Customer: ${user.firstName} ${user.lastName}`,
      `Customer ID: ${userId}`,
      `Credit Balance: PKR ${user.creditBalance}`,
      `Location: ${JSON.stringify(user.location)}`,
    ];

    if (activeMemory) {
      const prePaymentSteps: string[] = [
        AIMemoryStep.GATHERING_INFO,
        AIMemoryStep.SEARCHING_PROVIDERS,
        AIMemoryStep.AWAITING_SELECTION,
        AIMemoryStep.AWAITING_PAYMENT,
      ];
      const isPrePayment = prePaymentSteps.includes(activeMemory.currentStep);

      contextParts.push(`\nActive Booking Memory:`);
      contextParts.push(`Step: ${activeMemory.currentStep}`);

      if (isPrePayment) {
        if (activeMemory.categoryId)
          contextParts.push(`Category ID: ${activeMemory.categoryId}`);
        if (activeMemory.subCategory)
          contextParts.push(`Subcategory: ${activeMemory.subCategory}`);
        if (activeMemory.serviceDetails)
          contextParts.push(`Service Details: ${activeMemory.serviceDetails}`);
        if (activeMemory.scheduledDate)
          contextParts.push(`Scheduled Date: ${activeMemory.scheduledDate}`);
        if (activeMemory.scheduledTime)
          contextParts.push(`Scheduled Time: ${activeMemory.scheduledTime}`);
        if (activeMemory.bookingId)
          contextParts.push(`Booking ID: ${activeMemory.bookingId}`);
        if (activeMemory.selectedProviderId)
          contextParts.push(
            `Selected Provider: ${activeMemory.selectedProviderId}`,
          );
        if (activeMemory.estimatedPrice)
          contextParts.push(`Price: PKR ${activeMemory.estimatedPrice}`);
        if (activeMemory.providerOptions) {
          contextParts.push(
            `\nRanked Providers (already selected — use these directly, do NOT re-search):`,
          );
          contextParts.push(activeMemory.providerOptions);
        }
        if (activeMemory.location) {
          contextParts.push(
            `Booking Location: ${JSON.stringify(activeMemory.location)}`,
          );
        }
      } else if (
        activeMemory.currentStep === AIMemoryStep.AWAITING_COMPLETION
      ) {
        // Provider marked job done; waiting for customer to confirm or dispute.
        if (activeMemory.bookingId)
          contextParts.push(`Booking ID: ${activeMemory.bookingId}`);
        contextParts.push(
          `ACTION REQUIRED: The provider has marked this booking as complete and the customer has been asked to confirm. ` +
            `When the customer confirms the job is done, you MUST call the confirm_completion tool with bookingId = "${activeMemory.bookingId}". ` +
            `Do NOT claim the booking is complete without actually calling confirm_completion. ` +
            `If the customer says the job was NOT done properly, call create_dispute instead.`,
        );
      } else if (activeMemory.currentStep === AIMemoryStep.AWAITING_REVIEW) {
        // Booking is completed; waiting for the customer to leave a review.
        if (activeMemory.bookingId)
          contextParts.push(`Booking ID: ${activeMemory.bookingId}`);
        contextParts.push(
          `ACTION REQUIRED: The booking is complete. Ask the customer to rate their provider (1-5 stars) and an optional comment. ` +
            `When they provide a rating, call submit_review with bookingId = "${activeMemory.bookingId}", rating, and optional comment. ` +
            `Do NOT claim the review was submitted without calling submit_review.`,
        );
      } else {
        // Post-payment (other steps): only expose bookingId for tracking.
        // Do NOT include date, time, location or provider info — those belong to the old booking
        // and must not bleed into any new booking the user requests.
        if (activeMemory.bookingId)
          contextParts.push(`Booking ID: ${activeMemory.bookingId}`);
        contextParts.push(
          `IMPORTANT: This booking is already confirmed and paid. If the user is asking for a NEW service, you MUST collect all fresh details: service, preferred date, time, location, and notes. Do NOT reuse anything from this booking.`,
        );
      }
    }

    // Get chat history
    const chatHistory = await this.chatService.getMessagesForAI(userId, 30);
    this.logger.debug(`💬 Chat history: ${chatHistory.length} messages loaded`);

    // Build the chat
    const chat = this.genAI.chats.create({
      model: GlobalConstants.geminiModels.generative,
      history: chatHistory,
      config: {
        systemInstruction: SYSTEM_PROMPT,
        tools: [{ functionDeclarations: toolDefinitions }],
      },
    });

    // Send message with context
    const fullMessage = `[Context: ${contextParts.join(', ')}]\n\nUser message: ${message}`;
    this.logger.debug(
      `📤 Sending to Gemini: ${fullMessage.substring(0, 200)}...`,
    );

    // Collect all tool calls and results
    const allToolCalls: any[] = [];
    const allToolResults: any[] = [];
    const MAX_TOOL_ITERATIONS = 10;
    let toolIteration = 0;

    let result = await this.sendWithRetry(() =>
      chat.sendMessage({ message: fullMessage }),
    );

    this.logger.debug(
      `📥 Gemini response received. Candidates: ${JSON.stringify(result.candidates?.length)}`,
    );

    // Handle tool call loops (AI may call multiple tools in sequence)
    let functionCalls = result.functionCalls ?? [];
    this.logger.debug(
      `🔧 Function calls: ${functionCalls.length > 0 ? functionCalls.map((c) => c.name).join(', ') : 'none'}`,
    );

    while (functionCalls.length > 0 && toolIteration < MAX_TOOL_ITERATIONS) {
      toolIteration++;
      for (const call of functionCalls) {
        this.logger.debug(
          `🔧 Executing tool: ${call.name}(${JSON.stringify(call.args)})`,
        );
        allToolCalls.push({ name: call.name, args: call.args });

        try {
          const toolResult = await this.toolExecutor.execute(
            call.name,
            call.args,
            userId,
            emitThinking,
          );
          this.logger.debug(
            `✅ Tool ${call.name} result: ${JSON.stringify(toolResult).substring(0, 300)}`,
          );
          allToolResults.push({ name: call.name, result: toolResult });

          // Send tool result back to AI
          result = await chat.sendMessage({
            message: [
              {
                functionResponse: {
                  name: call.name,
                  response: toolResult,
                },
              },
            ],
          });
        } catch (error) {
          const err = error as Error;
          this.logger.error(
            `❌ Tool ${call.name} failed: ${err.message}`,
            err.stack,
          );
          allToolResults.push({ name: call.name, error: err.message });

          result = await chat.sendMessage({
            message: [
              {
                functionResponse: {
                  name: call.name,
                  response: { error: err.message },
                },
              },
            ],
          });
        }
      }

      // Check for more function calls in the new response
      functionCalls = result.functionCalls ?? [];
      this.logger.debug(
        `🔧 Follow-up function calls: ${functionCalls.length > 0 ? functionCalls.map((c) => c.name).join(', ') : 'none'}`,
      );
    }

    // Get the final text response (text() throws if response has only function calls)
    let responseText = '';
    try {
      responseText = result.text ?? '';
    } catch (e) {
      this.logger.warn(`⚠️ result.text() failed: ${(e as Error).message}`);
      responseText = '';
    }

    this.logger.debug(
      `📝 Final response text (${responseText.length} chars): "${responseText.substring(0, 200)}..."`,
    );

    // Emit the response as a single stream event.
    // Word-by-word throttling is handled on the Flutter side (90 ms/word queue),
    // so adding an artificial server-side delay only adds latency.
    if (responseText) {
      emitStream(responseText);
    }

    // Determine actions based on the booking flow state
    const actions = await this.determineActions(
      userId,
      allToolCalls,
      allToolResults,
      user?.location,
    );

    return {
      content: responseText,
      actions: actions.length > 0 ? actions : undefined,
      toolCalls: allToolCalls.length > 0 ? allToolCalls : undefined,
      toolResults: allToolResults.length > 0 ? allToolResults : undefined,
    };
  }

  /**
   * Generate a contextual AI response for provider status updates.
   * Called when provider updates booking status via REST API.
   */
  async generateStatusResponse(
    customerId: string,
    bookingId: string,
    newStatus: string,
    bookingDetails: any,
  ): Promise<{ content: string; actions?: ChatAction[] }> {
    const customerName = bookingDetails.customer?.firstName ?? 'the customer';

    const statusMessages: Record<string, string> = {
      INITIALIZED: `Write a single, brief message directly to ${customerName} telling them their provider ${bookingDetails.provider.firstName} ${bookingDetails.provider.lastName} has started working on their ${bookingDetails.category.name} (${bookingDetails.subCategoryName || bookingDetails.category.name}) booking scheduled for ${bookingDetails.scheduledAt}. Keep it to 2-3 sentences.`,
      PROVIDER_COMPLETED: `Write a single, brief message directly to ${customerName} telling them their provider ${bookingDetails.provider.firstName} ${bookingDetails.provider.lastName} has marked the ${bookingDetails.category.name} job as complete. Ask them to confirm whether the work was done to their satisfaction. Keep it to 2-3 sentences.`,
      CANCELLED: `Write a single, brief message directly to ${customerName} telling them that their provider ${bookingDetails.provider.firstName} ${bookingDetails.provider.lastName} has cancelled the ${bookingDetails.category.name} booking. Let them know a full refund of PKR ${bookingDetails.totalAmount} has been returned to their credits balance. Keep it to 2-3 sentences.`,
    };

    const instruction =
      statusMessages[newStatus] ??
      `Write a single brief message directly to ${customerName} about a status update on their ${bookingDetails.category.name} booking.`;

    const prompt = `${instruction}

Rules you MUST follow:
- Write ONE message only — no options, no alternatives, no "Option 1/2/3"
- Do NOT use any markdown: no **, no ##, no bullet points
- Address the customer directly (use their name: ${customerName})
- Plain conversational sentences only`;

    const result = await this.genAI.models.generateContent({
      model: GlobalConstants.geminiModels.generative,
      config: { systemInstruction: SYSTEM_PROMPT },
      contents: prompt,
    });
    const responseText = result.text ?? '';

    let actions: ChatAction[] = [];

    if (newStatus === 'PROVIDER_COMPLETED') {
      actions = [
        {
          type: 'CONFIRM_COMPLETION' as any,
          data: {
            bookingId,
            providerName: `${bookingDetails.provider.firstName} ${bookingDetails.provider.lastName}`,
            serviceDetails: bookingDetails.serviceDetails,
          },
        },
      ];

      // Force the AI's attention to this specific booking for confirmation
      await this.prisma.aIMemory.updateMany({
        where: { userId: customerId, isActive: true },
        data: { isActive: false },
      });

      const updatedMemories = await this.prisma.aIMemory.updateMany({
        where: { userId: customerId, bookingId },
        data: { currentStep: AIMemoryStep.AWAITING_COMPLETION, isActive: true },
      });

      if (updatedMemories.count === 0) {
        // Fallback: if memory doesn't exist for some reason, create one
        const chat = await this.prisma.chat.findFirst({
          where: { userId: customerId },
        });
        await this.prisma.aIMemory.create({
          data: {
            userId: customerId,
            chatId: chat!.id,
            bookingId,
            currentStep: AIMemoryStep.AWAITING_COMPLETION,
            isActive: true,
          },
        });
      }
    } else if (newStatus === 'INITIALIZED') {
      actions = [
        {
          type: 'BOOKING_CARD' as any,
          data: {
            bookingId,
            status: newStatus,
            categoryName: bookingDetails.category.name,
            subCategoryName: bookingDetails.subCategoryName,
            providerName: `${bookingDetails.provider.firstName} ${bookingDetails.provider.lastName}`,
            scheduledAt: bookingDetails.scheduledAt,
            totalAmount: bookingDetails.totalAmount,
          },
        },
      ];
    }

    return {
      content: responseText,
      actions: actions.length > 0 ? actions : undefined,
    };
  }

  /**
   * Wraps a Gemini API call with exponential-backoff retry for transient
   * errors (503 Service Unavailable, 429 Too Many Requests).
   */
  private async sendWithRetry(
    fn: () => Promise<any>,
    maxAttempts = 3,
  ): Promise<any> {
    let lastError: Error;
    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await fn();
      } catch (error) {
        lastError = error as Error;
        const isTransient =
          lastError.message?.includes('503') ||
          lastError.message?.includes('Service Unavailable') ||
          lastError.message?.includes('high demand') ||
          lastError.message?.includes('429') ||
          lastError.message?.includes('Too Many Requests');
        if (isTransient && attempt < maxAttempts) {
          const delay = Math.pow(2, attempt - 1) * 1500; // 1.5s, 3s
          this.logger.warn(
            `Gemini transient error (attempt ${attempt}/${maxAttempts}), retrying in ${delay}ms: ${lastError.message}`,
          );
          await new Promise((r) => setTimeout(r, delay));
          continue;
        }
        throw error;
      }
    }
    throw lastError!;
  }

  /**
   * Ensure an AIMemory exists for the user.
   * Creates one if not active.
   */
  async ensureMemory(userId: string) {
    const existing = await this.prisma.aIMemory.findFirst({
      where: { userId, isActive: true },
    });

    if (!existing) {
      // Get or create the chat to get the chatId
      const chat = await this.chatService.getOrCreateChat(userId);

      return this.prisma.aIMemory.create({
        data: {
          userId,
          chatId: chat.id,
          currentStep: AIMemoryStep.GATHERING_INFO,
          isActive: true,
        },
      });
    }

    return existing;
  }

  /**
   * Determine UI actions based on tool call results.
   */
  private async determineActions(
    userId: string,
    toolCalls: any[],
    toolResults: any[],
    userLocation?: any,
  ): Promise<ChatAction[]> {
    const actions: ChatAction[] = [];

    for (let i = 0; i < toolCalls.length; i++) {
      const call = toolCalls[i];
      const result = toolResults[i]?.result;
      if (!result) continue;

      if (call.name === 'request_location') {
        const coords = userLocation?.geo?.coordinates;
        actions.push({
          type: 'LOCATION_REQUEST' as any,
          data: {
            currentAddress: userLocation?.address || '',
            currentCity: userLocation?.city || '',
            currentLatitude: coords?.[1] ?? 0,
            currentLongitude: coords?.[0] ?? 0,
          },
        });
      }

      // Ranked providers → build PROVIDER_SELECTION action with AI reasoning
      if (
        call.name === 'rank_providers' &&
        result.rankedProviders?.length > 0
      ) {
        actions.push({
          type: 'PROVIDER_SELECTION' as any,
          data: {
            categoryName: result.categoryName,
            overallReasoning: result.overallReasoning,
            providers: result.rankedProviders.map((p: any) => ({
              rank: p.rank,
              providerId: p.providerId,
              name: p.name,
              rating: p.rating,
              totalJobs: p.totalJobs,
              experience: p.experience,
              bio: p.bio,
              distance: p.distance,
              availability: p.availability,
              reasoning: p.reasoning,
              estimatedPrice: p.estimatedPrice,
              isTopPick: p.isTopPick,
            })),
          },
        });
      }

      if (call.name === 'create_booking' && result.bookingId) {
        const customer = await this.prisma.user.findUnique({
          where: { id: userId },
          select: { creditBalance: true },
        });

        actions.push({
          type: 'PAYMENT_REQUEST' as any,
          data: {
            bookingId: result.bookingId,
            amount: result.totalAmount,
            providerName: result.providerName,
            scheduledAt: result.scheduledAt,
            customerCredits: customer.creditBalance,
            canPayWithCredits: customer.creditBalance >= result.totalAmount,
          },
        });
      }

      if (call.name === 'process_payment' && result.bookingId) {
        actions.push({
          type: 'BOOKING_CARD' as any,
          data: {
            bookingId: result.bookingId,
            status: 'PENDING',
            categoryName: result.categoryName,
            subCategoryName: result.subCategoryName,
            providerName: result.providerName,
            scheduledAt: result.scheduledAt,
            totalAmount: result.totalAmount,
            location: result.location,
            paidAt: result.paidAt,
          },
        });
      }

      if (call.name === 'confirm_completion') {
        actions.push({
          type: 'REVIEW_REQUEST' as any,
          data: {
            bookingId: toolCalls[i].args.bookingId,
            providerName: result.providerName || 'your provider',
          },
        });
      }

      if (call.name === 'find_booking' && result.bookings?.length > 0) {
        for (const booking of result.bookings) {
          actions.push({
            type: 'BOOKING_CARD' as any,
            data: {
              bookingId: booking.id,
              status: booking.status,
              categoryName: booking.categoryName,
              subCategoryName: booking.subCategoryName,
              providerName: booking.providerName,
              scheduledAt: booking.scheduledAt,
              totalAmount: booking.totalAmount,
              location: booking.location,
            },
          });
        }
      }
    }

    return actions;
  }

  private sleep(ms: number) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}
