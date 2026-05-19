import { Global, Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../utils/services/prisma.service';
import { GoogleGenAI } from '@google/genai';
import { GlobalConstants } from '../../utils/GlobalConstants';

@Injectable()
export class ProviderSearchService {
  private readonly logger = new Logger(ProviderSearchService.name);
  private readonly genAI: GoogleGenAI;
  // Separate AI Studio client for embeddings — enterprise endpoint doesn't support embedding models
  private readonly embeddingGenAI: GoogleGenAI;

  constructor(private readonly prisma: PrismaService) {
    this.genAI = new GoogleGenAI({
      enterprise: true,
      apiKey: process.env.GOOGLE_AGENT_PLATFORM_API_KEY,
    });
    this.embeddingGenAI = new GoogleGenAI({
      apiKey: process.env.GEMINI_API_KEY,
    });
  }

  /**
   * Generate a text embedding using Gemini Embedding model.
   */
  async generateEmbedding(
    text: string,
    taskType: 'RETRIEVAL_DOCUMENT' | 'RETRIEVAL_QUERY' = 'RETRIEVAL_QUERY',
  ): Promise<number[]> {
    const result = await this.embeddingGenAI.models.embedContent({
      model: GlobalConstants.geminiModels.embedding,
      contents: text,
      config: {
        taskType,
        outputDimensionality: 768,
      },
    });

    return result.embeddings?.[0]?.values ?? [];
  }

  /**
   * Search for service categories.
   * Tries vector search first; falls back to text search if embeddings are missing.
   */
  async searchServices(query: string, limit = 3) {
    this.logger.debug(`🔍 Searching services for: "${query}"`);

    // Try vector search first
    try {
      const queryEmbedding = await this.generateEmbedding(
        query,
        'RETRIEVAL_QUERY',
      );
      this.logger.debug(
        `🔢 Query embedding generated (${queryEmbedding.length} dims), first 5: [${queryEmbedding.slice(0, 5).join(', ')}]`,
      );

      const results = await this.prisma.serviceCategory.aggregateRaw({
        pipeline: [
          {
            $vectorSearch: {
              index: 'service_category_vector_index',
              path: 'embedding',
              queryVector: queryEmbedding,
              numCandidates: 20,
              limit,
            },
          },
          {
            $project: {
              _id: 1,
              name: 1,
              description: 1,
              isActive: 1,
              score: { $meta: 'vectorSearchScore' },
            },
          },
        ],
      });

      this.logger.debug(
        `📦 Raw vector search response: ${JSON.stringify(results).substring(0, 500)}`,
      );

      const vectorResults = (results as unknown as any[]).map((r) => ({
        id: r._id.$oid || r._id.toString(),
        name: r.name,
        description: r.description,
        score: r.score,
      }));

      if (vectorResults.length > 0) {
        this.logger.debug(
          `✅ Vector search found ${vectorResults.length} results: ${vectorResults.map((r) => `${r.name}(${r.score?.toFixed(3)})`).join(', ')}`,
        );
        return vectorResults;
      }

      this.logger.warn(
        `⚠️ Vector search returned 0 results. Is the Atlas Vector Search index "service_category_vector_index" created and active?`,
      );
    } catch (error) {
      this.logger.warn(
        `⚠️ Vector search failed, falling back to text search: ${(error as any).message}`,
      );
    }

    // Fallback: text-based search on name and description
    this.logger.debug(`📝 Using text fallback search for: "${query}"`);
    const allCategories = await this.prisma.serviceCategory.findMany({
      where: { isActive: true },
    });

    const queryLower = query.toLowerCase();
    const queryWords = queryLower.split(/\s+/);

    const scored = allCategories
      .map((cat) => {
        const nameLower = cat.name.toLowerCase();
        const descLower = cat.description.toLowerCase();
        let score = 0;

        // Exact name match
        if (nameLower.includes(queryLower)) score += 0.9;

        // Word-level matches
        for (const word of queryWords) {
          if (word.length < 3) continue;
          if (nameLower.includes(word)) score += 0.4;
          if (descLower.includes(word)) score += 0.2;
        }

        return {
          id: cat.id,
          name: cat.name,
          description: cat.description,
          score,
        };
      })
      .filter((r) => r.score > 0)
      .sort((a, b) => b.score - a.score)
      .slice(0, limit);

    this.logger.debug(
      `📝 Text search found ${scored.length} results: ${scored.map((s) => `${s.name}(${s.score})`).join(', ')}`,
    );
    return scored;
  }

  /**
   * Geospatial provider search.
   * Finds providers within 30km of a location that offer a specific service category.
   * Returns top 10 sorted by rating.
   */
  async searchProviders(
    categoryId: string,
    longitude: number,
    latitude: number,
    radiusKm = 30,
  ) {
    const radiusMeters = radiusKm * 1000;

    const results = (await this.prisma.$runCommandRaw({
      aggregate: 'users',
      pipeline: [
        {
          $geoNear: {
            near: {
              type: 'Point',
              coordinates: [longitude, latitude],
            },
            distanceField: 'distance',
            maxDistance: radiusMeters,
            query: {
              role: 'PROVIDER',
              isActive: true,
            },
            spherical: true,
          },
        },
        {
          $lookup: {
            from: 'provider_services',
            localField: '_id',
            foreignField: 'providerId',
            as: 'services',
          },
        },
        {
          $match: {
            'services.categoryId': { $oid: categoryId },
          },
        },
        {
          $project: {
            _id: 1,
            firstName: 1,
            lastName: 1,
            email: 1,
            phone: 1,
            bio: 1,
            experience: 1,
            rating: 1,
            totalJobs: 1,
            serviceRadius: 1,
            availability: 1,
            location: 1,
            distance: 1,
            services: 1,
          },
        },
        { $sort: { rating: -1 } },
        { $limit: 10 },
      ],
      cursor: {},
    })) as any;

    // Extract the results from the cursor response
    const docs = results?.cursor?.firstBatch || [];

    return docs.map((doc: any) => ({
      id: doc._id.$oid || doc._id.toString(),
      firstName: doc.firstName,
      lastName: doc.lastName,
      bio: doc.bio,
      experience: doc.experience,
      rating: doc.rating || 0,
      totalJobs: doc.totalJobs || 0,
      serviceRadius: doc.serviceRadius,
      availability: doc.availability || [],
      location: doc.location,
      distance: Math.round(((doc.distance || 0) / 1000) * 10) / 10, // Convert to km, 1 decimal
      services: (doc.services || []).map((s: any) => ({
        categoryId: s.categoryId?.$oid || s.categoryId,
        minPrice: s.minPrice,
        maxPrice: s.maxPrice,
      })),
    }));
  }
}
