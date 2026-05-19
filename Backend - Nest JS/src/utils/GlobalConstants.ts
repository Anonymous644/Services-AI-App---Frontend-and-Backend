import { ValidationPipe } from '@nestjs/common';
import { DocumentBuilder } from '@nestjs/swagger';
import { Env, NodeEnv } from './EnviromentVariables';

export const GlobalConstants = {
  appName: 'Services AI',
  appVersion: '1.0',

  environment: {
    isLocal: Env.environment == NodeEnv.local,
    isDevelopment: Env.environment == NodeEnv.development,
    isProduction: Env.environment == NodeEnv.production,
  },

  geminiModels: {
    generative: 'gemini-3.1-flash-lite',
    embedding: 'gemini-embedding-2',
  },
};

export const AppConfigurations = {
  jwtKey:
    process.env.JWT_SECRET || 'services-ai-jwt-secret-change-in-production',

  swaggerConfig: new DocumentBuilder()
    .setTitle(`${GlobalConstants.appName} API`)
    .setDescription(
      `API for ${GlobalConstants.appName} - AI-powered services marketplace platform`,
    )
    .setVersion(GlobalConstants.appVersion)
    .addBearerAuth()
    .build(),

  validationPipesConfig: new ValidationPipe({
    whitelist: true,
    transform: true,
    forbidNonWhitelisted: true,
  }),
};
