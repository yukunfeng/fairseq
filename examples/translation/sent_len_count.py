import sys
import re

if __name__ == "__main__":
    fh_list = []
    if len(sys.argv) >= 2:
        extra_params = sys.argv[1:]
        for file_path in extra_params:
            fh = open(file_path, 'r')
            fh_list.append(fh)
    else:
        fh = sys.stdin
        fh_list.append(fh)

    lens = {}
    for fh in fh_list:
        for line in fh:
            line = line.strip()
            if line == "":
                continue
            items = line.split(' ')
            sent_len = len(items)
            if sent_len < 50:
              sent_len = "-50"
            elif sent_len < 100:
              sent_len = "50-100"
            elif sent_len < 200:
              sent_len = "100-200"
            else:
              sent_len = "200+"
            if sent_len not in lens:
              lens[sent_len] = 0 
            lens[sent_len] += 1 

    for fh in fh_list:
        fh.close()

    total = sum(lens.values())
    for sent_len in lens.keys():
      percent = lens[sent_len] / total 
      percent = f"{percent * 100: .2f}"
      print(f"{sent_len}: {percent} {lens[sent_len]}/{total}")
