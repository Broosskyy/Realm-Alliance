extends Node
class_name RACombatAudio
# Small authored PCM sounds, preloaded once; bounded voices, no external licenses.
var enabled: bool = true
var voices: Array[AudioStreamPlayer] = []
var sounds: Dictionary = {}
var cursor: int = 0
func _ready() -> void:
    for id in ["swing","impact","fire","arcane","shield","reward"]:
        sounds[id]=load("res://assets/audio/"+id+".wav")
    for i in 4:
        var v=AudioStreamPlayer.new();v.volume_db=-19;add_child(v);voices.append(v)
func play(id: String) -> void:
    if not enabled or voices.is_empty() or not sounds.has(id):return
    var v=voices[cursor%voices.size()];cursor+=1
    v.stream=sounds[id];v.play()
