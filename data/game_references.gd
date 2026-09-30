class_name game_references
extends RefCounted

enum ActionState {
	PENDING,
	RUNNING,
	COMPLETED,
	FAILED,
	CANCELLED
}

enum DeviceTypes {
	ROUTER,
	LAPTOP,
	SERVER
}

enum PacketTypes {
	ADVERTISE
}
