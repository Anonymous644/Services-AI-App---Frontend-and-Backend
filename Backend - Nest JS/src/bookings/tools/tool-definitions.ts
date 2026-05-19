/**
 * Gemini function declarations for the AI agent's tools.
 * These define the tools the AI can call during conversation.
 */
import { FunctionDeclaration, Type } from '@google/genai';

export const toolDefinitions: FunctionDeclaration[] = [
  {
    name: 'request_location',
    description: 'Call this tool when you need the customer to confirm or update their booking location. It displays a map UI for them to confirm or pin a new location. DO NOT ask for location details in text if you call this tool.',
    parameters: { type: Type.OBJECT, properties: {} }
  },
  {
    name: 'search_services',
    description:
      'Search for service categories using semantic/vector search. Call this when the user describes a service they need. Returns the top matching service categories with relevance scores.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        query: {
          type: Type.STRING,
          description:
            'The user\'s service description, e.g. "AC repair", "plumbing leak fix", "house cleaning"',
        },
      },
      required: ['query'],
    },
  },
  {
    name: 'search_providers',
    description:
      'Search for service providers within 30km of a location that offer a specific service category. Returns up to 10 providers sorted by rating. Call this after identifying the service category and booking location.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        categoryId: {
          type: Type.STRING,
          description: 'The service category ID from search_services result',
        },
        longitude: {
          type: Type.NUMBER,
          description: 'Longitude of the booking location',
        },
        latitude: {
          type: Type.NUMBER,
          description: 'Latitude of the booking location',
        },
      },
      required: ['categoryId', 'longitude', 'latitude'],
    },
  },
  {
    name: 'rank_providers',
    description:
      'After receiving providers from search_providers, call this tool to submit your top picks. Include only real provider IDs from the search result — if fewer than 3 providers exist, omit secondPick and/or thirdPick entirely. Do NOT fabricate or use placeholder IDs. Analyze providers based on rating, experience, distance, availability, and pricing. This generates the structured provider cards shown to the customer.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        categoryName: {
          type: Type.STRING,
          description: 'Name of the service category, e.g. "AC Services"',
        },
        topPick: {
          type: Type.OBJECT,
          description: 'Your #1 recommended provider (required)',
          properties: {
            providerId: {
              type: Type.STRING,
              description: 'Provider ID from search_providers result',
            },
            reasoning: {
              type: Type.STRING,
              description:
                'Detailed explanation of why this provider is the best choice (rating, distance, experience, availability match, pricing)',
            },
            estimatedPrice: {
              type: Type.NUMBER,
              description:
                'AI-determined price in PKR based on service complexity and provider pricing range',
            },
          },
          required: ['providerId', 'reasoning', 'estimatedPrice'],
        },
        secondPick: {
          type: Type.OBJECT,
          description:
            'Your #2 recommended provider. Omit if fewer than 2 providers are available.',
          properties: {
            providerId: {
              type: Type.STRING,
              description: 'Provider ID from search_providers result',
            },
            reasoning: {
              type: Type.STRING,
              description: 'Why this provider is a strong alternative',
            },
            estimatedPrice: {
              type: Type.NUMBER,
              description: 'AI-determined price in PKR',
            },
          },
          required: ['providerId', 'reasoning', 'estimatedPrice'],
        },
        thirdPick: {
          type: Type.OBJECT,
          description:
            'Your #3 recommended provider. Omit if fewer than 3 providers are available.',
          properties: {
            providerId: {
              type: Type.STRING,
              description: 'Provider ID from search_providers result',
            },
            reasoning: {
              type: Type.STRING,
              description: 'Why this provider is included as an option',
            },
            estimatedPrice: {
              type: Type.NUMBER,
              description: 'AI-determined price in PKR',
            },
          },
          required: ['providerId', 'reasoning', 'estimatedPrice'],
        },
        overallReasoning: {
          type: Type.STRING,
          description:
            'Brief summary of the ranking methodology: what factors you prioritized and why the #1 pick stands out',
        },
      },
      required: ['categoryName', 'topPick', 'overallReasoning'],
    },
  },
  {
    name: 'create_booking',
    description:
      'Create a new booking after the customer has selected a provider. The booking is created with UNPAID status. Call this after the customer selects a provider from the ranked list.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        providerId: {
          type: Type.STRING,
          description: 'ID of the selected provider',
        },
        categoryId: {
          type: Type.STRING,
          description: 'Service category ID',
        },
        subCategoryName: {
          type: Type.STRING,
          description:
            'AI-inferred subcategory name, e.g. "AC Repair", "Leak Fix"',
        },
        serviceDetails: {
          type: Type.STRING,
          description:
            'Detailed description of the service needed, gathered from conversation',
        },
        scheduledDate: {
          type: Type.STRING,
          description: 'Booking date in ISO format (YYYY-MM-DD)',
        },
        scheduledTime: {
          type: Type.STRING,
          description: 'Booking time in HH:mm format',
        },
        estimatedDuration: {
          type: Type.NUMBER,
          description: 'Estimated duration in minutes',
        },
        totalAmount: {
          type: Type.NUMBER,
          description:
            'Total price determined by AI for this specific provider',
        },
        matchReasoning: {
          type: Type.STRING,
          description: 'AI reasoning for why this provider was selected',
        },
        locationAddress: {
          type: Type.STRING,
          description: 'Booking location address',
        },
        locationCity: {
          type: Type.STRING,
          description: 'Booking location city',
        },
        locationLongitude: {
          type: Type.NUMBER,
          description: 'Booking location longitude',
        },
        locationLatitude: {
          type: Type.NUMBER,
          description: 'Booking location latitude',
        },
      },
      required: [
        'providerId',
        'categoryId',
        'subCategoryName',
        'serviceDetails',
        'scheduledDate',
        'scheduledTime',
        'totalAmount',
        'locationAddress',
        'locationCity',
        'locationLongitude',
        'locationLatitude',
      ],
    },
  },
  {
    name: 'process_payment',
    description:
      'Process mock payment for a booking. Call this when the customer confirms they want to pay. The system will automatically use credits if the customer has enough, otherwise it creates a mock card payment.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        bookingId: {
          type: Type.STRING,
          description: 'The booking ID to process payment for',
        },
      },
      required: ['bookingId'],
    },
  },
  {
    name: 'confirm_completion',
    description:
      'Mark a booking as officially completed after the customer confirms the job is done. This triggers the provider payout (95%) and platform fee (5%). Only call this when the customer explicitly confirms the job is complete. IMPORTANT: Always use the bookingId from the recent system message that asked for confirmation, do NOT default to the Active Memory bookingId if it does not match.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        bookingId: {
          type: Type.STRING,
          description: 'The booking ID to mark as completed',
        },
      },
      required: ['bookingId'],
    },
  },
  {
    name: 'create_dispute',
    description:
      'Create a dispute for a booking when the customer reports that the job was not completed properly or there is fraudulent activity. This freezes the provider payment and creates a dispute record.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        bookingId: {
          type: Type.STRING,
          description: 'The booking ID to dispute',
        },
        reason: {
          type: Type.STRING,
          description:
            "The customer's reason for the dispute, summarized from the conversation",
        },
      },
      required: ['bookingId', 'reason'],
    },
  },
  {
    name: 'find_booking',
    description:
      'Search for bookings belonging to the current customer. Use this when the customer asks about their bookings. Can search by booking ID, status, or return recent bookings.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        bookingId: {
          type: Type.STRING,
          description: 'Specific booking ID to look up (optional)',
        },
        status: {
          type: Type.STRING,
          description:
            'Filter by booking status: UNPAID, PENDING, INITIALIZED, PROVIDER_COMPLETED, COMPLETED, CANCELLED, DISPUTED (optional)',
        },
      },
    },
  },
  {
    name: 'submit_review',
    description:
      'Submit a review from the customer for the provider after a completed booking. Call this after gathering the rating and optional comment from the customer.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        bookingId: {
          type: Type.STRING,
          description: 'The booking ID to review',
        },
        rating: {
          type: Type.NUMBER,
          description: 'Rating from 1 to 5',
        },
        comment: {
          type: Type.STRING,
          description: 'Optional review comment from the customer',
        },
      },
      required: ['bookingId', 'rating'],
    },
  },
];
