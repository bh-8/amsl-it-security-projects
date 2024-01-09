import argparse
from collections import deque
from functools import reduce
import json
from pathlib import Path
import sys

from scapy.all import *
import yara

# argument parsing
parser = argparse.ArgumentParser(
    prog="yara-packet-inspector",
    description="applies yara rules to network data stream buffer"
)
parser.add_argument("yara_file", nargs="+", help="yara rule file(s)")
parser.add_argument("-pcap", type=str, help="pcap file to apply rules to; if none is given, real-time network data stream will be used")
parser.add_argument("-pbs", "--packet-buffer-size", type=int, default=1, help="set packet buffer size on which the rules are applied to")
args = parser.parse_args()

# parameterization
YARA_FILES = [Path(yara_file).resolve() for yara_file in args.yara_file]
if not reduce(lambda x, y: x and y, [yara_file.is_file() and yara_file.exists() for yara_file in YARA_FILES], True):
    print(f"[!] ERROR: Failed to access one or more of the given yara rule files!")
    sys.exit(1)

PCAP_FILE = None
if args.pcap is not None:
    PCAP_FILE = Path(args.pcap).resolve()
    if not PCAP_FILE.exists():
        print(f"[!] ERROR: Failed to access given pcap file!")
        sys.exit(1)

PACKET_BUFFER_SIZE = args.packet_buffer_size
PACKET_SNIFF_FILTER = "ip"

print(f"[!] Initializing with following parameterization:")
print(f"    YARA_FILES={[str(yf) for yf in YARA_FILES]}")
print(f"    MODE={'REALTIME_SNIFF' if PCAP_FILE is None else f'(PCAP_INSPECTION={PCAP_FILE})'}")
print(f"    PACKET_BUFFER_SIZE={PACKET_BUFFER_SIZE}")
print(f"    PACKET_SNIFF_FILTER={PACKET_SNIFF_FILTER}")

print(f"[!] Compiling {len(YARA_FILES)} YARA rule file(s): {', '.join([file.name for file in YARA_FILES])}...")
yara_rules = [yara.compile(str(rule_file)) for rule_file in YARA_FILES]
print(f"[!] {len(yara_rules)} YARA rule files compiled.")

# global structure to temporarily store packets
packet_buffer_deque = deque([])

# global structure to log results
log_dict = {}

# only used when real-time sniffing mode is used
sniff_packet_index = 0

# collect interesting results
def fit_match_vector_to_dict(match_vector: list, index: int) -> None:
    global log_dict, YARA_FILES
    for i, rule_match in enumerate(match_vector):
        # use yara rule file name as key to store related results
        key_yara_file = YARA_FILES[i].name
        if not key_yara_file in log_dict:
            log_dict[key_yara_file] = {}

        # check if any rule of yara rule file i matched
        if len(rule_match) > 0:
            # loop concrete matches of that rule file
            for rule_match2 in rule_match:
                if "main" in rule_match2.tags:
                    if not str(rule_match2) in log_dict[key_yara_file]:
                        log_dict[key_yara_file][str(rule_match2)] = []
                    log_dict[key_yara_file][str(rule_match2)].append(index)

def handle_packet(packet, index = -1) -> None:
    # append new packet to queue
    packet_buffer_deque.appendleft(packet)

    # remove oldest packet from queue if maximum size exceeded
    if len(packet_buffer_deque) > PACKET_BUFFER_SIZE:
        packet_buffer_deque.pop()

    # convert queue to raw data
    raw_data = b"".join([
        raw(packet) + b"\xff" + (round(packet.time * 1000000).to_bytes(8, "little")) + b"\xfe"
        for packet in packet_buffer_deque
    ])

    # match vector contains an entry for every yara rule, even if the rule has not been triggered
    match_vector = [rule.match(data=raw_data) for rule in yara_rules]

    # store rule matches in dict
    if index == -1:
        # sniffing mode case
        global sniff_packet_index
        sniff_packet_index += 1
        fit_match_vector_to_dict(match_vector, sniff_packet_index)
        print(f"{sniff_packet_index}: {match_vector}")
    elif len(match_vector) > 0:
        # pcap case
        #print(f"=== Packet {index + 2} ===") #TODO: DEBUG
        fit_match_vector_to_dict(match_vector, index + 1)

if PCAP_FILE is None:
    print(f"[!] Sniffing...")
    sniff(filter=PACKET_SNIFF_FILTER, prn=handle_packet)
else:
    print(f"[!] Reading packets from pcap file '{PCAP_FILE}'...")
    pcap_packets = rdpcap(str(PCAP_FILE))
    print(f"[!] Applying YARA rules...")
    [handle_packet(packet, i) for i, packet in enumerate(pcap_packets)]

print(f"[!] Done!")
print(f"[!] JSON={json.dumps(log_dict, indent=4)}")
