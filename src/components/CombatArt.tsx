import React from "react";
import type {EnemyArchetype} from "../data/content";

type Family="cloud"|"lava"|"ice"|"crystal"|"sun"|"void"|string;
const palette:Record<string,[string,string,string,string]>={
 cloud:["#dff8ff","#73cde8","#426e91","#fff4c7"],lava:["#ffcc72","#e95732","#6f2830","#ffe7a3"],
 ice:["#e9fdff","#7ddcea","#4a83a5","#ffffff"],crystal:["#e5ddff","#9a7bea","#51498e","#8ff4ff"],
 sun:["#ffe89a","#d99c45","#8b5b35","#fff7c7"],void:["#e5a4ff","#9b4cc7","#392850","#ff8fe6"]
};
export function HeroPlaceholder({state="idle"}:{state?:string}){
 return <svg className={"code-art hero-art state-"+state} viewBox="0 0 220 260" role="img" aria-label="Held">
  <ellipse className="art-shadow" cx="110" cy="236" rx="62" ry="12"/>
  <path className="hero-cape" d="M76 104 Q48 145 61 218 Q91 237 119 215 L111 112Z"/>
  <path className="hero-leg" d="M87 178 L79 229 L99 229 L110 179Z"/><path className="hero-leg" d="M116 179 L126 229 L146 229 L135 174Z"/>
  <path className="hero-boot" d="M77 221 Q92 218 102 230 L96 239 H68Q67 229 77 221Z"/><path className="hero-boot" d="M126 221 Q143 218 153 231 L148 239 H120Z"/>
  <path className="hero-body-art" d="M76 99 Q109 80 145 103 L137 177 Q108 194 78 174Z"/>
  <path className="hero-shoulder" d="M71 102 Q55 105 52 126 L77 134Z"/><path className="hero-shoulder" d="M145 103 Q163 106 166 126 L139 135Z"/>
  <path className="hero-arm" d="M58 121 Q49 150 69 174 L84 162 L76 127Z"/><path className="hero-arm" d="M159 121 Q170 147 148 171 L134 159 L142 127Z"/>
  <path className="hero-head" d="M81 50 Q108 25 139 50 L143 91 Q112 113 79 89Z"/>
  <path className="hero-hair" d="M78 61 Q83 29 112 29 Q143 30 148 62 L136 55 L130 70 L119 55 L104 68 L92 54Z"/>
  <path className="hero-face" d="M91 66 Q109 54 132 67 L129 91 Q110 101 92 89Z"/>
  <path className="hero-eye" d="M97 72h8v5h-8zM119 72h8v5h-8z"/>
  <path className="hero-belt" d="M78 151 Q110 160 139 151 L138 165 Q109 173 78 164Z"/><path className="hero-chest-trim" d="M82 105 L108 119 L136 104 L132 146 L109 155 L84 144Z"/><path className="hero-scarf" d="M83 93 Q109 104 140 92 L135 108 Q110 116 86 106Z"/><path className="hero-scarf-tail" d="M85 103 Q59 119 55 151 Q72 139 91 127Z"/><path className="hero-knee" d="M83 183 L104 183 L99 204 L80 204Z"/><path className="hero-knee" d="M119 183 L139 179 L145 201 L124 204Z"/>
  <path className="hero-sword" d="M151 49 L164 40 L151 139 L139 151 L143 130Z"/><path className="hero-armor-panel" d="M91 112 L108 122 L126 112 L130 145 L109 153 L88 144Z"/><path className="hero-armor-rim" d="M91 112 L108 122 L126 112 M88 144 L109 153 L130 145"/><path className="hero-gauntlet" d="M57 142 L73 139 L82 163 L68 174Z"/><path className="hero-gauntlet right" d="M151 139 L165 144 L150 172 L136 160Z"/><path className="hero-rune" d="M103 129 L109 121 L115 129 L109 139Z"/><path className="hero-pauldron-rim" d="M54 119 Q61 101 76 104 L78 121 Q65 116 54 126Z"/><path className="hero-pauldron-rim right" d="M164 119 Q157 101 142 104 L140 121 Q153 116 164 126Z"/><path className="hero-cloak-fold" d="M70 119 Q78 151 72 203 M82 119 Q92 151 86 211"/><path className="hero-gem" d="M105 106 L109 100 L113 106 L109 112Z"/><path className="hero-sword-edge" d="M158 47 L164 40 L151 139 L147 135Z"/>
  <path className="hero-guard" d="M132 139 L159 151 L154 159 L128 147Z"/>
 </svg>
}
export function MonsterPlaceholder({family,archetype,variant=0,boss=false,pose="idle"}:{family:Family;archetype:EnemyArchetype;variant?:number;boss?:boolean;pose?:string}){
 const p=palette[family]??palette.cloud; const eye=p[3]; const seed=variant%3;
 return <svg className={"code-art monster-art family-art-"+family+" archetype-art-"+archetype+" pose-"+pose+(boss?" boss-art":"")} viewBox="0 0 300 280" role="img" aria-label="Gegner" style={{"--art-a":p[0],"--art-b":p[1],"--art-c":p[2],"--art-eye":eye} as React.CSSProperties}>
  <ellipse className="art-shadow" cx="150" cy="247" rx={boss?96:78} ry="14"/>
  {archetype==="swift"&&<><path className="monster-tail" d="M91 174 Q37 163 39 117 Q57 143 90 137Z"/><path className="monster-wing" d="M105 116 Q54 74 49 120 Q71 112 102 145Z"/><path className="monster-wing right" d="M195 116 Q246 74 251 120 Q229 112 198 145Z"/></>}
  {archetype==="caster"&&<><path className="monster-orbit" d="M61 137 Q150 65 239 137 Q150 213 61 137Z"/><circle className="monster-rune" cx="150" cy="48" r="12"/></>}
  {archetype==="guardian"&&<><path className="monster-shield" d="M72 121 Q45 173 80 218 L104 198 L98 128Z"/><path className="monster-shield right" d="M228 121 Q255 173 220 218 L196 198 L202 128Z"/></>}
  {archetype==="stalker"&&<><path className="monster-tail" d="M91 181 Q38 214 45 239 Q72 215 116 212Z"/><path className="monster-spike" d="M96 91 L72 48 L118 76Z"/><path className="monster-spike right" d="M204 91 L228 48 L182 76Z"/></>}
  {archetype==="brute"&&<><path className="monster-horn" d="M103 82 Q70 35 55 72 L94 106Z"/><path className="monster-horn right" d="M197 82 Q230 35 245 72 L206 106Z"/></>}
  {family==="cloud"&&<><path className="family-ornament cloud-tuft" d="M102 93 Q114 68 132 85 Q150 57 168 85 Q188 69 199 95 Q178 102 150 98 Q124 103 102 93Z"/><path className="family-ornament cloud-ribbon" d="M84 178 Q53 165 39 184 Q63 184 91 198Z"/></>}
  {family==="lava"&&<><path className="family-ornament lava-spine" d="M111 91 L121 57 L137 86 L150 48 L163 86 L180 58 L190 94Z"/><path className="family-ornament lava-vent" d="M121 191 L135 174 L150 196 L164 174 L181 192"/></>}
  {family==="ice"&&<><path className="family-ornament ice-crown" d="M111 91 L122 52 L139 82 L151 39 L164 82 L181 51 L191 92Z"/><path className="family-ornament ice-spur" d="M89 179 L63 190 L84 157 M211 179 L237 190 L216 157"/></>}
  {family==="crystal"&&<><path className="family-ornament crystal-crown" d="M112 94 L128 53 L143 78 L154 42 L168 79 L187 57 L190 96Z"/><path className="family-ornament crystal-shard" d="M88 176 L64 151 L98 158 M212 176 L236 151 L202 158"/></>}
  {family==="sun"&&<><path className="family-ornament sun-crown" d="M106 91 L118 65 L133 77 L150 49 L167 77 L183 64 L195 92Z"/><path className="family-ornament sun-collar" d="M104 101 Q150 78 196 101 L183 115 Q150 99 117 115Z"/></>}
  {family==="void"&&<><path className="family-ornament void-horn" d="M110 91 Q91 48 113 35 Q119 65 136 84 M190 91 Q209 48 187 35 Q181 65 164 84"/><path className="family-ornament void-tendril" d="M91 191 Q53 214 62 239 Q74 213 111 207 M209 191 Q247 214 238 239 Q226 213 189 207"/></>}
  {boss&&<><path className="monster-horn" d="M105 78 L82 22 L132 65Z"/><path className="monster-horn right" d="M195 78 L218 22 L168 65Z"/><path className="boss-crown" d="M112 65 L128 31 L149 57 L171 27 L188 67Z"/></>}
  <path className="monster-body" d={boss?"M78 113 Q89 66 150 61 Q211 66 222 113 L226 190 Q210 235 150 238 Q90 235 74 190Z":"M91 121 Q101 78 150 76 Q199 78 209 121 L211 188 Q198 226 150 230 Q102 226 89 188Z"}/><path className="monster-plate" d="M102 104 Q150 78 198 104 L186 145 Q150 126 114 145Z"/><path className="monster-side-plate" d="M90 142 L111 151 L105 197 L83 184Z"/><path className="monster-side-plate right" d="M210 142 L189 151 L195 197 L217 184Z"/><path className="monster-crack" d="M150 91 L141 116 L153 132 L144 155 L158 174 L150 202"/><circle className="monster-core" cx="150" cy="151" r="9"/>
  <path className="monster-belly" d="M111 150 Q150 128 189 150 L184 205 Q150 220 116 204Z"/><path className="monster-crest" d="M126 86 L150 68 L174 86 L164 101 L150 94 L136 101Z"/><path className="monster-armor-line" d="M111 151 Q150 164 189 151 M116 177 Q150 190 184 177"/><circle className="monster-core-ring" cx="150" cy="151" r="16"/><path className="monster-plate-rim" d="M104 106 Q150 83 196 106 M91 143 L108 151 M209 143 L192 151"/><path className="monster-cheek" d="M103 139 L118 143 L112 155 L98 151Z"/><path className="monster-cheek right" d="M197 139 L182 143 L188 155 L202 151Z"/>
  <path className="monster-brow" d="M105 119 Q124 105 141 116 L136 126 Q119 119 106 129Z"/><path className="monster-brow right" d="M195 119 Q176 105 159 116 L164 126 Q181 119 194 129Z"/>
  <path className="monster-eye" d="M111 127 Q125 116 138 128 Q126 143 112 134Z"/><path className="monster-eye right" d="M189 127 Q175 116 162 128 Q174 143 188 134Z"/>
  <path className="monster-pupil" d="M122 125 L130 130 L123 136 L117 131Z"/><path className="monster-pupil right" d="M178 125 L170 130 L177 136 L183 131Z"/>
  <path className="monster-mouth" d={seed===0?"M126 169 Q150 185 174 169 Q166 195 150 197 Q134 195 126 169Z":seed===1?"M126 177 Q150 162 174 177 Q151 191 126 177Z":"M128 171 L142 181 L151 170 L161 182 L174 170"}/>
  <path className="monster-foot" d="M99 207 Q78 221 80 241 H126 L132 218Z"/><path className="monster-foot right" d="M201 207 Q222 221 220 241 H174 L168 218Z"/>
  <path className="monster-mark" d={seed===0?"M143 92 L150 78 L157 92 L150 105Z":seed===1?"M137 91 Q150 77 163 91 Q150 107 137 91Z":"M139 86 L161 86 L150 106Z"}/>
 </svg>
}

export function PetPlaceholder({kind="wisp",stage=1}:{kind?:string;stage?:number}){
 const ears=kind==="fox"||kind==="owl", wings=kind==="drake"||kind==="owl";
 return <svg className={"code-art pet-art pet-"+kind+" pet-evo-"+stage} viewBox="0 0 120 110" aria-hidden="true">
  <ellipse className="art-shadow" cx="60" cy="99" rx="31" ry="6"/>
  {wings&&<><path className="pet-wing" d="M39 55 Q10 37 15 70 Q28 65 43 75Z"/><path className="pet-wing right" d="M81 55 Q110 37 105 70 Q92 65 77 75Z"/></>}
  {ears&&<><path className="pet-ear" d="M39 39 L29 13 L52 33Z"/><path className="pet-ear right" d="M81 39 L91 13 L68 33Z"/></>}
  <path className="pet-body-art" d="M34 54 Q39 28 60 27 Q82 28 87 54 L83 84 Q61 101 37 84Z"/>
  <path className="pet-face-art" d="M43 53 Q60 42 77 53 L74 72 Q60 82 46 72Z"/><path className="pet-chest-art" d="M45 76 Q60 84 76 76 L72 90 Q60 99 48 89Z"/><path className="pet-tail-art" d="M36 76 Q16 82 23 96 Q35 90 47 84Z"/><path className="pet-brow-art" d="M45 52 L54 49 M75 52 L66 49"/><path className="pet-collar-art" d="M43 75 Q60 83 78 74 L74 82 Q60 89 47 82Z"/><circle className="pet-core-art" cx="60" cy="79" r="3"/>
  <circle className="pet-eye-art" cx="51" cy="58" r="4"/><circle className="pet-eye-art" cx="69" cy="58" r="4"/>
  <path className="pet-mark-art" d="M55 42 L60 34 L65 42 L60 49Z"/>
  {stage>=2&&<path className="pet-aura-art" d="M24 76 Q10 50 29 28 M96 76 Q110 50 91 28"/>}
 </svg>
}
export function LootPlaceholder({slot="weapon",rarity="common"}:{slot?:string;rarity?:string}){
 return <svg className={"code-art loot-art loot-"+slot+" rarity-art-"+rarity} viewBox="0 0 100 100" aria-hidden="true">
  <path className="loot-glow" d="M50 6 L62 24 L84 18 L78 41 L95 53 L76 65 L80 88 L58 80 L43 95 L31 76 L8 79 L17 57 L3 42 L25 34 L27 12Z"/>
  {slot==="weapon"?<><path className="loot-blade" d="M69 13 L82 18 L47 65 L36 70 L39 58Z"/><path className="loot-guard" d="M29 59 L52 76 L45 84 L22 67Z"/><path className="loot-grip" d="M31 72 L18 88"/></>:slot==="armor"?<><path className="loot-armor" d="M29 25 L42 17 Q50 25 58 17 L72 25 L83 43 L70 50 L68 82 H32 L30 50 L17 43Z"/><path className="loot-crest" d="M42 36 L50 28 L58 36 L50 51Z"/></>:<><circle className="loot-charm" cx="50" cy="55" r="23"/><path className="loot-chain" d="M31 36 Q50 6 69 36"/><path className="loot-crest" d="M43 50 L50 39 L58 50 L50 66Z"/></>}
 </svg>
}
export function ChestPlaceholder({open=false}:{open?:boolean}){
 return <svg className={"code-art chest-art "+(open?"open":"")} viewBox="0 0 130 105" aria-hidden="true">
  <ellipse className="art-shadow" cx="65" cy="94" rx="47" ry="7"/><path className="chest-body-art" d="M22 48 H108 L103 89 H27Z"/><path className="chest-band-art" d="M57 47 H73 V91 H57Z"/>
  <path className="chest-lid-art" d="M24 47 Q27 19 51 15 H80 Q103 20 106 47Z"/><path className="chest-rim-art" d="M20 43 H110 V55 H20Z"/><path className="chest-lock-art" d="M57 48 H73 V68 H57Z"/>
 </svg>
}
export function WorldScenery({world=0}:{world?:number}){
 return <svg className={"code-art world-art world-art-"+(world+1)} viewBox="0 0 420 330" preserveAspectRatio="none" aria-hidden="true">
  <path className="world-sky-art" d="M0 0H420V330H0Z"/><circle className="world-sun-art" cx={world===5?330:72} cy="62" r={world===5?28:38}/>
  <path className="world-back-art" d={world===0?"M0 180 Q55 125 108 171 Q167 99 226 169 Q300 107 420 172 V330H0Z":world===1?"M0 205 L54 115 L103 188 L158 74 L225 194 L292 106 L350 187 L420 129 V330H0Z":world===2?"M0 190 L72 91 L126 164 L193 57 L252 169 L326 84 L420 174 V330H0Z":world===3?"M0 205 L54 135 L84 190 L125 82 L165 188 L224 104 L260 191 L326 61 L365 186 L420 126 V330H0Z":world===4?"M0 195 L50 161 L86 177 L118 117 L154 177 L207 137 L256 177 L302 102 L352 174 L420 142 V330H0Z":"M0 185 Q62 106 112 170 Q178 73 229 166 Q294 91 420 159 V330H0Z"}/>
  <path className="world-ground-art" d="M0 218 Q96 193 194 222 Q303 191 420 219 V330H0Z"/>{world===0&&<><path className="cloud-island-back" d="M18 185 Q43 155 72 171 Q88 136 119 157 Q142 147 159 180 Q133 198 89 199 Q47 199 18 185Z"/><path className="cloud-island-back second" d="M270 170 Q297 141 322 159 Q343 124 370 151 Q398 150 414 179 Q377 194 334 191 Q296 190 270 170Z"/><path className="cloud-waterfall" d="M91 193 Q104 196 116 192 L111 282 Q102 300 95 280Z"/><path className="cloud-waterfall second" d="M337 187 Q348 191 359 187 L356 263 Q349 278 341 261Z"/><path className="cloud-ruin" d="M184 202 V161 H197 V147 H210 V161 H224 V202 H214 V178 H194 V202Z"/></>}
  {world===0&&<><path className="world-prop-art" d="M28 231 Q55 188 81 231Z M317 229 Q344 179 374 229Z"/><path className="world-prop2-art" d="M116 229 Q151 208 184 229Z"/></>}
  {world===1&&<><path className="world-prop-art" d="M50 252 L76 206 L96 252 M321 252 L346 199 L370 252"/><path className="world-prop2-art" d="M0 273 Q72 245 130 275 Q188 249 240 276 Q326 242 420 272"/></>}
  {world===2&&<><path className="world-prop-art" d="M48 250 L69 188 L86 250 M329 250 L349 177 L369 250"/><path className="world-prop2-art" d="M125 249 L145 214 L161 249 M252 250 L271 207 L289 250"/></>}
  {world===3&&<><path className="world-prop-art" d="M55 256 L75 176 L97 256 M318 256 L343 165 L368 256"/><path className="world-prop2-art" d="M128 256 L145 208 L166 256 M254 256 L272 198 L292 256"/></>}
  {world===4&&<><path className="world-prop-art" d="M45 258 V196 H64 V258 M351 258 V188 H370 V258"/><path className="world-prop2-art" d="M121 253 L138 202 H159 L176 253 M249 253 L267 211 H288 L305 253"/></>}
  {world===5&&<><path className="world-prop-art" d="M53 260 Q66 201 90 172 Q83 228 103 260 M320 260 Q341 202 367 177 Q354 228 374 260"/><path className="world-prop2-art" d="M196 248 L210 188 L224 248"/></>}
 </svg>
}

export function AdventureEnemyPlaceholder({boss=false,room="battle",mode="dungeon"}:{boss?:boolean;room?:string;mode?:string}){
 return <svg className={"code-art adventure-enemy-art room-art-"+room+" mode-art-"+mode+(boss?" adventure-boss-art":"")} viewBox="0 0 210 190" aria-hidden="true">
  <ellipse className="art-shadow" cx="105" cy="176" rx="66" ry="9"/>
  {boss&&<><path className="adv-horn" d="M73 61 L50 16 L88 48Z"/><path className="adv-horn right" d="M137 61 L160 16 L122 48Z"/></>}
  <path className="adv-cloak" d="M61 85 Q105 49 149 85 L161 165 Q105 187 49 165Z"/>
  <path className="adv-head" d="M69 58 Q105 30 141 58 L137 104 Q105 125 73 104Z"/>
  <path className="adv-mask" d="M78 68 Q105 52 132 68 L127 94 Q105 108 83 94Z"/>
  <path className="adv-eye" d="M87 73 L100 78 L88 84Z"/><path className="adv-eye right" d="M123 73 L110 78 L122 84Z"/>
  <path className="adv-arm" d="M60 91 Q35 116 44 151 L68 140Z"/><path className="adv-arm right" d="M150 91 Q175 116 166 151 L142 140Z"/>
  {room==="treasure"?<path className="adv-treasure" d="M76 133 H134 L130 166 H80Z M78 132 Q82 112 105 111 Q128 112 132 132Z"/>:<path className="adv-weapon" d="M151 73 L172 56 L143 139 L132 147Z"/>}
  <path className="adv-rune" d="M97 122 L105 110 L113 122 L105 135Z"/>
 </svg>
}
export function RelicPlaceholder({kind="warSigil"}:{kind?:string}){
 const shape=kind==="lifeSeed"?"seed":kind==="fortuneIdol"?"idol":kind==="skillPrism"?"prism":kind==="adventureCrown"?"crown":"sigil";
 return <svg className={"code-art relic-art relic-"+shape} viewBox="0 0 100 100" aria-hidden="true">
  <circle className="relic-halo" cx="50" cy="50" r="39"/>
  {shape==="seed"?<><path className="relic-main" d="M50 16 Q80 42 65 70 Q50 92 35 70 Q20 42 50 16Z"/><path className="relic-detail" d="M50 35 V72 M50 53 Q36 46 31 36 M50 57 Q66 49 71 38"/></>:shape==="idol"?<><path className="relic-main" d="M32 20 H68 L77 42 L68 82 H32 L23 42Z"/><circle className="relic-detail-fill" cx="50" cy="45" r="13"/><path className="relic-detail" d="M38 70 H62"/></>:shape==="prism"?<><path className="relic-main" d="M50 12 L78 38 L66 83 H34 L22 38Z"/><path className="relic-detail" d="M50 13 V82 M23 38 L66 83 M78 38 L34 83"/></>:shape==="crown"?<><path className="relic-main" d="M20 66 L25 31 L43 49 L51 20 L62 49 L79 31 L82 66Z"/><path className="relic-detail" d="M22 67 H81 V79 H22Z"/></>:<><path className="relic-main" d="M50 12 L82 50 L50 88 L18 50Z"/><path className="relic-detail" d="M50 27 L67 50 L50 73 L33 50Z"/></>}
 </svg>
}
export function ShopItemPlaceholder({kind="chest"}:{kind?:string}){
 return <svg className={"code-art shop-art shop-"+kind} viewBox="0 0 110 100" aria-hidden="true">
  <ellipse className="art-shadow" cx="55" cy="91" rx="35" ry="6"/>
  {kind==="key"?<><circle className="shop-key-ring" cx="38" cy="42" r="17"/><path className="shop-key" d="M50 54 L82 82 M67 67 L77 57 M74 74 L85 64"/></>:kind==="potion"?<><path className="shop-bottle" d="M43 20 H67 V35 Q82 49 75 76 Q55 92 35 76 Q28 49 43 35Z"/><path className="shop-liquid" d="M36 58 Q55 48 74 58 L72 75 Q55 85 38 75Z"/></>:kind==="material"?<><path className="shop-crystal" d="M55 11 L82 43 L68 87 H41 L26 43Z"/><path className="shop-detail" d="M55 12 V86 M27 43 L68 87"/></>:<><path className="shop-chest" d="M22 47 H88 L84 84 H26Z"/><path className="shop-chest-lid" d="M25 46 Q29 21 55 20 Q81 21 85 46Z"/><path className="shop-band" d="M49 45 H62 V85 H49Z"/></>}
 </svg>
}

export function SkillPlaceholder({kind="slash"}:{kind?:string}){
 return <svg className={"code-art skill-art skill-art-"+kind} viewBox="0 0 100 100" aria-hidden="true">
  <circle className="skill-disc" cx="50" cy="50" r="43"/>
  {kind==="slash"?<><path className="skill-slash-a" d="M20 70 Q43 31 80 19 Q59 48 34 80Z"/><path className="skill-slash-b" d="M27 77 Q52 52 76 44"/></>:<><circle className="skill-core" cx="50" cy="50" r="17"/><path className="skill-orbit" d="M13 50 Q50 13 87 50 Q50 87 13 50Z"/><path className="skill-ray" d="M50 8 V27 M50 73 V92 M8 50 H27 M73 50 H92"/></>}
 </svg>
}
export function WeaponPlaceholder({name=""}:{name?:string}){
 const axe=name.includes("Axt"),staff=name.includes("Stab")||name.includes("Fokus"),bow=name.includes("Bogen"),dagger=name.includes("Dolche");
 return <svg className="code-art weapon-art" viewBox="0 0 110 110" aria-hidden="true">
  {axe?<><path className="weapon-handle" d="M34 94 L72 22"/><path className="weapon-metal" d="M67 19 Q93 13 95 37 Q76 43 62 33Z"/></>:staff?<><path className="weapon-handle" d="M37 96 L66 22"/><circle className="weapon-gem" cx="69" cy="20" r="12"/><path className="weapon-metal" d="M56 29 L47 12 M76 31 L88 17"/></>:bow?<><path className="weapon-bow" d="M29 14 Q91 55 31 96"/><path className="weapon-string" d="M29 14 L55 55 L31 96"/><path className="weapon-arrow" d="M17 55 H89"/></>:dagger?<><path className="weapon-metal" d="M25 75 L55 26 L63 35 L37 82Z"/><path className="weapon-metal" d="M51 80 L76 30 L85 38 L64 87Z"/></>:<><path className="weapon-metal" d="M24 88 L67 18 L80 25 L39 94Z"/><path className="weapon-guard" d="M27 73 L51 90"/></>}
 </svg>
}
export function WorldThumbnail({world=0}:{world?:number}){
 return <svg className={"code-art world-thumb-art wt-art-"+(world+1)} viewBox="0 0 100 100" aria-hidden="true">
  <circle className="wt-sky" cx="50" cy="50" r="46"/><circle className="wt-sun" cx="30" cy="27" r="10"/>
  <path className="wt-back" d={world===1?"M9 70 L29 31 L44 61 L62 22 L91 69 V91 H9Z":world===2?"M8 71 L31 29 L48 58 L66 18 L93 69 V92 H8Z":world===3?"M9 76 L27 43 L39 68 L53 24 L66 68 L81 35 L93 75 V92 H9Z":world===4?"M8 73 L27 58 L38 65 L51 38 L63 66 L78 45 L93 70 V92 H8Z":world===5?"M8 70 Q31 30 48 64 Q68 25 93 62 V92 H8Z":"M8 72 Q29 43 45 65 Q65 31 93 63 V92 H8Z"}/>
  <path className="wt-ground" d="M7 73 Q50 62 93 73 V93 H7Z"/>
 </svg>
}

export function CombatPropSet({world=0}:{world?:number}){
 const kind=world===1?"lava":world===2?"ice":world===3?"crystal":world===4?"sun":world===5?"void":"cloud";
 return <svg className={"code-art combat-props props-"+kind} viewBox="0 0 420 120" preserveAspectRatio="none" aria-hidden="true">
  <path className="prop-ground" d="M0 104 Q62 87 126 102 Q204 83 274 102 Q349 84 420 101 V120 H0Z"/>
  {kind==="cloud"&&<><path className="prop-rock" d="M14 104 L31 72 L51 65 L67 104Z"/><path className="prop-grass" d="M42 104 L48 78 L51 103 L61 81 L58 104"/><path className="prop-rock right" d="M349 104 L367 69 L391 77 L407 104Z"/><path className="prop-grass right" d="M355 104 L365 80 L366 104 L377 75 L374 104"/></>}
  {kind==="lava"&&<><path className="prop-spire" d="M12 106 L36 42 L51 106Z"/><path className="prop-crack" d="M65 106 L84 91 L99 102 L117 86"/><path className="prop-spire right" d="M356 106 L384 35 L406 106Z"/></>}
  {kind==="ice"&&<><path className="prop-crystal" d="M18 105 L37 50 L50 104 L61 70 L72 105Z"/><path className="prop-crystal right" d="M345 105 L365 60 L378 104 L391 45 L406 105Z"/></>}
  {kind==="crystal"&&<><path className="prop-crystal" d="M14 105 L31 58 L44 86 L58 37 L75 105Z"/><path className="prop-crystal right" d="M346 105 L361 48 L377 78 L390 31 L408 105Z"/></>}
  {kind==="sun"&&<><path className="prop-pillar" d="M19 105 V58 H55 V105 M14 58 H60 L53 47 H22Z"/><path className="prop-pillar right" d="M359 105 V53 H397 V105 M354 53 H402 L394 42 H363Z"/></>}
  {kind==="void"&&<><path className="prop-tendril" d="M10 107 Q27 78 21 46 Q50 67 45 105Z"/><path className="prop-tendril right" d="M410 107 Q390 73 399 39 Q367 66 374 105Z"/><path className="prop-rune" d="M73 99 L86 75 L99 99 L86 111Z"/></>}
 </svg>
}

export function MonsterPortrait({family="cloud",archetype="brute",known=true}:{family?:string;archetype?:EnemyArchetype;known?:boolean}){
 if(!known)return <svg className="code-art portrait-art unknown-portrait" viewBox="0 0 80 80"><circle cx="40" cy="40" r="34"/><path d="M29 31 Q40 20 51 31 Q53 42 43 47 V54 H36 V43 Q45 40 45 33 Q40 28 35 34Z"/><circle cx="40" cy="62" r="4"/></svg>;
 const p=palette[family]??palette.cloud;
 return <svg className={"code-art portrait-art portrait-"+archetype} viewBox="0 0 80 80" style={{"--art-a":p[0],"--art-b":p[1],"--art-c":p[2],"--art-eye":p[3]} as React.CSSProperties}>
  <circle className="portrait-bg" cx="40" cy="40" r="36"/>
  {archetype==="brute"&&<><path className="portrait-horn" d="M27 29 L13 10 L33 23Z"/><path className="portrait-horn right" d="M53 29 L67 10 L47 23Z"/></>}
  {archetype==="stalker"&&<><path className="portrait-horn" d="M28 29 L20 9 L38 24Z"/><path className="portrait-horn right" d="M52 29 L60 9 L42 24Z"/></>}
  <path className="portrait-head" d="M18 36 Q21 17 40 16 Q59 17 62 36 L60 58 Q40 72 20 58Z"/>
  <path className="portrait-face" d="M25 40 Q40 30 55 40 L52 57 Q40 65 28 57Z"/>
  <path className="portrait-eye" d="M28 42 L38 45 L29 49Z"/><path className="portrait-eye right" d="M52 42 L42 45 L51 49Z"/>
 </svg>
}
export function RewardBurst({slot="weapon",rarity="common",boss=false}:{slot?:string;rarity?:string;boss?:boolean}){
 return <div className={"reward-art-stage rarity-stage-"+rarity+(boss?" boss-reward-stage":"")}><i className="reward-ray r1"/><i className="reward-ray r2"/><i className="reward-ray r3"/><i className="reward-ray r4"/>{boss&&<ChestPlaceholder open/>}<LootPlaceholder slot={slot} rarity={rarity}/></div>
}
export function MerchantItemPlaceholder({name=""}:{name?:string}){
 const n=name.toLowerCase(),kind=n.includes("schlüssel")?"key":n.includes("trank")||n.includes("heil")?"potion":n.includes("truhe")?"chest":"material";
 return <ShopItemPlaceholder kind={kind}/>
}
export function GardenPlaceholder({level=1}:{level?:number}){
 return <svg className="code-art garden-art" viewBox="0 0 320 150" preserveAspectRatio="none" aria-hidden="true">
  <path className="garden-sky" d="M0 0H320V150H0Z"/><path className="garden-cloud" d="M15 42 Q28 21 45 38 Q61 18 79 41 Q94 42 96 55 H15Z M222 31 Q237 12 251 29 Q267 11 283 32 Q300 33 302 45 H222Z"/>
  <path className="garden-ground" d="M0 88 Q79 70 157 90 Q240 70 320 88 V150 H0Z"/>
  <path className="garden-house" d="M225 72 L260 43 L295 72 V126 H225Z"/><path className="garden-roof" d="M216 74 L260 35 L304 74Z"/><path className="garden-door" d="M253 91 H270 V126 H253Z"/>
  <path className="garden-tree" d="M54 69 Q32 59 42 40 Q51 20 68 36 Q80 17 94 39 Q107 60 84 70Z"/><path className="garden-trunk" d="M65 66 H76 V119 H65Z"/>
  {level>2&&<><circle className="garden-flower" cx="133" cy="105" r="6"/><circle className="garden-flower" cx="157" cy="114" r="5"/></>}
  {level>4&&<path className="garden-bush" d="M171 113 Q171 91 190 96 Q199 79 211 98 Q222 99 221 116Z"/>}
 </svg>
}

export function UiGlyph({kind="attack"}:{kind?:string}){
 return <svg className={"code-art ui-glyph ui-glyph-"+kind} viewBox="0 0 64 64" aria-hidden="true">
  {kind==="attack"?<><path className="uig-metal" d="M14 51 L42 9 L52 13 L26 56Z"/><path className="uig-gold" d="M14 43 L29 54"/></>:
   kind==="tower"?<><path className="uig-main" d="M16 55 V22 H24 V13 H32 V22 H40 V13 H48 V55Z"/><path className="uig-dark" d="M28 55 V39 H37 V55Z"/></>:
   kind==="quest"?<><path className="uig-paper" d="M16 9 H45 L51 16 V55 H16Z"/><path className="uig-line" d="M23 24 H43 M23 33 H43 M23 42 H36"/></>:
   kind==="gift"?<><path className="uig-main" d="M11 28 H53 V55 H11Z"/><path className="uig-gold" d="M28 27 H36 V55 H28Z M8 20 H56 V30 H8Z"/><path className="uig-line" d="M32 20 Q16 18 19 9 Q29 7 32 20 Q48 18 45 9 Q35 7 32 20"/></>:
   kind==="shield"?<><path className="uig-main" d="M32 7 L51 15 V30 Q48 48 32 57 Q16 48 13 30 V15Z"/><path className="uig-gold" d="M32 17 V45 M20 29 H44"/></>:
   kind==="world"?<><circle className="uig-main" cx="32" cy="32" r="23"/><path className="uig-line" d="M10 32 H54 M32 9 Q20 32 32 55 M32 9 Q44 32 32 55"/></>:
   kind==="menu"?<><path className="uig-line thick" d="M13 18 H51 M13 32 H51 M13 46 H51"/></>:
   <><path className="uig-main" d="M32 7 L53 32 L32 57 L11 32Z"/><path className="uig-gold" d="M32 19 L43 32 L32 45 L21 32Z"/></>}
 </svg>
}
export function AdventureModeArt({mode="dungeon"}:{mode?:string}){
 return <svg className={"code-art mode-art-card mode-card-"+mode} viewBox="0 0 150 105" aria-hidden="true">
  <path className="mode-sky" d="M0 0 H150 V105 H0Z"/>
  {mode==="tower"?<><path className="mode-back" d="M0 73 L29 45 L51 67 L82 31 L111 65 L150 39 V105 H0Z"/><path className="mode-building" d="M54 91 V39 H65 V27 H76 V39 H87 V27 H98 V91Z"/><path className="mode-window" d="M70 50 H80 V61 H70Z M86 50 H94 V61 H86Z"/></>:<><path className="mode-back" d="M0 80 Q31 31 62 65 Q91 25 150 68 V105 H0Z"/><path className="mode-cave" d="M22 105 Q31 42 75 32 Q120 42 130 105Z"/><path className="mode-door" d="M50 105 Q55 62 76 57 Q98 63 103 105Z"/><path className="mode-crystal" d="M28 83 L39 56 L49 83 M110 85 L120 51 L130 85"/></>}
 </svg>
}

export function PetEvolutionOverlay({stage=1}:{stage?:number}){
 const t=Math.min(3,Math.max(1,stage));return <svg className={"code-art pet-evolution-overlay pet-form-"+t} viewBox="0 0 120 120" aria-hidden="true">{t>=2&&<><path className="pet-evo-ear" d="M35 45 L24 19 L48 37Z"/><path className="pet-evo-ear right" d="M85 45 L96 19 L72 37Z"/><path className="pet-evo-armor" d="M37 72 Q60 60 83 72 L76 91 Q60 101 44 91Z"/></>}{t>=3&&<><path className="pet-evo-crown" d="M39 40 L47 21 L58 34 L67 16 L76 35 L87 22 L83 43Z"/><path className="pet-evo-tail" d="M33 78 Q4 67 12 96 Q29 91 45 84Z"/><path className="pet-evo-wing" d="M42 73 Q14 48 13 71 Q28 70 46 87Z"/><path className="pet-evo-wing right" d="M78 73 Q106 48 107 71 Q92 70 74 87Z"/></>}</svg>}
export function ChestRevealArt({open=false}:{open?:boolean}){return <svg className={"code-art chest-reveal-art "+(open?"is-open":"")} viewBox="0 0 180 150" aria-hidden="true"><ellipse className="chest-floor" cx="90" cy="132" rx="62" ry="10"/><path className="chest-rays" d="M90 85 L90 8 M70 87 L45 20 M110 87 L136 20 M59 96 L17 55 M121 96 L163 55"/><path className="chest-box" d="M37 78 H143 L136 130 H44Z"/><path className="chest-lid" d={open?"M37 76 Q44 36 90 31 Q136 36 143 76 L129 67 Q90 48 51 67Z":"M37 78 Q44 48 90 45 Q136 48 143 78Z"}/><path className="chest-band" d="M82 77 H99 V131 H82Z"/><rect className="chest-lock" x="80" y="83" width="21" height="18" rx="4"/>{open&&<><circle className="chest-spark s1" cx="51" cy="39" r="4"/><circle className="chest-spark s2" cx="126" cy="30" r="3"/><circle className="chest-spark s3" cx="104" cy="14" r="3"/></>}</svg>}
export function WorldPathOrnament({world=0}:{world?:number}){return <svg className={"code-art world-path-ornament path-world-"+world} viewBox="0 0 80 170" preserveAspectRatio="none" aria-hidden="true"><path className="path-line" d="M40 0 C14 35 67 58 40 86 C13 113 65 137 40 170"/>{[20,85,150].map((y,i)=><circle key={i} className="path-node" cx={i%2?40:i?55:27} cy={y} r="5"/>)}<path className="path-glint" d="M34 0 C8 35 61 58 34 86"/></svg>}

export function SocialEmblem({kind="clan"}:{kind?:string}){
 return <svg className={"code-art social-emblem emblem-"+kind} viewBox="0 0 120 120" aria-hidden="true"><path className="emblem-shield" d="M60 7 L101 24 L94 78 Q82 102 60 113 Q38 102 26 78 L19 24Z"/>{kind==="arena"?<><path className="emblem-blade" d="M32 84 L79 27 L89 35 L43 92Z M88 84 L41 27 L31 35 L77 92Z"/></>:kind==="rank"?<><path className="emblem-crown" d="M30 66 L37 37 L55 53 L61 29 L77 53 L91 37 L88 68Z"/><path className="emblem-star" d="M60 71 L66 82 L78 84 L69 92 L71 104 L60 98 L49 104 L51 92 L42 84 L54 82Z"/></>:<><path className="emblem-tower" d="M38 84 V43 H48 V33 H57 V43 H67 V30 H78 V43 H87 V84Z"/><path className="emblem-gate" d="M54 84 V65 Q60 56 66 65 V84Z"/></>}</svg>}

export function HeroEvolutionOverlay({stage=1,mutation=0}:{stage?:number;mutation?:number}){
 const t=Math.min(4,Math.max(1,stage));
 return <svg className={"code-art hero-evolution-overlay hero-form-"+t+" hero-mutation-"+Math.min(4,mutation)} viewBox="0 0 220 260" aria-hidden="true">
  {t>=2&&<><path className="evo-shoulder" d="M48 126 L57 101 L78 97 L73 123Z"/><path className="evo-shoulder right" d="M172 126 L163 101 L142 97 L147 123Z"/><path className="evo-knee" d="M78 185 L104 179 L101 207 L76 209Z"/><path className="evo-knee right" d="M142 185 L117 179 L120 207 L145 209Z"/></>}
  {t>=3&&<><path className="evo-crown" d="M80 57 L91 33 L104 47 L113 23 L124 48 L139 34 L146 59 L132 53 L111 61 L94 52Z"/><path className="evo-cape-rim" d="M62 119 Q45 166 59 218 Q84 235 104 221 M158 119 Q175 166 160 218 Q137 235 116 221"/></>}
  {t>=4&&<><path className="evo-wing" d="M70 130 Q26 93 20 135 Q44 129 76 160Z"/><path className="evo-wing right" d="M150 130 Q194 93 200 135 Q176 129 144 160Z"/><path className="evo-halo" d="M74 57 Q110 24 146 57 Q110 75 74 57Z"/></>}
  {mutation>0&&<><path className="mutation-vein" d="M92 108 L103 124 L96 141 M128 108 L117 124 L124 141"/><circle className="mutation-core" cx="110" cy="132" r={4+Math.min(4,mutation)}/></>}
 </svg>
}
export function LootDropArt({rarity="common",slot="weapon"}:{rarity?:string;slot?:string}){
 return <svg className={"code-art loot-drop-art rarity-"+rarity} viewBox="0 0 180 180" aria-hidden="true"><path className="drop-beam" d="M67 158 L79 20 H101 L114 158Z"/><ellipse className="drop-ground" cx="90" cy="157" rx="55" ry="12"/><path className="drop-star" d="M90 25 L98 48 L122 50 L103 65 L109 89 L90 76 L71 89 L77 65 L58 50 L82 48Z"/><g transform="translate(48 67) scale(.84)"><LootPlaceholder slot={slot} rarity={rarity}/></g></svg>
}
export function UpgradeBurst({kind="power"}:{kind?:string}){
 return <svg className={"code-art upgrade-burst burst-"+kind} viewBox="0 0 120 120" aria-hidden="true"><circle className="burst-ring" cx="60" cy="60" r="25"/><path className="burst-rays" d="M60 5 V29 M60 91 V115 M5 60 H29 M91 60 H115 M21 21 L38 38 M82 82 L99 99 M99 21 L82 38 M38 82 L21 99"/><path className="burst-core" d="M60 37 L69 51 L84 60 L69 69 L60 84 L51 69 L36 60 L51 51Z"/></svg>
}

export function EquipmentAura({rarity="common",level=1}:{rarity?:string;level?:number}){
 const tier=Math.min(4,Math.max(1,Math.ceil(level/5)));
 return <svg className={"code-art equipment-aura rarity-"+rarity+" gear-tier-"+tier} viewBox="0 0 220 260" aria-hidden="true"><ellipse className="gear-halo" cx="110" cy="205" rx={58+tier*7} ry={24+tier*3}/>{tier>=2&&<path className="gear-rune-ring" d="M42 204 Q110 156 178 204 Q110 244 42 204Z"/>}{tier>=3&&<><path className="gear-spark" d="M48 142 L53 130 L58 142 L53 153Z"/><path className="gear-spark right" d="M162 126 L168 111 L174 126 L168 140Z"/></>}{tier>=4&&<path className="gear-wings" d="M79 173 Q35 141 27 174 Q52 170 84 195 M141 173 Q185 141 193 174 Q168 170 136 195"/>}</svg>
}
export function SkillEvolutionArt({kind="slash",level=1}:{kind?:string;level?:number}){
 const tier=Math.min(4,Math.max(1,Math.ceil(level/4)));
 return <svg className={"code-art skill-evolution-art skill-"+kind+" skill-tier-"+tier} viewBox="0 0 120 120" aria-hidden="true"><circle className="skill-evo-ring" cx="60" cy="60" r={31+tier*4}/>{kind==="nova"?<><circle className="skill-evo-core" cx="60" cy="60" r={12+tier*2}/><path className="skill-evo-rays" d="M60 7 V31 M60 89 V113 M7 60 H31 M89 60 H113 M23 23 L40 40 M80 80 L97 97 M97 23 L80 40 M40 80 L23 97"/></>:<><path className="skill-evo-blade" d="M84 15 L99 23 L56 85 L38 99 L45 78Z"/><path className="skill-evo-slash" d="M20 81 Q57 39 105 36 M25 96 Q61 57 106 54"/></>}{tier>=3&&<path className="skill-evo-rune" d="M60 18 L68 30 L60 42 L52 30Z"/>}</svg>
}
export function PanelOrnament({kind="realm"}:{kind?:string}){
 return <svg className={"code-art panel-ornament ornament-"+kind} viewBox="0 0 420 44" preserveAspectRatio="none" aria-hidden="true"><path className="ornament-line" d="M0 22 H156 L177 8 H243 L264 22 H420"/><path className="ornament-core" d="M210 5 L226 22 L210 39 L194 22Z"/><path className="ornament-inner" d="M210 12 L219 22 L210 32 L201 22Z"/></svg>
}

export function HalloweenArt({kind="portal"}:{kind?:"portal"|"pumpkin"|"relic"}){
 return <svg className={"code-art halloween-art halloween-"+kind} viewBox="0 0 180 150" aria-hidden="true">
  <ellipse className="hw-shadow" cx="90" cy="130" rx="62" ry="12"/>
  {kind==="portal"?<><path className="hw-stone" d="M36 126 Q23 71 48 31 Q90 3 132 31 Q157 71 144 126 L121 126 Q132 77 113 49 Q90 32 67 49 Q48 77 59 126Z"/><ellipse className="hw-rift" cx="90" cy="82" rx="37" ry="49"/><path className="hw-rune" d="M42 69 L53 61 M127 60 L139 69 M52 109 L63 116 M117 116 L129 108"/></>:kind==="pumpkin"?<><path className="hw-stem" d="M85 33 Q88 14 105 13 Q96 22 98 38Z"/><path className="hw-pumpkin" d="M34 82 Q35 42 70 40 Q90 31 110 40 Q145 42 146 82 Q145 124 108 126 Q90 135 72 126 Q35 124 34 82Z"/><path className="hw-face" d="M57 69 L76 62 L70 81Z M123 69 L104 62 L110 81Z M62 99 Q90 118 119 98 L110 116 L99 108 L90 120 L80 108 L69 116Z"/></>:<><path className="hw-relic" d="M90 18 L124 49 L114 111 L90 132 L66 111 L56 49Z"/><path className="hw-relic-core" d="M90 43 L108 65 L100 101 L90 111 L80 101 L72 65Z"/><path className="hw-rune" d="M90 50 V102 M78 70 L102 82 M102 70 L78 82"/></>}
 </svg>
}
export function EvolutionCrest({stage=1,mutation=0}:{stage?:number;mutation?:number}){
 return <svg className={"code-art evolution-crest crest-"+stage} viewBox="0 0 100 100" aria-hidden="true"><path className="crest-ring" d="M50 5 L78 17 L94 46 L84 77 L50 95 L16 77 L6 46 L22 17Z"/><path className="crest-core" d="M50 19 L68 39 L62 69 L50 81 L38 69 L32 39Z"/>{Array.from({length:Math.min(4,stage)},(_,i)=><circle key={i} className="crest-star" cx={29+i*14} cy="88" r="3"/>)}{mutation>0&&<path className="crest-mutation" d="M50 28 L57 44 L72 50 L57 57 L50 73 L43 57 L28 50 L43 44Z"/>}</svg>
}

export function NavGlyph({kind="fight"}:{kind?:string}){
 return <svg className={"code-art nav-glyph nav-glyph-"+kind} viewBox="0 0 72 72" aria-hidden="true">
  {kind==="fight"?<><path className="nav-metal" d="M14 57 L45 10 L55 15 L27 62Z"/><path className="nav-gold" d="M15 49 L31 61"/><path className="nav-spark" d="M49 9 L54 3 M58 17 L67 15"/></>:kind==="adventure"?<><path className="nav-main" d="M13 58 V27 H23 V17 H31 V27 H41 V13 H50 V27 H59 V58Z"/><path className="nav-dark" d="M31 58 V43 H42 V58Z"/><path className="nav-gold" d="M10 59 H62"/></>:kind==="being"?<><path className="nav-main" d="M36 7 L56 22 L51 51 L36 64 L21 51 L16 22Z"/><path className="nav-face" d="M25 29 L33 33 L26 38 M47 29 L39 33 L46 38"/><path className="nav-gold" d="M29 48 Q36 53 43 48"/></>:kind==="inventory"?<><path className="nav-main" d="M13 28 H59 V59 H13Z"/><path className="nav-gold" d="M30 27 H42 V59 H30Z M10 20 H62 V31 H10Z"/><path className="nav-line" d="M36 20 Q21 18 24 9 Q33 7 36 20 Q51 18 48 9 Q39 7 36 20"/></>:<><circle className="nav-main" cx="36" cy="36" r="7"/><path className="nav-gear" d="M31 7 H41 L44 17 L52 20 L61 15 L67 24 L59 32 L60 41 L68 47 L62 57 L52 53 L44 58 L42 68 H30 L28 58 L20 54 L10 58 L4 48 L12 41 L12 31 L5 24 L11 15 L21 20 L28 17Z"/></>}
 </svg>
}
export function ResourceFrame({kind="gold"}:{kind?:string}){
 return <svg className={"code-art resource-frame frame-"+kind} viewBox="0 0 120 42" preserveAspectRatio="none" aria-hidden="true"><path className="frame-bg" d="M9 3 H111 L119 21 L111 39 H9 L1 21Z"/><path className="frame-rim" d="M12 6 H108 L115 21 L108 36 H12 L5 21Z"/><path className="frame-shine" d="M16 8 H104"/></svg>
}

export function ResourceGlyph({kind="gold"}:{kind?:string}){
 return <svg className={"code-art resource-glyph resource-"+kind} viewBox="0 0 48 48" aria-hidden="true">
  {kind==="gold"?<><circle className="res-gold" cx="24" cy="24" r="17"/><circle className="res-line" cx="24" cy="24" r="10"/><path className="res-line" d="M18 24 H30"/></>:
   kind==="essence"?<><path className="res-essence" d="M24 4 L42 24 L24 44 L6 24Z"/><path className="res-line" d="M24 13 L33 24 L24 35 L15 24Z"/></>:
   kind==="dust"?<><path className="res-dust" d="M24 5 L30 18 L43 24 L30 30 L24 43 L18 30 L5 24 L18 18Z"/><circle className="res-core" cx="24" cy="24" r="5"/></>:
   <><path className="res-shard" d="M24 4 L40 16 L35 38 L15 43 L7 23Z"/><path className="res-line" d="M24 5 L22 37 M8 23 L35 38 M40 16 L15 43"/></>}
 </svg>
}
export function StatGlyph({kind="strength"}:{kind?:string}){
 return <svg className={"code-art stat-glyph stat-"+kind} viewBox="0 0 64 64" aria-hidden="true">
  <circle className="stat-bg" cx="32" cy="32" r="28"/>
  {kind==="strength"?<><path className="stat-metal" d="M15 49 L39 13 L49 18 L27 54Z"/><path className="stat-gold" d="M15 42 L30 53"/></>:kind==="endurance"?<path className="stat-heart" d="M32 52 Q8 36 12 21 Q17 8 32 20 Q47 8 52 21 Q56 36 32 52Z"/>:<><circle className="stat-focus" cx="32" cy="32" r="12"/><path className="stat-rays" d="M32 5 V15 M32 49 V59 M5 32 H15 M49 32 H59 M13 13 L20 20 M44 44 L51 51 M51 13 L44 20 M20 44 L13 51"/></>}
 </svg>
}
export function ForgeGlyph(){
 return <svg className="code-art forge-glyph" viewBox="0 0 72 72" aria-hidden="true"><path className="forge-handle" d="M18 61 L46 30"/><path className="forge-head" d="M31 13 H59 L65 22 L54 34 L38 27 L27 38 L16 27Z"/><path className="forge-spark" d="M58 43 L63 51 M47 49 L47 60 M62 34 L70 35"/></svg>
}
