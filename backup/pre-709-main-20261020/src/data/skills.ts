export type SkillId="slash"|"nova";
export type SkillDefinition={id:SkillId;name:string;icon:string;baseMultiplier:number;cooldownMs:number;unlockLevel:number;description:string;milestones:{level:number;name:string;effect:string}[]};
export const SKILLS:Record<SkillId,SkillDefinition>={
slash:{id:"slash",name:"Risshieb",icon:"✦",baseMultiplier:1.8,cooldownMs:3200,unlockLevel:2,description:"Ein harter fokussierter Treffer.",milestones:[{level:3,name:"Doppelriss",effect:"+8 Momentum pro Einsatz"},{level:6,name:"Klingenecho",effect:"durchdringt Wächterbarrieren"},{level:10,name:"Weltenriss",effect:"+18% Meisterschaden"}]},
nova:{id:"nova",name:"Leerenstoß",icon:"⌁",baseMultiplier:2.5,cooldownMs:6200,unlockLevel:5,description:"Entlädt gespeicherte Essenz in einem schweren Schlag.",milestones:[{level:3,name:"Essenzwelle",effect:"+10 Zorn pro Einsatz"},{level:6,name:"Leerenkern",effect:"ignoriert Wächterbarrieren"},{level:10,name:"Nullnova",effect:"+28% gegen verwundete Gegner"}]}
};
export function skillMultiplier(id:SkillId,level:number){const base=SKILLS[id].baseMultiplier;return Number((base+(Math.max(1,level)-1)*(id==="slash"?.12:.18)).toFixed(2))}
export function skillEvolution(id:SkillId,level:number){const d=SKILLS[id],reached=[...d.milestones].reverse().find(m=>level>=m.level);return reached??{level:1,name:d.name,effect:d.description}}
export function nextSkillEvolution(id:SkillId,level:number){return SKILLS[id].milestones.find(m=>m.level>level)}
