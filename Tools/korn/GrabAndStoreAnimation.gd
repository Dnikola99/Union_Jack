@tool
class_name GrabAndStoreAnimation
extends Node3D

@export var animation_player:AnimationPlayer
@export var skeleton:Skeleton3D
@export var target_animation_names:Array[CopyTargetAnimation]
@export var animation_sampling_seconds:float = 0.1

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
	var result:StoredAnimation = StoredAnimation.new()
	result.animation_name = save_name
	result.duration = length
	result.sampling = animation_sampling_seconds
	result.tracks = []
	
	var bone_count:int = skeleton.get_bone_count()
	var sampled_time:float = 0.0
	
	for b in bone_count :
		var ctrack:StoredTrack = StoredTrack.new()
		ctrack.track_name = skeleton.get_bone_name(b)
		ctrack.rest_pose = skeleton.get_bone_rest(b)
		ctrack.key_frames = []
		result.tracks.append(ctrack)
		
		sampled_time = 0.0
		while sampled_time < length:
			animation_player.seek(sampled_time, true)
			
			var rest = skeleton.get_bone_rest(b)
			var pose = skeleton.get_bone_pose(b)
			var relative = rest.inverse() * pose
				
			var kframe:StoredKeyFrame = StoredKeyFrame.new()
			kframe.time = sampled_time
			kframe.position = relative.origin
			kframe.rotation = relative.basis.get_rotation_quaternion()
			ctrack.key_frames.append(kframe)
				
			sampled_time += animation_sampling_seconds
	ResourceSaver.save(result, "res://Tools/animation_library/"+save_name+".tres")
	
