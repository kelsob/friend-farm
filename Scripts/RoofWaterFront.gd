extends Control

tool

var active_particle_object = null

onready var particles_light = $Particles2DLight
onready var particles_normal = $Particles2DNormal
onready var particles_heavy = $Particles2DHeavy
onready var particles_torrential = $Particles2DTorrential

onready var particles_array = [particles_light, particles_normal, particles_heavy, particles_torrential]

func _ready():
	for particles in particles_array:
		particles.process_material = particles.process_material.duplicate()
		particles.process_material.emission_box_extents.x = rect_size.x / 2
		particles.process_material.emission_box_extents.y = rect_size.y / 2
		particles.position = Vector2(rect_size.x/2, rect_size.y/2)

func weather_changed(weather_precipitation, weather_light):
	disable_active_particle_object()
	match weather_precipitation:
		4:
			active_particle_object = particles_light
		5:
			active_particle_object = particles_normal
		6:
			active_particle_object = particles_heavy
		7:
			active_particle_object = particles_torrential
		_:
			active_particle_object = null

	enable_active_particle_object()

func enable_active_particle_object():
	if active_particle_object != null:
		active_particle_object.emitting = true
		active_particle_object.visible = true

func disable_active_particle_object():
	if active_particle_object != null:
		active_particle_object.emitting = false
		active_particle_object.visible = false
		active_particle_object = null

