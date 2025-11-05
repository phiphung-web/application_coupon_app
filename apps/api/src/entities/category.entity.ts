import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Entity("categories")
export class Category {
  @PrimaryGeneratedColumn()
  id: number;

  @Index()
  @Column({ length: 120 })
  name: string;

  // ảnh đại diện danh mục (frontend view all hiển thị)
  @Column({ nullable: true })
  imageUrl?: string;

  // sắp xếp ưu tiên
  @Column("int", { default: 0 })
  priority: number;

  @Column({ default: true })
  isActive: boolean;
}
