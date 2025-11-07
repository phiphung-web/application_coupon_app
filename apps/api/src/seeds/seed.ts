import "reflect-metadata";
import { DataSource } from "typeorm";
import { Category } from "../entities/category.entity";
import { Source } from "../entities/source.entity";
import { Product } from "../entities/product.entity";
import { Coupon } from "../entities/coupon.entity";
import * as fs from "fs";
import * as path from "path";

const ds = new DataSource({
  type: "postgres",
  host: process.env.DB_HOST,
  port: +(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME,
  username: process.env.DB_USER,
  password: process.env.DB_PASS,
  entities: [Category, Source, Product, Coupon],
  synchronize: true, // chỉ dùng cho seed/dev
  logging: false,
});

// ---- helper: đọc JSON sync (KHÔNG async) ----
function loadJsonSync<T = any>(name: string): T {
  const p = path.join(__dirname, name);
  const raw = fs.readFileSync(p, "utf8");
  return JSON.parse(raw) as T;
}

async function run() {
  await ds.initialize();

  const catRepo = ds.getRepository(Category);
  const srcRepo = ds.getRepository(Source);
  const prodRepo = ds.getRepository(Product);
  const coupRepo = ds.getRepository(Coupon);

  // Xóa dữ liệu theo thứ tự khóa ngoại
  await coupRepo.delete({});
  await prodRepo.delete({});
  await srcRepo.delete({});
  await catRepo.delete({});

  // ---- nạp JSON ----
  const catJson = loadJsonSync<any[]>("categories.json");
  const srcJson = loadJsonSync<any[]>("sources.json");
  const prodJson = loadJsonSync<any[]>("products.json");
  const coupJson = loadJsonSync<any[]>("coupons.json");

  // ---- save categories & sources ----
  await catRepo.save(catJson);
  await srcRepo.save(srcJson);

  // ---- chuẩn hóa products (tính discountPercent nếu thiếu) ----
  const products = prodJson.map((p) => ({
    ...p,
    discountPercent:
      p.discountPercent ??
      (p.originalPrice && p.originalPrice > p.basePrice
        ? Math.round(100 - (p.basePrice * 100) / p.originalPrice)
        : null),
  }));

  await prodRepo.save(products);

  // ---- chuẩn hóa coupons (convert expiredAt nếu có) ----
  const coupons = coupJson.map((c) => ({
    ...c,
    expiredAt: c.expiredAt ? new Date(c.expiredAt) : null,
  }));

  await coupRepo.save(coupons);

  console.log("Seed done.");
  await ds.destroy();
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
