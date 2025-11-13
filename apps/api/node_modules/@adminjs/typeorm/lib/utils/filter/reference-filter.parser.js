"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ReferenceParser = void 0;
exports.ReferenceParser = {
    isParserForType: (filter) => filter.property.type() === 'reference',
    parse: (filter) => {
        const [column] = filter.property.column.propertyPath.split('.');
        return { filterKey: column, filterValue: filter.value };
    },
};
//# sourceMappingURL=reference-filter.parser.js.map