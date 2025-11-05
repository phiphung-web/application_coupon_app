import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProductsModule } from './products/products.module';
import { CouponsModule } from './coupons/coupons.module';
import { CategoriesModule } from './categories/categories.module';
import { ShopsModule } from './shops/shops.module';
import { AppDataSource } from '../typeorm.config';

@Module({
  imports: [
    TypeOrmModule.forRoot(AppDataSource.options),
    CategoriesModule,
    ShopsModule,
    ProductsModule,
    CouponsModule,
  ],
})
export class AppModule {}
