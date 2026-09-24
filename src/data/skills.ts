export type SkillId="slash"|"nova";
export type SkillDefinition={id:SkillId;name:string;icon:string;baseMultiplier:number;cooldownMs:number;unlockLevel:number;description:string};
export const SKILLS:Record<SkillId,SkillDefinition>={
slash:{id:"slash",name:"Risshieb",icon:"✦",baseMultiplier:1.8,cooldownMs:3200,unlockLevel:2,description:"Ein harter fokussierter Treffer."},
nova:{id:"nova",name:"Leerenstoß",icon:"⌁",baseMultiplier:2.5,cooldownMs:6200,unlockLevel:5,description:"Entlädt gespeicherte Essenz in einem schweren Schlag."}
};
export function skillMultiplier(id:SkillId,level:number){const base=SKILLS[id].baseMultiplier;return Number((base+(Math.max(1,level)-1)*(id==="slash"?.12:.18)).toFixed(2))}
