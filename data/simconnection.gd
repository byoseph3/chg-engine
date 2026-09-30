class_name sim_connection
extends RefCounted

var id: String
var device_a_id: String
var device_b_id: String
var refsClass: game_references

func _init(a_id: String, b_id: String, connection_id: String):
	id = connection_id
	device_a_id = a_id
	device_b_id = b_id

func getRouter(world: world_state) -> Device:
	var dev_a: Device = world.devices[device_a_id]
	var dev_b: Device = world.devices[device_b_id]
	
	if (dev_a.get_device_type() == refsClass.DeviceTypes.ROUTER):
		return dev_a
	if (dev_b.get_device_type() == refsClass.DeviceTypes.ROUTER):
		return dev_b
	return null

func is_device_in_connection(device_id: String) -> bool:
	return (device_a_id == device_id or device_b_id == device_id)
