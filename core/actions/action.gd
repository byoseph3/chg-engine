class_name action
extends RefCounted

var ActionState = game_references.ActionState

var id: String
var actor_id: String

var state = ActionState.PENDING
var progress: float = 0.0

var target_id: String
var parameters: Dictionary

signal action_started
signal action_canceled
signal action_completed

func start(world):
	pass
	
func update(world, delta: float):
	pass

func cancel(world):
	state = ActionState.CANCELLED

func complete(world):
	action_completed.emit(self)
	state = ActionState.COMPLETED
