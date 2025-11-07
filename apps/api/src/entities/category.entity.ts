import {
  Column,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
} from "typeorm";

@Entity("categories")
export class Category {
  @PrimaryGeneratedColumn()
  id!: number;

  @Index()
  @Column({ length: 120 })
  name!: string;

  @Column({ nullable: true })
  imageUrl?: string;

  @Column("int", { nullable: true })
  parentId?: number;

  @Column("int", { default: 0 })
  priority: number = 0;

  @Column({ default: true })
  isActive: boolean = true;

  @CreateDateColumn() createdAt!: Date;
  @UpdateDateColumn() updatedAt!: Date;
  @DeleteDateColumn() deletedAt?: Date;
}
