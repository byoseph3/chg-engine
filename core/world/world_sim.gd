extends Node

var world: world_state
var showcase_agent: debug_agent
var action_sys: action_system
var network_sys: network_system

var showcase_id = 3

func _ready() -> void:
	world = world_state.new()
	action_sys = action_system.new()
	network_sys = network_system.new()
	
	if (showcase_id == 1):
		showcase_agent = debug_agent.new()
		world.showcase1_setup()
		var serverid = world.showcase_get_device_id("server1")
		var fileid = world.showcase_get_file_id("flag.txt", serverid)
		#print("File_ID: %s" % [fileid])
		showcase_agent.setup(
			world.showcase_get_device_id("laptop1"),
			serverid,
			fileid
		)
		
		#Showcase
		world.debug_showcase_print_world_state_devices()
		showcase_agent.initiateFTA(action_sys)
		#world.debug_showcase_print_world_state()
	elif (showcase_id == 2):
		world.showcase2_setup()
		world.debug_showcase_print_world_state_networks()
	elif (showcase_id == 3):
		world.showcase2_setup() # built upon showcase 2
		world.debug_showcase_print_world_state_networks()
		world.debug_showcase_print_world_state_routing_tables()

func _process(delta: float) -> void:
	# Tick function
	action_sys.update(world, delta)
	world.update_devices(delta)
