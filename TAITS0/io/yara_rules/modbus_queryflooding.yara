import "numeric"

rule modbus_queryflooding_repetition : main {
    strings:
        $modbus_query_request = { 00 80 F4 09 51 3B 00 0C 29 E6 14 0D 08 00 45 00 00 34 [2] 40 00 40 06 [2] AC 1B E0 32 AC 1B E0 FA [2] 01 F6 [4] [4] 50 18 72 10 [2] 00 00 [2] 00 00 00 06 01 06 00 06 00 00 }
    condition:
        #modbus_query_request >= 3
}

rule modbus_queryflooding_timing : main {
    strings:
        $modbus_query_request = { 00 80 F4 09 51 3B 00 0C 29 E6 14 0D 08 00 45 00 00 34 [2] 40 00 40 06 [2] AC 1B E0 32 AC 1B E0 FA [2] 01 F6 [4] [4] 50 18 72 10 [2] 00 00 [2] 00 00 00 06 01 06 00 06 00 00 FF [8] FE }
    condition:
        #modbus_query_request >= 2 and (numeric.int64(@modbus_query_request[1] + 66) - numeric.int64(@modbus_query_request[2] + 66)) < 100000
}
