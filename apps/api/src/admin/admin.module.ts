// src/admin/admin.module.ts
import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { AdminModule as NestAdminModule } from "@adminjs/nestjs";
import { Database, Resource } from "@adminjs/typeorm"; // ✅ Import trực tiếp bình thường
import { DataSource } from "typeorm";
import AdminJS from "adminjs";

// Import Entities
import { Product } from "../entities/product.entity";
import { Coupon } from "../entities/coupon.entity";
import { Category } from "../entities/category.entity";
import { CouponCategory } from "../entities/coupon_category.entity";
import { Badge } from "../entities/badge.entity";
import { Source } from "../entities/source.entity";
import { ProductCoupon } from "../entities/product_coupon.entity";

// Đăng ký Adapter ngay bên ngoài (cho gọn)
AdminJS.registerAdapter({ Database, Resource });

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Product, Coupon, Category, CouponCategory, Badge, Source, ProductCoupon
    ]),

    NestAdminModule.createAdminAsync({
      inject: [DataSource],
      useFactory: async (ds: DataSource) => {
        return {
          adminJsOptions: {
            rootPath: "/admin",
            branding: { companyName: "Coupon CMS" },
            resources: [
              // ✅ AdminJS v6 tự hiểu Entity, không cần { model: ds }
              Product,
              Coupon,
              Category,
              CouponCategory,
              Badge,
              Source,
              ProductCoupon,
            ],
          },
          auth: {
            authenticate: async (email, password) =>
              email === process.env.ADMIN_EMAIL && password === process.env.ADMIN_PASSWORD
                ? { email }
                : null,
            cookieName: "adminjs",
            cookiePassword: process.env.ADMIN_COOKIE_SECRET || "secret-password",
          },
          sessionOptions: {
            resave: false,
            saveUninitialized: true,
            secret: process.env.ADMIN_COOKIE_SECRET || "secret-password",
          },
        };
      },
    }),
  ],
})
export class AdminCmsModule {}