# AI GENERATED CODE!!!

class_name IDGenerator
extends RefCounted

func generate() -> String:
	var bytes := PackedByteArray()

	for i in range(16):
		bytes.append(randi() % 256)

	# UUID v4 version
	bytes[6] = (bytes[6] & 0x0F) | 0x40

	# UUID variant
	bytes[8] = (bytes[8] & 0x3F) | 0x80

	return "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x" % [
		bytes[0], bytes[1], bytes[2], bytes[3],
		bytes[4], bytes[5],
		bytes[6], bytes[7],
		bytes[8], bytes[9],
		bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]
	]

# HUMAN-GENERATED CODE
func generate_router_ip() -> String:
	return str(randi() % 256) + "." + str(randi() % 256) + "." + str(randi() % 256) + "." + str(randi() % 256)

# Should I have this function here? Seems like tight coupling...
func generate_ip_given_router(r: router) -> String:
	var ip: String = generate_ip_mask_given_router(r)
	ip += "." + str(randi() % 256) + "." + str(randi() % 256)
	return ip

func generate_ip_mask_given_router(r: router) -> String:
	var ip: String = ""
	var dots = 0
	for i in r.ip:
		if (i == "."):
			dots += 1
			if (dots == 2):
				break
		ip += i
	return ip
