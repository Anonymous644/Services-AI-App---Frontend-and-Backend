import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../utils/services/prisma.service';
import { ChatMessageRole } from '@prisma/client';
import { ChatAction } from '../types/actions.types';

@Injectable()
export class ChatService {
  private readonly logger = new Logger(ChatService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Get or create a chat for a customer.
   * Each customer has exactly one chat.
   */
  async getOrCreateChat(userId: string) {
    let chat = await this.prisma.chat.findUnique({
      where: { userId },
    });

    if (!chat) {
      chat = await this.prisma.chat.create({
        data: { userId },
      });
      this.logger.log(`Created new chat for user ${userId}`);
    }

    return chat;
  }

  /**
   * Get chat history for a customer.
   * Returns messages ordered by creation time.
   */
  async getChatHistory(userId: string, limit = 50) {
    const chat = await this.getOrCreateChat(userId);

    const messages = await this.prisma.chatMessage.findMany({
      where: { chatId: chat.id },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });

    // Reverse so the result is chronological (oldest → newest)
    messages.reverse();

    return messages.map((msg) => ({
      ...msg,
      actions: msg.actions ? JSON.parse(msg.actions) : null,
      toolCalls: msg.toolCalls ? JSON.parse(msg.toolCalls) : null,
      toolResults: msg.toolResults ? JSON.parse(msg.toolResults) : null,
    }));
  }

  /**
   * Save a user message to the chat.
   */
  async saveUserMessage(userId: string, content: string) {
    const chat = await this.getOrCreateChat(userId);

    return this.prisma.chatMessage.create({
      data: {
        chatId: chat.id,
        role: ChatMessageRole.USER,
        content,
      },
    });
  }

  /**
   * Save an AI assistant message to the chat.
   */
  async saveAssistantMessage(
    userId: string,
    content: string,
    actions?: ChatAction[],
    toolCalls?: any[],
    toolResults?: any[],
  ) {
    const chat = await this.getOrCreateChat(userId);

    return this.prisma.chatMessage.create({
      data: {
        chatId: chat.id,
        role: ChatMessageRole.ASSISTANT,
        content,
        actions: actions ? JSON.stringify(actions) : null,
        toolCalls: toolCalls ? JSON.stringify(toolCalls) : null,
        toolResults: toolResults ? JSON.stringify(toolResults) : null,
      },
    });
  }

  /**
   * Save a system message (automated status updates).
   */
  async saveSystemMessage(
    userId: string,
    content: string,
    actions?: ChatAction[],
  ) {
    const chat = await this.getOrCreateChat(userId);

    return this.prisma.chatMessage.create({
      data: {
        chatId: chat.id,
        role: ChatMessageRole.SYSTEM,
        content,
        actions: actions ? JSON.stringify(actions) : null,
      },
    });
  }

  /**
   * Clear all chat messages and AI memories for a user.
   * Resets the conversation to a clean slate.
   */
  async clearChatHistory(userId: string) {
    const chat = await this.prisma.chat.findUnique({ where: { userId } });

    if (chat) {
      await this.prisma.chatMessage.deleteMany({ where: { chatId: chat.id } });
    }

    await this.prisma.aIMemory.deleteMany({ where: { userId } });

    this.logger.log(`Cleared chat history and AI memory for user ${userId}`);
  }

  /**
   * Get the last N messages formatted for Gemini context.
   * Strips internal fields and formats for the AI model.
   */
  async getMessagesForAI(userId: string, limit = 30) {
    const chat = await this.getOrCreateChat(userId);

    const messages = await this.prisma.chatMessage.findMany({
      where: { chatId: chat.id },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });

    // Format for Gemini
    const formatted = messages.reverse().map((msg) => ({
      role: msg.role === ChatMessageRole.USER ? 'user' : 'model',
      parts: [{ text: msg.content }],
    }));

    // Gemini requires the history to start with a 'user' message
    while (formatted.length > 0 && formatted[0].role !== 'user') {
      formatted.shift();
    }

    // Remove trailing user turns. The current user message is saved to DB
    // BEFORE processMessage is called, so it already appears at the end of this
    // list. Sending it both in the history AND via sendMessage() would present it
    // to Gemini twice — causing confusing/repeated responses.
    // This also auto-discards orphaned user messages (those where a previous
    // AI call failed with no response saved), preventing context pollution.
    while (
      formatted.length > 0 &&
      formatted[formatted.length - 1].role === 'user'
    ) {
      formatted.pop();
    }

    return formatted;
  }
}
