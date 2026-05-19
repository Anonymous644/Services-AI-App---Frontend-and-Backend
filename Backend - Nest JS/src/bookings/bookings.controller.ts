import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiParam,
  ApiTags,
} from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { GetUser } from '../auth/decorators/get-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { BookingService } from './services/booking.service';
import { ReviewService } from './services/review.service';
import { NotificationService } from './services/notification.service';
import { AIService } from './services/ai.service';
import { ChatService } from './services/chat.service';
import { ChatGateway } from './gateway/chat.gateway';
import { UpdateStatusDto } from './dto/update-status.dto';
import { CreateReviewDto } from './dto/create-review.dto';
import { BookingQueryDto } from './dto/booking-query.dto';

@ApiTags('Bookings')
@ApiBearerAuth()
@Controller('bookings')
export class BookingsController {
  constructor(
    private readonly bookingService: BookingService,
    private readonly reviewService: ReviewService,
    private readonly notificationService: NotificationService,
    private readonly aiService: AIService,
    private readonly chatService: ChatService,
    private readonly chatGateway: ChatGateway,
  ) {}

  /**
   * List bookings for the authenticated user.
   * Customers see their bookings, providers see theirs.
   */
  @Get()
  @ApiOperation({ summary: 'List bookings (filtered by role)' })
  async getBookings(
    @GetUser() user: JwtPayload,
    @Query() query: BookingQueryDto,
  ) {
    return this.bookingService.getBookings(user.sub, user.role, query);
  }

  /**
   * Get a single booking by ID.
   */
  @Get(':id')
  @ApiOperation({ summary: 'Get booking details' })
  @ApiParam({ name: 'id', description: 'Booking ID' })
  async getBooking(
    @GetUser('sub') userId: string,
    @Param('id') bookingId: string,
  ) {
    return this.bookingService.getBookingById(bookingId, userId);
  }

  /**
   * Provider updates booking status.
   * Triggers AI response to customer via WebSocket.
   */
  @Patch(':id/status')
  @Roles(UserRole.PROVIDER)
  @ApiOperation({ summary: 'Update booking status (Provider only)' })
  @ApiParam({ name: 'id', description: 'Booking ID' })
  async updateStatus(
    @GetUser('sub') providerId: string,
    @Param('id') bookingId: string,
    @Body() dto: UpdateStatusDto,
  ) {
    const booking = await this.bookingService.updateStatus(
      bookingId,
      providerId,
      dto.status,
    );

    // Generate AI response for customer and push via WebSocket
    const aiResponse = await this.aiService.generateStatusResponse(
      booking.customerId,
      bookingId,
      dto.status,
      booking,
    );

    // Save as assistant message in customer's chat
    const message = await this.chatService.saveAssistantMessage(
      booking.customerId,
      aiResponse.content,
      aiResponse.actions,
    );

    // Push to customer's WebSocket if connected
    this.chatGateway.emitToUser(booking.customerId, 'message_complete', {
      id: message.id,
      role: 'ASSISTANT',
      content: aiResponse.content,
      actions: aiResponse.actions,
      createdAt: message.createdAt,
    });

    return booking;
  }

  /**
   * Process mock payment for a booking.
   */
  @Post(':id/pay')
  @Roles(UserRole.CUSTOMER)
  @ApiOperation({ summary: 'Process payment for a booking (Customer only)' })
  @ApiParam({ name: 'id', description: 'Booking ID' })
  async payBooking(
    @GetUser('sub') customerId: string,
    @Param('id') bookingId: string,
  ) {
    return this.bookingService.processPayment(bookingId, customerId);
  }

  /**
   * Submit a review for a booking.
   * Both customer and provider can review each other.
   */
  @Post(':id/review')
  @ApiOperation({ summary: 'Submit a review for a booking' })
  @ApiParam({ name: 'id', description: 'Booking ID' })
  async submitReview(
    @GetUser('sub') reviewerId: string,
    @Param('id') bookingId: string,
    @Body() dto: CreateReviewDto,
  ) {
    // Determine reviewee based on reviewer's role in the booking
    const booking = await this.bookingService.getBookingById(bookingId, reviewerId);
    const revieweeId = booking.customerId === reviewerId
      ? booking.providerId
      : booking.customerId;

    return this.reviewService.submitReview(
      bookingId,
      reviewerId,
      revieweeId,
      dto.rating,
      dto.comment,
    );
  }

  /**
   * Get notifications for the authenticated user.
   */
  @Get('notifications/list')
  @ApiOperation({ summary: 'Get user notifications' })
  async getNotifications(@GetUser('sub') userId: string) {
    return this.notificationService.getNotifications(userId);
  }
}
