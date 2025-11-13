"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.convertFilter = void 0;
const default_filter_parser_1 = require("./default-filter.parser");
const filter_utils_1 = require("./filter.utils");
const convertFilter = (filterObject) => {
    if (!filterObject) {
        return {};
    }
    const { filters } = filterObject !== null && filterObject !== void 0 ? filterObject : {};
    const where = {};
    Object.entries(filters !== null && filters !== void 0 ? filters : {}).forEach(([fieldKey, filter]) => {
        const parser = filter_utils_1.parsers.find((p) => p.isParserForType(filter));
        if (parser) {
            const { filterValue, filterKey } = parser.parse(filter, fieldKey);
            where[filterKey] = filterValue;
        }
        else {
            const { filterValue, filterKey } = default_filter_parser_1.DefaultParser.parse(filter, fieldKey);
            where[filterKey] = filterValue;
        }
    });
    return where;
};
exports.convertFilter = convertFilter;
//# sourceMappingURL=filter.converter.js.map