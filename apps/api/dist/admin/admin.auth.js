"use strict";
// src/admin/admin.auth.ts
Object.defineProperty(exports, "__esModule", { value: true });
exports.buildAuth = buildAuth;
function buildAuth() {
    const ADMIN_EMAIL = process.env.ADMIN_EMAIL || "admin@example.com";
    const ADMIN_PASS = process.env.ADMIN_PASSWORD || "admin123";
    return {
        authenticate: async (email, password) => email === ADMIN_EMAIL && password === ADMIN_PASS ? { email } : null,
        cookieName: "adminjs",
        cookiePassword: process.env.ADMIN_COOKIE_SECRET || "replace_me",
    };
}
