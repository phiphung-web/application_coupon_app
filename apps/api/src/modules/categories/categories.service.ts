import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository, IsNull } from "typeorm";
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
    if (q.active !== undefined) qb.andWhere("c.isActive = :a", { a: q.active });
    if (q.parentId !== undefined) {
      if (q.parentId === 0) qb.andWhere("c.parentId IS NULL");
      else qb.andWhere("c.parentId = :pid", { pid: q.parentId });
    }

    // sort: priority desc, name asc
    qb.orderBy("c.priority", "DESC").addOrderBy("c.name", "ASC");

    const page = q.page ?? 1,
      limit = q.limit ?? 20;
    qb.skip((page - 1) * limit).take(limit);

    const [items, total] = await qb.getManyAndCount();
    return { items, meta: { page, limit, total } };
  }

  async listAll(activeOnly = false) {
    return this.repo.find({
      where: activeOnly ? { isActive: true } : {},
      order: { priority: "DESC", name: "ASC" },
    });
  }

  async get(id: number) {
    const c = await this.repo.findOne({ where: { id } });
    if (!c) throw new NotFoundException("Category not found");
    return c;
  }

  async create(dto: CreateCategoryDto) {
    const c = this.repo.create({
      name: dto.name,
      imageUrl: dto.imageUrl,
      parentId: dto.parentId,
      priority: dto.priority ?? 0,
      isActive: dto.isActive ?? true,
    });
    return this.repo.save(c);
  }

  async update(id: number, dto: UpdateCategoryDto) {
    const c = await this.get(id);
    Object.assign(c, dto);
    return this.repo.save(c);
  }

  async remove(id: number) {
    const c = await this.get(id);
    await this.repo.remove(c);
    return { ok: true };
  }

  async tree(activeOnly = false) {
    const rows = await this.listAll(activeOnly);
    const byParent = new Map<number | null, Category[]>();
    for (const r of rows) {
      const k = r.parentId ?? null;
      if (!byParent.has(k)) byParent.set(k, []);
      byParent.get(k)!.push(r);
    }
    const build = (pid: number | null): any[] =>
      (byParent.get(pid) ?? []).map((n) => ({
        ...n,
        children: build(n.id),
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
