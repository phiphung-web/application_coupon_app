import {
  BaseEntity,
  Column,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
} from "typeorm";

@Entity("coupon_categories")
export class CouponCategory extends BaseEntity {
  @PrimaryGeneratedColumn() id!: number;

  @Index() @Column({ length: 120 }) name!: string;
  @Column({ nullable: true }) imageUrl?: string;
  @Column("int", { nullable: true }) parentId?: number;
  @Column("int", { default: 0 }) priority!: number;
  @Index() @Column({ default: true }) isActive!: boolean;

  @CreateDateColumn() createdAt!: Date;
  @UpdateDateColumn() updatedAt!: Date;
  @DeleteDateColumn() deletedAt?: Date;
}
