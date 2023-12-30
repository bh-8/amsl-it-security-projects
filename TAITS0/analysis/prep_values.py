from statistics import mean, stdev, variance

file_list = [
    "singlechannel.txt"
]

for f in file_list:
    entropy1 = []
    entropy1_last = None
    entropy2 = []
    entropy2_last = None
    entropy3 = []
    entropy3_last = None

    with open(f) as h:
        lines = [s for s in h.readlines()]

        i=0
        while(i < len(lines)):
            line = lines[i]
            if "entropy1" in line:
                if (entropy1_last is None) or (entropy1_last != line.strip()):
                    entropy1_last = line.strip()
                    val = line.split("=")[1].strip()
                    entropy1.append(str(val))
                    print(f"{i} entropy1>{val}")
            elif "entropy2" in line:
                if (entropy2_last is None) or (entropy2_last != line.strip()):
                    entropy2_last = line.strip()
                    val = line.split("=")[1].strip()
                    entropy2.append(str(val))
                    print(f"{i} entropy2>{val}")
            elif "entropy3" in line:
                if (entropy3_last is None) or (entropy3_last != line.strip()):
                    entropy3_last = line.strip()
                    val = line.split("=")[1].strip()
                    entropy3.append(str(val))
                    print(f"{i} entropy3>{val}")
            else:
                pass
            i += 1
        with open(f"{f}-entropy1.txt", "w") as h:
            h.write("\n".join(entropy1))
            h.close()
        with open(f"{f}-entropy2.txt", "w") as h:
            h.write("\n".join(entropy2))
            h.close()
        with open(f"{f}-entropy3.txt", "w") as h:
            h.write("\n".join(entropy3))
            h.close()
