import { Type } from 'class-transformer';
import { IsBoolean, IsInt, IsNotEmpty, IsOptional, IsPositive, IsString, MaxLength } from 'class-validator';

export class CreateProductDto {
  @IsString() @MaxLength(200) @IsNotEmpty() name!: string;
  @IsOptional() @IsString() imageUrl?: string;

  @Type(() => Number) @IsInt() @IsPositive() basePrice!: number;
  @Type(() => Number) @IsInt() @IsOptional() originalPrice?: number;
  @Type(() => Number) @IsInt() @IsOptional() discountPercent?: number;

  @Type(() => Number) @IsInt() @IsPositive() categoryId!: number;

  @IsOptional() @IsString() shopId?: string;
  @IsOptional() @IsString() description?: string;

  @IsOptional() @IsBoolean() isHot?: boolean = false;
}
export class UpdateProductDto extends CreateProductDto {}

export class QueryProductsDto {
  @Type(() => Number) @IsInt() @IsOptional() page: number = 1;
  @Type(() => Number) @IsInt() @IsOptional() pageSize: number = 20;
  @Type(() => Number) @IsInt() @IsOptional() categoryId?: number;
  @IsOptional() @IsString() q?: string;
  @IsOptional() @IsString() sort?: 'new'|'hot'|'priceAsc'|'priceDesc'|'discountDesc';
  @IsOptional() @IsString() shopId?: string;
}
