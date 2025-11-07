import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { CouponCategory } from "../../entities/coupon_category.entity";

@Injectable()
export class CouponCategoriesService {
  constructor(
    @InjectRepository(CouponCategory)
    private readonly repo: Repository<CouponCategory>
  ) {}

  list() {
    return this.repo.find({
      where: { isActive: true },
      order: { priority: "DESC" },
    });
  }
  get(id: number) {
    return this.repo.findOneByOrFail({ id });
  }
  async create(data: Partial<CouponCategory>) {
    return this.repo.save(this.repo.create(data));
  }
  async update(id: number, data: Partial<CouponCategory>) {
    const c = await this.repo.findOneBy({ id });
    if (!c) throw new NotFoundException();
    Object.assign(c, data);
    return this.repo.save(c);
  }
  async remove(id: number) {
    await this.repo.softDelete({ id });
    return { ok: true };
  }
}
