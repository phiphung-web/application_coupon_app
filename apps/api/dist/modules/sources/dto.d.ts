import { SourceType } from "../../entities/source.entity";
export declare class CreateSourceDto {
    id: string;
    name: string;
    type: SourceType;
    logoUrl?: string;
    domain?: string;
    packageId?: string;
    bundleId?: string;
    publisher?: string;
    priority?: number;
    isActive?: boolean;
}
export declare class UpdateSourceDto {
    name?: string;
    type?: SourceType;
    logoUrl?: string;
    domain?: string;
    packageId?: string;
    bundleId?: string;
    publisher?: string;
    priority?: number;
    isActive?: boolean;
}
