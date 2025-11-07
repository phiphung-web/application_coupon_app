import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, FindOptionsWhere } from 'typeorm';
import { Category } from '../../entities/category.entity';
import { CreateCategoryDto, ListCategoryDto, UpdateCategoryDto } from './dto';

@Injectable()
export class CategoriesService {
  constructor(@InjectRepository(Category) private repo: Repository<Category>) {}

  async list(q: ListCategoryDto) {
    const { page=1, pageSize=20, q: keyword, isActive } = q;
    const where: FindOptionsWhere<Category> = {};
    if (isActive !== undefined) where.isActive = isActive;
    if (keyword) (where as any).name = () => `ILIKE '%${keyword}%'`;

    const [items, total] = await this.repo.findAndCount({
      where, order: { priority: 'DESC', id: 'ASC' },
      skip: (page-1)*pageSize, take: pageSize,
    });
    return { items, total, page, pageSize };
  }

  get(id: number) { return this.repo.findOne({ where: { id } }); }
  create(dto: CreateCategoryDto) { return this.repo.save(this.repo.create(dto)); }
  async update(id: number, dto: UpdateCategoryDto) {
    await this.repo.update({ id }, dto); return this.get(id);
  }
  async remove(id: number) { await this.repo.delete({ id }); return { ok: true }; }
}
