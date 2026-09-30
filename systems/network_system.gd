class_name network_system
extends RefCounted

# Facade + Strategy Pattern
# System will provide an interface
# Given Parameters, functions will
# change accordingly.
# Class is mostly abstract with run-time
# implementation happening.

func find_route(src_id: String, dst_id: String, world: world_state):
	var src: Device = world.devices[src_id]
	var dst: Device = world.devices[dst_id]

func connect_to(src_id: String, dst_id: String, world: world_state):
	var src: Device = world.devices[src_id]
	var dst: Device = world.devices[dst_id]

func disconnect_from(src_id: String, dst_id: String, world: world_state):
	var src: Device = world.devices[src_id]
	var dst: Device = world.devices[dst_id]
