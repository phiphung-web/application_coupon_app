import { AppDataSource } from "./typeorm.config";
import { Category } from "./entities/category.entity";
import { Shop } from "./entities/shop.entity";
import { Product } from "./entities/product.entity";
import { Coupon } from "./entities/coupon.entity";

async function seed() {
  const ds = await AppDataSource.initialize();

  const catRepo = ds.getRepository(Category);
  const shopRepo = ds.getRepository(Shop);
  const productRepo = ds.getRepository(Product);
  const couponRepo = ds.getRepository(Coupon);

  if ((await catRepo.count()) === 0) {
    await catRepo.save([
      {
        name: "Điện tử",
        priority: 10,
        imageUrl: "https://picsum.photos/seed/cat1/600/400",
        isActive: true,
      },
      {
        name: "Thời trang",
        priority: 9,
        imageUrl: "https://picsum.photos/seed/cat2/600/400",
        isActive: true,
      },
      {
        name: "Gia dụng",
        priority: 8,
        imageUrl: "https://picsum.photos/seed/cat3/600/400",
        isActive: true,
      },
      {
        name: "Mẹ & Bé",
        priority: 7,
        imageUrl: "https://picsum.photos/seed/cat4/600/400",
        isActive: true,
      },
      {
        name: "Sách",
        priority: 6,
        imageUrl: "https://picsum.photos/seed/cat5/600/400",
        isActive: true,
      },
      {
        name: "Thể thao",
        priority: 5,
        imageUrl: "https://picsum.photos/seed/cat6/600/400",
        isActive: true,
      },
    ]);
  }

  if ((await shopRepo.count()) === 0) {
    await shopRepo.save([
      {
        id: "shopee",
        name: "Shopee",
        logoUrl: "https://.../shopee.png",
        domain: "shopee.vn",
        priority: 10,
        isActive: true,
      },
      {
        id: "lazada",
        name: "Lazada",
        logoUrl: "https://.../lazada.png",
        domain: "lazada.vn",
        priority: 9,
        isActive: true,
      },
      {
        id: "tiki",
        name: "Tiki",
        logoUrl: "https://.../tiki.png",
        domain: "tiki.vn",
        priority: 8,
        isActive: true,
      },
    ]);
  }

  if ((await productRepo.count()) === 0) {
    const cats = await catRepo.find();
    const shops = await shopRepo.find();
    const rand = (min: number, max: number) =>
      Math.floor(min + Math.random() * (max - min + 1));

    const list: Product[] = [];
    for (let i = 1; i <= 48; i++) {
      const base = 99000 + rand(0, 400000);
      const original = base + Math.floor((base * rand(10, 35)) / 100);
      const pct = Math.round(100 - (base * 100) / original);
      const cat = cats[i % cats.length];
      const shop = shops[i % shops.length];

      list.push(
        productRepo.create({
          name: `Sản phẩm #${i}`,
          imageUrl: `https://picsum.photos/seed/p${i}/600/400`,
          basePrice: base,
          originalPrice: original,
          discountPercent: pct,
          categoryId: cat.id,
          shopId: shop.id,
          isHot: i % 4 === 0,
          description: "Mô tả demo sản phẩm...",
        })
      );
    }
    await productRepo.save(list);
  }

  if ((await couponRepo.count()) === 0) {
    const cats = await catRepo.find();
    const shops = await shopRepo.find();

    const list: Coupon[] = [];
    for (let i = 1; i <= 60; i++) {
      const isPercent = i % 2 === 0;
      const cat = cats[i % cats.length];
      const shop = shops[i % shops.length];

      list.push(
        couponRepo.create({
          id: `c${i}`,
          title: isPercent
            ? `Giảm ${10 + (i % 5) * 5}% toàn sàn`
            : `Giảm ${20000 + (i % 5) * 30000}đ`,
          code: `CODE${1000 + i}`,
          discountType: isPercent ? "PERCENT" : "FIXED",
          discountValue: isPercent ? 10 + (i % 5) * 5 : 20000 + (i % 5) * 30000,
          minSpend: i % 3 === 0 ? 150000 : undefined,
          maxDiscount: isPercent ? 100000 : undefined,
          expiredAt: new Date(Date.now() + i * 86400000),
          categoryId: cat.id,
          applicableTypes: ["general"],
          shopId: shop.id,
          imageUrl: `https://picsum.photos/seed/c${i}/600/400`,
          tags: i % 4 === 0 ? ["hot"] : [],
          priority: i % 4 === 0 ? 90 : 50,
          trackingLink: "https://example.com/track",
          deeplink: "https://example.com/deeplink",
          isActive: true,
        })
      );
    }
    await couponRepo.save(list);
  }

  console.log("Seed done.");
  await ds.destroy();
}

seed().catch((e) => {
  console.error(e);
  process.exit(1);
});
