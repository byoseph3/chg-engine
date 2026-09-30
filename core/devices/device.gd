class_name Device
extends RefCounted

var id: String
var name: String # Primarily for debugging
var files: Dictionary = {}
var ip: String
var device_type
var refsClass: game_references
var subnet_devices_cache: Array = []

signal signal_send_packet(d: Device, packet: Dictionary)

func update(delta: float) -> void:
	# Namespace being used here so all devices can have update functionality
	pass

func handle_packet(packet: Dictionary) -> void:
	# Namespace being used here so all devices can have update functionality
	pass

#recv
func update_subnet_devices_cache(subnet_device_ids: Array):
	subnet_devices_cache = subnet_device_ids

func get_device_type():
	return device_type

func add_file(file: sim_file):
	# by now, the file should have it's own file id.
	files[file.id] = file

func delete_file(file_id: String):
	files.erase(file_id)

# Networking Functions
func send_packet(packet: Dictionary):
	signal_send_packet.emit(self, packet)

func debug_print_file_ids():
	for values in files.values():
		print("id: %s, filename: %s" % [values.id, values.file_name])
