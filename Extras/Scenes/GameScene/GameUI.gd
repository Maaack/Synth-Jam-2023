extends Control


@export var starting_note : int = 56
@export_file("*.mid") var sample_midi : String
@export var pressed_colors : Array[Color]
@onready var action_names = AppSettings.get_filtered_action_names()
@onready var white_keys_container = %WhiteKeys
@onready var black_keys_container = %BlackKeys
@onready var device_list_panel = %DeviceListPanel
@onready var device_list_label = %DeviceList
@onready var device_connected_option = %DeviceConnected
@onready var web_notice = %WebNoticeLabel
@onready var web_notice_2 = %WebNoticeLabel2
@onready var load_midi_button = %LoadMIDIFileButton
@onready var loaded_midi_label = %LoadedMIDIFileLabel
@onready var play_button = %PlayButton
@onready var stop_pause_container = %StopPauseContainer
@onready var load_sample_button = %LoadSampleButton

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
var _paused_at : float = 0
var _note_key_map : Dictionary = {}

func _press_key_for_note(key_note : int, pressed : bool):
	if _note_key_map.has(key_note):
		var note_button : Button = _note_key_map[key_note]
		note_button.set_pressed_no_signal(pressed)

func _input(event):
	if event is InputEventKey:
		var note : int = event.keycode % 128
		if event.is_pressed() and not event.is_echo():
			var midi_event : InputEventMIDI = InputEventMIDI.new()
			midi_event.message = MIDI_MESSAGE_NOTE_ON
			midi_event.pitch = note
			midi_event.velocity = 0x6E # 110
			$GodotMIDIPlayer.receive_raw_midi_message(midi_event)
		_press_key_for_note(note, event.is_pressed())
	elif event is InputEventMIDI:
		$GodotMIDIPlayer.receive_raw_midi_message(event)
		_press_key_for_note(event.pitch, event.message == MIDI_MESSAGE_NOTE_ON)

func _on_note_played(note : int) -> void:
	var midi_event : InputEventMIDI = InputEventMIDI.new()
	midi_event.message = MIDI_MESSAGE_NOTE_ON
	midi_event.pitch = note
	midi_event.velocity = 0x6E # 110
	$GodotMIDIPlayer.receive_raw_midi_message(midi_event)

func _on_note_released(key_button : Button) -> void:
	key_button.set_pressed_no_signal(false)

func _if_mouse_pressed_play_note(key_button : Button, note : int) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		key_button.set_pressed_no_signal(true)
		_on_note_played(note)

func _on_mouse_exited(key_button : Button):
	key_button.set_pressed_no_signal(false)

func _apply_color_for_pressed(key_button : Button, iter : int):
	var color_iter : int = iter % pressed_colors.size()
	var color : Color = pressed_colors[color_iter]
	var stylebox : StyleBox = key_button.get_theme_stylebox(&"pressed")
	if stylebox is StyleBoxFlat:
		var stylebox_new : StyleBoxFlat = stylebox.duplicate()
		stylebox_new.bg_color = color
		key_button.add_theme_stylebox_override(&"pressed", stylebox_new)

func _attach_keys():
	_note_key_map.clear()
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
		current_key.connect(&"mouse_entered", _if_mouse_pressed_play_note.bind(current_key, key_note))
		current_key.connect(&"mouse_exited", _on_mouse_exited.bind(current_key))
		current_key.connect(&"button_down", _on_note_played.bind(key_note))
		current_key.connect(&"button_up", _on_note_released.bind(current_key))
		_note_key_map[key_note] = current_key
		_apply_color_for_pressed(current_key, iter)

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
		device_list_panel.fade_in()
	device_connected_option.button_pressed = _real_connected_midi_devices.size() > 0

func _ready():
	InGameMenuController.scene_tree = get_tree()
	_attach_keys()
	load_sample_button.visible = !sample_midi.is_empty()
	if OS.has_feature("web"):
		web_notice.show()
		web_notice_2.show()
		load_midi_button.hide()
	else:
		OS.open_midi_inputs()
		_detect_MIDI_devices()
		$CheckMIDIDevicesTimer.start()

func _on_check_midi_devices_timer_timeout():
	if OS.has_feature("web"):
		return
	_detect_MIDI_devices()

func _update_control_buttons():
	play_button.visible = !$GodotMIDIPlayer.playing
	stop_pause_container.visible = $GodotMIDIPlayer.playing
	load_sample_button.visible = !$GodotMIDIPlayer.playing and !sample_midi.is_empty() and $GodotMIDIPlayer.file != sample_midi

func _on_load_midi_file_button_pressed():
	$FileDialog.popup_centered()

func _on_file_dialog_file_selected(path : String):
	if path == "":
		loaded_midi_label.visible = false
		play_button.visible = false
		stop_pause_container.visible = false
		return
	$GodotMIDIPlayer.set_file(path)
	$GodotMIDIPlayer.play()
	loaded_midi_label.text = path.get_file().get_basename()
	loaded_midi_label.visible = true
	_update_control_buttons()

func _on_play_button_pressed():
	$GodotMIDIPlayer.play(_paused_at)
	_update_control_buttons()

func _on_stop_button_pressed():
	_paused_at = 0
	$GodotMIDIPlayer.stop()
	_update_control_buttons()

func _on_pause_button_pressed():
	_paused_at = $GodotMIDIPlayer.position
	$GodotMIDIPlayer.stop()
	_update_control_buttons()

func _on_load_sample_button_pressed():
	$GodotMIDIPlayer.set_file(sample_midi)
	$GodotMIDIPlayer.play()
	_update_control_buttons()

func _on_godot_midi_player_midi_event(channel, event):
	if event is SMF.MIDIEventNoteOn:
		_press_key_for_note(event.note, true)
	if event is SMF.MIDIEventNoteOff:
		_press_key_for_note(event.note, false)
