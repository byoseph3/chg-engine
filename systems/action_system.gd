class_name action_system
extends RefCounted

var refsClass: game_references
var processes: Dictionary = {}

func add_action(act: action):
	pass

func add_process(proc: action):
	processes["demo_key"] = proc
	# Maybe world state shouldn't start a proc?
	#proc.start(world)
	pass

# To be used for instant actions
# and for time-based processes
func update(world: world_state, delta: float):
	var completed_procs: Array[String] = []
	for key in processes.keys():
		var proc: action = processes[key]
		proc.update(world, delta)
		if helper_should_clean_up(proc):
			completed_procs.append(key)
	
	# clean up
	for key in completed_procs:
		processes.erase(key)
	if completed_procs.size() > 0:
		world.debug_showcase_print_world_state_devices()
		completed_procs.clear()

func helper_should_clean_up(proc: action):
	return proc.state in [
		refsClass.ActionState.COMPLETED,
		refsClass.ActionState.FAILED,
		refsClass.ActionState.CANCELLED
	]
