import "console"
import "math"

rule modbus_lsbstego_1register {
    strings:
        $modbus_read_holding_registers = { 00 00 [2] 01 03 02 }
    condition:
        #modbus_read_holding_registers > 0 and not(math.in_range(math.entropy(@modbus_read_holding_registers[1] + 7, 2), 0.9851822858420934 - 0.12082618019034695, 0.9851822858420934 + 0.12082618019034695))
}
rule modbus_lsbstego_2registers {
    strings:
        $modbus_read_holding_registers = { 00 00 [2] 01 03 04 }
    condition:
        #modbus_read_holding_registers > 0 and not(math.in_range(math.entropy(@modbus_read_holding_registers[1] + 7, 4), 1.950122040034813 - 0.2208671561468587, 1.950122040034813 + 0.2208671561468587))
}
rule modbus_lsbstego_3registers {
    strings:
        $modbus_read_holding_registers = { 00 00 [2] 01 03 06 }
    condition:
        #modbus_read_holding_registers > 0 and not(math.in_range(math.entropy(@modbus_read_holding_registers[1] + 7, 6), 1.7225273324885348 - 0.23124366933954676, 1.7225273324885348 + 0.23124366933954676) or math.in_range(math.entropy(@modbus_read_holding_registers[1] + 7, 6), 2.1014714753549786 - 0.28592777941526104, 2.1014714753549786 + 0.28592777941526104) or math.in_range(math.entropy(@modbus_read_holding_registers[1] + 7, 6), 2.5287874335102107 - 0.24226990225705541, 2.5287874335102107 + 0.24226990225705541))
}
rule modbus_lsbstego_5registers {
    strings:
        $modbus_read_holding_registers = { 00 00 [2] 01 03 0a }
    condition:
        #modbus_read_holding_registers > 0 and not(math.in_range(math.entropy(@modbus_read_holding_registers[1] + 7, 10), 3.1758527350390287 - 0.3591791558008315, 3.1758527350390287 + 0.3591791558008315))
}
rule modbus_lsbstego_9registers {
    strings:
        $modbus_read_holding_registers = { 00 00 [2] 01 03 12 }
    condition:
        #modbus_read_holding_registers > 0 and not(math.in_range(math.entropy(@modbus_read_holding_registers[1] + 7, 18), 3.926174540225418 - 0.4244056379419754, 3.926174540225418 + 0.4244056379419754))
}
rule modbus_lsbstego_12registers {
    strings:
        $modbus_read_holding_registers = { 00 00 [2] 01 03 18 }
    condition:
        #modbus_read_holding_registers > 0 and not(math.in_range(math.entropy(@modbus_read_holding_registers[1] + 7, 24), 4.275659897356143 - 0.4380360123303514, 4.275659897356143 + 0.4380360123303514))
}
