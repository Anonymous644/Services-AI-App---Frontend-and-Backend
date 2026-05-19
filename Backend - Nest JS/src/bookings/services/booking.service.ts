import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../utils/services/prisma.service';
import { BookingStatus, CancelledBy, UserRole } from '@prisma/client';
import { TransactionService } from './transaction.service';
import { NotificationService } from './notification.service';

@Injectable()
export class BookingService {
  private readonly logger = new Logger(BookingService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly transactionService: TransactionService,
    private readonly notificationService: NotificationService,
  ) {}

  /**
   * Create a new booking (called by AI tool).
   */
  async createBooking(data: {
    customerId: string;
    providerId: string;
    categoryId: string;
    subCategoryName?: string;
    serviceDetails: string;
    customerNotes?: string;
    scheduledAt: Date;
    estimatedDuration?: number;
    location: {
      address: string;
      city: string;
      state?: string;
      country?: string;
      geo: { type: string; coordinates: number[] };
    };
    totalAmount: number;
    matchReasoning?: string;
  }) {
    const booking = await this.prisma.booking.create({
      data: {
        customerId: data.customerId,
        providerId: data.providerId,
        categoryId: data.categoryId,
        subCategoryName: data.subCategoryName,
        serviceDetails: data.serviceDetails,
        customerNotes: data.customerNotes,
        scheduledAt: data.scheduledAt,
        estimatedDuration: data.estimatedDuration,
        location: data.location,
        totalAmount: data.totalAmount,
        matchReasoning: data.matchReasoning,
        status: BookingStatus.UNPAID,
      },
      include: {
        customer: {
          select: { id: true, firstName: true, lastName: true, email: true },
        },
        provider: {
          select: { id: true, firstName: true, lastName: true, email: true },
        },
        category: { select: { id: true, name: true } },
      },
    });

    this.logger.log(
      `Booking created: ${booking.id} for customer ${data.customerId}`,
    );
    return booking;
  }

  /**
   * Process mock payment for a booking.
   */
  async processPayment(bookingId: string, customerId: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      include: {
        provider: { select: { id: true, firstName: true, lastName: true } },
      },
    });

    if (!booking) throw new NotFoundException('Booking not found');
    if (booking.customerId !== customerId)
      throw new ForbiddenException('Not your booking');
    if (booking.status !== BookingStatus.UNPAID) {
      throw new BadRequestException('Booking is not in UNPAID status');
    }

    // Check if customer has enough credits
    const customer = await this.prisma.user.findUnique({
      where: { id: customerId },
      select: { creditBalance: true },
    });

    const useCredits = customer.creditBalance >= booking.totalAmount;

    // Create mock transaction
    await this.transactionService.createPaymentTransaction(
      bookingId,
      customerId,
      booking.totalAmount,
      useCredits,
    );

    // Update booking status
    const updatedBooking = await this.prisma.booking.update({
      where: { id: bookingId },
      data: {
        status: BookingStatus.PENDING,
        paidAt: new Date(),
      },
      include: {
        customer: { select: { id: true, firstName: true, lastName: true } },
        provider: { select: { id: true, firstName: true, lastName: true } },
        category: { select: { id: true, name: true } },
      },
    });

    // Notify provider
    await this.notificationService.create(
      booking.providerId,
      'NEW_BOOKING',
      'New Booking Request',
      `You have a new booking for ${updatedBooking.category.name} from ${updatedBooking.customer.firstName} ${updatedBooking.customer.lastName}`,
      JSON.stringify({ bookingId }),
    );

    this.logger.log(`Payment processed for booking ${bookingId}`);
    return updatedBooking;
  }

  /**
   * Update booking status (provider action).
   * Returns the updated booking.
   */
  async updateStatus(
    bookingId: string,
    providerId: string,
    newStatus: BookingStatus,
  ) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      include: {
        customer: { select: { id: true, firstName: true, lastName: true } },
        provider: { select: { id: true, firstName: true, lastName: true } },
        category: { select: { id: true, name: true } },
      },
    });

    if (!booking) throw new NotFoundException('Booking not found');
    if (booking.providerId !== providerId)
      throw new ForbiddenException('Not your booking');

    // Validate status transitions
    this.validateStatusTransition(booking.status, newStatus, 'PROVIDER');

    const updateData: any = { status: newStatus };

    if (newStatus === BookingStatus.INITIALIZED) {
      updateData.initializedAt = new Date();
    }

    if (newStatus === BookingStatus.CANCELLED) {
      updateData.cancelledAt = new Date();
      updateData.cancelledBy = CancelledBy.PROVIDER;

      // Refund customer
      await this.transactionService.createRefundTransaction(
        bookingId,
        booking.customerId,
        booking.totalAmount,
      );
    }

    const updatedBooking = await this.prisma.booking.update({
      where: { id: bookingId },
      data: updateData,
      include: {
        customer: { select: { id: true, firstName: true, lastName: true } },
        provider: { select: { id: true, firstName: true, lastName: true } },
        category: { select: { id: true, name: true } },
      },
    });

    return updatedBooking;
  }

  /**
   * Confirm booking completion (called by AI after customer confirms).
   */
  async confirmCompletion(bookingId: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      include: {
        provider: { select: { id: true, firstName: true, lastName: true } },
      },
    });

    if (!booking) throw new NotFoundException('Booking not found');
    if (booking.status !== BookingStatus.PROVIDER_COMPLETED) {
      throw new BadRequestException(
        'Booking is not in PROVIDER_COMPLETED status',
      );
    }

    const platformFee = Math.round(booking.totalAmount * 0.05 * 100) / 100;
    const providerPayout = booking.totalAmount - platformFee;

    // Create payout transactions
    await this.transactionService.createPayoutTransactions(
      bookingId,
      booking.providerId,
      providerPayout,
      platformFee,
    );

    // Update booking
    const updatedBooking = await this.prisma.booking.update({
      where: { id: bookingId },
      data: {
        status: BookingStatus.COMPLETED,
        completedAt: new Date(),
        platformFee,
        providerPayout,
      },
      include: {
        customer: { select: { id: true, firstName: true, lastName: true } },
        provider: { select: { id: true, firstName: true, lastName: true } },
        category: { select: { id: true, name: true } },
      },
    });

    // Notify provider
    await this.notificationService.create(
      booking.providerId,
      'BOOKING_COMPLETED',
      'Booking Completed',
      `Your booking has been completed. PKR ${providerPayout} has been added to your credits.`,
      JSON.stringify({ bookingId }),
    );

    this.logger.log(
      `Booking ${bookingId} completed. Payout: ${providerPayout}, Fee: ${platformFee}`,
    );
    return updatedBooking;
  }

  /**
   * Get bookings for a user (customer or provider).
   */
  async getBookings(
    userId: string,
    role: UserRole,
    filters: { status?: BookingStatus; page?: number; limit?: number },
  ) {
    const page = filters.page || 1;
    const limit = filters.limit || 20;
    const skip = (page - 1) * limit;

    const where: any =
      role === UserRole.CUSTOMER
        ? { customerId: userId }
        : { providerId: userId };

    if (filters.status) {
      where.status = filters.status;
    }

    const [bookings, total] = await Promise.all([
      this.prisma.booking.findMany({
        where,
        include: {
          customer: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              avatarUrl: true,
            },
          },
          provider: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              avatarUrl: true,
              rating: true,
            },
          },
          category: { select: { id: true, name: true } },
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.booking.count({ where }),
    ]);

    return { bookings, total, page, limit };
  }

  /**
   * Get a single booking by ID.
   */
  async getBookingById(bookingId: string, userId: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      include: {
        customer: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
            phone: true,
            avatarUrl: true,
            location: true,
          },
        },
        provider: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
            phone: true,
            avatarUrl: true,
            rating: true,
            totalJobs: true,
            bio: true,
          },
        },
        category: { select: { id: true, name: true } },
        transactions: true,
        reviews: true,
        dispute: true,
      },
    });

    if (!booking) throw new NotFoundException('Booking not found');
    if (booking.customerId !== userId && booking.providerId !== userId) {
      throw new ForbiddenException('You do not have access to this booking');
    }

    return booking;
  }

  /**
   * Find bookings for the AI tool (search by various criteria).
   */
  async findBookings(
    customerId: string,
    filters: { bookingId?: string; status?: BookingStatus; search?: string },
  ) {
    if (filters.bookingId) {
      const booking = await this.prisma.booking.findUnique({
        where: { id: filters.bookingId },
        include: {
          provider: {
            select: { id: true, firstName: true, lastName: true, rating: true },
          },
          category: { select: { id: true, name: true } },
        },
      });
      if (booking && booking.customerId === customerId) {
        return [booking];
      }
      return [];
    }

    const where: any = { customerId };
    if (filters.status) where.status = filters.status;

    return this.prisma.booking.findMany({
      where,
      include: {
        provider: {
          select: { id: true, firstName: true, lastName: true, rating: true },
        },
        category: { select: { id: true, name: true } },
      },
      orderBy: { createdAt: 'desc' },
      take: 10,
    });
  }

  /**
   * Validate that a status transition is allowed.
   */
  private validateStatusTransition(
    currentStatus: BookingStatus,
    newStatus: BookingStatus,
    actor: 'PROVIDER' | 'CUSTOMER',
  ) {
    const validTransitions: Record<string, BookingStatus[]> = {
      // Provider transitions
      [`PROVIDER:${BookingStatus.PENDING}`]: [
        BookingStatus.INITIALIZED,
        BookingStatus.CANCELLED,
      ],
      [`PROVIDER:${BookingStatus.INITIALIZED}`]: [
        BookingStatus.PROVIDER_COMPLETED,
        BookingStatus.CANCELLED,
      ],
    };

    const key = `${actor}:${currentStatus}`;
    const allowed = validTransitions[key] || [];

    if (!allowed.includes(newStatus)) {
      throw new BadRequestException(
        `Cannot transition from ${currentStatus} to ${newStatus} as ${actor}`,
      );
    }
  }
}
