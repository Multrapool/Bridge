extends Node

var CUE := load("res://mods-unpacked/Multrapool-Cue/cue.gd")

# Name of the directory that this file is in, and full ID of the mod (AuthorName-ModName)
const MOD_ID := "AuthorName-ModName"

var mod_dir_path := ""
var extensions_dir_path := ""


# your _ready func.
func _init() -> void:
    ModLoaderLog.info("Init", MOD_ID)
    mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_ID)
    extensions_dir_path = mod_dir_path.path_join("extensions")

    # Add extensions
    install_script_extensions()
    install_script_hook_files()

    # Load translations for your mod, if you need them.
    # Add translations by adding a CSV called "AuthorName-ModName.csv" into the "translations" directory.
    # Godot will automatically generate a ".translation" file, eg "AuthorName-ModName.en.translation".
    # Note that in this example, only the file called "AuthorName-ModName.csv" is custom
    #ModLoaderMod.add_translation(mod_dir_path.path_join("AuthorName-ModName.en.translation"))


func install_script_extensions() -> void:
    pass
    # any script extensions should go in /extensions, and should follow the same directory structure as vanilla

    # ? Brief description/reason behind this edit of vanilla code...
    #ModLoaderMod.install_script_extension(extensions_dir_path.path_join("main.gd"))


func install_script_hook_files() -> void:
    pass
    
    # ? Brief description/reason behind this edit of vanilla code...
    #ModLoaderMod.install_script_hooks("res://main.gd", extensions_dir_path.path_join("main.gd"))


func _ready() -> void:
    ModLoaderLog.info("Ready", MOD_ID)
