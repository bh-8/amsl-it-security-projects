from statistics import mean, stdev, variance

file_list = [
    "entropy23.txt",
    "entropy33.txt",
    "entropy41.txt",
    "entropy42.txt",
    "entropy45.txt",
    "entropy49.txt",
    "entropy412.txt",
    "entropy53.txt"
]

for f in file_list:
    with open(f) as h:
        floating_numbers = [float(s) for s in h.readlines()]

        print(f"""=== {f} ===
  > sample size : {len(floating_numbers)}
  > mean        : {mean(floating_numbers)}
  > st. dev.    : {stdev(floating_numbers)}
  > variance    : {variance(floating_numbers)}
""")
