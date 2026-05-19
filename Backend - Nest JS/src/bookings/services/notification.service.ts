import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../utils/services/prisma.service';
import { NotificationType } from '@prisma/client';

@Injectable()
export class NotificationService {
  private readonly logger = new Logger(NotificationService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Create an in-app notification for a user.
   */
  async create(
    userId: string,
    type: keyof typeof NotificationType,
    title: string,
    body: string,
    data?: string,
  ) {
    const notification = await this.prisma.notification.create({
      data: {
        userId,
        type: NotificationType[type],
        title,
        body,
        data,
      },
    });

    this.logger.log(`Notification created for user ${userId}: ${title}`);
    return notification;
  }

  /**
   * Get notifications for a user.
   */
  async getNotifications(userId: string, limit = 50) {
    return this.prisma.notification.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  }

  /**
   * Mark a notification as read.
   */
  async markAsRead(notificationId: string, userId: string) {
    return this.prisma.notification.updateMany({
      where: { id: notificationId, userId },
      data: { isRead: true },
    });
  }
}
