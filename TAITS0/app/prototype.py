import argparse
from functools import reduce
from pathlib import Path
import sys
from collections import deque

from scapy.all import *
import yara

# argument parsing
parser = argparse.ArgumentParser(
    prog="yara-packet-inspector",
    description="applies yara rules to network data stream"
)
parser.add_argument("pcap_file", nargs="*", help="pcap file(s) to apply rules to; if none is given, real-time network data stream will be used")
parser.add_argument("-pbs", "--packet-buffer-size", type=int, default=1, help="set packet buffer size on which the rules are applied to")
parser.add_argument("-psf", "--packet-sniff-filter", type=str, default="ip", help="set scapy sniff filter; only applied when no pcap file is used")
parser.add_argument("-yrp", "--yara-rules-path", type=str, default="./io/yara_rules/", help="set directory where yara rule files (*.yara) are located")
args = parser.parse_args()

# parameterization
PCAP_LIST = args.pcap_file
if len(args.pcap_file) > 0:
    PCAP_LIST = [Path(pcap_file).resolve() for pcap_file in args.pcap_file]
PACKET_BUFFER_SIZE = args.packet_buffer_size
PACKET_SNIFF_FILTER = args.packet_sniff_filter
YARA_RULES_PATH = Path(args.yara_rules_path).resolve()

print(f"[!] Initializing with following parameterization:")
print(f"    MODE={'PCAP_INSPECTION' if len(PCAP_LIST) > 0 else 'REALTIME_SNIFF'}")
print(f"    PACKET_BUFFER_SIZE={PACKET_BUFFER_SIZE}")
print(f"    PACKET_SNIFF_FILTER={PACKET_SNIFF_FILTER}")
print(f"    YARA_RULES_PATH={YARA_RULES_PATH}")

if len(PCAP_LIST) > 0:
    # check existance of given pcap files
    if not reduce(lambda x, y: x and y, [pcap_file.exists() for pcap_file in PCAP_LIST], True):
        print(f"[!] ERROR: Failed to access one or more of the given pcap files!")
        sys.exit(1)

# load yara rules
if not YARA_RULES_PATH.exists():
    print(f"[!] ERROR: Failed to access yara rule directory '{YARA_RULES_PATH}'!")
    sys.exit(1)
yara_rule_files = [file.resolve() for file in YARA_RULES_PATH.glob("*.yara") if file.is_file()]
if len(yara_rule_files) <= 0:
    print(f"[!] ERROR: Could not find any yara rule files in '{str(YARA_RULES_PATH / '*.yara')}'!")
    sys.exit(1)
print(f"[!] Compiling {len(yara_rule_files)} YARA rule files: {', '.join([file.name for file in yara_rule_files])}...")
yara_rules = [yara.compile(str(rule_file)) for rule_file in yara_rule_files]
print(f"[!] {len(yara_rules)} YARA rules compiled.")

# global structure to temporarily store packets
packet_buffer_deque = deque([])

# only used when real-time sniffing mode is used
sniff_packet_index = 0

def handle_packet(packet, index = -1) -> None:
    # append new packet to queue
    packet_buffer_deque.appendleft(packet)

    # remove oldest packet from queue if maximum size exceeded
    if len(packet_buffer_deque) > PACKET_BUFFER_SIZE:
        packet_buffer_deque.pop()

    # convert queue to raw data
    raw_data = b"".join([raw(packet) + b"\xff" + (round(packet.time * 1000000000).to_bytes(8, "big")) + b"\xfe" for packet in packet_buffer_deque])

    # match vector contains an entry for every yara rule, even if the rule has not been triggered
    match_vector = [rule.match(data=raw_data) for rule in yara_rules]

    # filter interesting results
    result = [rule_match for rule_match in match_vector if len(rule_match) > 0]

    if index == -1:
        # sniffing mode case
        global sniff_packet_index
        sniff_packet_index += 1
        print(f"{sniff_packet_index}: {result}")
    elif len(result) > 0:
        # pcap case
        print(f"{index + 1}: {result}")

if len(PCAP_LIST) == 0:
    print(f"[!] Sniffing...")
    sniff(filter=PACKET_SNIFF_FILTER, prn=handle_packet)
else:
    for pcap_file in PCAP_LIST:
        print(f"[!] Reading packets from pcap file '{pcap_file}'...")
        pcap_packets = rdpcap(str(pcap_file))
        [handle_packet(packet, i) for i, packet in enumerate(pcap_packets)]
