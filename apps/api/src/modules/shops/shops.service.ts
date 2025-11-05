import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ILike, Repository } from 'typeorm';
import { Shop } from '../../entities/shop.entity';
import { CreateShopDto, UpdateShopDto } from './dto';

@Injectable()
export class ShopsService {
  constructor(@InjectRepository(Shop) private repo: Repository<Shop>) {}

  create(dto: CreateShopDto) { return this.repo.save(this.repo.create(dto)); }
  async update(id: string, dto: UpdateShopDto) { await this.repo.update({ id }, dto); return this.repo.findOneBy({ id }); }
  async remove(id: string) { await this.repo.delete({ id }); return { ok: true }; }
  getById(id: string) { return this.repo.findOneBy({ id }); }

  async list(q?: { q?: string }) {
    const where: any = {};
    if (q?.q) where.name = ILike(`%${q.q}%`);
    return this.repo.find({ where, order: { priority: 'DESC' } });
  }
}
