// src/seeds/seed.ts
import "dotenv/config";
import { DataSource } from "typeorm";
import dataSource from "../typeorm.config";
import { readFileSync } from "fs";
import { join } from "path";
import { Source } from "../entities/source.entity";
import { Badge } from "../entities/badge.entity";
import { Category } from "../entities/category.entity";
import { CouponCategory } from "../entities/coupon_category.entity";
import { Coupon } from "../entities/coupon.entity";
import { Product } from "../entities/product.entity";
import { ProductCoupon } from "../entities/product_coupon.entity";

function load<T>(file: string): T {
  const p = join(__dirname, file);
  return JSON.parse(readFileSync(p, "utf8"));
}

(async () => {
  // --- SỬA LỖI TẠI ĐÂY ---
  // Kiểm tra: Nếu chưa kết nối thì mới khởi tạo, ngược lại dùng luôn cái đã có.
  if (!dataSource.isInitialized) {
    await dataSource.initialize();
  }
  const ds = dataSource;
  // -----------------------

  const sourceRepo = ds.getRepository(Source);
  const badgeRepo = ds.getRepository(Badge);
  const pCatRepo = ds.getRepository(Category);
  const cCatRepo = ds.getRepository(CouponCategory);
  const couponRepo = ds.getRepository(Coupon);
  const prodRepo = ds.getRepository(Product);
  const pcRepo = ds.getRepository(ProductCoupon);

  console.log("🌱 Starting seed...");

  // sources
  for (const s of load<any[]>("./sources.json")) {
    await sourceRepo.save(sourceRepo.create(s));
  }

  // badges
  for (const b of load<any[]>("./badges.json")) {
    await badgeRepo.save(badgeRepo.create(b));
  }

  // product categories
  for (const c of load<any[]>("./product_categories.json")) {
    await pCatRepo.save(pCatRepo.create(c));
  }

  // coupon categories
  for (const c of load<any[]>("./coupon_categories.json")) {
    await cCatRepo.save(cCatRepo.create(c));
  }

  // coupons
  for (const c of load<any[]>("./coupons.json")) {
    await couponRepo.save(
      couponRepo.create({
        ...c,
        endAt: c.endAt ? new Date(c.endAt) : null,
      })
    );
  }

  // products + attach categories/badges by name/key
  const badges = await badgeRepo.find();
  const cats = await pCatRepo.find();

  for (const p of load<any[]>("./products.json")) {
    const attachBadges = badges.filter((b) =>
      (p.badgeKeys ?? []).includes(b.key)
    );
    const attachCats = cats.filter((c) =>
      (p.categoryNames ?? []).includes(c.name)
    );

    const prod = prodRepo.create({
      name: p.name,
      imageUrl: p.imageUrl,
      priceOriginal: p.priceOriginal,
      priceCurrent: p.priceCurrent,
      currency: p.currency ?? "USD",
      sourceId: p.sourceId,
      categories: attachCats,
      badges: attachBadges,
      description: p.description,
    });
    await prodRepo.save(prod);
  }

  // link product_coupons
  const allProducts = await prodRepo.find();
  for (const link of load<any[]>("./product_coupons.json")) {
    const prod = allProducts.find((x) => x.name === link.productName);
    if (!prod) continue;
    await pcRepo.save(
      pcRepo.create({
        productId: prod.id,
        couponId: link.couponId,
        isPrimary: !!link.isPrimary,
      })
    );
  }

  console.log("✅ Seed done");
  
  // Ngắt kết nối an toàn
  if (ds.isInitialized) {
    await ds.destroy();
  }
})().catch((e) => {
  console.error("❌ Seed failed:", e);
  process.exit(1);
});