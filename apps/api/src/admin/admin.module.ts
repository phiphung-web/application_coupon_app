// src/admin/admin.module.ts
import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { AdminModule as NestAdminModule } from "@adminjs/nestjs";
import { Database, Resource } from "@adminjs/typeorm"; // ✅ Import trực tiếp bình thường
import { DataSource } from "typeorm";
import AdminJS from "adminjs";

// Import Entities
import { Item } from "../entities/item.entity";
import { Coupon } from "../entities/coupon.entity";
import { Category } from "../entities/category.entity";
import { CouponCategory } from "../entities/coupon_category.entity";
import { Badge } from "../entities/badge.entity";
import { Source } from "../entities/source.entity";
import { ItemCouponLink } from "../entities/item_coupon_link.entity";
import { User } from "../entities/user.entity";

// Đăng ký Adapter ngay bên ngoài (cho gọn)
AdminJS.registerAdapter({ Database, Resource });

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Item,
      Coupon,
      Category,
      CouponCategory,
      Badge,
      Source,
      ItemCouponLink,
      User,
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
              Item,
              Coupon,
              Category,
              CouponCategory,
              Badge,
              Source,
              ItemCouponLink,
              User,
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
