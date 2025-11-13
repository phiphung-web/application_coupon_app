"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.EnumParser = void 0;
exports.EnumParser = {
    isParserForType: (filter) => filter.property.column.type === 'enum',
    parse: (filter, fieldKey) => ({ filterKey: fieldKey, filterValue: filter.value }),
};
//# sourceMappingURL=enum-filter.parser.js.map