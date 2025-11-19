import { ResourceWithOptions } from "adminjs";
import { DataSource } from "typeorm";
export declare function buildAdminOptions(ds: DataSource): {
    rootPath: string;
    databases: DataSource[];
    resources: ResourceWithOptions[];
    branding: {
        companyName: string;
        softwareBrothers: boolean;
    };
    locale: {
        language: string;
    };
};
