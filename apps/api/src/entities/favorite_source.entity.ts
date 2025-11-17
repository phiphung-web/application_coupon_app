import { BaseEntity, Entity, JoinColumn, ManyToOne, PrimaryColumn } from "typeorm";
import { User } from "./user.entity";
import { Source } from "./source.entity";

@Entity("favorite_sources")
export class FavoriteSource extends BaseEntity {
  @PrimaryColumn({ name: "user_id" })
  userId!: number;

  @PrimaryColumn({ name: "source_id" })
  sourceId!: number;

  @ManyToOne(() => User, (user) => user.favoriteSources, {
    onDelete: "CASCADE",
  })
  @JoinColumn({ name: "user_id" })
  user!: User;

  @ManyToOne(() => Source, { onDelete: "CASCADE" })
  @JoinColumn({ name: "source_id" })
  source!: Source;
}
