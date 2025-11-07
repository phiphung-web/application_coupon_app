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
    return this.repo.find({ order: { priority: "DESC", name: "ASC" } });
  }

  async get(id: string) {
    const s = await this.repo.findOne({ where: { id } });
    if (!s) throw new NotFoundException("Source not found");
    return s;
  }

  async create(dto: CreateSourceDto) {
    const exists = await this.repo.findOne({ where: { id: dto.id } });
    if (exists) throw new Error("Source ID already exists");
    const s = this.repo.create(dto);
    return this.repo.save(s);
  }

  async update(id: string, dto: UpdateSourceDto) {
    const s = await this.repo.findOne({ where: { id } });
    if (!s) throw new NotFoundException("Source not found");
    Object.assign(s, dto);
    return this.repo.save(s);
  }

  async remove(id: string) {
    const s = await this.repo.findOne({ where: { id } });
    if (!s) throw new NotFoundException("Source not found");
    await this.repo.softDelete({ id });
    return { ok: true };
  }
}
