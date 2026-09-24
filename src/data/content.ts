export type EnemyDefinition={id:string;name:string;maxHp:number;attack:number;xp:number;gold:number;essence:number;tier:"normal"|"tough"|"boss"};
export type ItemSlot="weapon"|"armor"|"charm";
export type ItemDefinition={id:string;name:string;power:number;rarity:"common"|"uncommon"|"rare"|"epic";slot:ItemSlot;hp?:number;crit?:number};
export const enemies:EnemyDefinition[]=[
{id:"shade-wisp",name:"Dämmerling",maxHp:32,attack:2,xp:10,gold:6,essence:1,tier:"normal"},
{id:"rift-mite",name:"Risskriecher",maxHp:48,attack:3,xp:14,gold:9,essence:1,tier:"normal"},
{id:"hollow-eye",name:"Hohlauge",maxHp:70,attack:4,xp:20,gold:13,essence:1,tier:"tough"},
{id:"void-shell",name:"Leerenpanzer",maxHp:96,attack:5,xp:28,gold:18,essence:1,tier:"tough"},
{id:"rift-warden",name:"Risswächter",maxHp:165,attack:8,xp:55,gold:36,essence:2,tier:"boss"}];
export const items:ItemDefinition[]=[
{id:"rust-blade",name:"Rissklinge",power:3,rarity:"common",slot:"weapon"},
{id:"shade-mail",name:"Schattenpanzer",power:0,hp:14,rarity:"common",slot:"armor"},
{id:"rift-shard",name:"Risssplitter",power:1,crit:2,rarity:"uncommon",slot:"charm"},
{id:"void-edge",name:"Leerenklinge",power:7,crit:2,rarity:"rare",slot:"weapon"},
{id:"core-plate",name:"Kernrüstung",power:1,hp:32,rarity:"rare",slot:"armor"},
{id:"echo-heart",name:"Echoherz",power:3,hp:10,crit:4,rarity:"epic",slot:"charm"}];
export function itemForEnemy(i:number,victories=0){const base=Math.min(i,items.length-2);const rare=(victories+1)%10===0?items.length-1:base;return items[rare]}
