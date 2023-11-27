from scapy import sniff
#https://scapy.readthedocs.io/en/latest/usage.html#sniffing
pendingPackets = []
baseFilename = "capture-"
totalPackets = 0

def handle_packet(packet):
    pendingPackets.append(packet)
    totalPackets += 1

    if len(pendingPackets) >= 100:
        filename = baseFilename + str(totalPackets) + ".pcap"
        wrpcap(filename, pendingPackets)
        pendingPackets = []

sniff(filter="ip", prn=handle_packet)
