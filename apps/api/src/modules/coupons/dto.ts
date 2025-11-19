import {
  IsDateString,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
} from "class-validator";
import { DiscountType } from "../../entities/coupon.entity";
import { PaginationDto } from "../../common/dtos/pagination.dto";

export class UpsertCouponDto {
  @IsOptional()
  id?: number;

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
  sourceId?: number;

  @IsOptional()
  @IsInt()
  categoryId?: number;

  @IsOptional()
  @IsInt()
  badgeId?: number;

  @IsOptional()
  @IsDateString()
  startDate?: string;

  @IsOptional()
  @IsDateString()
  endDate?: string;
}

export class CouponQueryDto extends PaginationDto {
  @IsOptional()
  @IsEnum(DiscountType)
  discountType?: DiscountType;

  @IsOptional()
  @IsDateString()
  expiresFrom?: string;

  @IsOptional()
  @IsDateString()
  expiresTo?: string;
}
