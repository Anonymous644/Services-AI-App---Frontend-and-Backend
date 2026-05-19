import { Injectable, Logger, OnApplicationBootstrap } from '@nestjs/common';
import { GoogleGenAI } from '@google/genai';
import { GlobalConstants } from './utils/GlobalConstants';

@Injectable()
export class AppService implements OnApplicationBootstrap {
  private readonly logger = new Logger('AIStartupCheck');

  getHello() {
    return { message: 'Welcome to Services AI API!' };
  }

  async onApplicationBootstrap() {
    const genAI = new GoogleGenAI({
      enterprise: true,
      apiKey: process.env.GOOGLE_AGENT_PLATFORM_API_KEY,
    });
    const embeddingGenAI = new GoogleGenAI({
      apiKey: process.env.GEMINI_API_KEY,
    });

    await Promise.all([
      this.checkGenerativeAI(genAI),
      this.checkEmbeddingAI(embeddingGenAI),
    ]);
  }

  private async checkGenerativeAI(genAI: GoogleGenAI) {
    this.logger.log('Running Gemini generative API check...');
    try {
      const result = await genAI.models.generateContent({
        model: GlobalConstants.geminiModels.generative,
        contents: [
          { role: 'user', parts: [{ text: 'Reply with the single word: ok' }] },
        ],
      });

      const reply =
        result.candidates?.[0]?.content?.parts?.[0]?.text?.trim() ??
        '(no response)';
      this.logger.log(`✅ Generative AI reachable — response: "${reply}"`);
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : String(err);
      this.logger.error(`❌ Generative AI check failed: ${message}`);
    }
  }

  private async checkEmbeddingAI(genAI: GoogleGenAI) {
    this.logger.log('Running Gemini embedding API check...');
    try {
      const result = await genAI.models.embedContent({
        model: GlobalConstants.geminiModels.embedding,
        contents: 'startup connectivity test',
        config: {
          taskType: 'RETRIEVAL_QUERY',
          outputDimensionality: 768,
        },
      });

      const dims = result.embeddings?.[0]?.values?.length ?? 0;
      if (dims === 0) throw new Error('Embedding returned 0 dimensions');
      this.logger.log(`✅ Embedding API reachable — vector dims: ${dims}`);
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : String(err);
      this.logger.error(`❌ Embedding API check failed: ${message}`);
    }
  }
}
