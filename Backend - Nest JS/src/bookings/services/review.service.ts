import {
  BadRequestException,
  ConflictException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../utils/services/prisma.service';

@Injectable()
export class ReviewService {
  private readonly logger = new Logger(ReviewService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Submit a review for a booking.
   * Both customer and provider can review each other (one review per party per booking).
   */
  async submitReview(
    bookingId: string,
    reviewerId: string,
    revieweeId: string,
    rating: number,
    comment?: string,
  ) {
    // Check booking exists and is completed
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
    });

    if (!booking) throw new NotFoundException('Booking not found');
    if (booking.status !== 'COMPLETED') {
      throw new BadRequestException('Can only review completed bookings');
    }

    // Check reviewer is part of the booking
    if (booking.customerId !== reviewerId && booking.providerId !== reviewerId) {
      throw new BadRequestException('You are not part of this booking');
    }

    // Check if review already exists
    const existingReview = await this.prisma.review.findUnique({
      where: {
        bookingId_reviewerId: {
          bookingId,
          reviewerId,
        },
      },
    });

    if (existingReview) {
      throw new ConflictException('You have already reviewed this booking');
    }

    // Create review
    const review = await this.prisma.review.create({
      data: {
        bookingId,
        reviewerId,
        revieweeId,
        rating,
        comment,
      },
    });

    // Recalculate the reviewee's average rating
    await this.recalculateRating(revieweeId);

    this.logger.log(`Review submitted: ${review.id} (${rating}/5) for user ${revieweeId}`);
    return review;
  }

  /**
   * Recalculate a user's average rating from all their received reviews.
   */
  private async recalculateRating(userId: string) {
    const result = await this.prisma.review.aggregate({
      where: { revieweeId: userId },
      _avg: { rating: true },
      _count: { rating: true },
    });

    await this.prisma.user.update({
      where: { id: userId },
      data: {
        rating: result._avg.rating || 0,
        totalJobs: result._count.rating || 0,
      },
    });
  }
}
