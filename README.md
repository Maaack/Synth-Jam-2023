# Godot MIDI Keyboard
For Godot 4.2.1

Result of some experimenting with Godot, MIDI, and soundfonts.

The application should detect connected MIDI devices and read their output. It can also read MIDI files and play them back on the keyboard.

[Try it on itch.io](https://maaack.itch.io/godot-midi-keyboard)

![Opening](/Media/Screenshot-1.png)  
![Load MIDI](/Media/Screenshot-2.png)  
![Play Controls](/Media/Screenshot-3.png)  
![Rainbow Keys](/Media/Screenshot-4.png)  
  
## Plugins
This Godot project requires the following plugin(s):

1. `Godot MIDI Player for Godot Engine 4` by arlez80.

### Installation
1. Open the Asset Lib window in Godot.
   * ![Asset Lib Button](Docs/AssetLibButton.png)
2. Make sure you are searching `godotengine.org`.
   * ![Asset Lib Site](Docs/AssetLibSite.png)
3. Search for "MIDI" and select `Godot MIDI Player for Godot Engine 4`.
4. In the details window for the plugin, select download.
   * ![Download Button](Docs/DownloadButton.png)
5. Let the plugin download and then start the install...
6. Let the plugin install in `/addons/midi`.
    * ![Install the MIDI plugin](Docs/InstallMIDIPlugin.png)
7.  Open the Project Settings window and select the Plugins tab.
8.  Under the column "Status", check the boxes to Enable the plugins.
    * ![Enable the plugins](Docs/EnablePlugins.png)
9.  Reload the project.
    * ![Reload the project](Docs/ReloadProject.png)

## Links
[Attribution](ATTRIBUTION.md)  
[License](LICENSE.txt)  