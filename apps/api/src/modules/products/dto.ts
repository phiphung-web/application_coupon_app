import {
  IsBoolean,
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
} from "class-validator";
import { ItemType } from "../../entities/item.entity";
import { DiscountType } from "../../entities/coupon.entity";

export class CreateProductDto {
  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  imageUrl?: string;

  @IsOptional()
  @IsEnum(ItemType)
  itemType: ItemType = ItemType.PRODUCT;

  @IsOptional()
  @IsString()
  itemUrl?: string;

  @IsOptional()
  @IsNumber()
  price?: number | null;

  @IsOptional()
  sourceId?: number;

  @IsOptional()
  categoryId?: number;

  @IsOptional()
  badgeId?: number;

  @IsOptional()
  createCoupon?: {
    code: string;
    description?: string;
    imageUrl?: string;
    discountType: DiscountType;
    discountValue?: number | null;
    dealUrl?: string;
    badgeId?: number;
    categoryId?: number;
    startDate?: string;
    endDate?: string;
  };
}

export class UpdateProductDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  imageUrl?: string;

  @IsOptional()
  @IsEnum(ItemType)
  itemType?: ItemType;

  @IsOptional()
  @IsString()
  itemUrl?: string;

  @IsOptional()
  @IsNumber()
  price?: number | null;

  @IsOptional()
  sourceId?: number;

  @IsOptional()
  categoryId?: number;

  @IsOptional()
  badgeId?: number;
}

export class LinkCouponDto {
  @IsNumber()
  couponId!: number;

  @IsBoolean()
  isPrimary = false;
}
