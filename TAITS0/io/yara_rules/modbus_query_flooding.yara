import "console"
import "numeric"

rule modbus_query_flooding {
    strings:
        $modbus_query_request = { 00 80 F4 09 51 3B 00 0C 29 E6 14 0D 08 00 45 00 00 34 [2] 40 00 40 06 [2] AC 1B E0 32 AC 1B E0 FA [2] 01 F6 [4] [4] 50 18 72 10 [2] 00 00 [2] 00 00 00 06 01 06 00 06 00 00 }
    condition:
        #modbus_query_request >= 3
}

rule modbus_polling_interval {
    strings:
        $modbus_polling_request = { 00 0C 29 9D 9E 9E 00 80 F4 09 51 3B 08 00 45 00 00 47 [2] 40 00 40 06 [2] AC 1B E0 FA AC 1B E0 46 01 F6 C1 5B [4] [4] 50 18 22 08 [2] 00 00 00 00 00 00 00 19 01 03 16 [2] [2] [2] [2] [2] [2] [2] [2] [2] [2] [2] FF [8] FE }
    condition:
        #modbus_polling_request >= 2 and console.log("most recent diff. time: ", (numeric.int64(@modbus_polling_request[1] + 86) - numeric.int64(@modbus_polling_request[2] + 86)))
}
