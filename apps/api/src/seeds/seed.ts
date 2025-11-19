import "dotenv/config";
import { readFileSync } from "fs";
import { join } from "path";
import dataSource from "../typeorm.config";
import { Source } from "../entities/source.entity";
import { Badge } from "../entities/badge.entity";
import { ItemCategory } from "../entities/item_category.entity";
import { CouponCategory } from "../entities/coupon_category.entity";
import { Item } from "../entities/item.entity";
import { Coupon } from "../entities/coupon.entity";
import { ItemCouponLink } from "../entities/item_coupon_link.entity";
import { User } from "../entities/user.entity";
import { FavoriteItem } from "../entities/favorite_item.entity";
import { FavoriteCoupon } from "../entities/favorite_coupon.entity";
import { FavoriteSource } from "../entities/favorite_source.entity";
import {
  Notification,
  NotificationCategory,
} from "../entities/notification.entity";

function load<T>(file: string): T {
  const p = join(__dirname, file);
  return JSON.parse(readFileSync(p, "utf8"));
}

(async () => {
  if (!dataSource.isInitialized) {
    await dataSource.initialize();
  }
  const ds = dataSource;

  const sourceRepo = ds.getRepository(Source);
  const badgeRepo = ds.getRepository(Badge);
  const itemCategoryRepo = ds.getRepository(ItemCategory);
  const couponCategoryRepo = ds.getRepository(CouponCategory);
  const itemRepo = ds.getRepository(Item);
  const couponRepo = ds.getRepository(Coupon);
  const linkRepo = ds.getRepository(ItemCouponLink);
  const userRepo = ds.getRepository(User);
  const favItemRepo = ds.getRepository(FavoriteItem);
  const favCouponRepo = ds.getRepository(FavoriteCoupon);
  const favSourceRepo = ds.getRepository(FavoriteSource);
  const notificationRepo = ds.getRepository(Notification);

  console.log("🌱 Starting seed...");

  const sourceMap = new Map<string, Source>();
  for (const s of load<any[]>("./sources.json")) {
    const entity = sourceRepo.create(s as Partial<Source>);
    const saved = await sourceRepo.save(entity);
    sourceMap.set(s.name, saved);
  }

  const badgeMap = new Map<string, Badge>();
  for (const b of load<any[]>("./badges.json")) {
    const entity = badgeRepo.create(b as Partial<Badge>);
    const saved = await badgeRepo.save(entity);
    if (b.slug) badgeMap.set(b.slug, saved);
    badgeMap.set(b.name, saved);
  }

  const itemCategoryMap = new Map<string, ItemCategory>();
  for (const c of load<any[]>("./item_categories.json")) {
    const entity = itemCategoryRepo.create(c as Partial<ItemCategory>);
    const saved = await itemCategoryRepo.save(entity);
    itemCategoryMap.set(c.name, saved);
  }

  const couponCategoryMap = new Map<string, CouponCategory>();
  for (const c of load<any[]>("./coupon_categories.json")) {
    const entity = couponCategoryRepo.create(c as Partial<CouponCategory>);
    const saved = await couponCategoryRepo.save(entity);
    couponCategoryMap.set(c.name, saved);
  }

  const itemMap = new Map<string, Item>();
  for (const item of load<any[]>("./items.json")) {
    const entity = itemRepo.create({
      name: item.name,
      description: item.description,
      imageUrl: item.imageUrl,
      itemType: item.itemType,
      itemUrl: item.itemUrl,
      price: item.price != null ? String(item.price) : undefined,
      sourceId: sourceMap.get(item.source)?.id,
      categoryId: itemCategoryMap.get(item.category)?.id,
      badgeId: item.badge ? badgeMap.get(item.badge)?.id : undefined,
    } as Partial<Item>);
    const saved = await itemRepo.save(entity);
    itemMap.set(item.name, saved);
  }

  const couponMap = new Map<string, Coupon>();
  for (const c of load<any[]>("./coupons.json")) {
    const entity = couponRepo.create({
      code: c.code,
      description: c.description,
      imageUrl: c.imageUrl,
      discountType: c.discountType,
      discountValue:
        c.discountValue != null ? String(c.discountValue) : undefined,
      dealUrl: c.dealUrl,
      sourceId: sourceMap.get(c.source)?.id,
      categoryId: couponCategoryMap.get(c.category)?.id,
      badgeId: c.badge ? badgeMap.get(c.badge)?.id : undefined,
      startDate: c.startDate ? new Date(c.startDate) : undefined,
      endDate: c.endDate ? new Date(c.endDate) : undefined,
    } as Partial<Coupon>);
    const saved = await couponRepo.save(entity);
    couponMap.set(c.code, saved);
  }

  for (const link of load<any[]>("./item_coupon_links.json")) {
    const item = itemMap.get(link.item);
    const coupon = couponMap.get(link.coupon);
    if (!item || !coupon) continue;
    await linkRepo.save(
      linkRepo.create({
        itemId: item.id,
        couponId: coupon.id,
        isPrimaryDisplay: !!link.isPrimaryDisplay,
      })
    );
  }

  const userMap = new Map<string, User>();
  for (const u of load<any[]>("./users.json")) {
    const entity = await userRepo.save(
      userRepo.create({
        username: u.username,
        imageUrl: u.imageUrl,
        email: u.email,
        passwordHash: u.password,
        role: u.role,
      })
    );
    userMap.set(u.email, entity);
  }

  for (const fav of load<any[]>("./favorite_items.json")) {
    const user = userMap.get(fav.userEmail);
    const item = itemMap.get(fav.item);
    if (!user || !item) continue;
    await favItemRepo.save(
      favItemRepo.create({ userId: user.id, itemId: item.id })
    );
  }

  for (const fav of load<any[]>("./favorite_coupons.json")) {
    const user = userMap.get(fav.userEmail);
    const coupon = couponMap.get(fav.coupon);
    if (!user || !coupon) continue;
    await favCouponRepo.save(
      favCouponRepo.create({ userId: user.id, couponId: coupon.id })
    );
  }

  for (const fav of load<any[]>("./favorite_sources.json")) {
    const user = userMap.get(fav.userEmail);
    const source = sourceMap.get(fav.source);
    if (!user || !source) continue;
    await favSourceRepo.save(
      favSourceRepo.create({ userId: user.id, sourceId: source.id })
    );
  }

    for (const raw of load<any[]>("./notifications.json")) {
    await notificationRepo.save(
      notificationRepo.create({
        title: raw.title,
        message: raw.message,
        category:
          (raw.category as NotificationCategory) ?? NotificationCategory.SYSTEM,
        importance: raw.importance ?? 0,
        tags: raw.tags,
        sourceId: raw.source ? sourceMap.get(raw.source)?.id : undefined,
        itemId: raw.item ? itemMap.get(raw.item)?.id : undefined,
        couponId: raw.coupon ? couponMap.get(raw.coupon)?.id : undefined,
      })
    );
  }

  console.log("🌱 Starting seed...");

  const sourceMap = new Map<string, Source>();
  for (const s of load<any[]>("./sources.json")) {
    const entity = sourceRepo.create(s as Partial<Source>);
    const saved = await sourceRepo.save(entity);
    sourceMap.set(s.name, saved);
  }

  const badgeMap = new Map<string, Badge>();
  for (const b of load<any[]>("./badges.json")) {
    const entity = badgeRepo.create(b as Partial<Badge>);
    const saved = await badgeRepo.save(entity);
    if (b.slug) badgeMap.set(b.slug, saved);
    badgeMap.set(b.name, saved);
  }

  const itemCategoryMap = new Map<string, ItemCategory>();
  for (const c of load<any[]>("./item_categories.json")) {
    const entity = itemCategoryRepo.create(c as Partial<ItemCategory>);
    const saved = await itemCategoryRepo.save(entity);
    itemCategoryMap.set(c.name, saved);
  }

  const couponCategoryMap = new Map<string, CouponCategory>();
  for (const c of load<any[]>("./coupon_categories.json")) {
    const entity = couponCategoryRepo.create(c as Partial<CouponCategory>);
    const saved = await couponCategoryRepo.save(entity);
    couponCategoryMap.set(c.name, saved);
  }

  const itemMap = new Map<string, Item>();
  for (const item of load<any[]>("./items.json")) {
    const entity = itemRepo.create({
      name: item.name,
      description: item.description,
      imageUrl: item.imageUrl,
      itemType: item.itemType,
      itemUrl: item.itemUrl,
      price: item.price != null ? String(item.price) : undefined,
      sourceId: sourceMap.get(item.source)?.id,
      categoryId: itemCategoryMap.get(item.category)?.id,
      badgeId: item.badge ? badgeMap.get(item.badge)?.id : undefined,
    } as Partial<Item>);
    const saved = await itemRepo.save(entity);
    itemMap.set(item.name, saved);
  }

  const couponMap = new Map<string, Coupon>();
  for (const c of load<any[]>("./coupons.json")) {
    const entity = couponRepo.create({
      code: c.code,
      description: c.description,
      imageUrl: c.imageUrl,
      discountType: c.discountType,
      discountValue:
        c.discountValue != null ? String(c.discountValue) : undefined,
      dealUrl: c.dealUrl,
      sourceId: sourceMap.get(c.source)?.id,
      categoryId: couponCategoryMap.get(c.category)?.id,
      badgeId: c.badge ? badgeMap.get(c.badge)?.id : undefined,
      startDate: c.startDate ? new Date(c.startDate) : undefined,
      endDate: c.endDate ? new Date(c.endDate) : undefined,
    } as Partial<Coupon>);
    const saved = await couponRepo.save(entity);
    couponMap.set(c.code, saved);
  }

  for (const link of load<any[]>("./item_coupon_links.json")) {
    const item = itemMap.get(link.item);
    const coupon = couponMap.get(link.coupon);
    if (!item || !coupon) continue;
    await linkRepo.save(
      linkRepo.create({
        itemId: item.id,
        couponId: coupon.id,
        isPrimaryDisplay: !!link.isPrimaryDisplay,
      })
    );
  }

  const userMap = new Map<string, User>();
  for (const u of load<any[]>("./users.json")) {
    const entity = await userRepo.save(
      userRepo.create({
        username: u.username,
        imageUrl: u.imageUrl,
        email: u.email,
        passwordHash: u.password,
        role: u.role,
      })
    );
    userMap.set(u.email, entity);
  }

  for (const fav of load<any[]>("./favorite_items.json")) {
    const user = userMap.get(fav.userEmail);
    const item = itemMap.get(fav.item);
    if (!user || !item) continue;
    await favItemRepo.save(
      favItemRepo.create({ userId: user.id, itemId: item.id })
    );
  }

  for (const fav of load<any[]>("./favorite_coupons.json")) {
    const user = userMap.get(fav.userEmail);
    const coupon = couponMap.get(fav.coupon);
    if (!user || !coupon) continue;
    await favCouponRepo.save(
      favCouponRepo.create({ userId: user.id, couponId: coupon.id })
    );
  }

  for (const fav of load<any[]>("./favorite_sources.json")) {
    const user = userMap.get(fav.userEmail);
    const source = sourceMap.get(fav.source);
    if (!user || !source) continue;
    await favSourceRepo.save(
      favSourceRepo.create({ userId: user.id, sourceId: source.id })
    );
  }


  console.log("✅ Seed done");

  if (ds.isInitialized) {
    await ds.destroy();
  }
})().catch((e) => {
  console.error("❌ Seed failed:", e);
  process.exit(1);
});
