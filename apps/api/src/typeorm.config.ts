// src/typeorm.config.ts
import 'dotenv/config';
import { DataSource } from 'typeorm';

const isSSL = /\bsslmode=require\b/i.test(process.env.DATABASE_URL ?? '');

const AppDataSource = new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL, // ví dụ: postgres://postgres:postgres@127.0.0.1:5432/coupon_app
  ssl: isSSL ? { rejectUnauthorized: false } : false,
  entities: [__dirname + '/**/*.entity{.ts,.js}'],
  migrations: [__dirname + '/migrations/*{.ts,.js}'],
  // logging: true,
});

// 👇 CHỈ GIỮ DÒNG NÀY, KHÔNG export gì khác
export default AppDataSource;
