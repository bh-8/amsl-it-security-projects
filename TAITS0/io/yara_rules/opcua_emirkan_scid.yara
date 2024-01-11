rule opcua_securechannelid : main
{
    strings:
        $opcua_msgf = { 4D 53 47 46 [8] 01 00 00 00 }
    condition:
        #opcua_msgf >= 2 and (uint32(@opcua_msgf[1] + 8) - uint32(@opcua_msgf[2] + 8)) != 0
}

rule opcua_error : main
{
    strings:
        $opcua_error = { 45 52 52 46 ?? 00 00 00 }
    condition:
        any of them
}
