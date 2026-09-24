export type EnemyDefinition={id:string;name:string;maxHp:number;attack:number;xp:number;gold:number;essence:number;tier:"normal"|"tough"|"boss"};
export type ItemDefinition={id:string;name:string;power:number;rarity:"common"|"uncommon"|"rare"};
export const enemies:EnemyDefinition[]=[
{id:"shade-wisp",name:"Dämmerling",maxHp:32,attack:2,xp:10,gold:6,essence:1,tier:"normal"},
{id:"rift-mite",name:"Risskriecher",maxHp:48,attack:3,xp:14,gold:9,essence:1,tier:"normal"},
{id:"hollow-eye",name:"Hohlauge",maxHp:70,attack:4,xp:20,gold:13,essence:1,tier:"tough"},
{id:"void-shell",name:"Leerenpanzer",maxHp:96,attack:5,xp:28,gold:18,essence:1,tier:"tough"},
{id:"rift-warden",name:"Risswächter",maxHp:165,attack:8,xp:55,gold:36,essence:2,tier:"boss"}];
export const items:ItemDefinition[]=[
{id:"rift-shard",name:"Risssplitter",power:1,rarity:"common"},
{id:"dark-core",name:"Dunkelkern",power:2,rarity:"uncommon"},
{id:"echo-fragment",name:"Echofragment",power:3,rarity:"rare"}];
export function itemForEnemy(i:number){return items[Math.min(Math.floor(i/2),items.length-1)]}
