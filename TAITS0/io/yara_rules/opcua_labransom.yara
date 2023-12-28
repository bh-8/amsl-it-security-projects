import "console"
import "numeric"

rule opcua_labransom_writevalue {
    strings:
        $opcua_writerequest = { 4D 53 47 46 [8] 01 00 00 00 [8] 01 00 A1 02 [46] FF FF FF FF 03 0A [4] 00 00 00 00 }
    condition:
        #opcua_writerequest > 0 and (int8(@opcua_writerequest[1] + 80) != 0)
}

rule opcua_labransom_scid {
    strings:
        $opcua_writerequest = { 4D 53 47 46 [8] 01 00 00 00 [8] 01 00 A1 02 [46] FF FF FF FF 03 0A [4] 00 00 00 00 }
    condition:
        #opcua_writerequest > 0
}

rule opcua_ransom_sign_writevalue {
    strings:
        $opcua_sign_writerequest = { 4D 53 47 46 [8] 01 00 00 00 [8] 01 00 A1 02 [78] FF FF FF FF 01 0A }
    condition:
        #opcua_sign_writerequest > 0 and console.log("=", numeric.float32(@opcua_sign_writerequest[1] + 112))
}
