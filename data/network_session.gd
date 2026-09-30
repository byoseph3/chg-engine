class_name network_session
extends RefCounted

var id: String
var dev_a_id: String
var dev_b_id: String
var route: Dictionary = {}

func _init(a_id: String, connection_id: String):
	dev_a_id = a_id
	id = connection_id

func add_conn(conn: sim_connection):
	route[conn.id] = conn

func close_network():
	route.clear()
