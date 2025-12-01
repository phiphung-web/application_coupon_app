import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Source } from "../../entities/source.entity";
import {
  CreateSourceDto,
  SourceHighlightQueryDto,
  UpdateSourceDto,
} from "./dto";

@Injectable()
export class SourcesService {
  constructor(
    @InjectRepository(Source) private readonly repo: Repository<Source>
  ) {}

  async list() {
    return this.repo.find({ order: { name: "ASC" } });
  }

  async get(id: number) {
    const s = await this.repo.findOne({ where: { id } });
    if (!s) throw new NotFoundException("Source not found");
    return s;
  }

  async create(dto: CreateSourceDto) {
    const s = this.repo.create(dto as Source);
    return this.repo.save(s);
  }

  async update(id: number, dto: UpdateSourceDto) {
    const s = await this.repo.findOne({ where: { id } });
    if (!s) throw new NotFoundException("Source not found");
    Object.assign(s, dto);
    return this.repo.save(s);
  }

  async remove(id: number) {
    const s = await this.repo.findOne({ where: { id } });
    if (!s) throw new NotFoundException("Source not found");
    await this.repo.delete({ id });
    return { ok: true };
  }

  async highlights(q: SourceHighlightQueryDto) {
    const limit = Math.min(q.limit ?? 12, 50);
    const qb = this.repo
      .createQueryBuilder("s")
      .leftJoin("s.items", "items")
      .leftJoin("s.coupons", "coupons")
      .select("s")
      .addSelect("COUNT(DISTINCT items.id)", "item_count")
      .addSelect("COUNT(DISTINCT coupons.id)", "coupon_count");
    if (q.type) {
      qb.where("s.type = :type", { type: q.type });
    }
    qb.groupBy("s.id")
      .orderBy("s.priority", "DESC")
      .addOrderBy("COUNT(DISTINCT coupons.id)", "DESC")
      .limit(limit);
    const rows = await qb.getRawAndEntities();
    return rows.entities.map((entity, idx) => ({
      ...entity,
      itemCount: Number(rows.raw[idx].item_count ?? 0),
      couponCount: Number(rows.raw[idx].coupon_count ?? 0),
    }));
  }
}
