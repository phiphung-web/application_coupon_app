import {
  IsBoolean,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
} from "class-validator";
import { PaginationDto } from "../../common/dtos/pagination.dto";

export type SourceType = "ECOM" | "APP" | "GAME" | "SERVICE" | "OTHER";

export class CreateSourceDto {
  @IsString() @MaxLength(50) id!: string;
  @IsString() @MaxLength(120) name!: string;
  @IsEnum(["ECOM", "APP", "GAME", "SERVICE", "OTHER"]) type: SourceType =
    "ECOM";
  @IsString() @IsOptional() logoUrl?: string;
  @IsString() @IsOptional() domain?: string;
  @IsString() @IsOptional() packageId?: string;
  @IsString() @IsOptional() bundleId?: string;
  @IsString() @IsOptional() publisher?: string;
  @IsInt() @Min(0) @IsOptional() priority?: number = 0;
  @IsBoolean() @IsOptional() isActive?: boolean = true;
}

export class UpdateSourceDto {
  @IsString() @IsOptional() name?: string;
  @IsEnum(["ECOM", "APP", "GAME", "SERVICE", "OTHER"])
  @IsOptional()
  type?: SourceType;
  @IsString() @IsOptional() logoUrl?: string;
  @IsString() @IsOptional() domain?: string;
  @IsString() @IsOptional() packageId?: string;
  @IsString() @IsOptional() bundleId?: string;
  @IsString() @IsOptional() publisher?: string;
  @IsInt() @Min(0) @IsOptional() priority?: number;
  @IsBoolean() @IsOptional() isActive?: boolean;
}

export class ListSourceDto extends PaginationDto {
  @IsString() @IsOptional() type?: SourceType;
  @IsBoolean() @IsOptional() isActive?: boolean;
}
