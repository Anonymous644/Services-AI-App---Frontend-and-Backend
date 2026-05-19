import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { PrismaService } from '../utils/services/prisma.service';
import { ProviderSearchService } from '../bookings/services/provider-search.service';
import { UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const SERVICE_CATEGORIES = [
  {
    name: 'AC Services',
    description:
      'Air conditioning installation, repair, maintenance, gas refilling, and cleaning services for split and window AC units',
  },
  {
    name: 'Plumbing Services',
    description:
      'Pipe repair, leak fixing, drain cleaning, water heater installation, faucet replacement, and bathroom fixture services',
  },
  {
    name: 'Electrical Services',
    description:
      'Wiring, switch and socket installation, circuit breaker repair, fan installation, lighting setup, and electrical troubleshooting',
  },
  {
    name: 'Cleaning Services',
    description:
      'Deep home cleaning, kitchen cleaning, bathroom cleaning, sofa and carpet cleaning, move-in/move-out cleaning services',
  },
  {
    name: 'Painting Services',
    description:
      'Interior and exterior wall painting, texture painting, waterproofing, wood polishing, and color consultation',
  },
  {
    name: 'Carpentry Services',
    description:
      'Furniture repair, door and window fitting, cabinet installation, woodwork, and custom furniture making',
  },
  {
    name: 'Pest Control',
    description:
      'Termite treatment, cockroach control, mosquito fumigation, bed bug treatment, and rodent control services',
  },
  {
    name: 'Appliance Repair',
    description:
      'Washing machine, refrigerator, microwave, oven, dishwasher, and other home appliance repair and maintenance',
  },
  {
    name: 'Home Security',
    description:
      'CCTV camera installation, smart lock setup, alarm system installation, intercom setup, and security system maintenance',
  },
  {
    name: 'Landscaping Services',
    description:
      'Garden design, lawn mowing, tree trimming, irrigation system setup, and outdoor maintenance services',
  },
  {
    name: 'Moving Services',
    description:
      'Home and office relocation, packing, loading/unloading, furniture disassembly and reassembly, and storage services',
  },
  {
    name: 'Renovation Services',
    description:
      'Kitchen and bathroom renovation, floor tiling, false ceiling installation, wall demolition, and home remodeling',
  },
];

// Availability presets — varied schedules for realistic data
const AVAILABILITY_PRESETS = {
  // Full-time Mon-Sat
  fullTime: [
    { dayOfWeek: 1, startTime: '09:00', endTime: '18:00' },
    { dayOfWeek: 2, startTime: '09:00', endTime: '18:00' },
    { dayOfWeek: 3, startTime: '09:00', endTime: '18:00' },
    { dayOfWeek: 4, startTime: '09:00', endTime: '18:00' },
    { dayOfWeek: 5, startTime: '09:00', endTime: '18:00' },
    { dayOfWeek: 6, startTime: '10:00', endTime: '14:00' },
  ],
  // Early bird Mon-Fri
  earlyBird: [
    { dayOfWeek: 1, startTime: '07:00', endTime: '15:00' },
    { dayOfWeek: 2, startTime: '07:00', endTime: '15:00' },
    { dayOfWeek: 3, startTime: '07:00', endTime: '15:00' },
    { dayOfWeek: 4, startTime: '07:00', endTime: '15:00' },
    { dayOfWeek: 5, startTime: '07:00', endTime: '15:00' },
  ],
  // Late shift Mon-Sat
  lateShift: [
    { dayOfWeek: 1, startTime: '12:00', endTime: '21:00' },
    { dayOfWeek: 2, startTime: '12:00', endTime: '21:00' },
    { dayOfWeek: 3, startTime: '12:00', endTime: '21:00' },
    { dayOfWeek: 4, startTime: '12:00', endTime: '21:00' },
    { dayOfWeek: 5, startTime: '12:00', endTime: '21:00' },
    { dayOfWeek: 6, startTime: '12:00', endTime: '18:00' },
  ],
  // Weekdays only 10-6
  weekdaysOnly: [
    { dayOfWeek: 1, startTime: '10:00', endTime: '18:00' },
    { dayOfWeek: 2, startTime: '10:00', endTime: '18:00' },
    { dayOfWeek: 3, startTime: '10:00', endTime: '18:00' },
    { dayOfWeek: 4, startTime: '10:00', endTime: '18:00' },
    { dayOfWeek: 5, startTime: '10:00', endTime: '18:00' },
  ],
  // Full week including Sunday
  fullWeek: [
    { dayOfWeek: 0, startTime: '10:00', endTime: '16:00' },
    { dayOfWeek: 1, startTime: '08:00', endTime: '17:00' },
    { dayOfWeek: 2, startTime: '08:00', endTime: '17:00' },
    { dayOfWeek: 3, startTime: '08:00', endTime: '17:00' },
    { dayOfWeek: 4, startTime: '08:00', endTime: '17:00' },
    { dayOfWeek: 5, startTime: '08:00', endTime: '17:00' },
    { dayOfWeek: 6, startTime: '09:00', endTime: '15:00' },
  ],
  // Morning only Mon-Sat
  morningOnly: [
    { dayOfWeek: 1, startTime: '08:00', endTime: '13:00' },
    { dayOfWeek: 2, startTime: '08:00', endTime: '13:00' },
    { dayOfWeek: 3, startTime: '08:00', endTime: '13:00' },
    { dayOfWeek: 4, startTime: '08:00', endTime: '13:00' },
    { dayOfWeek: 5, startTime: '08:00', endTime: '13:00' },
    { dayOfWeek: 6, startTime: '08:00', endTime: '12:00' },
  ],
  // Extended hours Mon-Fri
  extendedHours: [
    { dayOfWeek: 1, startTime: '06:00', endTime: '22:00' },
    { dayOfWeek: 2, startTime: '06:00', endTime: '22:00' },
    { dayOfWeek: 3, startTime: '06:00', endTime: '22:00' },
    { dayOfWeek: 4, startTime: '06:00', endTime: '22:00' },
    { dayOfWeek: 5, startTime: '06:00', endTime: '22:00' },
  ],
  // Split shift (morning + evening)
  splitShift: [
    { dayOfWeek: 1, startTime: '08:00', endTime: '12:00' },
    { dayOfWeek: 1, startTime: '16:00', endTime: '20:00' },
    { dayOfWeek: 2, startTime: '08:00', endTime: '12:00' },
    { dayOfWeek: 2, startTime: '16:00', endTime: '20:00' },
    { dayOfWeek: 3, startTime: '08:00', endTime: '12:00' },
    { dayOfWeek: 3, startTime: '16:00', endTime: '20:00' },
    { dayOfWeek: 4, startTime: '08:00', endTime: '12:00' },
    { dayOfWeek: 4, startTime: '16:00', endTime: '20:00' },
    { dayOfWeek: 5, startTime: '08:00', endTime: '12:00' },
    { dayOfWeek: 5, startTime: '16:00', endTime: '20:00' },
  ],
};

type AvailabilityKey = keyof typeof AVAILABILITY_PRESETS;

// 30 providers — locations spread around Islamabad near 33.714178, 73.071544
const PROVIDER_SEEDS = [
  // --- AC Services specialists ---
  {
    firstName: 'Ahmed',
    lastName: 'Khan',
    email: 'ahmed.khan@provider.com',
    bio: 'Expert AC technician with 8 years of experience in split and window AC systems',
    experience: 8,
    rating: 4.8,
    totalJobs: 120,
    serviceRadius: 25,
    lat: 33.72,
    lng: 73.07,
    availability: 'fullTime' as AvailabilityKey,
    services: ['AC Services', 'Electrical Services'],
  },
  {
    firstName: 'Shahid',
    lastName: 'Iqbal',
    email: 'shahid.iqbal@provider.com',
    bio: 'Inverter AC specialist, Daikin & Gree certified',
    experience: 5,
    rating: 4.5,
    totalJobs: 67,
    serviceRadius: 20,
    lat: 33.73,
    lng: 73.08,
    availability: 'earlyBird' as AvailabilityKey,
    services: ['AC Services'],
  },
  {
    firstName: 'Kamran',
    lastName: 'Shah',
    email: 'kamran.shah@provider.com',
    bio: 'All-brand AC and appliance repair technician',
    experience: 9,
    rating: 4.6,
    totalJobs: 130,
    serviceRadius: 20,
    lat: 33.705,
    lng: 73.04,
    availability: 'lateShift' as AvailabilityKey,
    services: ['AC Services', 'Appliance Repair'],
  },
  // --- Plumbing specialists ---
  {
    firstName: 'Usman',
    lastName: 'Ali',
    email: 'usman.ali@provider.com',
    bio: 'Professional plumber, specialized in modern plumbing and bathroom fittings',
    experience: 6,
    rating: 4.5,
    totalJobs: 85,
    serviceRadius: 20,
    lat: 33.71,
    lng: 73.065,
    availability: 'fullTime' as AvailabilityKey,
    services: ['Plumbing Services'],
  },
  {
    firstName: 'Waqar',
    lastName: 'Zafar',
    email: 'waqar.zafar@provider.com',
    bio: 'Emergency plumber available for urgent leak repairs and water line fixes',
    experience: 10,
    rating: 4.9,
    totalJobs: 210,
    serviceRadius: 30,
    lat: 33.735,
    lng: 73.05,
    availability: 'extendedHours' as AvailabilityKey,
    services: ['Plumbing Services'],
  },
  {
    firstName: 'Naveed',
    lastName: 'Aslam',
    email: 'naveed.aslam@provider.com',
    bio: 'Plumbing and sanitary works contractor for residential projects',
    experience: 7,
    rating: 4.3,
    totalJobs: 75,
    serviceRadius: 15,
    lat: 33.695,
    lng: 73.06,
    availability: 'weekdaysOnly' as AvailabilityKey,
    services: ['Plumbing Services', 'Renovation Services'],
  },
  // --- Electrical specialists ---
  {
    firstName: 'Bilal',
    lastName: 'Hussain',
    email: 'bilal.hussain@provider.com',
    bio: 'Certified electrician with residential and commercial wiring experience',
    experience: 10,
    rating: 4.9,
    totalJobs: 200,
    serviceRadius: 30,
    lat: 33.725,
    lng: 73.09,
    availability: 'fullWeek' as AvailabilityKey,
    services: ['Electrical Services', 'Home Security'],
  },
  {
    firstName: 'Arslan',
    lastName: 'Mehmood',
    email: 'arslan.mehmood@provider.com',
    bio: 'Solar panel installation and electrical troubleshooting expert',
    experience: 4,
    rating: 4.2,
    totalJobs: 45,
    serviceRadius: 25,
    lat: 33.74,
    lng: 73.075,
    availability: 'earlyBird' as AvailabilityKey,
    services: ['Electrical Services'],
  },
  {
    firstName: 'Nadeem',
    lastName: 'Butt',
    email: 'nadeem.butt@provider.com',
    bio: 'UPS, generator, and home electrical systems specialist',
    experience: 11,
    rating: 4.7,
    totalJobs: 180,
    serviceRadius: 20,
    lat: 33.7,
    lng: 73.085,
    availability: 'splitShift' as AvailabilityKey,
    services: ['Electrical Services', 'Appliance Repair'],
  },
  // --- Cleaning specialists ---
  {
    firstName: 'Hassan',
    lastName: 'Raza',
    email: 'hassan.raza@provider.com',
    bio: 'Professional deep cleaning specialist for homes and offices',
    experience: 4,
    rating: 4.3,
    totalJobs: 60,
    serviceRadius: 15,
    lat: 33.715,
    lng: 73.055,
    availability: 'morningOnly' as AvailabilityKey,
    services: ['Cleaning Services'],
  },
  {
    firstName: 'Saad',
    lastName: 'Qureshi',
    email: 'saad.qureshi@provider.com',
    bio: 'Sofa, carpet, and upholstery cleaning with industrial equipment',
    experience: 3,
    rating: 4.4,
    totalJobs: 50,
    serviceRadius: 20,
    lat: 33.728,
    lng: 73.068,
    availability: 'fullTime' as AvailabilityKey,
    services: ['Cleaning Services'],
  },
  {
    firstName: 'Imran',
    lastName: 'Siddiqui',
    email: 'imran.siddiqui@provider.com',
    bio: 'Move-in/move-out cleaning and commercial facility maintenance',
    experience: 6,
    rating: 4.6,
    totalJobs: 90,
    serviceRadius: 25,
    lat: 33.705,
    lng: 73.095,
    availability: 'lateShift' as AvailabilityKey,
    services: ['Cleaning Services', 'Moving Services'],
  },
  // --- Painting specialists ---
  {
    firstName: 'Farhan',
    lastName: 'Malik',
    email: 'farhan.malik@provider.com',
    bio: 'Interior and exterior painting expert with color consultation',
    experience: 7,
    rating: 4.6,
    totalJobs: 95,
    serviceRadius: 25,
    lat: 33.718,
    lng: 73.042,
    availability: 'weekdaysOnly' as AvailabilityKey,
    services: ['Painting Services', 'Renovation Services'],
  },
  {
    firstName: 'Asif',
    lastName: 'Javed',
    email: 'asif.javed@provider.com',
    bio: 'Texture painting and waterproofing specialist',
    experience: 9,
    rating: 4.8,
    totalJobs: 140,
    serviceRadius: 20,
    lat: 33.732,
    lng: 73.058,
    availability: 'fullTime' as AvailabilityKey,
    services: ['Painting Services'],
  },
  // --- Carpentry specialists ---
  {
    firstName: 'Zain',
    lastName: 'Ul Abideen',
    email: 'zain.abideen@provider.com',
    bio: 'Master carpenter specializing in custom furniture and kitchen cabinets',
    experience: 12,
    rating: 4.7,
    totalJobs: 150,
    serviceRadius: 20,
    lat: 33.708,
    lng: 73.078,
    availability: 'fullTime' as AvailabilityKey,
    services: ['Carpentry Services', 'Renovation Services'],
  },
  {
    firstName: 'Faisal',
    lastName: 'Nawaz',
    email: 'faisal.nawaz@provider.com',
    bio: 'Door, window, and furniture fitting specialist',
    experience: 8,
    rating: 4.5,
    totalJobs: 100,
    serviceRadius: 15,
    lat: 33.722,
    lng: 73.035,
    availability: 'earlyBird' as AvailabilityKey,
    services: ['Carpentry Services'],
  },
  // --- Pest Control specialists ---
  {
    firstName: 'Tariq',
    lastName: 'Mehmood',
    email: 'tariq.mehmood@provider.com',
    bio: 'Licensed pest control specialist for termites and cockroaches',
    experience: 5,
    rating: 4.4,
    totalJobs: 70,
    serviceRadius: 35,
    lat: 33.738,
    lng: 73.062,
    availability: 'morningOnly' as AvailabilityKey,
    services: ['Pest Control'],
  },
  {
    firstName: 'Rizwan',
    lastName: 'Ahmed',
    email: 'rizwan.ahmed@provider.com',
    bio: 'Fumigation expert for residential and commercial properties',
    experience: 7,
    rating: 4.6,
    totalJobs: 110,
    serviceRadius: 30,
    lat: 33.698,
    lng: 73.05,
    availability: 'fullWeek' as AvailabilityKey,
    services: ['Pest Control', 'Cleaning Services'],
  },
  // --- Appliance Repair specialists ---
  {
    firstName: 'Waseem',
    lastName: 'Akram',
    email: 'waseem.akram@provider.com',
    bio: 'Washing machine and dryer repair expert for all major brands',
    experience: 6,
    rating: 4.5,
    totalJobs: 88,
    serviceRadius: 20,
    lat: 33.713,
    lng: 73.072,
    availability: 'lateShift' as AvailabilityKey,
    services: ['Appliance Repair'],
  },
  {
    firstName: 'Junaid',
    lastName: 'Akhtar',
    email: 'junaid.akhtar@provider.com',
    bio: 'Refrigerator and microwave repair technician',
    experience: 8,
    rating: 4.7,
    totalJobs: 115,
    serviceRadius: 25,
    lat: 33.726,
    lng: 73.048,
    availability: 'splitShift' as AvailabilityKey,
    services: ['Appliance Repair', 'AC Services'],
  },
  // --- Home Security specialists ---
  {
    firstName: 'Atif',
    lastName: 'Rauf',
    email: 'atif.rauf@provider.com',
    bio: 'CCTV and smart home security system installer',
    experience: 6,
    rating: 4.8,
    totalJobs: 95,
    serviceRadius: 25,
    lat: 33.735,
    lng: 73.085,
    availability: 'fullTime' as AvailabilityKey,
    services: ['Home Security', 'Electrical Services'],
  },
  {
    firstName: 'Sohail',
    lastName: 'Afridi',
    email: 'sohail.afridi@provider.com',
    bio: 'Alarm and intercom system specialist for homes and offices',
    experience: 4,
    rating: 4.3,
    totalJobs: 40,
    serviceRadius: 15,
    lat: 33.7,
    lng: 73.038,
    availability: 'weekdaysOnly' as AvailabilityKey,
    services: ['Home Security'],
  },
  // --- Landscaping specialists ---
  {
    firstName: 'Hamza',
    lastName: 'Tariq',
    email: 'hamza.tariq@provider.com',
    bio: 'Garden design and lawn maintenance professional',
    experience: 5,
    rating: 4.5,
    totalJobs: 65,
    serviceRadius: 20,
    lat: 33.72,
    lng: 73.1,
    availability: 'earlyBird' as AvailabilityKey,
    services: ['Landscaping Services'],
  },
  {
    firstName: 'Yasir',
    lastName: 'Hayat',
    email: 'yasir.hayat@provider.com',
    bio: 'Tree trimming, irrigation systems, and outdoor landscaping',
    experience: 8,
    rating: 4.6,
    totalJobs: 105,
    serviceRadius: 30,
    lat: 33.71,
    lng: 73.03,
    availability: 'morningOnly' as AvailabilityKey,
    services: ['Landscaping Services'],
  },
  // --- Moving specialists ---
  {
    firstName: 'Omer',
    lastName: 'Farooq',
    email: 'omer.farooq@provider.com',
    bio: 'Home and office relocation specialist with a professional moving crew',
    experience: 7,
    rating: 4.7,
    totalJobs: 135,
    serviceRadius: 40,
    lat: 33.73,
    lng: 73.045,
    availability: 'extendedHours' as AvailabilityKey,
    services: ['Moving Services'],
  },
  {
    firstName: 'Adeel',
    lastName: 'Abbasi',
    email: 'adeel.abbasi@provider.com',
    bio: 'Furniture packing and safe transport specialist',
    experience: 4,
    rating: 4.2,
    totalJobs: 55,
    serviceRadius: 25,
    lat: 33.705,
    lng: 73.075,
    availability: 'fullTime' as AvailabilityKey,
    services: ['Moving Services', 'Carpentry Services'],
  },
  // --- Renovation specialists ---
  {
    firstName: 'Kashif',
    lastName: 'Dar',
    email: 'kashif.dar@provider.com',
    bio: 'Kitchen and bathroom renovation contractor with modern design skills',
    experience: 10,
    rating: 4.8,
    totalJobs: 160,
    serviceRadius: 20,
    lat: 33.717,
    lng: 73.062,
    availability: 'fullWeek' as AvailabilityKey,
    services: ['Renovation Services', 'Painting Services'],
  },
  {
    firstName: 'Danish',
    lastName: 'Saleem',
    email: 'danish.saleem@provider.com',
    bio: 'Floor tiling and false ceiling installation expert',
    experience: 6,
    rating: 4.4,
    totalJobs: 80,
    serviceRadius: 15,
    lat: 33.728,
    lng: 73.09,
    availability: 'weekdaysOnly' as AvailabilityKey,
    services: ['Renovation Services', 'Carpentry Services'],
  },
  // --- Multi-service providers ---
  {
    firstName: 'Ali',
    lastName: 'Haider',
    email: 'ali.haider@provider.com',
    bio: 'Jack of all trades — electrical, plumbing, and general handyman services',
    experience: 15,
    rating: 4.9,
    totalJobs: 300,
    serviceRadius: 35,
    lat: 33.715,
    lng: 73.068,
    availability: 'fullWeek' as AvailabilityKey,
    services: ['Electrical Services', 'Plumbing Services', 'AC Services'],
  },
  {
    firstName: 'Mohsin',
    lastName: 'Naqvi',
    email: 'mohsin.naqvi@provider.com',
    bio: 'Experienced home maintenance professional covering multiple trades',
    experience: 11,
    rating: 4.7,
    totalJobs: 220,
    serviceRadius: 25,
    lat: 33.722,
    lng: 73.055,
    availability: 'extendedHours' as AvailabilityKey,
    services: [
      'Plumbing Services',
      'Electrical Services',
      'Renovation Services',
    ],
  },
];

@Injectable()
export class SeedService implements OnModuleInit {
  private readonly logger = new Logger(SeedService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly providerSearchService: ProviderSearchService,
  ) {}

  async onModuleInit() {
    await this.seed();
  }

  async seed() {
    const categoryCount = await this.prisma.serviceCategory.count();

    if (categoryCount > 0) {
      this.logger.log('Database already seeded. Skipping.');
      return;
    }

    this.logger.log('🌱 Starting database seeding...');

    // Seed service categories with embeddings
    await this.seedCategories();

    // Seed provider users
    await this.seedProviders();

    this.logger.log('🌱 Database seeding complete!');
  }

  private async seedCategories() {
    this.logger.log('Seeding service categories...');

    for (const cat of SERVICE_CATEGORIES) {
      let embedding: number[] = [];

      try {
        const embeddingText = `${cat.name}: ${cat.description}`;
        embedding = await this.providerSearchService.generateEmbedding(
          embeddingText,
          'RETRIEVAL_DOCUMENT',
        );
        this.logger.log(`Generated embedding for: ${cat.name}`);
      } catch (error) {
        this.logger.warn(
          `Failed to generate embedding for ${cat.name}: ${error.message}`,
        );
      }

      await this.prisma.serviceCategory.create({
        data: {
          name: cat.name,
          description: cat.description,
          embedding,
          isActive: true,
        },
      });
    }

    this.logger.log(
      `✅ Seeded ${SERVICE_CATEGORIES.length} service categories`,
    );
  }

  private async seedProviders() {
    this.logger.log('Seeding provider users...');

    const salt = parseInt(process.env.SALT) || 12;
    const hashedPassword = await bcrypt.hash('provider123', salt);

    // Get category map
    const categories = await this.prisma.serviceCategory.findMany();
    const categoryMap = new Map(categories.map((c) => [c.name, c.id]));

    for (const provider of PROVIDER_SEEDS) {
      const user = await this.prisma.user.create({
        data: {
          email: provider.email,
          password: hashedPassword,
          firstName: provider.firstName,
          lastName: provider.lastName,
          role: UserRole.PROVIDER,
          bio: provider.bio,
          experience: provider.experience,
          rating: provider.rating,
          totalJobs: provider.totalJobs,
          serviceRadius: provider.serviceRadius,
          isVerified: true,
          location: {
            address: `${provider.firstName}'s Location, Islamabad`,
            city: 'Islamabad',
            country: 'PK',
            geo: {
              type: 'Point',
              coordinates: [provider.lng, provider.lat],
            },
          },
          availability: AVAILABILITY_PRESETS[provider.availability],
        },
      });

      // Link provider to services
      for (const serviceName of provider.services) {
        const categoryId = categoryMap.get(serviceName);
        if (categoryId) {
          await this.prisma.providerService.create({
            data: {
              providerId: user.id,
              categoryId,
              minPrice: 1000 + Math.floor(Math.random() * 2000),
              maxPrice: 5000 + Math.floor(Math.random() * 5000),
            },
          });
        }
      }

      this.logger.log(
        `✅ Seeded provider: ${provider.firstName} ${provider.lastName}`,
      );
    }

    this.logger.log(`✅ Seeded ${PROVIDER_SEEDS.length} providers`);
  }
}
