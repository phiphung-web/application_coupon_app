"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Init1710000000000 = void 0;
class Init1710000000000 {
    constructor() {
        this.name = "Init1710000000000";
    }
    async up(q) {
        await q.query(`
      CREATE TABLE IF NOT EXISTS badges (
        id SERIAL PRIMARY KEY,
        "key" VARCHAR(50) NOT NULL,
        label VARCHAR(120) NOT NULL,
        color TEXT, "bgColor" TEXT, icon TEXT,
        priority INT DEFAULT 0,
        "isActive" BOOLEAN DEFAULT TRUE,
        "createdAt" TIMESTAMPTZ DEFAULT NOW(),
        "updatedAt" TIMESTAMPTZ DEFAULT NOW(),
        "deletedAt" TIMESTAMPTZ
      );
      CREATE UNIQUE INDEX IF NOT EXISTS ux_badges_key ON badges("key");

      CREATE TABLE IF NOT EXISTS coupon_categories (
        id SERIAL PRIMARY KEY,
        name VARCHAR(120) NOT NULL,
        "imageUrl" TEXT, "parentId" INT,
        priority INT DEFAULT 0,
        "isActive" BOOLEAN DEFAULT TRUE,
        "createdAt" TIMESTAMPTZ DEFAULT NOW(),
        "updatedAt" TIMESTAMPTZ DEFAULT NOW(),
        "deletedAt" TIMESTAMPTZ
      );

      CREATE TABLE IF NOT EXISTS product_categories (
        id SERIAL PRIMARY KEY,
        name VARCHAR(120) NOT NULL,
        "imageUrl" TEXT, "parentId" INT,
        priority INT DEFAULT 0,
        "isActive" BOOLEAN DEFAULT TRUE,
        "createdAt" TIMESTAMPTZ DEFAULT NOW(),
        "updatedAt" TIMESTAMPTZ DEFAULT NOW(),
        "deletedAt" TIMESTAMPTZ
      );

      -- joins
      CREATE TABLE IF NOT EXISTS product_badges (
        "productId" INT NOT NULL,
        "badgeId" INT NOT NULL,
        PRIMARY KEY ("productId","badgeId")
      );
      CREATE TABLE IF NOT EXISTS coupon_badges (
        "couponId" VARCHAR(64) NOT NULL,
        "badgeId" INT NOT NULL,
        PRIMARY KEY ("couponId","badgeId")
      );
      CREATE TABLE IF NOT EXISTS product_categories (
        id SERIAL PRIMARY KEY,
        name VARCHAR(120) NOT NULL,
        "imageUrl" TEXT, "parentId" INT,
        priority INT DEFAULT 0,
        "isActive" BOOLEAN DEFAULT TRUE,
        "createdAt" TIMESTAMPTZ DEFAULT NOW(),
        "updatedAt" TIMESTAMPTZ DEFAULT NOW(),
        "deletedAt" TIMESTAMPTZ
      );
      CREATE TABLE IF NOT EXISTS product_categories_map (
        "productId" INT NOT NULL,
        "categoryId" INT NOT NULL,
        PRIMARY KEY ("productId","categoryId")
      );
      CREATE TABLE IF NOT EXISTS coupon_categories_map (
        "couponId" VARCHAR(64) NOT NULL,
        "categoryId" INT NOT NULL,
        PRIMARY KEY ("couponId","categoryId")
      );

      CREATE TABLE IF NOT EXISTS product_coupons (
        id SERIAL PRIMARY KEY,
        "productId" INT NOT NULL,
        "couponId" VARCHAR(64) NOT NULL,
        "isPrimary" BOOLEAN DEFAULT FALSE,
        "createdAt" TIMESTAMPTZ DEFAULT NOW()
      );
      CREATE UNIQUE INDEX IF NOT EXISTS ux_product_coupon ON product_coupons("productId","couponId");
      CREATE INDEX IF NOT EXISTS ix_product_coupon_primary ON product_coupons("productId") WHERE "isPrimary" = TRUE;
    `);
    }
    async down(q) {
        await q.query(`DROP TABLE IF EXISTS product_coupons`);
        await q.query(`DROP TABLE IF EXISTS coupon_categories_map`);
        await q.query(`DROP TABLE IF EXISTS product_categories_map`);
        await q.query(`DROP TABLE IF EXISTS coupon_badges`);
        await q.query(`DROP TABLE IF EXISTS product_badges`);
        await q.query(`DROP TABLE IF EXISTS coupon_categories`);
        await q.query(`DROP TABLE IF EXISTS product_categories`);
        await q.query(`DROP TABLE IF EXISTS badges`);
    }
}
exports.Init1710000000000 = Init1710000000000;
