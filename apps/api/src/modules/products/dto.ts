import {
  IsArray,
  IsBoolean,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Min,
} from "class-validator";

export class CreateProductDto {
  @IsString() @IsNotEmpty() name!: string;
  @IsOptional() @IsString() imageUrl?: string;

  @IsInt() @Min(0) priceOriginal!: number; // cent
  @IsOptional() @IsInt() @Min(0) priceCurrent?: number;

  @IsOptional() @IsString() description?: string;
  @IsOptional() @IsString() sourceId?: string;

  @IsArray() categoryIds!: number[]; // product categories
  @IsOptional() @IsArray() badgeIds?: number[];

  // tạo coupon kèm
  @IsOptional() createCoupon?: {
    id?: string;
    title: string;
    code: string;
    discountType: "PERCENT" | "FIXED";
    discountValue: number; // cent hoặc %
    minSpend?: number;
    maxDiscount?: number;
    endAt?: string;
    sourceId?: string;
  };
}

export class UpdateProductDto {
  @IsOptional() @IsString() name?: string;
  @IsOptional() @IsString() imageUrl?: string;
  @IsOptional() @IsInt() @Min(0) priceOriginal?: number;
  @IsOptional() @IsInt() @Min(0) priceCurrent?: number;
  @IsOptional() @IsString() description?: string;
  @IsOptional() @IsString() sourceId?: string;
  @IsOptional() categoryIds?: number[];
  @IsOptional() badgeIds?: number[];
}

export class LinkCouponDto {
  @IsString() couponId!: string;
  @IsBoolean() isPrimary = false;
}
