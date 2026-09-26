export type AccountMode="guest"|"email";
export type PlayerAccount={id:string;displayName:string;mode:AccountMode;email?:string;createdAt:number};
export type OnlineSnapshot={playerId:string;displayName:string;level:number;victories:number;bossKills:number;power:number;updatedAt:number};
export type Clan={id:string;name:string;tag:string;level:number;members:number;memberCap:number;weeklyScore:number;motd:string};
export type ArenaOpponent={id:string;name:string;rating:number;power:number;reward:number};
export type LiveEvent={id:string;name:string;subtitle:string;startsAt:number;endsAt:number;currencyName:string;accent:string;quests:{id:string;label:string;target:number;reward:number}[]};

const ACCOUNT_KEY="realm-alliance-account-v1";
const ONLINE_KEY="realm-alliance-online-snapshot-v1";
const CLAN_KEY="realm-alliance-clan-v1";
const ARENA_KEY="realm-alliance-arena-v1";

function id(prefix:string){return prefix+"-"+Math.random().toString(36).slice(2,8)+"-"+Date.now().toString(36).slice(-5)}
export function loadAccount():PlayerAccount|null{try{const raw=localStorage.getItem(ACCOUNT_KEY);return raw?JSON.parse(raw):null}catch{return null}}
export function createGuestAccount(name="Realmwächter"):PlayerAccount{const a={id:id("player"),displayName:name.trim()||"Realmwächter",mode:"guest" as const,createdAt:Date.now()};localStorage.setItem(ACCOUNT_KEY,JSON.stringify(a));return a}
export function createEmailAccount(email:string,name:string):PlayerAccount{const a={id:id("player"),displayName:name.trim()||"Realmwächter",mode:"email" as const,email:email.trim().toLowerCase(),createdAt:Date.now()};localStorage.setItem(ACCOUNT_KEY,JSON.stringify(a));return a}
export function saveAccount(a:PlayerAccount){localStorage.setItem(ACCOUNT_KEY,JSON.stringify(a))}
export function publishSnapshot(snapshot:OnlineSnapshot){localStorage.setItem(ONLINE_KEY,JSON.stringify(snapshot))}
export function localLeaderboard(me:OnlineSnapshot){const rivals:OnlineSnapshot[]=[
{playerId:"r-ash",displayName:"AshenFox",level:Math.max(3,me.level+4),victories:Math.max(24,me.victories+38),bossKills:Math.max(2,me.bossKills+3),power:Math.max(75,me.power+32),updatedAt:me.updatedAt},
{playerId:"r-luna",displayName:"LunaVale",level:Math.max(2,me.level+2),victories:Math.max(18,me.victories+17),bossKills:Math.max(1,me.bossKills+1),power:Math.max(58,me.power+15),updatedAt:me.updatedAt},
{playerId:"r-kai",displayName:"KaiRune",level:Math.max(1,me.level-1),victories:Math.max(8,me.victories-5),bossKills:Math.max(0,me.bossKills),power:Math.max(30,me.power-8),updatedAt:me.updatedAt},
{playerId:"r-mira",displayName:"Mira",level:Math.max(1,me.level-3),victories:Math.max(4,me.victories-14),bossKills:Math.max(0,me.bossKills-1),power:Math.max(22,me.power-17),updatedAt:me.updatedAt}
];return[me,...rivals].sort((a,b)=>b.power-a.power||b.victories-a.victories)}
export function loadClan():Clan|null{try{const raw=localStorage.getItem(CLAN_KEY);return raw?JSON.parse(raw):null}catch{return null}}
export function createClan(name:string,tag:string):Clan{const c={id:id("clan"),name:name.trim()||"Realm Alliance",tag:(tag.trim()||"RA").slice(0,4).toUpperCase(),level:1,members:1,memberCap:20,weeklyScore:0,motd:"Gemeinsam stärker."};localStorage.setItem(CLAN_KEY,JSON.stringify(c));return c}
export function leaveClan(){localStorage.removeItem(CLAN_KEY)}
export function arenaRating(){return Math.max(800,Number(localStorage.getItem(ARENA_KEY)||1000))}
export function setArenaRating(v:number){localStorage.setItem(ARENA_KEY,String(Math.max(800,Math.round(v))))}
export function arenaOpponents(rating:number,power:number):ArenaOpponent[]{return[
{id:"a1",name:"Nebeljäger",rating:rating+42,power:Math.max(20,power+10),reward:24},
{id:"a2",name:"Runenwolf",rating:rating+5,power:Math.max(18,power+2),reward:18},
{id:"a3",name:"Wolkenklinge",rating:Math.max(800,rating-31),power:Math.max(15,power-7),reward:14}
]}
export function halloweenEvent(now=Date.now()):LiveEvent{const year=new Date(now).getUTCFullYear(),startsAt=Date.UTC(year,9,1),endsAt=Date.UTC(year,10,3,23,59,59);return{id:"halloween-"+year,name:"Nacht der Kürbisse",subtitle:"Halloween · Saisonales LiveOps-Event",startsAt,endsAt,currencyName:"Geistersplitter",accent:"#ff8a38",quests:[{id:"h1",label:"Besiege 25 Wesen",target:25,reward:40},{id:"h2",label:"Besiege 3 Bosse",target:3,reward:60},{id:"h3",label:"Öffne 5 Truhen",target:5,reward:35}]}}
export function eventState(e:LiveEvent,now=Date.now()){return now<e.startsAt?"upcoming":now>e.endsAt?"ended":"active"}
