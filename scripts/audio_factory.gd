class_name AudioFactory
extends RefCounted

const SAMPLE_RATE := 22050


static func gunshot_pistol() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 28.0)
		var noise := randf_range(-1.0, 1.0)
		var tone := sin(TAU * 110.0 * t) * 0.35
		return (noise * 0.75 + tone) * env
	, 0.18)


static func gunshot_rifle() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 22.0)
		var noise := randf_range(-1.0, 1.0)
		var tone := sin(TAU * 85.0 * t) * 0.25
		return (noise * 0.9 + tone) * env
	, 0.14)


static func gunshot_shotgun() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 14.0)
		var noise := randf_range(-1.0, 1.0)
		var boom := sin(TAU * 55.0 * t) * 0.6
		return (noise * 1.0 + boom) * env
	, 0.35)


static func reload_click() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 35.0)
		return sin(TAU * 320.0 * t) * env * 0.7
	, 0.08)


static func weapon_switch() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 40.0)
		return sin(TAU * 520.0 * t) * env * 0.35
	, 0.06)


static func footstep() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 45.0)
		var noise := randf_range(-1.0, 1.0)
		return noise * env * 0.45
	, 0.07)


static func target_hit() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 30.0)
		return sin(TAU * 680.0 * t) * env * 0.5
	, 0.1)


static func target_destroyed() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 8.0)
		var noise := randf_range(-1.0, 1.0)
		var tone := sin(TAU * 140.0 * t) * 0.4
		return (noise * 0.6 + tone) * env
	, 0.25)


static func empty_click() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 50.0)
		return sin(TAU * 900.0 * t) * env * 0.25
	, 0.04)


static func dragon_roar() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 4.5)
		var noise := randf_range(-1.0, 1.0)
		var growl := sin(TAU * 55.0 * t) * 0.7 + sin(TAU * 33.0 * t) * 0.4
		return (noise * 0.5 + growl) * env
	, 0.9)


static func dragon_fire() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 6.0)
		var noise := randf_range(-1.0, 1.0)
		var whoosh := sin(TAU * 180.0 * t + t * t * 40.0) * 0.3
		return (noise * 0.85 + whoosh) * env
	, 0.55)


static func dragon_bite() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 18.0)
		var snap := sin(TAU * 220.0 * t) * 0.6
		var noise := randf_range(-1.0, 1.0) * 0.4
		return (snap + noise) * env
	, 0.2)


static func goblin_grunt() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 14.0)
		var growl := sin(TAU * 95.0 * t) * 0.45 + sin(TAU * 140.0 * t) * 0.2
		var noise := randf_range(-1.0, 1.0) * 0.25
		return (growl + noise) * env
	, 0.18)


static func goblin_stab() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 24.0)
		var snap := sin(TAU * 280.0 * t) * 0.55
		var noise := randf_range(-1.0, 1.0) * 0.35
		return (snap + noise) * env
	, 0.14)


static func goblin_hit() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 26.0)
		return sin(TAU * 420.0 * t) * env * 0.4
	, 0.08)


static func goblin_death() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 10.0)
		var tone := sin(TAU * (180.0 - t * 120.0) * t) * 0.5
		var noise := randf_range(-1.0, 1.0) * 0.35
		return (tone + noise) * env
	, 0.3)


static func golem_growl() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 8.0)
		var rumble := sin(TAU * 42.0 * t) * 0.65 + sin(TAU * 28.0 * t) * 0.35
		var noise := randf_range(-1.0, 1.0) * 0.2
		return (rumble + noise) * env
	, 0.35)


static func golem_slam() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 11.0)
		var boom := sin(TAU * 48.0 * t) * 0.85
		var noise := randf_range(-1.0, 1.0) * 0.55
		return (boom + noise) * env
	, 0.45)


static func golem_hit() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 20.0)
		return sin(TAU * 180.0 * t) * env * 0.45
	, 0.1)


static func golem_death() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 7.0)
		var crumble := sin(TAU * (120.0 - t * 80.0) * t) * 0.45
		var noise := randf_range(-1.0, 1.0) * 0.4
		return (crumble + noise) * env
	, 0.55)


static func health_restore() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 14.0)
		var tone := sin(TAU * 520.0 * t) * 0.35 + sin(TAU * 780.0 * t) * 0.2
		return tone * env
	, 0.2)


static func player_hurt() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var env := exp(-t * 12.0)
		var tone := sin(TAU * 160.0 * t) * 0.5
		var noise := randf_range(-1.0, 1.0) * 0.3
		return (tone + noise) * env
	, 0.25)


static func ambient_wind() -> AudioStreamWAV:
	return _make_stream(func(t: float, _d: float) -> float:
		var noise := randf_range(-1.0, 1.0)
		var wave := sin(TAU * 0.4 * t) * 0.3 + 0.7
		return noise * wave * 0.08
	, 4.0)


static func _make_stream(generator: Callable, duration: float) -> AudioStreamWAV:
	var sample_count := int(duration * SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(sample_count * 2)

	for i in sample_count:
		var t := float(i) / SAMPLE_RATE
		_write_sample(data, i, generator.call(t, duration))

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	return stream


static func _write_sample(data: PackedByteArray, index: int, value: float) -> void:
	var sample := int(clampf(value, -1.0, 1.0) * 32767.0)
	data[index * 2] = sample & 0xFF
	data[index * 2 + 1] = (sample >> 8) & 0xFF
