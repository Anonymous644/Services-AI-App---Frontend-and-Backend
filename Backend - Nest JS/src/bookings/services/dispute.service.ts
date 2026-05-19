import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../utils/services/prisma.service';
import { BookingStatus, DisputeStatus } from '@prisma/client';
import { TransactionService } from './transaction.service';
import { NotificationService } from './notification.service';

@Injectable()
export class DisputeService {
  private readonly logger = new Logger(DisputeService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly transactionService: TransactionService,
    private readonly notificationService: NotificationService,
  ) {}

  /**
   * Create a dispute for a booking (called by AI when customer reports an issue).
   */
  async createDispute(bookingId: string, reason: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      include: {
        provider: { select: { id: true, firstName: true, lastName: true } },
        customer: { select: { id: true, firstName: true, lastName: true } },
        category: { select: { id: true, name: true } },
      },
    });

    if (!booking) throw new Error('Booking not found');

    // Create dispute record
    const dispute = await this.prisma.dispute.create({
      data: {
        bookingId,
        reason,
        status: DisputeStatus.OPEN,
      },
    });

    // Update booking status
    await this.prisma.booking.update({
      where: { id: bookingId },
      data: {
        status: BookingStatus.DISPUTED,
        disputedAt: new Date(),
      },
    });

    // Freeze payment
    await this.transactionService.freezePayment(bookingId);

    // Notify provider
    await this.notificationService.create(
      booking.providerId,
      'BOOKING_DISPUTED',
      'Booking Disputed',
      `A dispute has been raised for your booking with ${booking.customer.firstName} ${booking.customer.lastName}. Reason: ${reason}`,
      JSON.stringify({ bookingId, disputeId: dispute.id }),
    );

    this.logger.log(`Dispute created for booking ${bookingId}: ${reason}`);
    return dispute;
  }
}
