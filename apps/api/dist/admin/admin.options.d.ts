import { ResourceOptions } from "adminjs";
import { DataSource } from "typeorm";
export declare function buildAdminOptions(ds: DataSource): {
    rootPath: string;
    resources: {
        resource: any;
        options?: ResourceOptions;
    }[];
    databases: DataSource[];
    branding: {
        companyName: string;
        softwareBrothers: boolean;
    };
    locale: {
        language: string;
    };
};
