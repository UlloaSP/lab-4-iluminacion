extends Node3D

@onready var light1: DirectionalLight3D = $Light1
@onready var light2: OmniLight3D = $Light2
@onready var light3: OmniLight3D = $Light3

@onready var cam_outside: Camera3D = $CameraOutside
@onready var cam_inside: Camera3D = $CameraInside
@onready var cam_fps: Camera3D = $PlayerFPS/CameraFPS

@onready var world_environment: WorldEnvironment = $WorldEnvironment

var env_enabled := true

func _ready() -> void:
	var env := world_environment.environment
	env_enabled = env.background_mode == Environment.BG_SKY and env.ambient_light_source != Environment.AMBIENT_SOURCE_DISABLED and env.reflected_light_source != Environment.REFLECTION_SOURCE_DISABLED
	cam_outside.make_current()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cam_outside"):
		cam_outside.make_current()
	elif event.is_action_pressed("cam_inside"):
		cam_inside.make_current()
	elif event.is_action_pressed("cam_fps"):
		cam_fps.make_current()
	elif event.is_action_pressed("toggle_light_1"):
		light1.visible = !light1.visible
	elif event.is_action_pressed("toggle_light_2"):
		light2.visible = !light2.visible
	elif event.is_action_pressed("toggle_light_3"):
		light3.visible = !light3.visible
	elif event.is_action_pressed("toggle_ao"):
		world_environment.environment.ssao_enabled = !world_environment.environment.ssao_enabled
	elif event.is_action_pressed("toggle_env"):
		_toggle_environment()

func _toggle_environment() -> void:
	var env := world_environment.environment
	env_enabled = !env_enabled

	if env_enabled:
		env.background_mode = Environment.BG_SKY
		env.ambient_light_source = Environment.AMBIENT_SOURCE_BG
		env.reflected_light_source = Environment.REFLECTION_SOURCE_BG
	else:
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(0.02, 0.02, 0.02)
		env.ambient_light_source = Environment.AMBIENT_SOURCE_DISABLED
		env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
