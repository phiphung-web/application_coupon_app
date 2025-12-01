"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.toPublicUrl = toPublicUrl;
function toPublicUrl(path) {
    if (!path)
        return path ?? undefined;
    if (/^https?:\/\//i.test(path)) {
        return path;
    }
    const cleaned = path.replace(/^\/+/, "");
    const base = process.env.APP_URL?.replace(/\/$/, "") ||
        `http://localhost:${process.env.PORT || 3000}`;
    return `${base}/uploads/${cleaned}`;
}
