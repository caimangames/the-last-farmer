extends SceneTree
## Generates the player's SpriteFrames from the 192x320 spritesheet (6x10 of 32x32).
##
## Run:
##   godot --headless --path . --script res://tools/build_player_spriteframes.gd

const FW := 32
const FH := 32
const SOURCE := "res://assets/sprites/characters/player.png"
const OUTPUT := "res://assets/sprites/characters/player_frames.tres"

# [name, row, start_col, num_frames, fps, loop]
const ANIM_DEF := [
	["idle_down",  1, 0, 6, 4.0,  true],
	["idle_up",    2, 0, 6, 4.0,  true],
	["idle_side",  4, 0, 1, 1.0,  true],
	["walk_down",  3, 0, 6, 8.0,  true],
	["walk_up",    5, 0, 6, 8.0,  true],
	["walk_side",  4, 0, 6, 8.0,  true],
]


func _initialize() -> void:
	var tex: Texture2D = load(SOURCE)
	if tex == null:
		push_error("Could not load %s" % SOURCE)
		quit(1)
		return

	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")

	for def in ANIM_DEF:
		var anim_name: String  = def[0]
		var row: int           = def[1]
		var col_start: int     = def[2]
		var count: int         = def[3]
		var fps: float         = def[4]
		var loop: bool         = def[5]

		frames.add_animation(anim_name)
		frames.set_animation_speed(anim_name, fps)
		frames.set_animation_loop(anim_name, loop)

		for col in range(col_start, col_start + count):
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(col * FW, row * FH, FW, FH)
			frames.add_frame(anim_name, atlas)

		print("  %-12s  row %d  %d frames  %.0f fps" % [anim_name, row, count, fps])

	var err := ResourceSaver.save(frames, OUTPUT)
	if err == OK:
		print("SpriteFrames -> %s" % OUTPUT)
	else:
		push_error("Error saving SpriteFrames: %d" % err)
	quit()
