import {
  IsBoolean,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
  Min,
} from "class-validator";
import { SourceType } from "../../entities/source.entity";

export class CreateSourceDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(50)
  id!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  name!: string;

  @IsEnum(["ECOM", "APP", "GAME", "SERVICE", "OTHER"])
  type!: SourceType;

  @IsOptional() @IsString() logoUrl?: string;
  @IsOptional() @IsString() domain?: string;
  @IsOptional() @IsString() packageId?: string;
  @IsOptional() @IsString() bundleId?: string;
  @IsOptional() @IsString() publisher?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  priority?: number;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class UpdateSourceDto {
  @IsOptional() @IsString() name?: string;
  @IsOptional()
  @IsEnum(["ECOM", "APP", "GAME", "SERVICE", "OTHER"])
  type?: SourceType;
  @IsOptional() @IsString() logoUrl?: string;
  @IsOptional() @IsString() domain?: string;
  @IsOptional() @IsString() packageId?: string;
  @IsOptional() @IsString() bundleId?: string;
  @IsOptional() @IsString() publisher?: string;
  @IsOptional()
  @IsInt()
  @Min(0)
  priority?: number;
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
