import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ILike, Repository } from 'typeorm';
import { Product } from '../../entities/product.entity';
import { CreateProductDto, QueryProductsDto, UpdateProductDto } from './dto';

@Injectable()
export class ProductsService {
  constructor(@InjectRepository(Product) private repo: Repository<Product>) {}

  async create(dto: CreateProductDto) {
    const p = this.repo.create(dto);
    if (!p.discountPercent && p.originalPrice && p.originalPrice > p.basePrice) {
      p.discountPercent = Math.round(100 - (p.basePrice * 100) / p.originalPrice);
    }
    return this.repo.save(p);
  }

  async update(id: number, dto: UpdateProductDto) {
    await this.repo.update(id, dto);
    return this.repo.findOneBy({ id });
  }

  async remove(id: number) { await this.repo.delete(id); return { ok: true }; }
  findById(id: number) { return this.repo.findOne({ where: { id } }); }

  hot(limit = 20) { return this.repo.find({ where: { isHot: true }, order: { id: 'DESC' }, take: limit }); }

  async list(q: QueryProductsDto) {
    const { page = 1, pageSize = 20, categoryId, q: text, sort, shopId } = q;
    const where: any = {};
    if (categoryId) where.categoryId = categoryId;
    if (shopId) where.shopId = shopId;
    if (text) where.name = ILike(`%${text}%`);

    const order: any = {};
    switch (sort) {
      case 'priceAsc': order.basePrice = 'ASC'; break;
      case 'priceDesc': order.basePrice = 'DESC'; break;
      case 'discountDesc': order.discountPercent = 'DESC'; break;
      case 'hot': order.isHot = 'DESC'; order.id = 'DESC'; break;
      default: order.id = 'DESC';
    }

    const [data, total] = await this.repo.findAndCount({
      where, order, take: pageSize, skip: (page - 1) * pageSize,
    });
    return { data, total, page, pageSize, hasMore: page * pageSize < total };
  }
}
