-- USAGE: http://wiki.wireshark.org/Lua
---- create an 'init.lua' script in your user directory (e.g. C:\Users\KPirard\init.lua)
---- add a line 
----    dofile('demo.lua').register()
----

    demo_table = DissectorTable.new("demo.type", "Demo	Protocol")
    tcp_table = DissectorTable.get("tcp.port")
    demo_port = 23

    demo_proto = Proto("demo","Demo Protocol")
    function demo_proto.dissector(buffer,pinfo,tree)
        pinfo.cols.protocol = "demo"
        
        local subtree = tree:add(demo_proto,buffer(),"demo Packet")
        local packet_type = buffer(0,1):uint()

        subtree:add(demo_proto.fields.packet_type, buffer(0,1));
        
        -- dispatch to packet-specific dissectors:
        demo_table:try(packet_type, buffer, pinfo, subtree)
    end
    tcp_table:add(demo_port,demo_proto)
    demo_proto.fields.packet_type = ProtoField.uint8("demo.packet_type", "Packet Type", base.HEX_DEC, {
            [0x01] = "demo.short",
            [0x02] = "demo.large"            
    })
    demo_proto.fields.port     = ProtoField.uint8("demo.port", "Port", base.HEX_DEC)
    demo_proto.fields.command  = ProtoField.uint8("demo.command", "Command", base.HEX_DEC)
    demo_proto.fields.checksum = ProtoField.uint8("demo.checksum", "Checksum")
    demo_proto.fields.payload  = ProtoField.bytes("demo.payload", "Payload")

    demo_short_packet_proto = Proto("demo.short", "Demo Short Packet")
    function demo_short_packet_proto.dissector(buffer, pinfo, tree)
        local fields = demo_short_packet_proto.fields
        tree:add(demo_proto.fields.port, buffer(1,1))
        tree:add(demo_proto.fields.command, buffer(2,1))
        tree:add(demo_proto.fields.checksum, buffer(3,1))
        tree:add(demo_proto.fields.payload, buffer(4,8))
    end
    demo_table:add(0x01, demo_short_packet_proto)
    --demo_short_packet_proto.fields = demo_proto.fields

    demo_large_packet_proto = Proto("demo.large", "Demo Large Packet")
    function demo_large_packet_proto.dissector(buffer, pinfo, tree)
        local fields = demo_large_packet_proto.fields
        tree:add(demo_proto.fields.port, buffer(1,1))
        tree:add(demo_proto.fields.command, buffer(2,1))
        tree:add(demo_proto.fields.checksum, buffer(3,1))
        tree:add(demo_proto.fields.payload, buffer(4,64))
    end
    demo_table:add(0x96, demo_large_packet_proto)
    --demo_large_packet_proto.fields.port = demo_proto.fields

    odbdemo_variable_size_packet_proto = Proto("demo.variable", "Odenberg Common demo Variable Packet")
    function odbdemo_variable_size_packet_proto.dissector(buffer, pinfo, tree)
        local fields = odbdemo_variable_size_packet_proto.fields

        tree:add(fields.sequence, buffer(1,1))
        local length = buffer(2,2)
        tree:add_le(fields.length, length)
        tree:add(demo_proto.fields.port, buffer(4,1))
        tree:add(demo_proto.fields.command, buffer(5,1))
        local checksum = buffer(6,2)
        tree:add_le(fields.checksum, checksum)
        local payload = buffer(8,length:le_uint())
        tree:add(demo_proto.fields.payload, payload)
    end
    demo_table:add(0xcc, odbdemo_variable_size_packet_proto)
    odbdemo_variable_size_packet_proto.fields.sequence = ProtoField.uint8("demo.var.sequence", "Sequence")
    odbdemo_variable_size_packet_proto.fields.length = ProtoField.uint16("demo.var.length", "Length")
    --odbdemo_variable_size_packet_proto.fields.port = demo_proto.fields.port
    --odbdemo_variable_size_packet_proto.fields.command = demo_proto.fields.command
    odbdemo_variable_size_packet_proto.fields.checksum = ProtoField.uint16("demo.var.checksum", "Checksum")
    --odbdemo_variable_size_packet_proto.fields.payload = demo_proto.fields.payload
end
    
return my_module