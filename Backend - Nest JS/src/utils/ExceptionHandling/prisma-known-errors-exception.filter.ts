import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpStatus,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { Request, Response } from 'express';

@Catch(Prisma.PrismaClientKnownRequestError)
export class PrismaKnownErrorsExceptionFilter implements ExceptionFilter {
  NotFound: string = 'P2025';
  UniqueContraintFailError: string = 'P2002';

  catch(exception: Prisma.PrismaClientKnownRequestError, host: ArgumentsHost) {
    console.error(exception.message);
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();
    const message = exception.message.replace(/\n/g, '');

    switch (exception.code) {
      case this.NotFound: {
        const status = HttpStatus.NOT_FOUND;
        response.status(status).json({
          statusCode: status,
          message: message,
        });
        break;
      }

      case this.UniqueContraintFailError: {
        const status = HttpStatus.CONFLICT;
        response.status(status).json({
          statusCode: status,
          message: message,
        });
        break;
      }

      default:
        const status = HttpStatus.BAD_REQUEST;
        response.status(status).json({
          statusCode: status,
          exception: exception,
          message: 'Bad Request ! ' + exception.name,
        });
        break;
    }

    // if (exception.code == this.NotFound) {
    //   response.status(HttpStatus.NOT_FOUND).json({
    //     statusCode: HttpStatus.NOT_FOUND,
    //     message: 'Not Found',
    //   });
    //   return;
    // }

    // if (exception.code == this.UniqueContraintFailError) {
    //   return response
    //     .status(HttpStatus.CONFLICT)
    //     .json({ message: 'User already exists' });
    // }
  }
}
