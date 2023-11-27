rule example1_mode1_modify_register_sequence {
    strings:
        $register_seq = { 00 0A 00 0B 00 0C 00 0D 00 0E 00 0F 00 10 00 11 00 12 00 13 }
    condition:
        $register_seq
}