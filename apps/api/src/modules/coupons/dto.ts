import {
  IsArray,
  IsBoolean,
  IsDateString,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Min,
} from "class-validator";

export enum DiscountTypeDto {
  PERCENT = "PERCENT",
  FIXED = "FIXED",
}

export class UpsertCouponDto {
  @IsOptional() @IsString() id?: string;
  @IsString() @IsNotEmpty() title!: string;
  @IsString() @IsNotEmpty() code!: string;

  @IsEnum(DiscountTypeDto) discountType!: DiscountTypeDto;
  @IsInt() @Min(0) discountValue!: number; // % hoặc cent

  @IsOptional() @IsInt() @Min(0) minSpend?: number;
  @IsOptional() @IsInt() @Min(0) maxDiscount?: number;

  @IsOptional() @IsDateString() endAt?: string;

  @IsOptional() @IsString() sourceId?: string;
  @IsOptional() @IsString() imageUrl?: string;

  @IsOptional() @IsArray() categoryIds?: number[]; // coupon categories
  @IsOptional() @IsArray() badgeIds?: number[];

  @IsOptional() @IsInt() priority?: number;
  @IsOptional() @IsString() trackingLink?: string;
  @IsOptional() @IsString() deeplink?: string;
  @IsOptional() @IsBoolean() isActive?: boolean;
}
