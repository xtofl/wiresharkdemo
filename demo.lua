demo_table = DissectorTable.new("demo.type", "Demo	Protocol")

demo_proto = Proto("demo","Demo Protocol")
function demo_proto.dissector(buffer,pinfo,tree)
	pinfo.cols.protocol = "demo"
        
	local subtree = tree:add(demo_proto,buffer(),"demo Packet")
	local packet_type = buffer(0,1):uint()

	subtree:add(demo_proto.fields.packet_type, buffer(0,1));
	
	-- dispatch to packet-specific dissectors:
	demo_table:try(packet_type, buffer, pinfo, subtree)
end
demo_proto.fields.packet_type = ProtoField.uint8("demo.packet_type", "Packet Type", base.HEX_DEC, {
		[0x01] = "demo.short",
		[0x02] = "demo.large"            
})
demo_proto.fields.command  = ProtoField.uint8("demo.command", "Command", base.HEX_DEC)
demo_proto.fields.payload  = ProtoField.bytes("demo.payload", "Payload")
demo_proto.fields.bitfield1 = ProtoField.uint8("demo.bitfield1", "Bitfield 1", base.HEX_DEC, nil, 0xF0)
demo_proto.fields.bitfield2 = ProtoField.uint8("demo.bitfield2", "Bitfield 2", base.HEX_DEC, nil, 0x0C)

tcp_table = DissectorTable.get("tcp.port")
tcp_table:add(8000,demo_proto)

demo_short_packet_proto = Proto("demo.short", "Demo Short Packet")
function demo_short_packet_proto.dissector(buffer, pinfo, tree)
	local fields = demo_short_packet_proto.fields
	tree:add(demo_proto.fields.command, buffer(1, 1))
	tree:add(demo_proto.fields.payload, buffer(1))
	tree:add(demo_proto.fields.bitfield1, buffer(1, 1))
	tree:add(demo_proto.fields.bitfield2, buffer(1, 1))
end
demo_table:add(0x01, demo_short_packet_proto)
--demo_short_packet_proto.fields = demo_proto.fields

demo_large_packet_proto = Proto("demo.large", "Demo Large Packet")
function demo_large_packet_proto.dissector(buffer, pinfo, tree)
	local fields = demo_large_packet_proto.fields
	tree:add(demo_proto.fields.command, buffer(1, 1))
	tree:add(demo_proto.fields.payload, buffer(1))
	tree:add(demo_proto.fields.bitfield1, buffer(1, 1))
	tree:add(demo_proto.fields.bitfield2, buffer(1, 1))
end
demo_table:add(0x02, demo_large_packet_proto)
--demo_large_packet_proto.fields.port = demo_proto.fields
