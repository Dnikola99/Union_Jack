@tool
class_name InjectAnimationToObject
extends Node3D

@export var skeleton:Skeleton3D
@export var animation_player:AnimationPlayer
@export var animation_configuration:Array[AnimationConfig] = []

@export var add_animation_and_adjust:bool = false :
	set(v):
		if v :
			process_all_animation()

func process_all_animation():
	for a in animation_configuration :
		add_and_adjust_animation(a.animation_name, a.time_scale, a.loop)

func add_and_adjust_animation(animation_name:String, time_scale:float, loop:int):
	#target_rest * inverse(source_rest) * animated_pose
	var file_path:String = "res://Tools/animation_library/"+animation_name+".json"
	if not FileAccess.file_exists(file_path) :
		print(file_path+" not exist")
		return
	var f:FileAccess = FileAccess.open(file_path,FileAccess.READ)
	var dct:Dictionary = JSON.parse_string(f.get_as_text())
	f.close()
	if time_scale <= 0 :
		print("time scale must > 0 ")
		return
	var duration:float = dct.duration / time_scale
	var sampling:float = dct.sampling
	if sampling <= 0.0 :
		print("bad sampling 0")
		return
	
	var anim = Animation.new()
	anim.length = duration
	anim.loop_mode = loop
	var skeleton_name:String = skeleton.name
	for track_name in dct.tracks :
		var position_track:int = anim.add_track(Animation.TYPE_POSITION_3D)
		var rotation_track:int = anim.add_track(Animation.TYPE_ROTATION_3D)
		anim.track_set_path(position_track, skeleton_name+":"+track_name)
		anim.track_set_path(rotation_track, skeleton_name+":"+track_name)
		
		var current_track_data:Array = dct.tracks[track_name]
		for i in current_track_data.size() :
			var time:float = current_track_data[i].time / time_scale
			var pos:Vector3 = str_to_var("Vector3"+current_track_data[i].position)
			anim.track_insert_key(position_track, time, pos)
			var quat:Quaternion = str_to_var("Quaternion"+current_track_data[i].rotation)
			quat = quat.normalized()
			anim.track_insert_key(rotation_track, time,  quat)
			
	
	var lib:AnimationLibrary = animation_player.get_animation_library("")
	if not lib :
		lib = AnimationLibrary.new()
		animation_player.add_animation_library("", lib)
		
	var old_anim:Animation = lib.get_animation(animation_name)
	if old_anim :
		lib.remove_animation(animation_name)
	lib.add_animation(animation_name, anim)
