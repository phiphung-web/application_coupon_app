import { Type } from "class-transformer";
import {
  IsArray,
  IsBoolean,
  IsInt,
  IsJSON,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  ValidateIf,
} from "class-validator";
import { PaginationDto } from "../../common/dtos/pagination.dto";

export class CreateProductDto {
  @IsString() @MaxLength(200) name!: string;
  @IsString() @IsOptional() imageUrl?: string;

  @Type(() => Number) @IsInt() @Min(0) basePrice!: number;
  @Type(() => Number) @IsInt() @Min(0) @IsOptional() originalPrice?: number;
  @Type(() => Number) @IsInt() @Min(0) @IsOptional() discountPercent?: number;

  @Type(() => Number) @IsInt() categoryId!: number;
  @IsString() @IsOptional() sourceId?: string;

  @IsString() @IsOptional() description?: string;
  @IsBoolean() @IsOptional() isHot?: boolean = false;

  @ValidateIf((v) => v.badges !== undefined)
  @IsArray()
  @IsOptional()
  badges?: any[];
}

export class UpdateProductDto extends CreateProductDto {}

export class ListProductDto extends PaginationDto {
  @Type(() => Number) @IsInt() @IsOptional() categoryId?: number;
  @IsString() @IsOptional() sourceId?: string;
  @IsBoolean() @IsOptional() isHot?: boolean;
  @IsString() @IsOptional() sort?:
    | "new"
    | "hot"
    | "priceAsc"
    | "priceDesc"
    | "discountDesc";
}
