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
    return this.repo.find({ order: { id: "DESC" } });
  }

  get(id: number) {
    return this.repo.findOneByOrFail({ id });
  }

  async create(data: Partial<Badge>) {
    return this.repo.save(this.repo.create(data));
  }

  async update(id: number, data: Partial<Badge>) {
    const badge = await this.repo.findOneBy({ id });
    if (!badge) throw new NotFoundException();
    Object.assign(badge, data);
    return this.repo.save(badge);
  }

  async remove(id: number) {
    await this.repo.delete({ id });
    return { ok: true };
  }
}
