@tool
class_name InjectAnimationToObject
extends Node3D

@export var skeleton:Skeleton3D
@export var animation_player:AnimationPlayer
@export var animation_configuration:Array[AnimationConfig] = []
@export var bone_mapping_db:BoneMappingSet

@export var add_animation_and_adjust:bool = false :
	set(v):
		if v :
			process_all_animation()

func process_all_animation():
	for a in animation_configuration :
		add_and_adjust_animation(a.animation_name, a.time_scale, a.loop)

func map_track(db:BoneMappingSet, _name:String) -> String:
	for m in db.mapping:
		if m.source_name == _name :
			return m.target_name
	return ""
	
func is_root_bone(db:BoneMappingSet, _name:String) -> bool:
	for m in db.mapping:
		if m.source_name == _name :
			return m.root
	return false
	
func _extract_vec3(s: String, key: String) -> Vector3:
	var start = s.find(key + ": (")
	if start == -1:
		return Vector3.ZERO

	start = s.find("(", start) + 1
	var end = s.find(")", start)

	var parts = s.substr(start, end - start).split(",")

	return Vector3(
		float(parts[0]),
		float(parts[1]),
		float(parts[2])
	)

func parse_transform3d(s: String) -> Transform3D:
	var x = _extract_vec3(s, "X")
	var y = _extract_vec3(s, "Y")
	var z = _extract_vec3(s, "Z")
	var o = _extract_vec3(s, "O")

	var _basis = Basis(x, y, z).orthonormalized()
	return Transform3D(_basis, o)

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
	var skeleton_name:String = skeleton.get_path()
	for lib_track_name in dct.tracks :
		var track_name:String = map_track(bone_mapping_db, lib_track_name)
		var target_bone_id:int = skeleton.find_bone(track_name)
		if target_bone_id < 0 : continue
		var root_bone:bool = is_root_bone(bone_mapping_db, lib_track_name)
		var full_animation_path:String = skeleton_name+":"+track_name
		var position_track:int = anim.add_track(Animation.TYPE_POSITION_3D)
		var rotation_track:int = anim.add_track(Animation.TYPE_ROTATION_3D)
		anim.track_set_path(position_track, full_animation_path)
		anim.track_set_path(rotation_track, full_animation_path)
		
		var current_track_data:Array = dct.tracks[lib_track_name].content
		var source_rest:Transform3D = parse_transform3d(dct.tracks[lib_track_name].rest_pose)
		var target_rest:Transform3D = skeleton.get_bone_rest(target_bone_id)
		
		#var src_forward = source_rest.basis.z
		#var tgt_forward = target_rest.basis.z
		#var flipped:bool = false
		#if src_forward.dot(tgt_forward) < 0:
			#flipped = true
		
		#var src_rot = source_rest.basis.get_rotation_quaternion()
		#var tgt_rot = target_rest.basis.get_rotation_quaternion()
		#var correction_rot = tgt_rot * src_rot.inverse()

		for i in current_track_data.size() :
			var animation_pose:Transform3D  = parse_transform3d(current_track_data[i].transform)
			var final:Transform3D = target_rest * animation_pose
			final.basis = final.basis.orthonormalized()

			var pos:Vector3 = final.origin
			var quat:Quaternion = final.basis.get_rotation_quaternion()
			if root_bone :
				pos = animation_pose.origin
			
			var time:float = current_track_data[i].time / time_scale
			anim.track_insert_key(position_track, time, pos)
			anim.track_insert_key(rotation_track, time,  quat)
			
	
	var lib:AnimationLibrary = animation_player.get_animation_library("")
	if not lib :
		lib = AnimationLibrary.new()
		animation_player.add_animation_library("", lib)
		
	var old_anim:Animation = lib.get_animation(animation_name)
	if old_anim :
		lib.remove_animation(animation_name)
	lib.add_animation(animation_name, anim)
