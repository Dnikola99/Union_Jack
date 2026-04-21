@tool
class_name InjectAnimationToObject
extends Node3D

@export var skeleton:Skeleton3D
@export var animation_player:AnimationPlayer
@export var animation_configuration:Array[AnimationConfig] = []
@export var bone_mapping_db:BoneMappingSet
@export var create_root_motion:bool = false

@export var add_animation_and_adjust:bool = false :
	set(v):
		if v :
			process_all_animation()

func process_all_animation():
	for a in animation_configuration :
		add_and_adjust_animation(a.animation, a.time_scale, a.loop)

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

func add_and_adjust_animation(animation:StoredAnimation, time_scale:float, loop:int):
	if time_scale <= 0 :
		print("time scale must > 0 ")
		return
		
	var duration:float = animation.duration / time_scale
	var sampling:float = animation.sampling
	if sampling <= 0.0 :
		print("bad sampling 0")
		return
		
	var anim = Animation.new()
	anim.length = animation.tracks[0].key_frames[animation.tracks[0].key_frames.size()-1].time / time_scale
	anim.loop_mode = loop
	var skeleton_name:String = skeleton.name
	
	var root_position_track:int
	var root_rotation_track:int
	if create_root_motion :
		var full_animation_path:String = skeleton_name+":root"
		root_position_track = anim.add_track(Animation.TYPE_POSITION_3D)
		root_rotation_track = anim.add_track(Animation.TYPE_ROTATION_3D)
		anim.track_set_path(root_position_track, full_animation_path)
		anim.track_set_path(root_rotation_track, full_animation_path)
		#anim.track_set_interpolation_loop_wrap(root_position_track, false)
		#anim.track_set_interpolation_loop_wrap(root_rotation_track, false)
			
	for track:StoredTrack in animation.tracks:
		var anim_track_name:String = map_track(bone_mapping_db, track.track_name)
		var target_bone_id:int = skeleton.find_bone(anim_track_name)
		if target_bone_id < 0: continue
		
		var full_animation_path:String = skeleton_name+":"+anim_track_name
		var position_track:int = anim.add_track(Animation.TYPE_POSITION_3D)
		var rotation_track:int = anim.add_track(Animation.TYPE_ROTATION_3D)
		anim.track_set_path(position_track, full_animation_path)
		anim.track_set_path(rotation_track, full_animation_path)
		

		var target_rest:Transform3D = skeleton.get_bone_rest(target_bone_id)
		var source_rest:Transform3D = track.rest_pose
		var rotation_offset:Basis = target_rest.basis.inverse() * source_rest.basis
		var root_bone:bool = is_root_bone(bone_mapping_db, track.track_name)

		for key_frame:StoredKeyFrame in track.key_frames:
			var source_delta_basis := Basis(key_frame.rotation)
			var source_delta_pos := key_frame.position
			
			var corrected_basis:Basis = rotation_offset * source_delta_basis * rotation_offset.inverse()
			
			var final_basis:Basis = target_rest.basis * corrected_basis
			var final_pos:Vector3 = target_rest.origin + (target_rest.basis * (rotation_offset * source_delta_pos))
			
			var time:float = key_frame.time / time_scale
			if root_bone and create_root_motion :
				var pos:Vector3 = final_pos
				pos.x = 0
				pos.z = 0
				anim.track_insert_key(position_track, time, pos)
				anim.track_insert_key(rotation_track, time, final_basis.get_rotation_quaternion())
				final_pos.y = 0
				anim.track_insert_key(root_position_track, time, final_pos)
				#anim.track_insert_key(root_rotation_track, time, final_basis.get_rotation_quaternion())
			else :
				anim.track_insert_key(position_track, time, final_pos)
				anim.track_insert_key(rotation_track, time, final_basis.get_rotation_quaternion())
			
	# create script keyframes
		
	var lib:AnimationLibrary = animation_player.get_animation_library("")
	if not lib :
		lib = AnimationLibrary.new()
		animation_player.add_animation_library("", lib)
		
	var old_anim:Animation = lib.get_animation(animation.animation_name)
	if old_anim :
		lib.remove_animation(animation.animation_name)
	lib.add_animation(animation.animation_name, anim)
