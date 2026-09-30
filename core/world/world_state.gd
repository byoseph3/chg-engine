class_name world_state
extends RefCounted

var id_generator = IDGenerator.new()
var refsClass = game_references

var characters: Dictionary = {}
var devices: Dictionary = {}
var network_topology: Dictionary = {}
#var network_sessions: Dictionary = {}
var locations: Dictionary = {}

# Directly World Altering Functions
func add_device(device: Device):
	device.id = id_generator.generate()
	devices[device.id] = device
	
	# Instantly setup routers
	if (device.device_type == refsClass.DeviceTypes.ROUTER):
		setup_device_networking(device, "")

func remove_device(id: String):
	devices.erase(id)

func setup_device_networking(device: Device, conn_id: String):
	# If router, gets a random ip address
	# Otherwise, gets a subnet address from router
	var is_router = device.device_type == refsClass.DeviceTypes.ROUTER
	var r: router
	
	# Checks for router by looking at what router is at the end of the connection
	if (!is_router and conn_id != ""):
		r = network_topology[conn_id].getRouter(self)
		if (r == null):
			printerr("No Router detected in setup!")
			return
		pass
	
	# Set up signal for packet movement
	device.signal_send_packet.connect(send_packet)
	if (is_router):
		device.signal_request_direct_routes_update.connect(check_direct_routes)
	
	# Assign ip
	if (is_router):
		device.ip = id_generator.generate_router_ip()
		device.mask = network_utils.get_mask_from_ip(device.ip)
	else:
		device.ip = id_generator.generate_ip_given_router(r)

# Update loops to bypass RefCounted issue
func update_devices(delta: float) -> void:
	for device in devices.values():
		device.update(delta)

# Toplogy specific
func add_connection(dev_a_id: String, dev_b_id: String):
	var conn = sim_connection.new(dev_a_id, dev_b_id, id_generator.generate())
	network_topology[conn.id] = conn
	
	# Update direct routes for routers involved
	var dev_a: Device = devices[dev_a_id]
	var dev_b: Device = devices[dev_b_id]
	
	if (dev_a.device_type == refsClass.DeviceTypes.ROUTER):
		update_neighbors_cache_for_router(dev_a)
	if (dev_b.device_type == refsClass.DeviceTypes.ROUTER):
		update_neighbors_cache_for_router(dev_b)
	
	return conn.id

func remove_connection(id: String):
	network_topology.erase(id)

func send_packet(d: Device, packet: Dictionary):
	# generalized function (think of it like a re-router)
	# packet will define which functions to use.
	# For example, packet meant to advertise will use the advertise function.
	if (packet.packet_type == refsClass.PacketTypes.ADVERTISE):
		advertise(d, packet)
		return
	
	# Packet hopping
	if packet.next_router_id in devices:
		devices[packet.next_router_id].receive_packet(packet)
	else:
		# drop
		pass

# aliasing function
func get_device_id_from_name(name: String) -> String:
	for device: Device in devices.values():
		if device.name == name:
			return device.id
	return ""

func update_neighbors_cache_for_router(r: router):
	var connected_router_ids := []
	for conn: sim_connection in network_topology.values():
		if (conn.is_device_in_connection(r.id)):
			var other_router: Device # changed to device type to avoid pointless error
			if (conn.device_a_id == r.id):
				other_router = devices[conn.device_b_id]
			else:
				other_router = devices[conn.device_a_id]
			if (other_router.device_type == refsClass.DeviceTypes.ROUTER):
				connected_router_ids.append(other_router.id)
	connected_router_ids.append((r.id))
	r.update_neghbors_cache(connected_router_ids)

# Will move this to routing script
func check_direct_routes(r: router):
	#print("%s is checking direct routes" % [r.name])
	var direct_routing_table: Dictionary = {}
	for conn: sim_connection in network_topology.values():
		if (conn.is_device_in_connection(r.id)):
			var other_router: Device # changed to device type to avoid pointless error
			if (conn.device_a_id == r.id):
				other_router = devices[conn.device_b_id]
			else:
				other_router = devices[conn.device_a_id]
			if (other_router.device_type == refsClass.DeviceTypes.ROUTER):
				# Here, I need to get the subnet of the other router, and then update the routing table.
				# mask : router id (?)
				# router id makes sense since I'll be doing router.receive_packet.
				# for the future, routers will likely have an in-game alias feature. (technically implemented already)
				var mask = id_generator.generate_ip_mask_given_router(other_router)
				#var router_name = other_router.name
				var router_id = other_router.id
				
				direct_routing_table[mask] = router_id
	# quick way of updating routing table is to treat generated routing table as an "other_routing_table"
	var packet = {}
	packet.router_id = "DIRECT_UPDATE" # For debugging purposes and cool in-game effect
	packet.packet_type = refsClass.PacketTypes.ADVERTISE
	packet.routing_table = direct_routing_table
	r.update_routing_table(packet)

func advertise(r: router, packet: Dictionary):
	#print("%s is advertising!" % [r.name])
	for conn: sim_connection in network_topology.values():
		# see if router is in the connection.
		# if so, then send the routing table to them.
		if (conn.is_device_in_connection(r.id)):
			var other_router: Device # need to change type here to avoid pointless error
			if (conn.device_a_id == r.id):
				other_router = devices[conn.device_b_id]
			else:
				other_router = devices[conn.device_a_id]
			if (other_router.device_type == refsClass.DeviceTypes.ROUTER):
				packet.dst_ip = other_router.ip
				other_router.receive_packet(packet)
				#other_router.update_routing_table(packet)
	debug_showcase_print_world_state_routing_tables()
## Network Session
#func create_net_session(device_a_id: String):
	#var session = network_session.new(device_a_id, id_generator.generate())
	#network_sessions[session.id] = session
#
#func remove_net_session(session_id: String):
	#network_sessions[session_id].close_network()
	#network_sessions.erase(session_id)
#
#func add_conn_to_net_session(conn_id: String, session_id: String):
	#var session = network_sessions[session_id]
	#var conn = network_topology[conn_id]
	#session.add_conn(conn) # Using object here to store connection in dictionary.
	

# Will need to replace this
func add_file(new: sim_file, device: Device):
	# Not sure if I'll need to switch out device to the ID
	# Will continue to use Device since this is the same script
	if device.id == "":
		add_device(device) # Sanity check
	new.id = id_generator.generate()
	device.add_file(new)

func showcase1_setup():
	# Vertical Slice Demonstration
	var laptop1: Laptop = Laptop.new()
	laptop1.name = "laptop1"
	add_device(laptop1)
	var server1: SimServer = SimServer.new()
	server1.name = "server1"
	add_device(server1)
	var file1 = sim_file.new()
	file1.file_name = "flag.txt"
	file1.contents = "Flag is 0xDEATHWISH"
	add_file(file1, server1)
	
	# world_sim-less test
	
	#print("Server1's files:")
	#server1.debug_print_file_ids()
	#print("==================")
	#print("Laptop1's files:")
	#laptop1.debug_print_file_ids()
	#print("==================")
	#print("Transferring...")
	#
	#print("==================")
	#print("Server1's files:")
	#server1.debug_print_file_ids()
	#print("==================")
	#print("Laptop1's files:")
	#laptop1.debug_print_file_ids()

func debug_showcase_print_world_state_networks():
	print("================= NETWORK TOPOLOGY =================")
	for value: sim_connection in network_topology.values():
		var dev_a: Device = devices[value.device_a_id]
		var dev_b: Device = devices[value.device_b_id]
		print("%s --- %s" % [dev_a.name, dev_b.name])
	print("================= DEVICE IPs =================")
	for value in devices.values():
		print("%s: %s" % [value.name, value.ip])

func debug_showcase_print_world_state_routing_tables():
	for device: Device in devices.values():
		if (device.device_type == refsClass.DeviceTypes.ROUTER):
			print("================= ROUTER %s =================" % [device.name])
			for mask in device.routing_table.keys():
				var r = devices[device.routing_table[mask]]
				print("%s/16 : %s" % [mask, r.name])

func debug_showcase_print_world_state_devices():
	for value in devices.values():
		print("=================")
		print("%s's files:" % [value.name])
		value.debug_print_file_ids()
	print("")

func showcase_get_device_id(deviceName: String):
	for id in devices.keys():
		var device = devices[id]
		if device.name == deviceName:
			return id
	return ""

func showcase_get_file_id(fileName: String, deviceid: String):
	var files = devices[deviceid].files
	#print("%s, %s" % [fileName, deviceid])
	for id in files.keys():
		if files[id].file_name == fileName:
			#print(id)
			return id
	return ""


func showcase2_setup():
	# Devices
	var router1 = router.new()
	router1.name = "router1"
	add_device(router1)
	var laptop1 = Laptop.new()
	laptop1.name = "laptop1"
	add_device(laptop1)
	var laptop2 = Laptop.new()
	laptop2.name = "laptop2"
	add_device(laptop2)
	
	# Connections
	var conn1 = add_connection(laptop1.id, router1.id)
	var conn2 = add_connection(laptop2.id, router1.id)
	setup_device_networking(laptop1, conn1)
	setup_device_networking(laptop2, conn2)
	
	# More Devices
	var server1 = SimServer.new()
	var server2 = SimServer.new()
	server1.name = "server1"
	server2.name = "server2"
	add_device(server1)
	add_device(server2)
	var router2 = router.new()
	router2.name = "router2"
	add_device(router2)
	
	# More Connections
	var conn3 = add_connection(server1.id, router2.id)
	var conn4 = add_connection(server2.id, router2.id)
	setup_device_networking(server1, conn3)
	setup_device_networking(server2, conn4)
	
	# Intermediary Router
	var router3 = router.new()
	router3.name = "router3"
	add_device(router3)
	
	# Router to router connection
	var conn5 = add_connection(router1.id, router3.id)
	var conn6 = add_connection(router2.id, router3.id)
	
	pass
