import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, FindOptionsWhere } from 'typeorm';
import { Source } from '../../entities/source.entity';
import { CreateSourceDto, ListSourceDto, UpdateSourceDto } from './dto';

@Injectable()
export class SourcesService {
  constructor(@InjectRepository(Source) private repo: Repository<Source>) {}

  async list(q: ListSourceDto) {
    const { page=1, pageSize=20, q: keyword, type, isActive } = q;
    const where: FindOptionsWhere<Source> = {};
    if (type) (where as any).type = type;
    if (isActive !== undefined) where.isActive = isActive;
    if (keyword) (where as any).name = () => `ILIKE '%${keyword}%'`;

    const [items, total] = await this.repo.findAndCount({
      where, order: { priority: 'DESC', id: 'ASC' },
      skip: (page-1)*pageSize, take: pageSize,
    });
    return { items, total, page, pageSize };
  }

  get(id: string) { return this.repo.findOne({ where: { id } }); }
  create(dto: CreateSourceDto) { return this.repo.save(this.repo.create(dto)); }
  async update(id: string, dto: UpdateSourceDto) {
    await this.repo.update({ id }, dto); return this.get(id);
  }
  async remove(id: string) { await this.repo.delete({ id }); return { ok: true }; }
}
