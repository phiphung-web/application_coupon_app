"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.JSONParser = void 0;
const filter_utils_1 = require("./filter.utils");
exports.JSONParser = {
    isParserForType: (filter) => ['boolean', 'number', 'float', 'object', 'array'].includes(filter.property.type()),
    parse: (filter, fieldKey) => ({
        filterKey: fieldKey,
        filterValue: (0, filter_utils_1.safeParseJSON)(filter.value),
    }),
};
//# sourceMappingURL=json-filter.parser.js.map