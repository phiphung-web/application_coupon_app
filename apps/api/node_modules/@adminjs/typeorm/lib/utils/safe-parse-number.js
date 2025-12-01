"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
/* eslint-disable no-restricted-globals */
const isNumeric = (value) => {
    const stringValue = (String(value)).replace(/,/g, '.');
    if (isNaN(parseFloat(stringValue)))
        return false;
    return isFinite(Number(stringValue));
};
const safeParseNumber = (value) => {
    if (isNumeric(value))
        return Number(value);
    return value;
};
exports.default = safeParseNumber;
//# sourceMappingURL=safe-parse-number.js.map