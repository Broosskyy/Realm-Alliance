export type PetId="wisp"|"fox"|"golem"|"owl"|"drake"|"voidling";
export type PetDefinition={id:PetId;name:string;icon:string;unlockLevel:number;description:string;attackBonus:number;hpBonus:number;goldBonus:number;ability:string;evolution:string};
export const PETS:PetDefinition[]=[
{id:"wisp",name:"Wolkenfunke",icon:"✦",unlockLevel:3,description:"Ein kleiner Himmelsgeist, der deinen Angriff verstärkt.",attackBonus:2,hpBonus:0,goldBonus:0,ability:"Funkenstoß",evolution:"Sturmlicht"},
{id:"fox",name:"Sturmfuchs",icon:"❖",unlockLevel:8,description:"Findet zusätzliche Münzen auf euren Reisen.",attackBonus:1,hpBonus:0,goldBonus:.08,ability:"Schatzsinn",evolution:"Gewitterfuchs"},
{id:"golem",name:"Runengolem",icon:"⬢",unlockLevel:14,description:"Ein treuer Wächter mit zusätzlicher Lebenskraft.",attackBonus:0,hpBonus:18,goldBonus:0,ability:"Runenschild",evolution:"Titanengolem"},
{id:"owl",name:"Prismakauz",icon:"◉",unlockLevel:20,description:"Ein arkaner Begleiter für präzisere Builds.",attackBonus:3,hpBonus:5,goldBonus:.02,ability:"Prismenblick",evolution:"Sternenkauz"},
{id:"drake",name:"Glutdrache",icon:"♨",unlockLevel:28,description:"Ein aggressiver Begleiter mit hohem Angriff.",attackBonus:5,hpBonus:0,goldBonus:0,ability:"Glutatem",evolution:"Infernodrache"},
{id:"voidling",name:"Leerenling",icon:"◆",unlockLevel:38,description:"Seltenes Wesen aus dem Leerenriss.",attackBonus:4,hpBonus:12,goldBonus:.04,ability:"Risssprung",evolution:"Leerenfürst"}
];
export function petById(id:PetId){return PETS.find(p=>p.id===id)??PETS[0]}
export function petEvolutionStage(level:number){return level>=15?3:level>=7?2:1}
