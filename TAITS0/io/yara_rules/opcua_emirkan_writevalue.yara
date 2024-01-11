import "console"
import "numeric"

rule opcua_writevalue : main
{
    strings:
        $opcua_writerequest = { 4D 53 47 46 58 00 00 00 [4] 01 00 00 00 [8] 01 00 A1 02 [46] FF FF FF FF 03 0A [4] 00 00 00 00 }
    condition:
        #opcua_writerequest > 0 and (int8(@opcua_writerequest[1] + 80) != 0)
}

rule opcua_error : main
{
    strings:
        $opcua_error = { 45 52 52 46 ?? 00 00 00 }
    condition:
        any of them
}

/*
SignWriteValue: Aufzeichnung ist unbrauchbar, da Manipulation fehlerhaft
SignEncrypt: Nix, verschlüsselt!
*/
