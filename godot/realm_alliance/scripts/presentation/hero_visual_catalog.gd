extends RefCounted
class_name RAHeroVisualCatalog
# Reviewed directly on normalized 640x512 alpha sprites. No screen-pixel offsets.
const HANDS={"idle":Vector2(496,353),"ready":Vector2(518,260),"windup":Vector2(389,152),"attack_contact":Vector2(577,278),"recovery":Vector2(509,339),"hit":Vector2(459,195)}
const ANGLES={"idle":-28.0,"ready":-34.0,"windup":-74.0,"attack_contact":-8.0,"recovery":-25.0,"hit":-45.0}
const SOCKETS={"idle":{"chest":Vector2(433,266),"head":Vector2(439,192),"back":Vector2(390,250)},"ready":{"chest":Vector2(448,278),"head":Vector2(460,214),"back":Vector2(408,270)},"windup":{"chest":Vector2(449,272),"head":Vector2(463,219),"back":Vector2(408,253)},"attack_contact":{"chest":Vector2(422,323),"head":Vector2(474,250),"back":Vector2(385,300)},"recovery":{"chest":Vector2(455,270),"head":Vector2(475,199),"back":Vector2(410,260)},"hit":{"chest":Vector2(445,267),"head":Vector2(432,213),"back":Vector2(400,255)}}
const ARMS={"idle":Rect2(477,307,40,67),"ready":Rect2(490,241,43,64),"windup":Rect2(359,140,60,98),"attack_contact":Rect2(459,255,137,43),"recovery":Rect2(478,295,47,65),"hit":Rect2(432,181,46,60)}
