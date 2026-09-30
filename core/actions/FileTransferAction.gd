class_name FileTransferAction
extends action

var src_device_id: String
var dst_device_id: String
var file_id: String

# need to use this for update loop
var transfer_speed: float = 100.0

func update(world: world_state, delta: float):
	progress += transfer_speed * delta
	
	if progress >= 100.0:
		complete(world)

func complete(world: world_state):
	var src = world.devices[src_device_id]
	var dst: Device = world.devices[dst_device_id]
	var file = src.files[file_id]
	dst.files[file_id] = file
	super.complete(world)
	#state = ActionState.COMPLETED
