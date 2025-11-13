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

@Entity("badges")
export class Badge extends BaseEntity {
  @PrimaryGeneratedColumn() id!: number;

  @Index() @Column({ length: 50 }) key!: string; // 'HOT', 'TOP_SELL'
  @Column({ length: 120 }) label!: string; // 'Hot'
  @Column({ nullable: true }) color?: string; // '#FFFFFF'
  @Column({ nullable: true }) bgColor?: string; // '#FF0000'
  @Column({ nullable: true }) icon?: string; // 'flame'
  @Column("int", { default: 0 }) priority!: number;
  @Index() @Column({ default: true }) isActive!: boolean;

  @CreateDateColumn() createdAt!: Date;
  @UpdateDateColumn() updatedAt!: Date;
  @DeleteDateColumn() deletedAt?: Date;
}
