import {
  IsBoolean,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
} from "class-validator";
import { PaginationDto } from "../../common/dtos/pagination.dto";

export class CreateCategoryDto {
  @IsString() @MaxLength(120) name!: string;
  @IsString() @IsOptional() imageUrl?: string;
  @IsInt() @IsOptional() parentId?: number;
  @IsInt() @Min(0) @IsOptional() priority?: number = 0;
  @IsBoolean() @IsOptional() isActive?: boolean = true;
}

export class UpdateCategoryDto extends CreateCategoryDto {}

export class ListCategoryDto extends PaginationDto {
  @IsBoolean() @IsOptional() isActive?: boolean;
}
