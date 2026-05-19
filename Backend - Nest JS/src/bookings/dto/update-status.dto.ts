import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty } from 'class-validator';
import { BookingStatus } from '@prisma/client';

export class UpdateStatusDto {
  @ApiProperty({
    enum: ['INITIALIZED', 'PROVIDER_COMPLETED', 'CANCELLED'],
    example: 'INITIALIZED',
    description: 'New booking status. Providers can set: INITIALIZED, PROVIDER_COMPLETED, CANCELLED',
  })
  @IsEnum(['INITIALIZED', 'PROVIDER_COMPLETED', 'CANCELLED'], {
    message: 'Status must be one of: INITIALIZED, PROVIDER_COMPLETED, CANCELLED',
  })
  @IsNotEmpty()
  status: BookingStatus;
}
