"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DefaultParser = void 0;
const typeorm_1 = require("typeorm");
const uuidRegex = /^[0-9A-F]{8}-[0-9A-F]{4}-[5|4|3|2|1][0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i;
exports.DefaultParser = {
    isParserForType: (filter) => filter.property.type() === 'string',
    parse: (filter, fieldKey) => {
        if (uuidRegex.test(filter.value.toString()) || filter.property.column.type === 'uuid') {
            return {
                filterKey: fieldKey,
                filterValue: (0, typeorm_1.Raw)((alias) => `CAST(${alias} AS CHAR(36)) = :value`, { value: filter.value }),
            };
        }
        return { filterKey: fieldKey, filterValue: (0, typeorm_1.Like)(`%${filter.value}%`) };
    },
};
//# sourceMappingURL=default-filter.parser.js.map