import {
  Column,
  Entity,
  Index,
  PrimaryColumn,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
} from "typeorm";

export type SourceType = "ECOM" | "APP" | "GAME" | "SERVICE" | "OTHER";

@Entity("sources")
export class Source {
  @PrimaryColumn({ length: 50 })
  id!: string; // ví dụ: 'shopee', 'lazada', 'genshin'

  @Index()
  @Column({ length: 120 })
  name!: string;

  @Column({ type: "varchar", length: 10, default: "ECOM" })
  type!: SourceType;

  @Column({ nullable: true })
  logoUrl?: string;

  @Column({ nullable: true })
  domain?: string;

  @Column({ nullable: true })
  packageId?: string; // Android app id

  @Column({ nullable: true })
  bundleId?: string; // iOS bundle id

  @Column({ nullable: true })
  publisher?: string; // Publisher name

  @Column("int", { default: 0 })
  priority!: number;

  @Index()
  @Column({ default: true })
  isActive!: boolean;

  @CreateDateColumn() createdAt!: Date;
  @UpdateDateColumn() updatedAt!: Date;
  @DeleteDateColumn() deletedAt?: Date;
}
