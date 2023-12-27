import "console"

rule opcua_labransom_writevalue {
    strings:
        $opcua_writerequest = { 4D 53 47 46 58 00 00 00 [4] 01 00 00 00 [8] 01 00 A1 02 02 00 00 [4] [8] [4] 00 [3] FF FF FF FF A0 0F 00 00 00 00 00 01 00 00 00 01 04 29 00 0D 00 00 00 FF FF FF FF 03 0A [4] 00 00 00 00 }
    condition:
        #opcua_writerequest > 0 and (int8(@opcua_writerequest[1] + 80) != 0)
}

rule opcua_labransom_scid {
    strings:
        $opcua_writerequest = { 4D 53 47 46 58 00 00 00 [4] 01 00 00 00 [8] 01 00 A1 02 02 00 00 [4] [8] [4] 00 [3] FF FF FF FF A0 0F 00 00 00 00 00 01 00 00 00 01 04 (29 00 | 2b 00) 0D 00 00 00 FF FF FF FF 03 0A [4] 00 00 00 00 }
    condition:
        #opcua_writerequest > 0
}
