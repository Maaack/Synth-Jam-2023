extends Control

@onready var action_names = AppSettings.get_filtered_action_names()

func _input(event):
	if event is InputEventKey and event.is_pressed():
		var midi_event : InputEventMIDI = InputEventMIDI.new()
		midi_event.message = MIDI_MESSAGE_NOTE_ON
		midi_event.pitch = event.keycode % 128
		midi_event.velocity = 0x6E # 110
		$GodotMIDIPlayer.receive_raw_midi_message(midi_event)
	elif event is InputEventMIDI:
		$GodotMIDIPlayer.receive_raw_midi_message(event)

func _ready():
	InGameMenuController.scene_tree = get_tree()
