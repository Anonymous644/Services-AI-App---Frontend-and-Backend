import {
  Logger,
  MiddlewareConsumer,
  Module,
  NestModule,
  OnModuleInit,
} from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import 'dotenv/config';

import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaService } from './utils/services/prisma.service';
import { AuthModule } from './auth/auth.module';
import { BookingsModule } from './bookings/bookings.module';
import { SeedService } from './seed/seed.service';
import { ProviderSearchService } from './bookings/services/provider-search.service';
import { JwtAuthGuard } from './auth/guards/jwt-auth.guard';
import { RolesGuard } from './auth/guards/roles.guard';

@Module({
  imports: [AuthModule, BookingsModule],
  controllers: [AppController],
  providers: [
    AppService,
    PrismaService,
    SeedService,
    ProviderSearchService,
    // Register JWT auth guard globally — all routes require auth by default
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
    // Register roles guard globally — checks @Roles() decorator on routes
    {
      provide: APP_GUARD,
      useClass: RolesGuard,
    },
  ],
})
export class AppModule implements NestModule, OnModuleInit {
  configure(consumer: MiddlewareConsumer) {}
  constructor(private prisma: PrismaService) {}

  async onModuleInit() {}
}
