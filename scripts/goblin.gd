extends CharacterBody3D

signal defeated

const SKETCHFAB_MODEL := "res://assets/models/goblin/sketchfab/goblin.glb"
const SKETCHFAB_SCALE := Vector3(1.8, 1.8, 1.8)
const RUN_SPEED := 6.2
const TURN_SPEED := 8.0
const DETECT_RANGE := 55.0
const STAB_RANGE := 2.8
const STAB_DAMAGE := 15.0
const STAB_COOLDOWN := 1.1
const STAB_LUNGE_SPEED := 5.5
const GROUND_BODY_OFFSET := 0.95
const RUN_BOB_SPEED := 14.0
const RUN_BOB_AMOUNT := 0.06

@export var max_health: float = 80.0

@onready var model_root: Node3D = $ModelRoot
@onready var stab_area: Area3D = $StabArea
@onready var grunt_player: AudioStreamPlayer3D = $GruntPlayer
@onready var stab_player: AudioStreamPlayer3D = $StabPlayer
@onready var death_player: AudioStreamPlayer3D = $DeathPlayer
@onready var hit_player: AudioStreamPlayer3D = $HitPlayer

var _health: float
var _player: Node3D
var _alive: bool = true
var _attacking: bool = false
var _stab_timer: float = 0.0
var _run_time: float = 0.0
var _mesh_instances: Array[MeshInstance3D] = []
var _model_base_y: float = 0.0
var _dagger: MeshInstance3D


func _ready() -> void:
	add_to_group("enemies")
	_health = max_health
	_model_base_y = model_root.position.y
	grunt_player.stream = AudioFactory.goblin_grunt()
	stab_player.stream = AudioFactory.goblin_stab()
	death_player.stream = AudioFactory.goblin_death()
	hit_player.stream = AudioFactory.goblin_hit()
	stab_area.body_entered.connect(_on_stab_area_body_entered)
	call_deferred("_setup_model")
	call_deferred("_find_player")


func _find_player() -> void:
	_player = get_tree().get_first_node_in_group("player") as Node3D


func _setup_model() -> void:
	for child in model_root.get_children():
		child.queue_free()

	_dagger = null
	if ResourceLoader.exists(SKETCHFAB_MODEL):
		var packed := load(SKETCHFAB_MODEL) as PackedScene
		if packed:
			var model := packed.instantiate()
			model.name = "GoblinSketchfab"
			model.scale = SKETCHFAB_SCALE
			model_root.add_child(model)
			_mesh_instances = _collect_mesh_instances(model)
			return

	var model := Node3D.new()
	model.name = "GoblinModel"
	model_root.add_child(model)
	var built := ModelFactory.build_goblin(model)
	_mesh_instances = built.meshes
	_dagger = built.dagger


func _collect_mesh_instances(node: Node, meshes: Array[MeshInstance3D] = []) -> Array[MeshInstance3D]:
	if node is MeshInstance3D:
		meshes.append(node)
	for child in node.get_children():
		_collect_mesh_instances(child, meshes)
	return meshes


func _physics_process(delta: float) -> void:
	if not _alive:
		return

	if not is_instance_valid(_player):
		_find_player()
		return

	_stab_timer = maxf(_stab_timer - delta, 0.0)

	var flat_distance := Vector2(
		_player.global_position.x - global_position.x,
		_player.global_position.z - global_position.z
	).length()

	if flat_distance > DETECT_RANGE:
		_idle(delta)
	else:
		_chase_and_stab(delta, flat_distance)

	move_and_slide()


func _idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, RUN_SPEED * delta * 6.0)
	velocity.z = move_toward(velocity.z, 0.0, RUN_SPEED * delta * 6.0)
	_snap_to_ground(delta)
	_reset_run_bob()


func _chase_and_stab(delta: float, flat_distance: float) -> void:
	_snap_to_ground(delta)

	var flat_to_player := Vector2(
		_player.global_position.x - global_position.x,
		_player.global_position.z - global_position.z
	)
	var flat_dir := Vector2.ZERO
	if flat_to_player.length_squared() > 0.01:
		flat_dir = flat_to_player.normalized()

	if flat_dir.length_squared() > 0.01:
		_rotate_toward(Vector3(flat_dir.x, 0.0, flat_dir.y), delta)

	if _attacking:
		return

	if flat_distance <= STAB_RANGE and _stab_timer <= 0.0:
		_try_stab()
		return

	if flat_distance > STAB_RANGE * 0.9:
		velocity.x = flat_dir.x * RUN_SPEED
		velocity.z = flat_dir.y * RUN_SPEED
		_animate_run(delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, RUN_SPEED * delta * 8.0)
		velocity.z = move_toward(velocity.z, 0.0, RUN_SPEED * delta * 8.0)
		_reset_run_bob()


func _try_stab() -> void:
	_attacking = true
	_stab_timer = STAB_COOLDOWN
	stab_player.pitch_scale = randf_range(0.92, 1.08)
	stab_player.play()

	velocity += -global_transform.basis.z * STAB_LUNGE_SPEED

	if _dagger:
		var tween := create_tween()
		tween.tween_property(_dagger, "rotation:x", deg_to_rad(-55.0), 0.12)
		tween.tween_property(_dagger, "rotation:x", 0.0, 0.18)

	stab_area.monitoring = true
	await get_tree().create_timer(0.32).timeout
	if not is_instance_valid(self):
		return
	stab_area.monitoring = false
	_attacking = false


func _on_stab_area_body_entered(body: Node3D) -> void:
	if not _alive or not _attacking:
		return
	if body == self or not body.is_in_group("player"):
		return
	if body.has_method("take_damage"):
		body.take_damage(STAB_DAMAGE, global_position)


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
	global_position.y = lerpf(global_position.y, ground_y, delta * 12.0)
	velocity.y = 0.0


func _rotate_toward(direction: Vector3, delta: float) -> void:
	if direction.length_squared() <= 0.01:
		return
	var current_quat := global_transform.basis.get_rotation_quaternion()
	var target_quat := Basis.looking_at(direction.normalized(), Vector3.UP).get_rotation_quaternion()
	global_transform.basis = Basis(current_quat.slerp(target_quat, delta * TURN_SPEED))


func _animate_run(delta: float) -> void:
	_run_time += delta * RUN_BOB_SPEED
	model_root.position.y = _model_base_y + absf(sin(_run_time)) * RUN_BOB_AMOUNT


func _reset_run_bob() -> void:
	_run_time = 0.0
	model_root.position.y = lerpf(model_root.position.y, _model_base_y, 0.2)


func take_damage(amount: float, _hit_position: Vector3 = Vector3.ZERO) -> void:
	if not _alive:
		return

	_health -= amount
	hit_player.pitch_scale = randf_range(0.9, 1.15)
	hit_player.play()
	_flash_hit()

	if _health <= 0.0:
		_die()
	elif randf() < 0.35:
		grunt_player.pitch_scale = randf_range(0.85, 1.1)
		grunt_player.play()


func _flash_hit() -> void:
	for mesh in _mesh_instances:
		var mat := mesh.get_active_material(0) as StandardMaterial3D
		if not mat:
			continue

		var original := mat.albedo_color
		mat.albedo_color = Color(1.0, 0.45, 0.35)
		await get_tree().create_timer(0.08).timeout
		if is_instance_valid(mat):
			mat.albedo_color = original


func _die() -> void:
	_alive = false
	defeated.emit()
	death_player.play()
	velocity = Vector3.ZERO
	stab_area.monitoring = false
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)

	if model_root:
		var tween := create_tween()
		tween.tween_property(model_root, "rotation:z", model_root.rotation.z + 1.2, 0.35)
		tween.parallel().tween_property(model_root, "position:y", model_root.position.y - 0.5, 0.35)

	await get_tree().create_timer(0.5).timeout
	queue_free()
