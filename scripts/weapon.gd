class_name Weapon
extends Node3D

@export var weapon_name: String = "Gun"
@export var damage: float = 25.0
@export var fire_rate: float = 0.2
@export var max_ammo: int = 30
@export var reload_time: float = 1.5
@export var spread: float = 0.0
@export var pellets: int = 1
@export var range: float = 200.0
@export var automatic: bool = false

var current_ammo: int = 0
var _can_fire: bool = true
var _reloading: bool = false
var _shoot_stream: AudioStream

@onready var muzzle: Marker3D = $Muzzle
@onready var shoot_sound: AudioStreamPlayer3D = $ShootSound
@onready var reload_sound: AudioStreamPlayer3D = $ReloadSound


func _ready() -> void:
	current_ammo = max_ammo
	_build_weapon_model()
	_setup_muzzle_flash()
	_assign_sounds()


func _build_weapon_model() -> void:
	var model_root := get_node_or_null("Model") as Node3D
	if not model_root:
		model_root = Node3D.new()
		model_root.name = "Model"
		add_child(model_root)

	match weapon_name:
		"Pistol":
			ModelFactory.build_pistol(model_root)
			muzzle.position = Vector3(0.08, -0.06, -0.54)
		"Assault Rifle":
			ModelFactory.build_rifle(model_root)
			muzzle.position = Vector3(0.1, -0.05, -0.92)
		"Shotgun":
			ModelFactory.build_shotgun(model_root)
			muzzle.position = Vector3(0.12, -0.04, -0.96)


func _setup_muzzle_flash() -> void:
	var flash := muzzle.get_node_or_null("MuzzleFlash")
	if flash:
		flash.queue_free()

	var muzzle_flash := ModelFactory.muzzle_flash_mesh()
	muzzle_flash.name = "MuzzleFlash"
	muzzle_flash.visible = false
	muzzle.add_child(muzzle_flash)


func _assign_sounds() -> void:
	match weapon_name:
		"Pistol":
			_shoot_stream = AudioFactory.gunshot_pistol()
		"Assault Rifle":
			_shoot_stream = AudioFactory.gunshot_rifle()
		"Shotgun":
			_shoot_stream = AudioFactory.gunshot_shotgun()
	shoot_sound.stream = _shoot_stream
	reload_sound.stream = AudioFactory.reload_click()


func try_fire(camera: Camera3D) -> void:
	if _reloading:
		return

	if not _can_fire:
		return

	if current_ammo <= 0:
		_play_empty_click()
		return

	current_ammo -= 1
	_can_fire = false
	_fire_raycasts(camera)
	_play_shoot_effects()

	if current_ammo <= 0:
		reload()

	await get_tree().create_timer(fire_rate).timeout
	_can_fire = true


func _play_empty_click() -> void:
	shoot_sound.stream = AudioFactory.empty_click()
	shoot_sound.play()
	await get_tree().create_timer(0.05).timeout
	shoot_sound.stream = _shoot_stream


func _fire_raycasts(camera: Camera3D) -> void:
	var space_state := get_world_3d().direct_space_state
	var origin := camera.global_position
	var base_dir := -camera.global_transform.basis.z

	for i in pellets:
		var direction := base_dir
		if spread > 0.0:
			direction = direction.rotated(camera.global_transform.basis.x, randf_range(-spread, spread))
			direction = direction.rotated(camera.global_transform.basis.y, randf_range(-spread, spread))
			direction = direction.normalized()

		var end := origin + direction * range
		var query := PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true
		query.exclude = _get_shooter_collision_excludes()

		var result := space_state.intersect_ray(query)
		if result.is_empty():
			continue

		var collider: Object = result.collider
		var damage_target := _resolve_damage_target(collider)
		if damage_target:
			damage_target.take_damage(damage, result.position)


func _resolve_damage_target(collider: Object) -> Object:
	var node := collider as Node
	while node:
		if node.has_method("take_damage"):
			return node
		node = node.get_parent()
	return null


func _play_shoot_effects() -> void:
	if shoot_sound and shoot_sound.stream:
		shoot_sound.pitch_scale = randf_range(0.95, 1.05)
		shoot_sound.play()

	if muzzle:
		var flash := muzzle.get_node_or_null("MuzzleFlash")
		if flash:
			flash.visible = true
			await get_tree().create_timer(0.05).timeout
			flash.visible = false


func reload() -> void:
	if _reloading or current_ammo == max_ammo:
		return

	_reloading = true
	if reload_sound:
		reload_sound.play()
	await get_tree().create_timer(reload_time).timeout
	current_ammo = max_ammo
	_reloading = false


func _get_shooter_collision_excludes() -> Array[RID]:
	var excludes: Array[RID] = []
	var node: Node = self
	while node:
		if node is CollisionObject3D:
			excludes.append(node.get_rid())
		node = node.get_parent()
	return excludes


func get_display_info() -> Dictionary:
	return {
		"name": weapon_name,
		"ammo": current_ammo,
		"max_ammo": max_ammo,
		"reloading": _reloading,
	}
