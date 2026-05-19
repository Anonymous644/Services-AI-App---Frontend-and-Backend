import { RequestMethod, VersioningType } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { SwaggerModule } from '@nestjs/swagger';
import { json, urlencoded } from 'express';
import { AppModule } from './app.module';
import { PrismaKnownErrorsExceptionFilter } from './utils/ExceptionHandling/prisma-known-errors-exception.filter';
import { AppConfigurations } from './utils/GlobalConstants';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.use(json({ limit: '50mb' }));
  app.use(urlencoded({ limit: '50mb', extended: true }));

  // Set global prefix
  app.setGlobalPrefix('api', {
    exclude: [
      { path: 'health', method: RequestMethod.GET },
      { path: 'health/provoke-error', method: RequestMethod.GET },
      { path: 'docs', method: RequestMethod.GET },
    ],
  });

  app.useGlobalPipes(AppConfigurations.validationPipesConfig); // Add a global validation pipe to the application to automatically validate input data in all routes
  app.useGlobalFilters(new PrismaKnownErrorsExceptionFilter()); // Add a global exception filter to the application to handle known Prisma errors

  SwaggerModule.setup(
    'docs',
    app,
    SwaggerModule.createDocument(app, AppConfigurations.swaggerConfig),
  );

  // Explicitly enable versioning
  app.enableVersioning({
    type: VersioningType.URI,
  });

  await app.listen(process.env.PORT || 8000);
}

bootstrap();
