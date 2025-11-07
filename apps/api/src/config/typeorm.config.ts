import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { Category } from '../entities/category.entity';
import { Source } from '../entities/source.entity';
import { Product } from '../entities/product.entity';
import { Coupon } from '../entities/coupon.entity';

export function typeormConfig(): TypeOrmModuleOptions {
  return {
    type: 'postgres',
    host: process.env.DB_HOST,
    port: +(process.env.DB_PORT || 5432),
    database: process.env.DB_NAME,
    username: process.env.DB_USER,
    password: process.env.DB_PASS,
    synchronize: false,  // dùng migration thật khi lên prod
    autoLoadEntities: true,
    entities: [Category, Source, Product, Coupon],
    logging: ['error'],
  };
}
