/**
 * Action types sent in ChatMessage.actions JSON field.
 * These define the UI elements the mobile app renders alongside the message text.
 */

export enum ActionType {
  PROVIDER_SELECTION = 'PROVIDER_SELECTION',
  PAYMENT_REQUEST = 'PAYMENT_REQUEST',
  BOOKING_CARD = 'BOOKING_CARD',
  LOCATION_REQUEST = 'LOCATION_REQUEST',
  CONFIRM_COMPLETION = 'CONFIRM_COMPLETION',
  REVIEW_REQUEST = 'REVIEW_REQUEST',
}

export interface ChatAction {
  type: ActionType;
  data: any;
}

export interface ProviderCard {
  providerId: string;
  name: string;
  rating: number;
  totalJobs: number;
  distance: number; // km from booking location
  price: number; // AI-inferred price for this provider
  minPrice: number;
  maxPrice: number;
  availability: { dayOfWeek: number; startTime: string; endTime: string }[];
  reasoning: string; // AI's reasoning for recommending this provider
}

export interface ProviderSelectionAction {
  type: ActionType.PROVIDER_SELECTION;
  data: {
    providers: ProviderCard[];
    categoryName: string;
    subCategoryName: string;
  };
}

export interface PaymentRequestAction {
  type: ActionType.PAYMENT_REQUEST;
  data: {
    bookingId: string;
    amount: number;
    customerCredits: number;
    canPayWithCredits: boolean;
  };
}

export interface BookingCardAction {
  type: ActionType.BOOKING_CARD;
  data: {
    bookingId: string;
    status: string;
    categoryName: string;
    subCategoryName: string;
    providerName: string;
    scheduledAt: string;
    totalAmount: number;
    location: { address: string; city: string };
  };
}

export interface ConfirmCompletionAction {
  type: ActionType.CONFIRM_COMPLETION;
  data: {
    bookingId: string;
    providerName: string;
    serviceDetails: string;
  };
}

export interface ReviewRequestAction {
  type: ActionType.REVIEW_REQUEST;
  data: {
    bookingId: string;
    providerName: string;
  };
}

// WebSocket event payloads
export interface SendMessagePayload {
  content: string;
}

export interface ActionResponsePayload {
  actionType: string;
  data: any;
}

export interface ThinkingEvent {
  message: string;
}

export interface AiThinkingEvent {
  content: string;
}

export interface StreamEvent {
  content: string;
}

export interface MessageCompleteEvent {
  id: string;
  role: string;
  content: string;
  actions?: ChatAction[];
  createdAt: string;
}
