import { Type } from 'class-transformer';
import { IsArray, IsDateString, IsEnum, IsInt, IsNotEmpty, IsOptional, IsPositive, IsString, MaxLength } from 'class-validator';
import { DiscountType } from '../../entities/coupon.entity';

export class CreateCouponDto {
  @IsString() @MaxLength(64) @IsNotEmpty() id!: string;
  @IsString() @MaxLength(200) @IsNotEmpty() title!: string;
  @IsString() @MaxLength(64)  @IsNotEmpty() code!: string;

  @IsEnum(['PERCENT','FIXED']) discountType!: DiscountType;
  @Type(() => Number) @IsInt() @IsPositive() discountValue!: number;

  @Type(() => Number) @IsInt() @IsOptional() minSpend?: number;
  @Type(() => Number) @IsInt() @IsOptional() maxDiscount?: number;

  @IsOptional() @IsDateString() expiredAt?: string;

  @Type(() => Number) @IsInt() @IsOptional() categoryId?: number;
  @IsOptional() @IsArray() applicableTypes?: string[];

  @IsOptional() @IsString() shopId?: string;
  @IsOptional() @IsString() imageUrl?: string;

  @IsOptional() @IsArray() tags?: string[];
  @Type(() => Number) @IsInt() @IsOptional() priority?: number;

  @IsOptional() @IsString() trackingLink?: string;
  @IsOptional() @IsString() deeplink?: string;

  @IsOptional() isActive?: boolean = true;
}
export class UpdateCouponDto extends CreateCouponDto {}

export class QueryCouponsDto {
  @Type(() => Number) @IsInt() @IsOptional() page: number = 1;
  @Type(() => Number) @IsInt() @IsOptional() pageSize: number = 20;
  @Type(() => Number) @IsInt() @IsOptional() categoryId?: number;
  @IsOptional() @IsString() q?: string;
  @IsOptional() @IsString() sort?: 'new'|'priorityDesc'|'endAtAsc'|'hot';
  @IsOptional() @IsString() shopId?: string;
}
