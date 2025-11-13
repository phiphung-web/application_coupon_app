"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parsers = exports.safeParseJSON = void 0;
const custom_filter_parser_1 = require("./custom-filter.parser");
const date_filter_parser_1 = require("./date-filter.parser");
const enum_filter_parser_1 = require("./enum-filter.parser");
const json_filter_parser_1 = require("./json-filter.parser");
const reference_filter_parser_1 = require("./reference-filter.parser");
const safeParseJSON = (json) => {
    try {
        return JSON.parse(json);
    }
    catch (e) {
        return null;
    }
};
exports.safeParseJSON = safeParseJSON;
exports.parsers = [
    // Has to be the first one, as it is intended to use custom filter if user overrides that
    custom_filter_parser_1.CustomParser,
    date_filter_parser_1.DateParser,
    enum_filter_parser_1.EnumParser,
    reference_filter_parser_1.ReferenceParser,
    json_filter_parser_1.JSONParser,
];
//# sourceMappingURL=filter.utils.js.map