extends CharacterBody3D

const MOVE_SPEED := 7.0
const JUMP_VELOCITY := 4.8
const MOUSE_SENSITIVITY := 0.003
const FOOTSTEP_DISTANCE := 2.2
const MAX_HEALTH := 100.0
const DAMAGE_FLASH_TIME := 0.15
const RESPAWN_DELAY := 2.0

@export var max_health: float = MAX_HEALTH

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var weapon_holder: Node3D = $Head/Camera3D/WeaponHolder
@onready var hud: Control = $HUD
@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer
@onready var ui_sound_player: AudioStreamPlayer = $UISoundPlayer

var weapons: Array[Weapon] = []
var current_weapon_index: int = 0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _distance_since_footstep: float = 0.0
var _health: float
var _alive: bool = true
var _spawn_position: Vector3
var _spawn_rotation: Vector3
var _hurt_player: AudioStreamPlayer3D


func _ready() -> void:
	add_to_group("player")
	_health = max_health
	_spawn_position = global_position
	_spawn_rotation = rotation
	_hurt_player = AudioStreamPlayer3D.new()
	_hurt_player.stream = AudioFactory.player_hurt()
	add_child(_hurt_player)
	call_deferred("_capture_mouse")
	_collect_weapons()
	_switch_weapon(0, false)
	footstep_player.stream = AudioFactory.footstep()


func _capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_rotate_view(event.relative)
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			_capture_mouse()
			get_viewport().set_input_as_handled()
			return

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("weapon_1"):
		_switch_weapon(0)
	elif event.is_action_pressed("weapon_2"):
		_switch_weapon(1)
	elif event.is_action_pressed("weapon_3"):
		_switch_weapon(2)
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_switch_weapon((current_weapon_index - 1 + weapons.size()) % weapons.size())
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_switch_weapon((current_weapon_index + 1) % weapons.size())


func _rotate_view(relative: Vector2) -> void:
	rotate_y(-relative.x * MOUSE_SENSITIVITY)
	head.rotate_x(-relative.y * MOUSE_SENSITIVITY)
	head.rotation.x = clampf(head.rotation.x, deg_to_rad(-89.0), deg_to_rad(89.0))


func take_damage(amount: float, _hit_position: Vector3 = Vector3.ZERO) -> void:
	if not _alive:
		return

	_health -= amount
	_hurt_player.pitch_scale = randf_range(0.9, 1.1)
	_hurt_player.play()
	_flash_damage()

	if _health <= 0.0:
		_die()


func _flash_damage() -> void:
	if not hud:
		return

	var crosshair: Control = hud.get_node("Crosshair")
	crosshair.modulate = Color(1.0, 0.2, 0.2)
	await get_tree().create_timer(DAMAGE_FLASH_TIME).timeout
	if is_instance_valid(crosshair):
		crosshair.modulate = Color.WHITE


func _die() -> void:
	_alive = false
	velocity = Vector3.ZERO
	if hud:
		var death_label: Label = hud.get_node_or_null("DeathLabel")
		if death_label:
			death_label.visible = true
	await get_tree().create_timer(RESPAWN_DELAY).timeout
	_respawn()


func _respawn() -> void:
	_health = max_health
	_alive = true
	global_position = _spawn_position
	rotation = _spawn_rotation
	velocity = Vector3.ZERO
	if hud:
		var death_label: Label = hud.get_node_or_null("DeathLabel")
		if death_label:
			death_label.visible = false


func _physics_process(delta: float) -> void:
	if not _alive:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()

	if direction:
		velocity.x = direction.x * MOVE_SPEED
		velocity.z = direction.z * MOVE_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, MOVE_SPEED)
		velocity.z = move_toward(velocity.z, 0.0, MOVE_SPEED)

	move_and_slide()
	_handle_footsteps(horizontal_speed)
	_handle_shooting()
	_update_hud()


func _handle_footsteps(horizontal_speed: float) -> void:
	if not is_on_floor() or horizontal_speed < 0.5:
		_distance_since_footstep = 0.0
		return

	_distance_since_footstep += horizontal_speed * get_physics_process_delta_time()
	if _distance_since_footstep >= FOOTSTEP_DISTANCE:
		_distance_since_footstep = 0.0
		footstep_player.pitch_scale = randf_range(0.9, 1.1)
		footstep_player.play()


func _collect_weapons() -> void:
	weapons.clear()
	for child in weapon_holder.get_children():
		if child is Weapon:
			weapons.append(child)
			child.visible = false


func _switch_weapon(index: int, play_sound: bool = true) -> void:
	if weapons.is_empty():
		return

	var next_index := clampi(index, 0, weapons.size() - 1)
	if next_index == current_weapon_index and weapons[current_weapon_index].visible:
		return

	weapons[current_weapon_index].visible = false
	current_weapon_index = next_index
	weapons[current_weapon_index].visible = true

	if play_sound:
		ui_sound_player.stream = AudioFactory.weapon_switch()
		ui_sound_player.play()


func _handle_shooting() -> void:
	if weapons.is_empty():
		return

	var weapon := weapons[current_weapon_index]
	if Input.is_action_just_pressed("reload"):
		weapon.reload()
		return

	if weapon.automatic:
		if Input.is_action_pressed("shoot"):
			weapon.try_fire(camera)
	elif Input.is_action_just_pressed("shoot"):
		weapon.try_fire(camera)


func _update_hud() -> void:
	if weapons.is_empty() or not hud:
		return

	var info := weapons[current_weapon_index].get_display_info()
	var ammo_label: Label = hud.get_node("AmmoLabel")
	var weapon_label: Label = hud.get_node("WeaponLabel")
	var crosshair: Control = hud.get_node("Crosshair")

	weapon_label.text = info.name
	if info.reloading:
		ammo_label.text = "Reloading..."
	else:
		ammo_label.text = "%d / %d" % [info.ammo, info.max_ammo]

	crosshair.modulate = Color.WHITE if info.ammo > 0 and not info.reloading else Color.RED

	var health_label: Label = hud.get_node_or_null("HealthLabel")
	if health_label:
		health_label.text = "Health: %d" % int(ceilf(_health))
		if _health > 60.0:
			health_label.modulate = Color(0.7, 1.0, 0.7)
		elif _health > 30.0:
			health_label.modulate = Color(1.0, 0.85, 0.4)
		else:
			health_label.modulate = Color(1.0, 0.35, 0.3)
