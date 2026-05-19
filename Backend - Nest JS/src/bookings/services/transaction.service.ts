import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../utils/services/prisma.service';
import { TransactionType, TransactionStatus } from '@prisma/client';

@Injectable()
export class TransactionService {
  private readonly logger = new Logger(TransactionService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Create a mock payment transaction.
   * If useCredits is true, deduct from customer's credit balance.
   */
  async createPaymentTransaction(
    bookingId: string,
    customerId: string,
    amount: number,
    useCredits: boolean,
  ) {
    if (useCredits) {
      // Deduct credits
      await this.prisma.user.update({
        where: { id: customerId },
        data: { creditBalance: { decrement: amount } },
      });
    }

    const transaction = await this.prisma.transaction.create({
      data: {
        bookingId,
        fromUserId: customerId,
        toUserId: null, // Platform
        amount,
        type: TransactionType.PAYMENT,
        status: TransactionStatus.SUCCESS,
      },
    });

    this.logger.log(`Payment transaction created: ${transaction.id} (credits: ${useCredits})`);
    return transaction;
  }

  /**
   * Create refund transaction and add to customer's credits.
   */
  async createRefundTransaction(
    bookingId: string,
    customerId: string,
    amount: number,
  ) {
    // Add credits back
    await this.prisma.user.update({
      where: { id: customerId },
      data: { creditBalance: { increment: amount } },
    });

    const transaction = await this.prisma.transaction.create({
      data: {
        bookingId,
        fromUserId: null, // Platform
        toUserId: customerId,
        amount,
        type: TransactionType.REFUND,
        status: TransactionStatus.SUCCESS,
      },
    });

    this.logger.log(`Refund transaction created: ${transaction.id}`);
    return transaction;
  }

  /**
   * Create payout transactions on booking completion.
   * - Provider payout (95%)
   * - Platform fee (5%)
   */
  async createPayoutTransactions(
    bookingId: string,
    providerId: string,
    providerAmount: number,
    platformFee: number,
  ) {
    // Add credits to provider
    await this.prisma.user.update({
      where: { id: providerId },
      data: { creditBalance: { increment: providerAmount } },
    });

    // Provider payout transaction
    const payout = await this.prisma.transaction.create({
      data: {
        bookingId,
        fromUserId: null, // Platform
        toUserId: providerId,
        amount: providerAmount,
        type: TransactionType.PROVIDER_PAYOUT,
        status: TransactionStatus.SUCCESS,
      },
    });

    // Platform fee transaction
    const fee = await this.prisma.transaction.create({
      data: {
        bookingId,
        fromUserId: null,
        toUserId: null,
        amount: platformFee,
        type: TransactionType.PLATFORM_FEE,
        status: TransactionStatus.SUCCESS,
      },
    });

    this.logger.log(`Payout: ${payout.id} (${providerAmount}), Fee: ${fee.id} (${platformFee})`);
    return { payout, fee };
  }

  /**
   * Freeze payment transaction (set to ON_HOLD for disputes).
   */
  async freezePayment(bookingId: string) {
    await this.prisma.transaction.updateMany({
      where: {
        bookingId,
        type: TransactionType.PAYMENT,
      },
      data: { status: TransactionStatus.ON_HOLD },
    });

    this.logger.log(`Payment frozen for booking ${bookingId}`);
  }
}
