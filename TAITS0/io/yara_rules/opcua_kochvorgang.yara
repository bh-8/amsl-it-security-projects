import "console"
import "numeric"

rule opcua_kochvorgang_temperature_exceeds_50 {
    strings:
        $opcua_writerequest = { 4D 53 47 46 58 00 00 00 [4] 01 00 00 00 [8] 01 00 A1 02 02 00 00 [4] [8] [4] 00 [3] FF FF FF FF A0 0F 00 00 00 00 00 01 00 00 00 01 04 29 00 0D 00 00 00 FF FF FF FF 03 0A [4] 00 00 00 00 }
    condition:
        #opcua_writerequest > 0 and console.log("most recent temperature: ", numeric.float32(@opcua_writerequest[1] + 80)) and numeric.float32(@opcua_writerequest[1] + 80) >= 50
}

rule opcua_kochvorgang_temperature_difference_exceeds_5 {
    strings:
        $opcua_writerequest = { 4D 53 47 46 58 00 00 00 [4] 01 00 00 00 [8] 01 00 A1 02 02 00 00 [4] [8] [4] 00 [3] FF FF FF FF A0 0F 00 00 00 00 00 01 00 00 00 01 04 29 00 0D 00 00 00 FF FF FF FF 03 0A [4] 00 00 00 00 }
    condition:
        #opcua_writerequest >= 2 and console.log("most recent diff. temp.: ", (numeric.float32(@opcua_writerequest[1] + 80) - numeric.float32(@opcua_writerequest[2] + 80))) and (numeric.float32(@opcua_writerequest[1] + 80) - numeric.float32(@opcua_writerequest[2] + 80)) > 5
}
