rule arp_request {
    strings:
        $arp_req = { 08 06 00 01 08 00 06 04 00 01 [20] 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 }
    condition:
        any of them
}

rule arp_reply {
    strings:
        $arp_rep = { 08 06 00 01 08 00 06 04 00 02 [20] 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 }
    condition:
        any of them
}

rule arp_mitm : main {
    strings:
        //known addresses
        $mac0 = { FF FF FF FF FF FF } //broadcast
        $mac1 = { 48 5B 39 64 40 79 } //asustek
        $mac2 = { 00 80 F4 09 51 3B } //telemec
        $mac3 = { 00 0C 29 9D 9E 9E } //vmware
    condition:
        //check if there are unknown mac addresses contained in arp packets
        (arp_request and (#mac0 + #mac1 + #mac2 + #mac3) < 3) or (arp_reply and (#mac0 + #mac1 + #mac2 + #mac3) < 4)
}
