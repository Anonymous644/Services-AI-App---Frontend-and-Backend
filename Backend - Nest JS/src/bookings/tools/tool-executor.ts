import { Injectable, Logger } from '@nestjs/common';
import { BookingService } from '../services/booking.service';
import { ProviderSearchService } from '../services/provider-search.service';
import { ReviewService } from '../services/review.service';
import { DisputeService } from '../services/dispute.service';
import { PrismaService } from '../../utils/services/prisma.service';
import { AIMemoryStep } from '@prisma/client';

/**
 * Routes AI tool calls to the appropriate service methods.
 * Manages AIMemory state transitions throughout the booking flow.
 */
@Injectable()
export class ToolExecutor {
  private readonly logger = new Logger(ToolExecutor.name);

  constructor(
    private readonly bookingService: BookingService,
    private readonly providerSearchService: ProviderSearchService,
    private readonly reviewService: ReviewService,
    private readonly disputeService: DisputeService,
    private readonly prisma: PrismaService,
  ) {}

  /**
   * Execute a tool call and return the result.
   */
  async execute(
    toolName: string,
    args: any,
    userId: string,
    emitThinking: (message: string) => void,
  ): Promise<any> {
    this.logger.log(`Executing tool: ${toolName} for user ${userId}`);

    switch (toolName) {
      case 'search_services':
        return this.handleSearchServices(args, userId, emitThinking);

      case 'request_location':
        return this.handleRequestLocation(args, userId, emitThinking);

      case 'search_providers':
        return this.handleSearchProviders(args, userId, emitThinking);

      case 'rank_providers':
        return this.handleRankProviders(args, userId, emitThinking);

      case 'create_booking':
        return this.handleCreateBooking(args, userId, emitThinking);

      case 'process_payment':
        return this.handleProcessPayment(args, userId, emitThinking);

      case 'confirm_completion':
        return this.handleConfirmCompletion(args, userId, emitThinking);

      case 'create_dispute':
        return this.handleCreateDispute(args, userId, emitThinking);

      case 'find_booking':
        return this.handleFindBooking(args, userId, emitThinking);

      case 'submit_review':
        return this.handleSubmitReview(args, userId, emitThinking);

      default:
        throw new Error(`Unknown tool: ${toolName}`);
    }
  }

  private async handleRequestLocation(
    args: any,
    userId: string,
    emitThinking: (msg: string) => void,
  ) {
    emitThinking('Requesting location confirmation...');
    return {
      success: true,
      message:
        'Location request sent to user. Wait for them to confirm or update their location.',
    };
  }

  private async handleSearchServices(
    args: any,
    userId: string,
    emitThinking: (msg: string) => void,
  ) {
    emitThinking('Searching for matching services...');

    // If there's a post-payment memory active, deactivate it so the new booking starts fresh.
    // The old booking's completion/review flow is driven by provider REST events, not memory.
    const postPaymentSteps: string[] = [
      AIMemoryStep.BOOKING_CREATED,
      AIMemoryStep.AWAITING_COMPLETION,
      AIMemoryStep.AWAITING_REVIEW,
      AIMemoryStep.COMPLETED,
    ];
    const existingMemory = await this.prisma.aIMemory.findFirst({
      where: { userId, isActive: true },
    });
    if (
      existingMemory &&
      postPaymentSteps.includes(existingMemory.currentStep)
    ) {
      this.logger.log(
        `🔄 New booking detected during post-payment step (${existingMemory.currentStep}). Clearing old memory.`,
      );
      await this.deactivateMemory(userId);
    }

    const results = await this.providerSearchService.searchServices(args.query);

    return {
      services: results,
      message:
        results.length > 0
          ? `Found ${results.length} matching services. Top match: ${results[0].name} (${(results[0].score * 100).toFixed(0)}% match)`
          : 'No matching services found.',
    };
  }

  private async handleSearchProviders(
    args: any,
    userId: string,
    emitThinking: (msg: string) => void,
  ) {
    emitThinking('Finding providers within 30km of your location...');

    const providers = await this.providerSearchService.searchProviders(
      args.categoryId,
      args.longitude,
      args.latitude,
    );

    // Check if the current memory belongs to a previous booking flow
    const currentMemory = await this.prisma.aIMemory.findFirst({
      where: { userId, isActive: true },
    });

    const postSearchSteps: string[] = [
      AIMemoryStep.AWAITING_SELECTION,
      AIMemoryStep.AWAITING_PAYMENT,
      AIMemoryStep.BOOKING_CREATED,
      AIMemoryStep.AWAITING_COMPLETION,
      AIMemoryStep.AWAITING_REVIEW,
      AIMemoryStep.COMPLETED,
    ];

    if (currentMemory && postSearchSteps.includes(currentMemory.currentStep)) {
      // Deactivate old memory — this is a new booking request
      this.logger.log(
        `🔄 New booking flow detected. Deactivating old memory (step=${currentMemory.currentStep}, bookingId=${currentMemory.bookingId})`,
      );
      await this.deactivateMemory(userId);

      // Create new memory for the new booking
      const chat = await this.prisma.chat.findFirst({ where: { userId } });
      await this.prisma.aIMemory.create({
        data: {
          userId,
          chatId: chat?.id || currentMemory.chatId,
          currentStep: AIMemoryStep.SEARCHING_PROVIDERS,
          categoryId: args.categoryId,
          providerOptions: JSON.stringify(providers),
          isActive: true,
        },
      });
    } else {
      // Update existing memory
      await this.updateMemory(userId, {
        currentStep: AIMemoryStep.SEARCHING_PROVIDERS,
        categoryId: args.categoryId,
        providerOptions: JSON.stringify(providers),
      });
    }

    return {
      providers,
      count: providers.length,
      message: `Found ${providers.length} providers within 30km. Providers are sorted by rating. Now call rank_providers to select and rank your top 3 picks with reasoning and pricing.`,
    };
  }

  private async handleRankProviders(
    args: any,
    userId: string,
    emitThinking: (msg: string) => void,
  ) {
    emitThinking('Analyzing and ranking providers for you...');

    // Collect only the picks the AI actually provided (secondPick and thirdPick are optional)
    const rawPicks = [args.topPick, args.secondPick, args.thirdPick].filter(
      Boolean,
    );

    // Filter out any picks with placeholder/invalid MongoDB ObjectIDs (must be 24-char hex)
    const OBJECT_ID_RE = /^[0-9a-fA-F]{24}$/;
    const picks = rawPicks.filter((p) => OBJECT_ID_RE.test(p.providerId ?? ''));

    if (picks.length === 0) {
      throw new Error(
        'rank_providers received no valid provider IDs. Ensure providerId values come from search_providers results.',
      );
    }

    const providerIds = picks.map((p) => p.providerId);

    // Fetch full provider data for enrichment
    const providers = await this.prisma.user.findMany({
      where: { id: { in: providerIds } },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        bio: true,
        experience: true,
        rating: true,
        totalJobs: true,
        serviceRadius: true,
        availability: true,
        location: true,
      },
    });

    const providerMap = new Map(providers.map((p) => [p.id, p]));

    // Fetch memory outside to parse cached distance from providerOptions
    let cachedProviders: any[] = [];
    try {
      const memory = await this.prisma.aIMemory.findFirst({
        where: { userId, isActive: true },
      });
      if (memory && memory.providerOptions) {
        cachedProviders = JSON.parse(memory.providerOptions);
      }
    } catch (e) {}

    // Build enriched ranked provider cards
    const rankedProviders = picks.map((pick, index) => {
      const provider = providerMap.get(pick.providerId);

      let distance = 0;
      const cachedProvider = cachedProviders.find(
        (p: any) => p.id === pick.providerId,
      );
      if (cachedProvider) {
        distance = cachedProvider.distance || 0;
      }

      return {
        rank: index + 1,
        providerId: pick.providerId,
        name: provider
          ? `${provider.firstName} ${provider.lastName}`
          : 'Unknown',
        rating: provider?.rating || 0,
        totalJobs: provider?.totalJobs || 0,
        experience: provider?.experience || 0,
        bio: provider?.bio || '',
        distance,
        availability: provider?.availability || [],
        location: provider?.location || null,
        reasoning: pick.reasoning,
        estimatedPrice: pick.estimatedPrice,
        isTopPick: index === 0,
      };
    });

    // Update AIMemory
    await this.updateMemory(userId, {
      currentStep: AIMemoryStep.AWAITING_SELECTION,
      providerOptions: JSON.stringify(rankedProviders),
    });

    return {
      categoryName: args.categoryName,
      overallReasoning: args.overallReasoning,
      rankedProviders,
      message:
        'Provider ranking complete. Present these options to the customer.',
    };
  }

  private async handleCreateBooking(
    args: any,
    userId: string,
    emitThinking: (msg: string) => void,
  ) {
    emitThinking('Creating your booking...');

    const scheduledAt = new Date(
      `${args.scheduledDate}T${args.scheduledTime}:00`,
    );

    const booking = await this.bookingService.createBooking({
      customerId: userId,
      providerId: args.providerId,
      categoryId: args.categoryId,
      subCategoryName: args.subCategoryName,
      serviceDetails: args.serviceDetails,
      scheduledAt,
      estimatedDuration: args.estimatedDuration,
      totalAmount: args.totalAmount,
      matchReasoning: args.matchReasoning,
      location: {
        address: args.locationAddress,
        city: args.locationCity,
        geo: {
          type: 'Point',
          coordinates: [args.locationLongitude, args.locationLatitude],
        },
      },
    });

    // Update AIMemory
    await this.updateMemory(userId, {
      currentStep: AIMemoryStep.AWAITING_PAYMENT,
      bookingId: booking.id,
      selectedProviderId: args.providerId,
      estimatedPrice: args.totalAmount,
      scheduledDate: args.scheduledDate,
      scheduledTime: args.scheduledTime,
    });

    return {
      bookingId: booking.id,
      status: booking.status,
      totalAmount: booking.totalAmount,
      providerName: `${booking.provider.firstName} ${booking.provider.lastName}`,
      scheduledAt: booking.scheduledAt,
      message: `Booking created successfully. Total amount: PKR ${booking.totalAmount}. Payment is pending.`,
    };
  }

  private async handleProcessPayment(
    args: any,
    userId: string,
    emitThinking: (msg: string) => void,
  ) {
    emitThinking('Processing your payment...');

    const booking = await this.bookingService.processPayment(
      args.bookingId,
      userId,
    );

    // Update AIMemory
    await this.updateMemory(userId, {
      currentStep: AIMemoryStep.BOOKING_CREATED,
    });

    // Fetch full booking details for the rich card
    const fullBooking = await this.prisma.booking.findUnique({
      where: { id: booking.id },
      include: { provider: true, category: true },
    });

    return {
      bookingId: booking.id,
      status: booking.status,
      paidAt: booking.paidAt,
      providerName: fullBooking?.provider
        ? `${fullBooking.provider.firstName} ${fullBooking.provider.lastName}`
        : 'Provider',
      categoryName: fullBooking?.category?.name,
      subCategoryName: fullBooking?.subCategoryName,
      scheduledAt: fullBooking?.scheduledAt,
      totalAmount: fullBooking?.totalAmount,
      location: fullBooking?.location,
      message: 'Payment processed successfully. Your booking is confirmed!',
    };
  }

  private async handleConfirmCompletion(
    args: any,
    userId: string,
    emitThinking: (msg: string) => void,
  ) {
    emitThinking('Confirming booking completion...');

    const booking = await this.bookingService.confirmCompletion(args.bookingId);

    // Update AIMemory
    await this.updateMemory(userId, {
      currentStep: AIMemoryStep.AWAITING_REVIEW,
    });

    return {
      bookingId: booking.id,
      status: booking.status,
      providerName: booking.provider
        ? `${booking.provider.firstName} ${booking.provider.lastName}`
        : undefined,
      providerPayout: booking.providerPayout,
      platformFee: booking.platformFee,
      message:
        'Booking marked as completed. Provider payment has been released.',
    };
  }

  private async handleCreateDispute(
    args: any,
    userId: string,
    emitThinking: (msg: string) => void,
  ) {
    emitThinking('Creating dispute record...');

    const dispute = await this.disputeService.createDispute(
      args.bookingId,
      args.reason,
    );

    // Deactivate memory
    await this.deactivateMemory(userId);

    return {
      disputeId: dispute.id,
      bookingId: args.bookingId,
      status: 'DISPUTED',
      message:
        'Dispute created. Provider payment has been frozen. Our support team will contact you.',
    };
  }

  private async handleFindBooking(
    args: any,
    userId: string,
    emitThinking: (msg: string) => void,
  ) {
    emitThinking('Looking up your bookings...');

    const bookings = await this.bookingService.findBookings(userId, {
      bookingId: args.bookingId,
      status: args.status,
    });

    return {
      bookings: bookings.map((b: any) => ({
        id: b.id,
        status: b.status,
        categoryName: b.category?.name,
        subCategoryName: b.subCategoryName,
        providerName: b.provider
          ? `${b.provider.firstName} ${b.provider.lastName}`
          : null,
        totalAmount: b.totalAmount,
        scheduledAt: b.scheduledAt,
        location: b.location,
        createdAt: b.createdAt,
      })),
      count: bookings.length,
      message:
        bookings.length > 0
          ? `Found ${bookings.length} booking(s).`
          : 'No bookings found matching your criteria.',
    };
  }

  private async handleSubmitReview(
    args: any,
    userId: string,
    emitThinking: (msg: string) => void,
  ) {
    emitThinking('Submitting your review...');

    const booking = await this.prisma.booking.findUnique({
      where: { id: args.bookingId },
      select: { providerId: true },
    });

    if (!booking) throw new Error('Booking not found');

    const review = await this.reviewService.submitReview(
      args.bookingId,
      userId,
      booking.providerId,
      args.rating,
      args.comment,
    );

    // Complete the memory
    await this.deactivateMemory(userId);

    return {
      reviewId: review.id,
      rating: review.rating,
      message: `Thank you for your ${args.rating}-star review!`,
    };
  }

  /**
   * Update the active AIMemory for a user.
   */
  private async updateMemory(userId: string, data: any) {
    const memory = await this.prisma.aIMemory.findFirst({
      where: { userId, isActive: true },
    });

    if (memory) {
      await this.prisma.aIMemory.update({
        where: { id: memory.id },
        data,
      });
    }
  }

  /**
   * Deactivate the user's current AIMemory.
   */
  private async deactivateMemory(userId: string) {
    await this.prisma.aIMemory.updateMany({
      where: { userId, isActive: true },
      data: {
        isActive: false,
        currentStep: AIMemoryStep.COMPLETED,
      },
    });
  }
}
