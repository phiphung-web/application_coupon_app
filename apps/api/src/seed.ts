import { DataSource } from "typeorm";
import { Coupon } from "./entities/coupon.entity";
import { Shop } from "./entities/shop.entity";
import { Category } from "./entities/category.entity";

const ds = new DataSource({
  type: "sqlite",
  database: "data.sqlite",
  entities: [Coupon, Shop, Category],
  synchronize: true,
});

async function run() {
  await ds.initialize();
  const shopRepo = ds.getRepository(Shop);
  const catRepo = ds.getRepository(Category);
  const couponRepo = ds.getRepository(Coupon);

  const shopee = shopRepo.create({ slug: "shopee", name: "Shopee" });
  const lazada = shopRepo.create({ slug: "lazada", name: "Lazada" });
  await shopRepo.save([shopee, lazada]);

  const fashion = catRepo.create({ key: "fashion", label: "Thời trang" });
  const tech = catRepo.create({ key: "tech", label: "Công nghệ" });
  await catRepo.save([fashion, tech]);

  const now = new Date();
  const plus = (d: number) => new Date(now.getTime() + d * 86400000);
  await couponRepo.save([
    couponRepo.create({
      title: "Giảm 100k đơn 500k",
      code: "SAVE100",
      startAt: now,
      endAt: plus(7),
      shop: shopee,
      category: fashion,
    }),
    couponRepo.create({
      title: "Giảm 10% tối đa 200k",
      code: "TENOFF",
      startAt: now,
      endAt: plus(3),
      shop: lazada,
      category: tech,
    }),
  ]);

  console.log("Seeded!");
  await ds.destroy();
}
run();
