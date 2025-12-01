import {
  IsBoolean,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  ValidateNested,
} from "class-validator";
import { Type } from "class-transformer";
import { ItemType } from "../../entities/item.entity";
import { DiscountType } from "../../entities/coupon.entity";

class CreateInlineCouponDto {
  @IsString()
  @IsNotEmpty()
  code!: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  imageUrl?: string;

  @IsEnum(DiscountType)
  discountType!: DiscountType;

  @IsOptional()
  @IsNumber()
  discountValue?: number | null;

  @IsOptional()
  @IsString()
  dealUrl?: string;

  @IsOptional()
  @IsInt()
  badgeId?: number;

  @IsOptional()
  @IsInt()
  categoryId?: number;

  @IsOptional()
  startDate?: string;

  @IsOptional()
  endDate?: string;
}

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
  @IsInt()
  sourceId?: number;

  @IsOptional()
  @IsInt()
  categoryId?: number;

  @IsOptional()
  @IsInt()
  badgeId?: number;

  @IsOptional()
  @ValidateNested()
  @Type(() => CreateInlineCouponDto)
  createCoupon?: CreateInlineCouponDto;
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
  @IsInt()
  sourceId?: number;

  @IsOptional()
  @IsInt()
  categoryId?: number;

  @IsOptional()
  @IsInt()
  badgeId?: number;
}

export class LinkCouponDto {
  @IsInt()
  couponId!: number;

  @IsBoolean()
  isPrimary = false;
}
