export type EnemyDefinition = {
  id: string;
  name: string;
  subtitle: string;
  maxHp: number;
  attack: number;
  xp: number;
  gold: number;
};

export type ItemDefinition = {
  id: string;
  name: string;
  slot: "weapon" | "charm";
  power: number;
  rarity: "common" | "uncommon" | "rare";
};

export const enemies: EnemyDefinition[] = [
  {
    id: "m001-waldwinzling",
    name: "Waldwinzling",
    subtitle: "Grünhains kleiner Unruhestifter",
    maxHp: 42,
    attack: 3,
    xp: 14,
    gold: 8,
  },
  {
    id: "m002-moosbeisser",
    name: "Moosbeißer",
    subtitle: "Zwischen Wurzeln lauert etwas Größeres",
    maxHp: 68,
    attack: 5,
    xp: 22,
    gold: 13,
  },
  {
    id: "m003-hainwaechter",
    name: "Hainwächter",
    subtitle: "Ein erster Wächter des tiefen Grünhains",
    maxHp: 104,
    attack: 8,
    xp: 36,
    gold: 21,
  },
];

export const items: ItemDefinition[] = [
  {
    id: "twig-blade",
    name: "Astklinge",
    slot: "weapon",
    power: 2,
    rarity: "common",
  },
  {
    id: "moss-edge",
    name: "Moosschneide",
    slot: "weapon",
    power: 4,
    rarity: "uncommon",
  },
  {
    id: "forest-charm",
    name: "Grünhain-Talisman",
    slot: "charm",
    power: 3,
    rarity: "rare",
  },
];

export function itemForEnemy(enemyIndex: number): ItemDefinition {
  return items[Math.min(enemyIndex, items.length - 1)];
}
