import { DataSource } from 'typeorm';
import { Product } from './entities/product.entity';
import { Coupon } from './entities/coupon.entity';
import { Category } from './entities/category.entity';
import { Shop } from './entities/shop.entity';

export const AppDataSource = new DataSource({
  type: 'sqlite',
  database: 'app.sqlite',
  synchronize: true, // dev only
  entities: [Product, Coupon, Category, Shop],
  logging: false,
});
