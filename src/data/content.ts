import{worldForZone,worldIndexForZone}from"./worlds";
import{encounterForStage,ENCOUNTERS,type EncounterKind}from"./encounters";
export type EnemyDefinition={id:string;name:string;maxHp:number;attack:number;xp:number;gold:number;essence:number;tier:"normal"|"tough"|"boss";family:string;encounter:EncounterKind;lootMultiplier:number};
export type ItemSlot="weapon"|"armor"|"charm";export type ItemDefinition={id:string;name:string;power:number;rarity:"common"|"uncommon"|"rare"|"epic";slot:ItemSlot;hp?:number;crit?:number};
const names=[
["Wolkenflink","Himmelskrabbler","Sturmauge","Nimbuswächter","Himmelskoloss"],
["Glutfunke","Magmakrabbler","Ascheauge","Lavapanzer","Vulkantyrann"],
["Frostling","Eiskrabbler","Polarauge","Gletscherpanzer","Frostgigant"],
["Kristallfunke","Splitterling","Prismaauge","Geodenpanzer","Kristallkönig"],
["Sonnengeist","Dünenläufer","Goldauge","Ruinenwächter","Sonnenkoloss"],
["Dämmerling","Risskriecher","Hohlauge","Leerenpanzer","Risswächter"]];
export function enemiesForZone(zone:number):EnemyDefinition[]{const w=worldIndexForZone(zone),world=worldForZone(zone),scale=1+(Math.max(1,zone)-1)*.22;return[32,48,70,96,165].map((hp,i)=>{const kind=encounterForStage(i,zone),mod=ENCOUNTERS[kind];return{id:world.family+"-"+i+"-"+kind,name:names[w][i],maxHp:Math.round(hp*scale*mod.hpMultiplier),attack:Math.max(2,Math.round([2,3,4,5,8][i]*(1+(zone-1)*.12)*mod.attackMultiplier)),xp:Math.round([10,14,20,28,55][i]*scale*mod.xpMultiplier),gold:Math.round([6,9,13,18,36][i]*scale*mod.goldMultiplier),essence:Math.max(1,Math.round((i===4?3:1)*mod.essenceMultiplier)),tier:kind==="boss"?"boss":kind==="tough"||kind==="elite"||kind==="cursed"?"tough":"normal",family:world.family,encounter:kind,lootMultiplier:mod.lootMultiplier}})}
export const enemies=enemiesForZone(1);
export const items:ItemDefinition[]=[
{id:"sky-sabre",name:"Himmelsklinge",power:4,rarity:"common",slot:"weapon"},{id:"ember-mail",name:"Glutpanzer",power:1,hp:18,rarity:"uncommon",slot:"armor"},{id:"frost-charm",name:"Frostsplitter",power:2,crit:3,rarity:"uncommon",slot:"charm"},{id:"prism-edge",name:"Prismaklinge",power:8,crit:3,rarity:"rare",slot:"weapon"},{id:"sun-plate",name:"Sonnenrüstung",power:2,hp:36,rarity:"rare",slot:"armor"},{id:"void-heart",name:"Leerenherz",power:4,hp:12,crit:5,rarity:"epic",slot:"charm"}];
export function itemForEnemy(i:number,victories=0,zone=1){const biome=(zone-1)%6;const boss=i===4,rare=(victories+1)%10===0;return items[rare?5:boss?Math.min(3+biome%3,5):Math.min(biome,items.length-1)]}
