"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CategoriesService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const category_entity_1 = require("../../entities/category.entity");
let CategoriesService = class CategoriesService {
    constructor(repo) {
        this.repo = repo;
    }
    async paginate(q) {
        const qb = this.repo.createQueryBuilder("c");
        if (q.q)
            qb.andWhere("c.name ILIKE :q", { q: `%${q.q}%` });
        if (q.parentId !== undefined) {
            if (q.parentId === 0)
                qb.andWhere("c.parentId IS NULL");
            else
                qb.andWhere("c.parentId = :pid", { pid: q.parentId });
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
    async get(id) {
        const category = await this.repo.findOne({ where: { id } });
        if (!category)
            throw new common_1.NotFoundException("Category not found");
        return category;
    }
    async create(dto) {
        const entity = this.repo.create({
            name: dto.name,
            imageUrl: dto.imageUrl,
            parentId: dto.parentId,
        });
        return this.repo.save(entity);
    }
    async update(id, dto) {
        const category = await this.get(id);
        Object.assign(category, dto);
        return this.repo.save(category);
    }
    async remove(id) {
        const category = await this.get(id);
        await this.repo.remove(category);
        return { ok: true };
    }
    async tree() {
        const rows = await this.listAll();
        const byParent = new Map();
        for (const r of rows) {
            const k = r.parentId ?? null;
            if (!byParent.has(k))
                byParent.set(k, []);
            byParent.get(k).push(r);
        }
        const build = (pid) => (byParent.get(pid) ?? []).map((node) => ({
            ...node,
            children: build(node.id),
        }));
        return build(null);
    }
    async breadcrumbs(id) {
        const path = [];
        let cur = await this.repo.findOne({ where: { id } });
        while (cur) {
            path.unshift(cur);
            cur = cur.parentId
                ? await this.repo.findOne({ where: { id: cur.parentId } })
                : null;
        }
        return path;
    }
};
exports.CategoriesService = CategoriesService;
exports.CategoriesService = CategoriesService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(category_entity_1.Category)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], CategoriesService);
