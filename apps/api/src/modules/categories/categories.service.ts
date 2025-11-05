import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ILike, Repository } from 'typeorm';
import { Category } from '../../entities/category.entity';
import { CreateCategoryDto, QueryCategoriesDto, UpdateCategoryDto } from './dto';

@Injectable()
export class CategoriesService {
  constructor(@InjectRepository(Category) private repo: Repository<Category>) {}

  create(dto: CreateCategoryDto) { return this.repo.save(this.repo.create(dto)); }
  async update(id: number, dto: UpdateCategoryDto) { await this.repo.update(id, dto); return this.repo.findOneBy({ id }); }
  async remove(id: number) { await this.repo.delete(id); return { ok: true }; }
  getById(id: number) { return this.repo.findOneBy({ id }); }

  async list(q: QueryCategoriesDto) {
    const { page = 1, pageSize = 50, q: text } = q;
    const where: any = {};
    if (text) where.name = ILike(`%${text}%`);
    const [data, total] = await this.repo.findAndCount({
      where, order: { priority: 'DESC', id: 'ASC' },
      take: pageSize, skip: (page - 1) * pageSize,
    });
    return { data, total, page, pageSize, hasMore: page * pageSize < total };
  }

  async top(limit = 20) {
    return this.repo.find({ where: { isActive: true }, order: { priority: 'DESC' }, take: limit });
  }
}
