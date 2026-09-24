export type PetId="wisp"|"fox"|"golem";
export type PetDefinition={id:PetId;name:string;icon:string;unlockLevel:number;description:string;attackBonus:number;hpBonus:number;goldBonus:number};
export const PETS:PetDefinition[]=[
{id:"wisp",name:"Wolkenfunke",icon:"✦",unlockLevel:3,description:"Ein kleiner Himmelsgeist, der deinen Angriff verstärkt.",attackBonus:2,hpBonus:0,goldBonus:0},
{id:"fox",name:"Sturmfuchs",icon:"❖",unlockLevel:8,description:"Findet zusätzliche Münzen auf euren Reisen.",attackBonus:1,hpBonus:0,goldBonus:.08},
{id:"golem",name:"Runengolem",icon:"⬢",unlockLevel:14,description:"Ein treuer Wächter mit zusätzlicher Lebenskraft.",attackBonus:0,hpBonus:18,goldBonus:0}
];
export function petById(id:PetId){return PETS.find(p=>p.id===id)??PETS[0]}
