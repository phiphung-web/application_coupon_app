import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Category } from "../../entities/category.entity";
import { CategoryQueryDto, CreateCategoryDto, UpdateCategoryDto } from "./dto";

@Injectable()
export class CategoriesService {
  constructor(
    @InjectRepository(Category) private readonly repo: Repository<Category>
  ) {}

  async paginate(q: CategoryQueryDto) {
    const qb = this.repo.createQueryBuilder("c");

    if (q.q) qb.andWhere("c.name ILIKE :q", { q: `%${q.q}%` });
    if (q.parentId !== undefined) {
      if (q.parentId === 0) qb.andWhere("c.parentId IS NULL");
      else qb.andWhere("c.parentId = :pid", { pid: q.parentId });
    }

    qb.orderBy("c.id", "DESC");

    const page = q.page ?? 1;
    const limit = q.limit ?? 20;
    qb.skip((page - 1) * limit).take(limit);

    const [items, total] = await qb.getManyAndCount();
    return { items, meta: { page, limit, total } };
  }

  async listAll() {
    return this.repo.find({ order: { id: "DESC" } });
  }

  async get(id: number) {
    const category = await this.repo.findOne({ where: { id } });
    if (!category) throw new NotFoundException("Category not found");
    return category;
  }

  async create(dto: CreateCategoryDto) {
    const entity = this.repo.create({
      name: dto.name,
      imageUrl: dto.imageUrl,
      parentId: dto.parentId,
    });
    return this.repo.save(entity);
  }

  async update(id: number, dto: UpdateCategoryDto) {
    const category = await this.get(id);
    Object.assign(category, dto);
    return this.repo.save(category);
  }

  async remove(id: number) {
    const category = await this.get(id);
    await this.repo.remove(category);
    return { ok: true };
  }

  async highlights(limit = 10) {
    const qb = this.repo
      .createQueryBuilder("c")
      .leftJoin("c.items", "items")
      .select("c")
      .addSelect("COUNT(items.id)", "item_count")
      .groupBy("c.id")
      .orderBy("COUNT(items.id)", "DESC")
      .limit(limit);
    const rows = await qb.getRawAndEntities();
    return rows.entities.map((entity, idx) => ({
      ...entity,
      itemCount: Number(rows.raw[idx].item_count ?? 0),
    }));
  }

  async tree() {
    const rows = await this.listAll();
    const byParent = new Map<number | null, Category[]>();
    for (const r of rows) {
      const k = r.parentId ?? null;
      if (!byParent.has(k)) byParent.set(k, []);
      byParent.get(k)!.push(r);
    }
    const build = (pid: number | null): any[] =>
      (byParent.get(pid) ?? []).map((node) => ({
        ...node,
        children: build(node.id),
      }));
    return build(null);
  }

  async breadcrumbs(id: number) {
    const path: Category[] = [];
    let cur: Category | null = await this.repo.findOne({ where: { id } });
    while (cur) {
      path.unshift(cur);
      cur = cur.parentId
        ? await this.repo.findOne({ where: { id: cur.parentId } })
        : null;
    }
    return path;
  }
}
