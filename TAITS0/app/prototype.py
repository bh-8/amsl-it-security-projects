from scapy.all import *
import yara
from pathlib import Path
import time

# parameterization
PACKET_FILTER = "ip"
PACKET_BUFFER_SIZE = 1
YARA_RULES_PATH = Path("./io/yara_rules/")
USE_PCAP = Path("./io/example1_mode1_modify.pcapng")
# TODO: apply argparse

print(f"""[!] Initializing with following parameterization:
    PACKET_FILTER='{PACKET_FILTER}'
    PACKET_BUFFER_SIZE={PACKET_BUFFER_SIZE}
    YARA_RULES_PATH='{YARA_RULES_PATH}'
    USE_PCAP='{USE_PCAP}'""")

# load yara rules
yara_rule_files = [file.resolve() for file in YARA_RULES_PATH.glob("*") if file.is_file()]
print(f"[!] Compiling {len(yara_rule_files)} YARA rule files: {', '.join([file.name for file in yara_rule_files])}...")
yara_rules = [yara.compile(str(rule_file)) for rule_file in yara_rule_files]
print(f"[!] {len(yara_rules)} YARA rules compiled.")
# TODO: exception handling

# one and only global structure to temporarily store packets
packet_buffer_queue = []

def handle_packet(packet) -> None:
    # append new packet to queue
    packet_buffer_queue.append(packet)

    # remove oldest packet from queue if maximum size exceeded
    if len(packet_buffer_queue) > PACKET_BUFFER_SIZE:
        packet_buffer_queue.pop(0)

    # convert queue to raw data
    raw_data_list = [raw(packet) for packet in packet_buffer_queue]
    raw_data = b"\n".join(raw_data_list)

    #print(f"{raw_data}")

    # yara matching
    match_vector = [rule.match(data=raw_data) for rule in yara_rules]
    result = [rule_match for rule_match in match_vector if len(rule_match) > 0]
    print(f"{time.time()} {result}")

if USE_PCAP is None:
    print(f"[!] Sniffing...")
    sniff(filter=PACKET_FILTER, prn=handle_packet)
else:
    # TODO: exception handling
    print(f"[!] Reading packets from pcap file '{USE_PCAP}'...")
    pcap_packets = rdpcap(str(USE_PCAP.resolve()))
    [handle_packet(packet) for packet in pcap_packets]
