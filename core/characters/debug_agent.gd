class_name debug_agent
extends RefCounted

var laptopid: String
var serverid: String
var fileid: String

func setup(srcid, dstid, filid):
	laptopid = srcid
	serverid = dstid
	fileid = filid

func initiateFTA(action_sys: action_system):
	var FTA = FileTransferAction.new()
	
	# Handled in setup
	# Get laptop id
	# Get server id
	# Get file id
	
	# Setup Action
	FTA.src_device_id = serverid
	FTA.dst_device_id = laptopid
	FTA.file_id = fileid
	
	# Invoke FTA
	action_sys.add_process(FTA)
	pass
