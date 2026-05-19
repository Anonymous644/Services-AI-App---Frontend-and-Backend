import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Server, Socket } from 'socket.io';
import { AIService } from '../services/ai.service';
import { ChatService } from '../services/chat.service';
import { PrismaService } from '../../utils/services/prisma.service';
import {
  SendMessagePayload,
  ActionResponsePayload,
  MessageCompleteEvent,
} from '../types/actions.types';
import { AppConfigurations } from '../../utils/GlobalConstants';

/**
 * Socket.IO WebSocket gateway for real-time AI chat.
 * Handles customer connections, message processing, and streaming.
 */
@WebSocketGateway({
  cors: { origin: '*' },
  namespace: '/chat',
})
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(ChatGateway.name);
  // Map userId -> socketId for real-time push
  private readonly userSockets = new Map<string, string>();

  constructor(
    private readonly jwtService: JwtService,
    private readonly aiService: AIService,
    private readonly chatService: ChatService,
    private readonly prisma: PrismaService,
  ) {}

  /**
   * Authenticate the socket connection using JWT.
   * Accepts token from:
   *   1. Handshake auth: { token: "Bearer xxx" }
   *   2. Header: Authorization: Bearer xxx
   *   3. Query param: ?token=xxx
   */
  async handleConnection(client: Socket) {
    try {
      // Try multiple token sources for flexibility (Postman, mobile, web)
      const rawToken =
        client.handshake.auth?.token ||
        client.handshake.headers?.authorization ||
        (client.handshake.query?.token as string);

      const token = rawToken?.replace('Bearer ', '');

      if (!token) {
        this.logger.warn(`Connection rejected: no token provided`);
        client.emit('error', {
          message:
            'Authentication required. Pass token via auth object, Authorization header, or ?token= query param.',
        });
        client.disconnect();
        return;
      }

      const payload = this.jwtService.verify(token, {
        secret: AppConfigurations.jwtKey,
      });

      // Attach user info to socket
      (client as any).userId = payload.sub;
      (client as any).userEmail = payload.email;
      (client as any).userRole = payload.role;

      // Map user to socket
      this.userSockets.set(payload.sub, client.id);

      // Load chat history and send to client
      const history = await this.chatService.getChatHistory(payload.sub);
      client.emit('chat_history', history);

      this.logger.log(`Client connected: ${payload.email} (${payload.sub})`);
    } catch (error) {
      this.logger.warn(`Connection rejected: invalid token - ${error.message}`);
      client.emit('error', { message: 'Invalid authentication token' });
      client.disconnect();
    }
  }

  handleDisconnect(client: Socket) {
    const userId = (client as any).userId;
    if (userId) {
      this.userSockets.delete(userId);
      this.logger.log(`Client disconnected: ${userId}`);
    }
  }

  /**
   * Handle incoming chat messages from customers.
   * Processes through AI pipeline with streaming.
   */
  @SubscribeMessage('send_message')
  async handleSendMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: SendMessagePayload,
  ) {
    const userId = (client as any).userId;

    if (!userId) {
      client.emit('error', { message: 'Not authenticated' });
      return;
    }

    if (!payload?.content?.trim()) {
      client.emit('error', { message: 'Message content is required' });
      return;
    }

    try {
      // Save user message
      const userMessage = await this.chatService.saveUserMessage(
        userId,
        payload.content,
      );
      client.emit('message_complete', {
        id: userMessage.id,
        role: 'USER',
        content: payload.content,
        createdAt: userMessage.createdAt,
      });

      // Ensure AI memory exists
      await this.aiService.ensureMemory(userId);

      // Process through AI with streaming callbacks
      const result = await this.aiService.processMessage(
        userId,
        payload.content,
        (msg) => client.emit('thinking', { message: msg }),
        (content) => client.emit('ai_thinking', { content }),
        (content) => client.emit('stream', { content }),
      );

      // Save assistant message
      const assistantMessage = await this.chatService.saveAssistantMessage(
        userId,
        result.content,
        result.actions,
        result.toolCalls,
        result.toolResults,
      );

      // Emit final complete message
      const completeEvent: MessageCompleteEvent = {
        id: assistantMessage.id,
        role: 'ASSISTANT',
        content: result.content,
        actions: result.actions,
        createdAt: assistantMessage.createdAt.toISOString(),
      };

      client.emit('message_complete', completeEvent);
    } catch (error) {
      this.logger.error(
        `Error processing message for ${userId}: ${error.message}`,
      );
      client.emit('error', {
        message: 'Failed to process your message. Please try again.',
      });
    }
  }

  /**
   * Handle action responses from the client (select provider, pay, confirm, review).
   * Routes them as regular messages to the AI for processing.
   */
  @SubscribeMessage('action_response')
  async handleActionResponse(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: ActionResponsePayload,
  ) {
    const userId = (client as any).userId;

    if (!userId) {
      client.emit('error', { message: 'Not authenticated' });
      return;
    }

    // Convert action response to a natural language message for the AI
    let message = '';

    switch (payload.actionType) {
      case 'LOCATION_CONFIRMED':
        message = `I will use my registered location for this booking.`;
        break;
      case 'LOCATION_UPDATED':
        message = `I have updated my location to: ${payload.data.location.address}. Please proceed.`;
        await this.prisma.user.update({
          where: { id: userId },
          data: {
            location: {
              address: payload.data.location.address,
              city: payload.data.location.city,
              state: payload.data.location.state,
              country: payload.data.location.country || 'PK',
              geo: {
                type: 'Point',
                coordinates: payload.data.location.coordinates,
              },
            }
          }
        });
        break;
      case 'SELECT_PROVIDER':
        message = `I'd like to select the provider with ID: ${payload.data.providerId}`;
        break;
      case 'PAY':
        message = `I want to proceed with the payment for booking ${payload.data.bookingId}`;
        break;
      case 'CONFIRM_COMPLETION':
        message = payload.data.confirmed
          ? `Yes, the job has been completed successfully for booking ${payload.data.bookingId}`
          : `No, the job was not completed properly for booking ${payload.data.bookingId}. ${payload.data.reason || ''}`;
        break;
      case 'SUBMIT_REVIEW':
        message = `I'd like to give a ${payload.data.rating} star rating. ${payload.data.comment || ''}`;
        break;
      default:
        message = JSON.stringify(payload.data);
    }

    // Process as a regular message
    await this.handleSendMessage(client, { content: message });
  }

  /**
   * Emit a message to a specific user's socket (for provider-triggered events).
   * Used by BookingService when provider updates status.
   */
  emitToUser(userId: string, event: string, data: any) {
    const socketId = this.userSockets.get(userId);
    if (socketId) {
      this.server.to(socketId).emit(event, data);
      this.logger.log(`Emitted ${event} to user ${userId}`);
    } else {
      this.logger.log(`User ${userId} not connected, message saved to DB`);
    }
  }

  /**
   * Clear all chat messages and AI memory for the authenticated user.
   * Emits `chat_cleared` on success.
   */
  @SubscribeMessage('clear_chat')
  async handleClearChat(@ConnectedSocket() client: Socket) {
    const userId = (client as any).userId;

    if (!userId) {
      client.emit('error', { message: 'Not authenticated' });
      return;
    }

    try {
      await this.chatService.clearChatHistory(userId);
      client.emit('chat_cleared');
      this.logger.log(`Chat history cleared for user ${userId}`);
    } catch (error) {
      this.logger.error(
        `Error clearing chat for ${userId}: ${(error as Error).message}`,
      );
      client.emit('error', {
        message: 'Failed to clear chat history. Please try again.',
      });
    }
  }
}
