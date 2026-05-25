class_name ModInfo
extends RefCounted

var id: String = ""
var name: String = ""
var version: String = "1.0.0"
var author: String = ""
var description: String = ""
var dependencies: Array = []
var load_order: int = 0
var source_path: String = ""
var enabled: bool = true
var is_loaded: bool = false
