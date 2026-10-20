export type ShopCurrency="gold"|"essence";
export type ShopOffer={id:string;name:string;subtitle:string;kind:"chest"|"key"|"bundle"|"cosmetic";currency:ShopCurrency;cost:number;badge?:string};
export const SHOP_OFFERS:ShopOffer[]=[
{id:"chest",name:"Abenteuertruhe",subtitle:"Ausrüstung aus deiner aktuellen Welt",kind:"chest",currency:"gold",cost:120},
{id:"key",name:"Runen-Schlüssel",subtitle:"Zugang zu einem Runenriss-Run",kind:"key",currency:"essence",cost:4},
{id:"hunter",name:"Jägerpaket",subtitle:"Truhe + Schlüssel · erspielbare Währungen",kind:"bundle",currency:"gold",cost:360,badge:"BUNDLE"},
{id:"aura",name:"Wolken-Aura",subtitle:"Kosmetik-Vorschau · kein Power-Vorteil",kind:"cosmetic",currency:"essence",cost:18,badge:"COSMETIC"}
];
export type HalloweenProgress={currency:number;claimed:string[]};
const KEY="realm-alliance-halloween-v1";
export function loadHalloweenProgress():HalloweenProgress{try{const r=localStorage.getItem(KEY);return r?JSON.parse(r):{currency:0,claimed:[]}}catch{return{currency:0,claimed:[]}}}
export function saveHalloweenProgress(p:HalloweenProgress){localStorage.setItem(KEY,JSON.stringify(p))}
export function halloweenQuestProgress(id:string,victories:number,bossKills:number,chests:number){return id==="h1"?victories:id==="h2"?bossKills:chests}
export function claimHalloweenQuest(p:HalloweenProgress,id:string,reward:number,progress:number,target:number){if(p.claimed.includes(id)||progress<target)return p;const n={currency:p.currency+reward,claimed:[...p.claimed,id]};saveHalloweenProgress(n);return n}
export const HALLOWEEN_REWARDS=[
{id:"r1",name:"Spuktruhe",cost:40,kind:"chest"},
{id:"r2",name:"Kürbis-Siegel",cost:75,kind:"cosmetic"},
{id:"r3",name:"Nachtwächter-Aura",cost:120,kind:"cosmetic"}
] as const;
export function spendHalloween(p:HalloweenProgress,cost:number){if(p.currency<cost)return p;const n={...p,currency:p.currency-cost};saveHalloweenProgress(n);return n}
