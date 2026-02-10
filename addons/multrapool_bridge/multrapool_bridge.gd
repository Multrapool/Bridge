@tool
extends EditorPlugin


func _enable_plugin() -> void:
    # Add autoloads here.
    pass


func _disable_plugin() -> void:
    # Remove autoloads here.
    pass


func download(link:String, file_name:String, process:Callable):
    var http := HTTPRequest.new()
    add_child(http)
    http.connect("request_completed", 
        func (result, _response_code, _headers, body):
        if result != OK:
            print("Download failed: "+link)
            print(result)
            return
        print("Downloaded "+link+" to "+http.download_file)
        process.call("res://addons/multrapool_bridge/temp/"+file_name)
        remove_child(http))

    http.download_file = ProjectSettings.globalize_path("res://addons/multrapool_bridge/temp/"+file_name)
    http.request(link)
    
static var reader = ZIPReader.new()
func extract_addon(file_name:String, extract_to:String, subfolder:String):
    if reader.open(file_name) == OK:
        # stolen from the docs
        DirAccess.make_dir_recursive_absolute(extract_to)
        var root_dir = DirAccess.open(extract_to)
        for unfiltered_path in reader.get_files():
            if not unfiltered_path.begins_with(subfolder): continue
            var file_path = unfiltered_path.substr(len(subfolder))
            # If the current entry is a directory.
            if file_path.ends_with("/"):
                root_dir.make_dir_recursive(file_path.substr(1))
                continue

            # Write file contents, creating folders automatically when needed.
            # Not all ZIP archives are strictly ordered, so we need to do this in case
            # the file entry comes before the folder entry.
            root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
            FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)\
                .store_buffer(reader.read_file(unfiltered_path))

signal finished
func _enter_tree() -> void:
    
    add_tool_menu_item("Multrapool Bridge: Init Environment", func():
        var after_download = func():
            # replace replacements
            var to_traverse:Array[String]=["res://addons/multrapool_bridge/replacements"]
            var replacements:Array[String]=[]
            while len(to_traverse) > 0 :
                for sub_file in DirAccess.get_directories_at(to_traverse[0]):
                    to_traverse.append(to_traverse[0]+"/"+sub_file)
                for sub_file in DirAccess.get_files_at(to_traverse[0]):
                    if sub_file.ends_with(".uid"): continue
                    replacements.append(to_traverse[0].substr(len("res://addons/multrapool_bridge/replacements/"))\
                        +"/"+sub_file)
                to_traverse.pop_front()
            for replacement in replacements:
                var file = FileAccess.open("res://addons/"+replacement, FileAccess.WRITE)
                file.store_buffer(FileAccess.open("res://addons/multrapool_bridge/replacements/"+replacement, FileAccess.READ)\
                        .get_as_text().to_utf8_buffer())
                file.flush()
                
            # hook hooks
            var to_hook:Array[String]=[
                "res://utils/utils.gd",
                "res://event_manager.gd",
                "res://ui/shop.gd",
                "res://Game.gd",
                "res://droplet.gd",
                "res://ball.gd",
            ]
            EditorInterface.get_editor_main_screen().get_node("ModToolsPanel").context_actions\
                .handle_mod_hook_creation({
                    mod_tool_hook_script_paths=to_hook
                })
                
            print("Multrapool Bridge: Project is set up! Please reload your project (Project > Reload Current Project)")
            
            pass
        var in_progress = [3]
        
        # add mod_tool
        download("https://github.com/GodotModding/godot-mod-tool/archive/3a99d2d0e0d2782db8fe94445d365ca51bb49cac.zip","mod_tool.zip",
            func(file_name):
            extract_addon(file_name, "res://addons/mod_tool", "godot-mod-tool-3a99d2d0e0d2782db8fe94445d365ca51bb49cac/addons/mod_tool")
            in_progress[0]-=1
            if in_progress[0] == 0: after_download.call()
            pass)
        # add mod_loader (todo: remove once this gets shipped)
        download("https://github.com/GodotModding/godot-mod-loader/archive/e75c0454882549a8df42186955a2c81e1acf4015.zip","mod_loader.zip",
            func(file_name):
            extract_addon(file_name, "res://addons/mod_loader", "godot-mod-loader-e75c0454882549a8df42186955a2c81e1acf4015/addons/mod_loader")
            in_progress[0]-=1
            if in_progress[0] == 0: after_download.call()
            pass)
        # add cue
        download("https://github.com/Multrapool/Cue/releases/download/0.4.1/Multrapool-Cue.zip", "cue.zip",
            func(file_name):
            extract_addon(file_name, "res://mods-unpacked/Multrapool-Cue", "mods-unpacked/Multrapool-Cue")
            in_progress[0]-=1
            if in_progress[0] == 0: after_download.call()
            pass)
            
        pass)


func _exit_tree() -> void:
    remove_tool_menu_item("Multrapool Bridge: Init Environment")
