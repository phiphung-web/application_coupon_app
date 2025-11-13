import { FilterElement } from 'adminjs';
export declare type FilterParser = {
    isParserForType: (filter: FilterElement) => boolean;
    parse: (filter: FilterElement, fieldKey: string) => {
        filterKey: string;
        filterValue: any;
    };
};
