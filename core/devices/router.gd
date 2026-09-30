class_name router
extends Device

var routing_table: Dictionary = {}
signal signal_request_direct_routes_update
var UPDATE_INTERVAL := 1.0
var timer_update: float
var router_neighbors_cache: Array = []
var mask: String

func _init():
	device_type = refsClass.DeviceTypes.ROUTER
	timer_update = UPDATE_INTERVAL
	#update_direct_routes()
	#advertise_routes()

func update(delta: float):
	_process_routing_timer(delta)

func _process_routing_timer(delta: float) -> void:
	timer_update -= delta
	
	if (timer_update <= 0):
		timer_update = UPDATE_INTERVAL
		update_direct_routes()
		advertise_routes()

func handle_packet(packet: Dictionary) -> void:
	match packet.packet_type:
		refsClass.PacketTypes.ADVERTISE:
			update_routing_table(packet)
		_:
			pass
	

#recv
func update_neghbors_cache(connected_router_ids: Array):
	router_neighbors_cache = connected_router_ids

# recv
func update_routing_table(packet: Dictionary):
	var other_routing_table = packet.routing_table
	var other_router_id = packet.router_id
	
	# Sanitize routing table (check if ids are neighbors)
	# while merging :sob:
	for mask in other_routing_table.keys():
		# Sanitize
		var rt_routers_id = other_routing_table[mask]
		if rt_routers_id not in router_neighbors_cache:
			rt_routers_id = other_router_id
		# Merge
		routing_table[mask] = rt_routers_id # I think this works?
	
	#routing_table.merge(other_routing_table)

#send/recv
func update_direct_routes():
	signal_request_direct_routes_update.emit(self)

#send
func advertise_routes():
	var packet := {}
	packet.src_ip = ip
	# doesn't need dst_ip in current development because advertise sends to all nearby connections via world state
	packet.router_id = id
	packet.next_router_id = "ADVERTISING" # for debugging and in-game aesthetic
	packet.routing_table = routing_table.duplicate(false) # using false for now since I'm only adding a packet type here.
	packet.packet_type = refsClass.PacketTypes.ADVERTISE
	signal_send_packet.emit(self, packet)
	pass

#recv
func receive_packet(packet):
	var packet_mask = network_utils.get_mask_from_ip(packet.dst_ip)
	# check if subnet belongs to router.
	if (packet_mask == mask):
		# if so, send to device connected to specific router.
		
		# addressed to router directly?
		if (packet.dst_ip == ip):
			handle_packet(packet)
		else:
			# check if device exists within subnet.
			# if not then drop
			pass
	else:
		packet.next_router_id = routing_table[packet_mask]
		signal_send_packet.emit(self, packet)
	# if not, forward
	pass
