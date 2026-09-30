class_name network_utils
extends RefCounted

static func get_mask_from_ip(ip: String) -> String:
	if not is_valid_ip_address(ip):
		return ""
	return ip.get_slice(".",0)+"."+ip.get_slice(".",1)
	

static func is_valid_ip_address(ip: String) -> bool:
	if (ip.get_slice_count(".") != 4):
		return false
	for i in range(4):
		if not (ip.get_slice(".", i).is_valid_int()):
			return false
		if int(ip.get_slice(".", i)) < 0 or int(ip.get_slice(".", i)) > 255:
			return false
	return true
