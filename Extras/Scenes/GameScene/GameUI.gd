extends Control


@export var starting_note : int = 56
@onready var action_names = AppSettings.get_filtered_action_names()
@onready var white_keys_container = %WhiteKeys
@onready var black_keys_container = %BlackKeys
@onready var device_list_label = %DeviceList
@onready var device_connected_option = %DeviceConnected
@onready var device_list_animation = %DeviceListAnimationPlayer

const WHITE_KEY := "WHITE_KEY"
const BLACK_KEY := "BLACK_KEY"
const LOW_A_MIDI_NOTE := 21
const OCTAVE_KEYS := [
	WHITE_KEY,
	BLACK_KEY,
	WHITE_KEY,
	WHITE_KEY,
	BLACK_KEY,
	WHITE_KEY,
	BLACK_KEY,
	WHITE_KEY,
	WHITE_KEY,
	BLACK_KEY,
	WHITE_KEY,
	BLACK_KEY,
]

var _connected_midi_devices : PackedStringArray
var _real_connected_midi_devices : Array[String]

func _input(event):
	if event is InputEventKey and event.is_pressed():
		var midi_event : InputEventMIDI = InputEventMIDI.new()
		midi_event.message = MIDI_MESSAGE_NOTE_ON
		midi_event.pitch = event.keycode % 128
		midi_event.velocity = 0x6E # 110
		$GodotMIDIPlayer.receive_raw_midi_message(midi_event)
	elif event is InputEventMIDI:
		$GodotMIDIPlayer.receive_raw_midi_message(event)

func _on_note_played(note : int) -> void:
	var midi_event : InputEventMIDI = InputEventMIDI.new()
	midi_event.message = MIDI_MESSAGE_NOTE_ON
	midi_event.pitch = note
	midi_event.velocity = 0x6E # 110
	$GodotMIDIPlayer.receive_raw_midi_message(midi_event)

func _attach_keys():
	var white_keys := white_keys_container.get_children()
	var black_keys := black_keys_container.find_children("", "Button")
	var total_keys = white_keys.size() + black_keys.size()
	var note_offset = (starting_note - LOW_A_MIDI_NOTE)% 12 
	for iter in total_keys:
		var key_iter = (note_offset + iter) % OCTAVE_KEYS.size()
		var key_color = OCTAVE_KEYS[key_iter]
		var current_key : Node
		match key_color:
			WHITE_KEY:
				current_key = white_keys.pop_front()
			BLACK_KEY:
				current_key = black_keys.pop_front()
		var key_note : int = starting_note + iter
		current_key.connect(&"mouse_entered", _on_note_played.bind(key_note))
		current_key.connect(&"button_down", _on_note_played.bind(key_note))

func _detect_MIDI_devices():
	_connected_midi_devices = OS.get_connected_midi_inputs()
	_real_connected_midi_devices.clear()
	var device_list_text = ""
	for device in _connected_midi_devices:
		if device == "Virtual RawMIDI":
			continue
		_real_connected_midi_devices.append(device)
	device_list_text = "\n".join(_real_connected_midi_devices)
	device_list_label.visible = device_list_text != ""
	if device_list_label.text != device_list_text:
		device_list_label.text = device_list_text
		device_list_animation.play(&"FadeOut")
	device_connected_option.button_pressed = _real_connected_midi_devices.size() > 0

func _ready():
	InGameMenuController.scene_tree = get_tree()
	_attach_keys()
	OS.open_midi_inputs()
	_detect_MIDI_devices()

func _on_check_midi_devices_timer_timeout():
	_detect_MIDI_devices()

func _on_panel_mouse_entered():
	if not device_list_animation.is_playing():
		device_list_animation.play(&"FadeIn")
	else:
		device_list_animation.play(&"RESET")

func _on_panel_mouse_exited():
	device_list_animation.play(&"FadeOut")
