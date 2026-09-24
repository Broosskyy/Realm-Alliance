export type EnemyDefinition={id:string;name:string;maxHp:number;attack:number;xp:number;gold:number;essence:number;tier:"normal"|"tough"|"boss";family:string};
export type ItemSlot="weapon"|"armor"|"charm";export type ItemDefinition={id:string;name:string;power:number;rarity:"common"|"uncommon"|"rare"|"epic";slot:ItemSlot;hp?:number;crit?:number};
const names=[
["Wolkenflink","Himmelskrabbler","Sturmauge","Nimbuswächter","Himmelskoloss"],
["Glutfunke","Magmakrabbler","Ascheauge","Lavapanzer","Vulkantyrann"],
["Frostling","Eiskrabbler","Polarauge","Gletscherpanzer","Frostgigant"],
["Kristallfunke","Splitterling","Prismaauge","Geodenpanzer","Kristallkönig"],
["Sonnengeist","Dünenläufer","Goldauge","Ruinenwächter","Sonnenkoloss"],
["Dämmerling","Risskriecher","Hohlauge","Leerenpanzer","Risswächter"]];
const families=["cloud","lava","ice","crystal","sun","void"];
export function enemiesForZone(zone:number):EnemyDefinition[]{const w=(zone-1)%6,scale=1+(zone-1)*.22;return[32,48,70,96,165].map((hp,i)=>({id:families[w]+"-"+i,name:names[w][i],maxHp:Math.round(hp*scale),attack:Math.max(2,Math.round([2,3,4,5,8][i]*(1+(zone-1)*.12))),xp:Math.round([10,14,20,28,55][i]*scale),gold:Math.round([6,9,13,18,36][i]*scale),essence:i===4?3:1,tier:i===4?"boss":i>=2?"tough":"normal",family:families[w]}))}
export const enemies=enemiesForZone(1);
export const items:ItemDefinition[]=[
{id:"sky-sabre",name:"Himmelsklinge",power:4,rarity:"common",slot:"weapon"},{id:"ember-mail",name:"Glutpanzer",power:1,hp:18,rarity:"uncommon",slot:"armor"},{id:"frost-charm",name:"Frostsplitter",power:2,crit:3,rarity:"uncommon",slot:"charm"},{id:"prism-edge",name:"Prismaklinge",power:8,crit:3,rarity:"rare",slot:"weapon"},{id:"sun-plate",name:"Sonnenrüstung",power:2,hp:36,rarity:"rare",slot:"armor"},{id:"void-heart",name:"Leerenherz",power:4,hp:12,crit:5,rarity:"epic",slot:"charm"}];
export function itemForEnemy(i:number,victories=0,zone=1){const biome=(zone-1)%6;const boss=i===4,rare=(victories+1)%10===0;return items[rare?5:boss?Math.min(3+biome%3,5):Math.min(biome,items.length-1)]}
