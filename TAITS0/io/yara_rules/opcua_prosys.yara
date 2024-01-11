import "numeric"
import "console"

rule opcua_prosys5 : main {
    strings:
        $pr = { 4d 53 47 46 [4] 05 00 00 00 01 00 00 00 [8] 01 00 3D 03 [12] 00 00 00 00 00 FF FF FF FF 00 00 00 01 00 00 00 [12] ?? [4] [8] 01 00 00 00 01 00 2B 03 01 [4] 05 00 00 00 [4] 0D 0B [8] [16] [4] 0D 0B [8] [16] [4] 0D 0B [8] [16] [4] 0D 0B [8] [16] [4] 0D 0B [8] [16] FF FF FF FF [4-12] FF FF FF FF }
        //$pr = { 4d 53 47 46 [4] 05 00 00 00 01 00 00 00 [8] 01 00 3D 03 [12] 00 00 00 00 00 FF FF FF FF 00 00 00 01 00 00 00 [12-16] ?? [4] [8] 01 00 00 00 01 00 2B 03 01 [4] 05 00 00 00 [4] 0D 0B [8] [16] [4] 0D 0B [8] [16] [4] 0D 0B [8] [16] [4] 0D 0B [8] [16] [4] 0D 0B [8] [16] FF FF FF FF [4-12] FF FF FF FF }
    condition:
        //any of them
        #pr > 0 and console.log("d1=", numeric.float64(@pr[1] + 104)) and console.log("d2=", numeric.float64(@pr[1] + 134)) and console.log("d3=", numeric.float64(@pr[1] + 164)) and console.log("d4=", numeric.float64(@pr[1] + 194)) and console.log("d5=", numeric.float64(@pr[1] + 224))
}

/*
- unterschiedliche Pakete: verschieden viele Werte pro Paket
- wenn in Pattern Match variable Längen sind z.B. [4-8], kann das Offset zum Parsen des Werts nicht fix angegeben werden
    --> man braucht einzelne Regeln für jedes Paket

- Wireshark-Filter: opcua.servicenodeid.numeric == 829
*/
