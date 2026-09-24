import type{ItemSlot}from"./content";
export type ItemRarity="common"|"uncommon"|"rare"|"epic"|"legendary";
export type AffixKey="attack"|"hp"|"crit"|"goldFind"|"xpGain"|"skillDamage";
export type ItemAffix={key:AffixKey;label:string;value:number};
export type ItemInstance={uid:string;baseId:string;name:string;slot:ItemSlot;rarity:ItemRarity;itemLevel:number;power:number;hp?:number;crit?:number;affixes:ItemAffix[];locked?:boolean};
const rarityOrder:ItemRarity[]=["common","uncommon","rare","epic","legendary"];
const prefixes=["Klar","Wild","Uralte","Sturm","Runen","Sternen"];
const bases:Record<ItemSlot,string[]>={
 weapon:["Klinge","Axt","Stab","Dolche","Bogen","Fokus"],
 armor:["Panzer","Mantel","Brustschutz","Gewand","Plattenrüstung","Wächterhaut"],
 charm:["Talisman","Siegel","Kern","Auge","Rune","Herz"]
};
function hash(seed:number){const x=Math.sin(seed*999.91)*43758.5453;return x-Math.floor(x)}
export function rarityRank(r:ItemRarity){return rarityOrder.indexOf(r)}
export function rollRarity(zone:number,lootMultiplier=1,seed=1):ItemRarity{const luck=Math.min(.16,(zone-1)*.006)+(lootMultiplier-1)*.05,r=hash(seed);if(r<.008+luck*.15)return"legendary";if(r<.05+luck*.35)return"epic";if(r<.19+luck*.65)return"rare";if(r<.48+luck)return"uncommon";return"common"}
export function rollItem(zone:number,enemyIndex:number,victories:number,lootMultiplier=1):ItemInstance{
 const seed=zone*10007+(victories+1)*97+enemyIndex*13,slot=(["weapon","armor","charm"] as ItemSlot[])[Math.floor(hash(seed+1)*3)],rarity=rollRarity(zone,lootMultiplier,seed+2),rank=rarityRank(rarity),itemLevel=Math.max(1,zone+Math.floor(victories/12)),roll=.86+hash(seed+3)*.3,base=Math.round((3+itemLevel*1.65)*(1+rank*.42)*roll);
 const affixCount=Math.min(3,rank),pool:AffixKey[]=["attack","hp","crit","goldFind","xpGain","skillDamage"],affixes:ItemAffix[]=[];
 for(let i=0;i<affixCount;i++){const key=pool[Math.floor(hash(seed+10+i)*pool.length)],v=Math.max(1,Math.round((2+itemLevel*.55)*(1+rank*.18)*(.8+hash(seed+20+i)*.5)));if(!affixes.some(a=>a.key===key))affixes.push({key,label:key==="attack"?"Angriff":key==="hp"?"Leben":key==="crit"?"Krit":key==="goldFind"?"Goldfund":key==="xpGain"?"XP": "Skill-Schaden",value:v})}
 const biome=["Himmel","Glut","Frost","Prisma","Sonne","Leere"][(zone-1)%6],name=`${rank>=2?prefixes[Math.floor(hash(seed+4)*prefixes.length)]+" ":""}${biome}-${bases[slot][Math.floor(hash(seed+5)*bases[slot].length)]}`;
 const affAtk=affixes.filter(a=>a.key==="attack").reduce((n,a)=>n+a.value,0),affHp=affixes.filter(a=>a.key==="hp").reduce((n,a)=>n+a.value,0),affCrit=affixes.filter(a=>a.key==="crit").reduce((n,a)=>n+a.value,0);
 return{uid:`${seed}-${Math.floor(hash(seed+6)*99999)}`,baseId:`${biome.toLowerCase()}-${slot}`,name,slot,rarity,itemLevel,power:slot==="weapon"?base+affAtk:Math.round(base*.32)+affAtk,hp:slot==="armor"?base*4+affHp:affHp||undefined,crit:slot==="charm"?2+rank*2+affCrit:affCrit||undefined,affixes}
}
export function itemScore(x?:ItemInstance){if(!x)return 0;return x.power*3+(x.hp??0)+(x.crit??0)*5+x.affixes.filter(a=>["goldFind","xpGain","skillDamage"].includes(a.key)).reduce((n,a)=>n+a.value*2,0)}
export function salvageValue(x:ItemInstance){return 1+rarityRank(x.rarity)*2+Math.floor(x.itemLevel/8)}
