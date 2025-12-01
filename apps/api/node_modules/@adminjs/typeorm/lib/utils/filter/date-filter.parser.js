"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DateParser = void 0;
const typeorm_1 = require("typeorm");
exports.DateParser = {
    isParserForType: (filter) => ['date', 'datetime'].includes(filter.property.type()),
    parse: (filter, fieldKey) => {
        if (typeof filter.value !== 'string'
            && filter.value.from
            && filter.value.to) {
            return {
                filterKey: fieldKey,
                filterValue: (0, typeorm_1.Between)(new Date(filter.value.from), new Date(filter.value.to)),
            };
        }
        if (typeof filter.value !== 'string' && filter.value.from) {
            return {
                filterKey: fieldKey,
                filterValue: (0, typeorm_1.MoreThanOrEqual)(new Date(filter.value.from).toISOString()),
            };
        }
        if (typeof filter.value !== 'string' && filter.value.to) {
            return {
                filterKey: fieldKey,
                filterValue: (0, typeorm_1.LessThanOrEqual)(new Date(filter.value.to)),
            };
        }
        throw new Error('Cannot parse date filter');
    },
};
//# sourceMappingURL=date-filter.parser.js.map