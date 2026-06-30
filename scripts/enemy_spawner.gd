class_name EnemySpawner
extends Node3D

const RESPAWN_DELAY := 40.0

var _slots: Array[Dictionary] = []


func add_slot(scene: PackedScene, position: Vector3) -> void:
	var index := _slots.size()
	_slots.append({
		"scene": scene,
		"position": position,
		"enemy": null,
		"respawn_timer": 0.0,
	})
	_spawn_slot(index)


func _spawn_slot(index: int) -> void:
	var slot: Dictionary = _slots[index]
	if slot.enemy and is_instance_valid(slot.enemy):
		return

	var enemy: Node3D = slot.scene.instantiate()
	enemy.position = slot.position
	add_child(enemy)
	slot.enemy = enemy

	if enemy.has_signal("defeated"):
		enemy.defeated.connect(_on_enemy_defeated.bind(index))


func _on_enemy_defeated(index: int) -> void:
	var slot: Dictionary = _slots[index]
	slot.enemy = null
	slot.respawn_timer = RESPAWN_DELAY


func _process(delta: float) -> void:
	for i in range(_slots.size()):
		var slot: Dictionary = _slots[i]
		if slot.respawn_timer <= 0.0:
			continue
		slot.respawn_timer = maxf(slot.respawn_timer - delta, 0.0)
		if slot.respawn_timer <= 0.0 and (not slot.enemy or not is_instance_valid(slot.enemy)):
			_spawn_slot(i)
