extends Control


@export var starting_note : int = 56
@onready var action_names = AppSettings.get_filtered_action_names()
@onready var white_keys = %WhiteKeys
@onready var black_keys = %BlackKeys

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

func _input(event):
	if event is InputEventKey and event.is_pressed():
		var midi_event : InputEventMIDI = InputEventMIDI.new()
		midi_event.message = MIDI_MESSAGE_NOTE_ON
		midi_event.pitch = event.keycode % 128
		midi_event.velocity = 0x6E # 110
		$GodotMIDIPlayer.receive_raw_midi_message(midi_event)
	elif event is InputEventMIDI:
		$GodotMIDIPlayer.receive_raw_midi_message(event)

func _on_mouse_entered_play_note(note : int) -> void:
	var midi_event : InputEventMIDI = InputEventMIDI.new()
	midi_event.message = MIDI_MESSAGE_NOTE_ON
	midi_event.pitch = note
	midi_event.velocity = 0x6E # 110
	midi_event.instrument = 26
	$GodotMIDIPlayer.receive_raw_midi_message(midi_event)

func _attach_keys():
	var white_keys := $WhiteKeys.get_children()
	var black_keys := $BlackKeys.find_children("", "Button")
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
		current_key.connect(&"mouse_entered", _on_mouse_entered_play_note.bind(key_note))

func _ready():
	InGameMenuController.scene_tree = get_tree()
	_attach_keys()
