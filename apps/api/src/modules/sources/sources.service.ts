import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Source } from "../../entities/source.entity";
import { CreateSourceDto, UpdateSourceDto } from "./dto";

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
    const s = this.repo.create(dto);
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
}
