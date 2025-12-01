"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// src/typeorm.config.ts
require("dotenv/config");
const typeorm_1 = require("typeorm");
const isSSL = /\bsslmode=require\b/i.test(process.env.DATABASE_URL ?? '');
const AppDataSource = new typeorm_1.DataSource({
    type: 'postgres',
    url: process.env.DATABASE_URL, // ví dụ: postgres://postgres:postgres@127.0.0.1:5432/coupon_app
    ssl: isSSL ? { rejectUnauthorized: false } : false,
    entities: [__dirname + '/**/*.entity{.ts,.js}'],
    migrations: [__dirname + '/migrations/*{.ts,.js}'],
    // logging: true,
});
// 👇 CHỈ GIỮ DÒNG NÀY, KHÔNG export gì khác
exports.default = AppDataSource;
