import { ComponentLoader, Locale, ResourceWithOptions } from "adminjs";
import { DataSource } from "typeorm";
export declare function buildAdminOptions(ds: DataSource): {
    rootPath: string;
    databases: DataSource[];
    resources: ResourceWithOptions[];
    componentLoader: ComponentLoader;
    branding: {
        companyName: string;
        softwareBrothers: boolean;
    };
    locale: Locale;
};
