export type WorldDefinition={id:string;name:string;icon:string;subtitle:string;family:string;material:string;mechanic:string};
export const WORLDS:WorldDefinition[]=[
{id:"cloud",name:"Wolkengarten",icon:"☁",subtitle:"Himmelsinseln",family:"cloud",material:"Wolkensplitter",mechanic:"Windladung"},
{id:"lava",name:"Glutkern",icon:"♨",subtitle:"Lavafelder",family:"lava",material:"Glutkern",mechanic:"Brand"},
{id:"ice",name:"Frosthain",icon:"❄",subtitle:"Eiswildnis",family:"ice",material:"Frostfragment",mechanic:"Frost"},
{id:"crystal",name:"Kristallhöhlen",icon:"◇",subtitle:"Leuchtende Tiefen",family:"crystal",material:"Prismakristall",mechanic:"Kristallschild"},
{id:"sun",name:"Sonnenruinen",icon:"☀",subtitle:"Goldene Ruinen",family:"sun",material:"Sonnenrelikt",mechanic:"Ermächtigung"},
{id:"void",name:"Leerenriss",icon:"◆",subtitle:"Instabile Sphäre",family:"void",material:"Leerenfragment",mechanic:"Verderbnis"}];
export const ZONES_PER_WORLD=5;
export function worldIndexForZone(zone:number){return Math.floor((Math.max(1,zone)-1)/ZONES_PER_WORLD)%WORLDS.length}
export function worldForZone(zone:number){return WORLDS[worldIndexForZone(zone)]}
export function worldStageForZone(zone:number){return((Math.max(1,zone)-1)%ZONES_PER_WORLD)+1}
export function worldCycle(zone:number){return Math.floor((Math.max(1,zone)-1)/(WORLDS.length*ZONES_PER_WORLD))+1}
export function firstZoneForWorld(index:number,cycle=1){return Math.max(1,(cycle-1)*WORLDS.length*ZONES_PER_WORLD+index*ZONES_PER_WORLD+1)}
