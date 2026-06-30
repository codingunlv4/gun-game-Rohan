extends Area3D

signal collected

const RESPAWN_DELAY := 30.0

@export var heal_amount: float = 40.0

var _active: bool = true
var _respawn_timer: float = 0.0
var _visual_root: Node3D
var _collision: CollisionShape3D
var _mesh_instances: Array[MeshInstance3D] = []


func _ready() -> void:
	_collision = get_node_or_null("CollisionShape3D") as CollisionShape3D
	_visual_root = Node3D.new()
	_visual_root.name = "VisualRoot"
	add_child(_visual_root)
	_mesh_instances = ModelFactory.build_health_pickup(_visual_root)
	body_entered.connect(_on_body_entered)
	monitoring = true


func _process(delta: float) -> void:
	if _active:
		return
	_respawn_timer = maxf(_respawn_timer - delta, 0.0)
	if _respawn_timer <= 0.0:
		_activate()


func _on_body_entered(body: Node3D) -> void:
	if not _active:
		return
	if not body.is_in_group("player"):
		return
	if not body.has_method("heal"):
		return
	if not body.heal(heal_amount):
		return

	collected.emit()
	_deactivate()


func _deactivate() -> void:
	_active = false
	_respawn_timer = RESPAWN_DELAY
	monitoring = false
	if _collision:
		_collision.disabled = true
	if _visual_root:
		_visual_root.visible = false


func _activate() -> void:
	_active = true
	monitoring = true
	if _collision:
		_collision.disabled = false
	if _visual_root:
		_visual_root.visible = true
	_pulse_visual()


func _pulse_visual() -> void:
	if _mesh_instances.is_empty():
		return
	var tween := create_tween()
	for mesh in _mesh_instances:
		if mesh:
			tween.parallel().tween_property(mesh, "scale", Vector3.ONE * 1.08, 0.2)
	tween.tween_property(_mesh_instances[0], "scale", Vector3.ONE, 0.15)
