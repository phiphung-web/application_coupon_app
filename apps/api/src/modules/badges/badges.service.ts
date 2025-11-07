import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Badge } from "../../entities/badge.entity";

@Injectable()
export class BadgesService {
  constructor(
    @InjectRepository(Badge) private readonly repo: Repository<Badge>
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
  async create(data: Partial<Badge>) {
    return this.repo.save(this.repo.create(data));
  }
  async update(id: number, data: Partial<Badge>) {
    const b = await this.repo.findOneBy({ id });
    if (!b) throw new NotFoundException();
    Object.assign(b, data);
    return this.repo.save(b);
  }
  async remove(id: number) {
    await this.repo.softDelete({ id });
    return { ok: true };
  }
}
