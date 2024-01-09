import "numeric"

rule opcua_kochvorgang_xcds50 : main {
    strings:
        $opcua_writerequest = { 4D 53 47 46 [8] 01 00 00 00 [8] 01 00 A1 02 [46] FF FF FF FF 03 0A [4] 00 00 00 00 }
    condition:
        #opcua_writerequest > 0 and numeric.float32(@opcua_writerequest[1] + 80) >= 50
}
