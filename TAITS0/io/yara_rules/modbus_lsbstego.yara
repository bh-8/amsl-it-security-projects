import "console"
import "math"
import "numeric"

rule modbus_lsbstego_3registers5 {
    strings:
        $mrhr = { 00 00 [2] 01 03 06 }
    condition:
        #mrhr > 0 and console.log("> entropy1 = ", math.entropy(@mrhr[1] + 7, 2)) and console.log("> entropy2 = ", math.entropy(@mrhr[1] + 9, 2)) and console.log("> entropy3 = ", math.entropy(@mrhr[1] + 11, 2))
}
rule modbus_lsbstego_3registers5pbs100 {
    strings:
        $mrhr = { 00 00 [2] 01 03 06 }
    condition:
        #mrhr >= 5 and console.log("> entropy1 = ", numeric.distributed_entropy(@mrhr[1] + 7, @mrhr[2] + 7, @mrhr[3] + 7, @mrhr[4] + 7, @mrhr[5] + 7)) and console.log("> entropy2 = ", numeric.distributed_entropy(@mrhr[1] + 9, @mrhr[2] + 9, @mrhr[3] + 9, @mrhr[4] + 9, @mrhr[5] + 9)) and console.log("> entropy3 = ", numeric.distributed_entropy(@mrhr[1] + 11, @mrhr[2] + 11, @mrhr[3] + 11, @mrhr[4] + 11, @mrhr[5] + 11))
}
