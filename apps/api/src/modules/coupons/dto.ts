import { Type } from 'class-transformer';
import { IsArray, IsBoolean, IsDateString, IsEnum, IsInt, IsOptional, IsString, MaxLength, Min, ValidateIf } from 'class-validator';
import { PaginationDto } from '../../common/dtos/pagination.dto';

export type DiscountType = 'PERCENT' | 'FIXED';

export class CreateCouponDto {
  @IsString() @MaxLength(64) id!: string;
  @IsString() @MaxLength(200) title!: string;
  @IsString() @MaxLength(64) code!: string;

  @IsEnum(['PERCENT','FIXED']) discountType!: DiscountType;
  @Type(() => Number) @IsInt() @Min(1) discountValue!: number;

  @Type(() => Number) @IsInt() @Min(0) @IsOptional() minSpend?: number;
  @Type(() => Number) @IsInt() @Min(0) @IsOptional() maxDiscount?: number;

  @IsDateString() @IsOptional() expiredAt?: string;

  @Type(() => Number) @IsInt() @IsOptional() categoryId?: number;
  @IsArray() @IsOptional() applicableTypes?: string[];

  @IsString() @IsOptional() sourceId?: string;
  @IsString() @IsOptional() imageUrl?: string;

  @ValidateIf(v => v.badges !== undefined)
  @IsArray() @IsOptional() badges?: any[];

  @Type(() => Number) @IsInt() @IsOptional() priority?: number;

  @IsString() @IsOptional() trackingLink?: string;
  @IsString() @IsOptional() deeplink?: string;

  @IsBoolean() @IsOptional() isActive?: boolean = true;
}

export class UpdateCouponDto extends CreateCouponDto {}

export class ListCouponDto extends PaginationDto {
  @Type(() => Number) @IsInt() @IsOptional() categoryId?: number;
  @IsString() @IsOptional() sourceId?: string;
  @IsString() @IsOptional() sort?: 'priorityDesc' | 'endAtAsc' | 'hot' | 'new';
  @IsBoolean() @IsOptional() isActive?: boolean;
}
