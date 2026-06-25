extends CharacterBody3D

const FLY_SPEED := 9.0
const TURN_SPEED := 2.5
const DETECT_RANGE := 90.0
const FIRE_RANGE := 38.0
const BITE_RANGE := 7.0
const FIRE_COOLDOWN := 2.2
const BITE_COOLDOWN := 1.6
const BITE_DAMAGE := 28.0
const HOVER_HEIGHT_OFFSET := 8.0
const ALTITUDE_MIN := 4.0
const ALTITUDE_MAX := 22.0

const ANIM_IDLE_CANDIDATES := ["Idle-loop", "Idle", "Take 001"]
const ANIM_FLY_CANDIDATES := ["Flying-loop", "Flying", "Fly", "Take 001"]
const ANIM_BITE_CANDIDATES := ["Walk-loop", "Walk", "Attack", "Take 001"]

const FIREBALL_SCENE := preload("res://scenes/dragon_fireball.tscn")

@export var max_health: float = 350.0

@onready var model_root: Node3D = $ModelRoot
@onready var mouth: Marker3D = $Mouth
@onready var bite_area: Area3D = $BiteArea
@onready var roar_player: AudioStreamPlayer3D = $RoarPlayer
@onready var fire_player: AudioStreamPlayer3D = $FirePlayer
@onready var bite_player: AudioStreamPlayer3D = $BitePlayer

var _health: float
var _player: Node3D
var _alive: bool = true
var _fire_timer: float = 0.0
var _bite_timer: float = 0.0
var _wing_time: float = 0.0
var _attacking: bool = false
var _animation_player: AnimationPlayer
var _current_anim: String = ""
var _model_instance: Node3D
var _mesh_instances: Array[MeshInstance3D] = []
var _anim_idle: String = ""
var _anim_fly: String = ""
var _anim_bite: String = ""
var _anim_state: String = "idle"


func _ready() -> void:
	add_to_group("enemies")
	_health = max_health
	roar_player.stream = AudioFactory.dragon_roar()
	fire_player.stream = AudioFactory.dragon_fire()
	bite_player.stream = AudioFactory.dragon_bite()
	bite_area.body_entered.connect(_on_bite_area_body_entered)
	call_deferred("_setup_model")
	call_deferred("_find_player")


func _find_player() -> void:
	_player = get_tree().get_first_node_in_group("player") as Node3D


func _physics_process(delta: float) -> void:
	if not _alive:
		return

	if not is_instance_valid(_player):
		_find_player()
		return

	_fire_timer = maxf(_fire_timer - delta, 0.0)
	_bite_timer = maxf(_bite_timer - delta, 0.0)
	_wing_time += delta

	var to_player := _player.global_position - global_position
	var flat_distance := Vector2(to_player.x, to_player.z).length()
	var vertical_distance := absf(to_player.y - global_position.y)

	if flat_distance > DETECT_RANGE and vertical_distance > DETECT_RANGE:
		_idle_hover(delta)
		_set_animation_state("idle")
	else:
		_chase_and_attack(delta, to_player, flat_distance)

	move_and_slide()


func _idle_hover(delta: float) -> void:
	velocity = velocity.lerp(Vector3.ZERO, delta * 2.0)
	velocity.y = sin(_wing_time * 1.5) * 0.8


func _chase_and_attack(delta: float, to_player: Vector3, flat_distance: float) -> void:
	if not _attacking:
		_set_animation_state("fly")

	var target_pos := _player.global_position + Vector3(0.0, HOVER_HEIGHT_OFFSET, 0.0)
	var move_dir := (target_pos - global_position)
	move_dir.y *= 0.6
	if move_dir.length_squared() > 0.01:
		move_dir = move_dir.normalized()
		velocity = move_dir * FLY_SPEED
	else:
		velocity = velocity.lerp(Vector3.ZERO, delta * 4.0)

	velocity.y = clampf(velocity.y, -4.0, 4.0)
	global_position.y = clampf(global_position.y, ALTITUDE_MIN, ALTITUDE_MAX)

	var look_dir := Vector3(to_player.x, global_position.y, to_player.z) - global_position
	if look_dir.length_squared() > 0.01:
		_rotate_toward(look_dir.normalized(), delta)

	if _attacking:
		return

	if flat_distance <= BITE_RANGE and _bite_timer <= 0.0:
		_try_bite()
	elif flat_distance <= FIRE_RANGE and _fire_timer <= 0.0:
		_try_fire()


func _rotate_toward(direction: Vector3, delta: float) -> void:
	var current_quat := global_transform.basis.get_rotation_quaternion()
	var target_quat := Basis.looking_at(direction, Vector3.UP).get_rotation_quaternion()
	global_transform.basis = Basis(current_quat.slerp(target_quat, delta * TURN_SPEED))


func _try_fire() -> void:
	if not _has_line_of_sight(_player):
		return

	_attacking = true
	_fire_timer = FIRE_COOLDOWN
	fire_player.play()
	_play_one_shot_animation(_anim_fly, 0.75)

	for i in 3:
		var fireball := FIREBALL_SCENE.instantiate()
		get_tree().current_scene.add_child(fireball)
		var spread := deg_to_rad(-8.0 + i * 8.0)
		var direction := -global_transform.basis.z.rotated(global_transform.basis.y, spread)
		fireball.launch(mouth.global_position, direction.normalized())

	await get_tree().create_timer(0.6).timeout
	if not is_instance_valid(self):
		return
	_attacking = false
	_set_animation_state("fly")


func _try_bite() -> void:
	_attacking = true
	_bite_timer = BITE_COOLDOWN
	bite_player.play()
	_play_one_shot_animation(_anim_bite, 1.35)

	velocity += -global_transform.basis.z * 6.0

	bite_area.monitoring = true
	await get_tree().create_timer(0.35).timeout
	if not is_instance_valid(self):
		return
	bite_area.monitoring = false
	_attacking = false
	_set_animation_state("fly")


func _on_bite_area_body_entered(body: Node3D) -> void:
	if body == self or not body.is_in_group("player"):
		return
	if body.has_method("take_damage"):
		body.take_damage(BITE_DAMAGE, global_position)


func _has_line_of_sight(target: Node3D) -> bool:
	var space_state := get_world_3d().direct_space_state
	var origin := mouth.global_position
	var end := target.global_position + Vector3(0.0, 1.0, 0.0)
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = [get_rid()]
	var result := space_state.intersect_ray(query)
	if result.is_empty():
		return true
	return result.collider == target or result.collider.is_in_group("player")


func _setup_model() -> void:
	_model_instance = model_root.get_node_or_null("DragonModel") as Node3D
	if not _model_instance and model_root.get_child_count() > 0:
		_model_instance = model_root.get_child(0) as Node3D

	if not _model_instance:
		_build_fallback_model()

	_animation_player = _find_animation_player(_model_instance)
	_anim_idle = _resolve_animation(ANIM_IDLE_CANDIDATES)
	_anim_fly = _resolve_animation(ANIM_FLY_CANDIDATES)
	_anim_bite = _resolve_animation(ANIM_BITE_CANDIDATES)
	_mesh_instances = _collect_mesh_instances(_model_instance)
	_attach_mouth_to_head()
	_set_animation_state("idle")


func _build_fallback_model() -> void:
	for child in model_root.get_children():
		child.queue_free()

	_model_instance = Node3D.new()
	_model_instance.name = "DragonModel"
	model_root.add_child(_model_instance)
	ModelFactory.build_dragon(_model_instance)


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer

	for child in node.get_children():
		var found := _find_animation_player(child)
		if found:
			return found

	return null


func _collect_mesh_instances(node: Node, meshes: Array[MeshInstance3D] = []) -> Array[MeshInstance3D]:
	if node is MeshInstance3D:
		meshes.append(node)

	for child in node.get_children():
		_collect_mesh_instances(child, meshes)

	return meshes


func _attach_mouth_to_head() -> void:
	var head_bone := _find_node_by_name(_model_instance, "Head")
	if not head_bone:
		head_bone = _find_node_by_name(_model_instance, "Jaw")
	if not head_bone:
		head_bone = _find_node_by_name(_model_instance, "World_Dragon")
	if head_bone:
		mouth.reparent(head_bone, false)
		mouth.position = Vector3(0.0, 0.15, 0.45)
		mouth.rotation_degrees = Vector3.ZERO
	else:
		mouth.position = Vector3(0.0, 2.0, -2.5)


func _find_node_by_name(node: Node, node_name: String) -> Node3D:
	if node.name == node_name and node is Node3D:
		return node as Node3D

	for child in node.get_children():
		var found := _find_node_by_name(child, node_name)
		if found:
			return found

	return null


func _resolve_animation(candidates: Array) -> String:
	if not _animation_player:
		return String(candidates[0])

	for candidate in candidates:
		var anim_name := String(candidate)
		if _animation_player.has_animation(anim_name):
			return anim_name

	for lib_name in _animation_player.get_animation_library_list():
		var library := _animation_player.get_animation_library(lib_name)
		for anim_name in library.get_animation_list():
			for candidate in candidates:
				if anim_name.find(String(candidate)) != -1:
					return anim_name

	return String(candidates[0])


func _set_animation_state(state: String) -> void:
	if _anim_state == state or not _animation_player:
		return

	_anim_state = state
	var anim_name := _anim_idle
	match state:
		"fly":
			anim_name = _anim_fly
		"idle":
			anim_name = _anim_idle
		"bite":
			anim_name = _anim_bite

	_play_looping_animation(anim_name)


func _play_looping_animation(anim_name: String) -> void:
	if not _animation_player or anim_name.is_empty():
		return
	if not _animation_player.has_animation(anim_name):
		return

	if _current_anim == anim_name and _animation_player.is_playing():
		return

	_current_anim = anim_name
	_animation_player.speed_scale = 1.0
	_animation_player.play(anim_name)


func _play_one_shot_animation(anim_name: String, speed_scale: float = 1.0) -> void:
	if not _animation_player or anim_name.is_empty():
		return
	if not _animation_player.has_animation(anim_name):
		return

	_current_anim = anim_name
	_animation_player.speed_scale = speed_scale
	_animation_player.play(anim_name)


func take_damage(amount: float, _hit_position: Vector3 = Vector3.ZERO) -> void:
	if not _alive:
		return

	_health -= amount
	_flash_hit()

	if _health <= 0.0:
		_die()
	elif _health < max_health * 0.5 and randf() < 0.25:
		roar_player.play()


func _flash_hit() -> void:
	for mesh in _mesh_instances:
		var mat := mesh.get_active_material(0) as StandardMaterial3D
		if not mat:
			continue

		var original := mat.albedo_color
		mat.albedo_color = Color(1.0, 0.5, 0.3)
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(mat):
			mat.albedo_color = original


func _die() -> void:
	_alive = false
	roar_player.pitch_scale = 0.8
	roar_player.play()
	velocity = Vector3.ZERO
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	if _animation_player and not _anim_bite.is_empty():
		_animation_player.speed_scale = 0.35
		_animation_player.play(_anim_bite)

	if _model_instance:
		var tween := create_tween()
		tween.tween_property(_model_instance, "position:y", _model_instance.position.y - 2.0, 1.2)
		tween.parallel().tween_property(_model_instance, "rotation:z", _model_instance.rotation.z + 0.5, 1.2)

	await get_tree().create_timer(1.5).timeout
	queue_free()
