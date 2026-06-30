extends CharacterBody3D

signal defeated

enum State { CHASE, WINDUP, SLAM, RECOVER }

const SKETCHFAB_MODEL := "res://assets/models/golem/sketchfab/golem.glb"
const SKETCHFAB_SCALE := Vector3(2.2, 2.2, 2.2)

const WALK_SPEED := 3.6
const TURN_SPEED := 5.0
const DETECT_RANGE := 48.0
const SLAM_RANGE := 5.0
const SLAM_DAMAGE := 40.0
const SLAM_COOLDOWN := 3.0
const WINDUP_TIME := 0.6
const SLAM_DROP_TIME := 0.18
const RECOVER_TIME := 0.7
const GROUND_BODY_OFFSET := 1.35
const LIFT_HEIGHT := 1.35

const ANIM_IDLE_CANDIDATES := ["Idle", "IdlePieces", "Armature|Armature|mixamo.com|Layer0"]
const ANIM_WALK_CANDIDATES := ["Walk", "Armature|Armature|mixamo.com|Layer0"]
const ANIM_SLAM_CANDIDATES := ["Attack1", "Attack2", "Attack3", "Armature|Armature|mixamo.com|Layer0"]

@export var max_health: float = 220.0

@onready var model_root: Node3D = $ModelRoot
@onready var slam_area: Area3D = $SlamArea
@onready var growl_player: AudioStreamPlayer3D = $GrowlPlayer
@onready var slam_player: AudioStreamPlayer3D = $SlamPlayer
@onready var death_player: AudioStreamPlayer3D = $DeathPlayer
@onready var hit_player: AudioStreamPlayer3D = $HitPlayer

var _health: float
var _player: Node3D
var _alive: bool = true
var _state: State = State.CHASE
var _slam_timer: float = 0.0
var _mesh_instances: Array[MeshInstance3D] = []
var _model_base_y: float = 0.0
var _model_instance: Node3D
var _animation_player: AnimationPlayer
var _current_anim: String = ""
var _anim_idle: String = ""
var _anim_walk: String = ""
var _anim_slam: String = ""
var _arm_left: Node3D
var _arm_right: Node3D


func _ready() -> void:
	add_to_group("enemies")
	_health = max_health
	_model_base_y = model_root.position.y
	growl_player.stream = AudioFactory.golem_growl()
	slam_player.stream = AudioFactory.golem_slam()
	death_player.stream = AudioFactory.golem_death()
	hit_player.stream = AudioFactory.golem_hit()
	slam_area.body_entered.connect(_on_slam_area_body_entered)
	call_deferred("_setup_model")
	call_deferred("_find_player")


func _find_player() -> void:
	_player = get_tree().get_first_node_in_group("player") as Node3D


func _setup_model() -> void:
	for child in model_root.get_children():
		child.queue_free()

	if ResourceLoader.exists(SKETCHFAB_MODEL):
		var packed := load(SKETCHFAB_MODEL) as PackedScene
		if packed:
			_model_instance = packed.instantiate()
			_model_instance.name = "GolemSketchfab"
			_model_instance.scale = SKETCHFAB_SCALE
			model_root.add_child(_model_instance)

	if not _model_instance:
		_model_instance = Node3D.new()
		_model_instance.name = "GolemModel"
		model_root.add_child(_model_instance)
		var built := ModelFactory.build_golem(_model_instance)
		_mesh_instances = built.meshes
		_arm_left = built.arm_left
		_arm_right = built.arm_right

	if _mesh_instances.is_empty() and _model_instance:
		_mesh_instances = _collect_mesh_instances(_model_instance)

	_animation_player = _find_animation_player(_model_instance)
	_anim_idle = _resolve_animation(ANIM_IDLE_CANDIDATES)
	_anim_walk = _resolve_animation(ANIM_WALK_CANDIDATES)
	_anim_slam = _resolve_animation(ANIM_SLAM_CANDIDATES)
	_play_looping_animation(_anim_idle, 1.0)


func _physics_process(delta: float) -> void:
	if not _alive:
		return

	if not is_instance_valid(_player):
		_find_player()
		_snap_to_ground(delta)
		move_and_slide()
		return

	_slam_timer = maxf(_slam_timer - delta, 0.0)

	if _state == State.CHASE:
		_chase(delta)
	else:
		_snap_to_ground(delta)
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()


func _chase(delta: float) -> void:
	_snap_to_ground(delta)

	var flat_distance := Vector2(
		_player.global_position.x - global_position.x,
		_player.global_position.z - global_position.z
	).length()

	if flat_distance > DETECT_RANGE:
		_idle(delta)
		return

	var flat_to_player := Vector2(
		_player.global_position.x - global_position.x,
		_player.global_position.z - global_position.z
	)
	var flat_dir := Vector2.ZERO
	if flat_to_player.length_squared() > 0.01:
		flat_dir = flat_to_player.normalized()

	if flat_dir.length_squared() > 0.01:
		_rotate_toward(Vector3(flat_dir.x, 0.0, flat_dir.y), delta)

	if flat_distance <= SLAM_RANGE and _slam_timer <= 0.0:
		_start_slam()
		return

	velocity.x = flat_dir.x * WALK_SPEED
	velocity.z = flat_dir.y * WALK_SPEED
	_play_looping_animation(_anim_walk, 1.0)


func _idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, WALK_SPEED * delta * 6.0)
	velocity.z = move_toward(velocity.z, 0.0, WALK_SPEED * delta * 6.0)
	_play_looping_animation(_anim_idle, 1.0)


func _start_slam() -> void:
	_state = State.WINDUP
	_slam_timer = SLAM_COOLDOWN
	velocity = Vector3.ZERO
	growl_player.pitch_scale = randf_range(0.9, 1.05)
	growl_player.play()
	_raise_arms()

	if not _anim_slam.is_empty():
		_play_one_shot_animation(_anim_slam, 0.9)

	var lift_y := _sample_ground_height(global_position) + GROUND_BODY_OFFSET + LIFT_HEIGHT
	var tween := create_tween()
	tween.tween_property(self, "global_position:y", lift_y, WINDUP_TIME)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	if not is_instance_valid(self) or not _alive:
		return

	_state = State.SLAM
	slam_player.pitch_scale = randf_range(0.92, 1.08)
	slam_player.play()
	slam_area.monitoring = true

	var ground_y := _sample_ground_height(global_position) + GROUND_BODY_OFFSET
	var drop := create_tween()
	drop.tween_property(self, "global_position:y", ground_y, SLAM_DROP_TIME)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await drop.finished
	if not is_instance_valid(self):
		return

	await get_tree().create_timer(0.12).timeout
	if not is_instance_valid(self):
		return

	slam_area.monitoring = false
	_state = State.RECOVER
	_reset_arms()
	await get_tree().create_timer(RECOVER_TIME).timeout
	if not is_instance_valid(self) or not _alive:
		return

	_state = State.CHASE
	_play_looping_animation(_anim_idle, 1.0)


func _raise_arms() -> void:
	if _arm_left:
		var tween_l := create_tween()
		tween_l.tween_property(_arm_left, "rotation:x", deg_to_rad(-125.0), WINDUP_TIME * 0.85)
	if _arm_right:
		var tween_r := create_tween()
		tween_r.tween_property(_arm_right, "rotation:x", deg_to_rad(-125.0), WINDUP_TIME * 0.85)


func _reset_arms() -> void:
	if _arm_left:
		var tween_l := create_tween()
		tween_l.tween_property(_arm_left, "rotation:x", 0.0, RECOVER_TIME)
	if _arm_right:
		var tween_r := create_tween()
		tween_r.tween_property(_arm_right, "rotation:x", 0.0, RECOVER_TIME)


func _on_slam_area_body_entered(body: Node3D) -> void:
	if not _alive or _state != State.SLAM:
		return
	if body == self or not body.is_in_group("player"):
		return
	if body.has_method("take_damage"):
		body.take_damage(SLAM_DAMAGE, global_position)


func _sample_ground_height(pos: Vector3) -> float:
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		pos + Vector3(0.0, 20.0, 0.0),
		pos + Vector3(0.0, -20.0, 0.0)
	)
	query.exclude = [get_rid()]
	var hit := space_state.intersect_ray(query)
	if hit.is_empty():
		return pos.y - GROUND_BODY_OFFSET
	return hit.position.y


func _snap_to_ground(delta: float) -> void:
	var ground_y := _sample_ground_height(global_position) + GROUND_BODY_OFFSET
	global_position.y = lerpf(global_position.y, ground_y, delta * 10.0)
	velocity.y = 0.0


func _rotate_toward(direction: Vector3, delta: float) -> void:
	if direction.length_squared() <= 0.01:
		return
	var current_quat := global_transform.basis.get_rotation_quaternion()
	var target_quat := Basis.looking_at(direction.normalized(), Vector3.UP).get_rotation_quaternion()
	global_transform.basis = Basis(current_quat.slerp(target_quat, delta * TURN_SPEED))


func take_damage(amount: float, _hit_position: Vector3 = Vector3.ZERO) -> void:
	if not _alive:
		return

	_health -= amount
	hit_player.pitch_scale = randf_range(0.9, 1.1)
	hit_player.play()
	_flash_hit()

	if _health <= 0.0:
		_die()
	elif randf() < 0.25:
		growl_player.pitch_scale = randf_range(0.85, 1.05)
		growl_player.play()


func _flash_hit() -> void:
	for mesh in _mesh_instances:
		var mat := mesh.get_active_material(0) as StandardMaterial3D
		if not mat:
			continue

		var original := mat.albedo_color
		mat.albedo_color = Color(0.95, 0.55, 0.35)
		await get_tree().create_timer(0.08).timeout
		if is_instance_valid(mat):
			mat.albedo_color = original


func _die() -> void:
	_alive = false
	defeated.emit()
	_state = State.RECOVER
	death_player.play()
	velocity = Vector3.ZERO
	slam_area.monitoring = false
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)

	if model_root:
		var tween := create_tween()
		tween.tween_property(model_root, "rotation:z", model_root.rotation.z + 0.8, 0.45)
		tween.parallel().tween_property(model_root, "position:y", model_root.position.y - 0.8, 0.45)

	await get_tree().create_timer(0.6).timeout
	queue_free()


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


func _resolve_animation(candidates: Array) -> String:
	if not _animation_player:
		return ""

	for candidate in candidates:
		var anim_name := String(candidate)
		if _animation_player.has_animation(anim_name):
			return anim_name

	for lib_name in _animation_player.get_animation_library_list():
		var library := _animation_player.get_animation_library(lib_name)
		for anim_name in library.get_animation_list():
			for candidate in candidates:
				if String(candidate).to_lower() in String(anim_name).to_lower():
					return anim_name

	return ""


func _play_looping_animation(anim_name: String, speed_scale: float = 1.0) -> void:
	if not _animation_player or anim_name.is_empty():
		return
	if not _animation_player.has_animation(anim_name):
		return
	if _current_anim == anim_name and _animation_player.is_playing():
		return

	_current_anim = anim_name
	_animation_player.speed_scale = speed_scale
	_animation_player.play(anim_name)


func _play_one_shot_animation(anim_name: String, speed_scale: float = 1.0) -> void:
	if not _animation_player or anim_name.is_empty():
		return
	if not _animation_player.has_animation(anim_name):
		return

	_current_anim = anim_name
	_animation_player.speed_scale = speed_scale
	_animation_player.play(anim_name)
