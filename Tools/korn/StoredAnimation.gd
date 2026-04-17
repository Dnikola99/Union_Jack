class_name StoredAnimation
extends Resource

@export var animation_name:String
@export var duration:float
@export var sampling:float
@export var tracks:Array[StoredTrack]

func has_track(track_name:String)->bool:
	for t in tracks :
		if t.track_name == track_name :
			return true
	return false

func get_track_by_name(track_name:String)->StoredTrack :
	for t in tracks :
		if t.track_name == track_name :
			return t
	return null
