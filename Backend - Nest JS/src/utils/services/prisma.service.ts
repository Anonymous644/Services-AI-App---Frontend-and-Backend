import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

export const TransactionTimout = {
  T1: 7000, // ? For Relatively Simple Transactions
  T2: 10000, // ? For Complex Transactions
  T3: 20000, // ? For Transactions Including Stripe
};

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit() {
    await this.$connect;
  }
}
