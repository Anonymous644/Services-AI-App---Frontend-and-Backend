import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { BookingsController } from './bookings.controller';
import { ChatGateway } from './gateway/chat.gateway';
import { AIService } from './services/ai.service';
import { BookingService } from './services/booking.service';
import { ChatService } from './services/chat.service';
import { TransactionService } from './services/transaction.service';
import { ProviderSearchService } from './services/provider-search.service';
import { ReviewService } from './services/review.service';
import { NotificationService } from './services/notification.service';
import { DisputeService } from './services/dispute.service';
import { ToolExecutor } from './tools/tool-executor';
import { PrismaService } from '../utils/services/prisma.service';
import { AppConfigurations } from '../utils/GlobalConstants';

@Module({
  imports: [
    JwtModule.register({
      secret: AppConfigurations.jwtKey,
      signOptions: { expiresIn: '30d' },
    }),
  ],
  controllers: [BookingsController],
  providers: [
    PrismaService,
    ChatGateway,
    AIService,
    BookingService,
    ChatService,
    TransactionService,
    ProviderSearchService,
    ReviewService,
    NotificationService,
    DisputeService,
    ToolExecutor,
  ],
  exports: [ChatGateway, ProviderSearchService],
})
export class BookingsModule {}
