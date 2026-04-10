@tool
class_name GrabAndStoreAnimation
extends Node3D

@export var animation_player:AnimationPlayer
@export var skeleton:Skeleton3D
@export var target_animation_names:Array[CopyTargetAnimation]
@export var animation_sampling_seconds:float = 0.1
@export var bone_map_db:BoneMappingSet

@export var export_listed_animation:bool = false :
	set(v):
		for an in target_animation_names :
			export_animation_by_name(an.source_name, an.save_name)

func export_animation_by_name(animation_name:String, save_name:String):
	if animation_sampling_seconds < 0.0 :
		print("sampling cannot be zero")
		return
	var anim:Animation = animation_player.get_animation(animation_name)
	if not animation_player.has_animation(animation_name):
		print(animation_name + " is not exist")
		return
	var length:float = anim.length
	
	animation_player.play(animation_name, 0, 0, false)
	var result:Dictionary = {}
	result.duration = length
	result.sampling = animation_sampling_seconds
	result.tracks = {}
	var root_start:Vector3 = Vector3.ZERO
	var root_initialized := false
	var bone_count:int = skeleton.get_bone_count()
	var t:float = 0.0
	while t < length:
		animation_player.seek(t, true)
		for b in bone_count :
			var bname:String = skeleton.get_bone_name(b)
			if not bname in result.tracks :
				result.tracks[bname] = {}
				var rest_pos:Transform3D = skeleton.get_bone_rest(b)
				result.tracks[bname].rest_pose = rest_pos
				result.tracks[bname].content = []
				
			var norm_name:String = bname.to_upper()
			if norm_name == "MIXAMORIG_HIPS" :
				print("root bone")
				var pose:Transform3D = skeleton.get_bone_pose(b)
				if not root_initialized:
					root_start =  skeleton.get_bone_rest(b).origin
					root_initialized = true
				pose.origin -= root_start
				pose.basis = pose.basis.orthonormalized()
				
				result.tracks[bname].content.append({
					time = t,
					transform = pose
				})
			else:
				var rest = skeleton.get_bone_rest(b)
				var pose = skeleton.get_bone_pose(b)
				var relative = rest.inverse() * pose
				#var rot:Quaternion = relative.basis.get_rotation_quaternion()
				#relative.basis = Basis(rot)
				
				#relative = rest.inverse() * pose
				#relative.basis = offset * relative.basis
				result.tracks[bname].content.append({
					time = t,
					transform = relative
				})
				
		t += animation_sampling_seconds
	var f:FileAccess = FileAccess.open("res://Tools/animation_library/"+save_name+".json", FileAccess.WRITE)
	f.store_string(JSON.stringify(result, "\t", false))
	f.close()
	
