import React from "react";

const ROOT="/assets/production";
function ArtImg({src,className,alt=""}:{src:string;className:string;alt?:string}){
 return <img src={src} className={className} alt={alt} draggable={false} onError={e=>{e.currentTarget.style.display="none"}}/>;
}
export function WolkgartenProductionStage(){
 return <div className="production-world" aria-hidden="true">
  <ArtImg src={ROOT+"/worlds/wolkgarten/castle-island.png"} className="prod-world prod-castle"/>
  <ArtImg src={ROOT+"/worlds/wolkgarten/ruin-island.png"} className="prod-world prod-ruin"/>
  <ArtImg src={ROOT+"/worlds/wolkgarten/floating-islands.png"} className="prod-world prod-float"/>
  <ArtImg src={ROOT+"/worlds/wolkgarten/ruins-strip.png"} className="prod-world prod-ruins"/>
  <ArtImg src={ROOT+"/worlds/wolkgarten/arena-platform.png"} className="prod-world prod-platform"/>
  <ArtImg src={ROOT+"/worlds/wolkgarten/foliage-rocks.png"} className="prod-world prod-foreground"/>
 </div>;
}
export function ProductionHero({state="idle"}:{state?:string}){
 const file=state==="defeat"?"defeated":state==="victory"?"victory":state==="hit"?"hit":state==="skill"?"skill":state==="attack"?"attack":"idle";
 return <ArtImg src={ROOT+"/hero/realmwaechter/"+file+".png"} className={"production-hero prod-hero-"+file} alt="Realmwächter"/>;
}
export function ProductionWeapon({rarity="common"}:{rarity?:string}){
 const file=rarity==="legendary"?"blade-fire":rarity==="epic"?"blade-gold":rarity==="rare"?"blade-crystal":"blade-basic";
 return <ArtImg src={ROOT+"/weapons/realmblade/"+file+".png"} className={"production-weapon prod-weapon-"+file} alt="Realmklinge"/>;
}
export function ProductionEnemy({pose="idle",family="",name=""}:{pose?:string;family?:string;name?:string}){
 const lower=(name+" "+family).toLowerCase();
 const kind=lower.includes("wolf")||lower.includes("best")?"crystal-wolf":"cloud-golem";
 const file=pose==="defeated"?"defeated":pose==="attack"?"attack":pose==="hit"?"hit":"idle";
 return <ArtImg src={ROOT+"/monsters/"+kind+"/"+file+".png"} className={"production-enemy prod-enemy-"+kind+" prod-enemy-"+file} alt={name}/>;
}
