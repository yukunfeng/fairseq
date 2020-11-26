import argparse
import os


def make_context_nmt_dataset(data_prefix,
                             src,
                             tgt,
                             out_dir,
                             both_context=False,
                             previous_n=1,
                             seg_symbol="SEP"):

  src_path = f"{data_prefix}.{src}"
  tgt_path = f"{data_prefix}.{tgt}"
  src_fh = open(src_path, "r")
  src_lines = []
  with open(src_path, 'r') as fh:
    for line in fh:
      line = line.strip()
      if line == "":
        continue
      src_lines.append(line)

  tgt_lines = []
  with open(tgt_path, 'r') as fh:
    for line in fh:
      line = line.strip()
      if line == "":
        continue
      tgt_lines.append(line)

  if len(src_lines) != len(tgt_lines):
    raise Exception(f"src and tgt len is not the same")

  if both_context:
    output = align_both_side(src_lines, tgt_lines, previous_n, seg_symbol)
  else:
    output = align_src_side(src_lines, tgt_lines, previous_n, seg_symbol)

  _, dataname = os.path.split(data_prefix)
  os.system(f"rm -rf {out_dir}")
  os.system(f"mkdir -p {out_dir}")

  src_path = f"{out_dir}/{dataname}.{src}"
  tgt_path = f"{out_dir}/{dataname}.{tgt}"
  with open(src_path, 'w') as fh:
    for src_line, _ in output:
      fh.write(f"{src_line}\n")
  with open(tgt_path, 'w') as fh:
    for _, tgt_line in output:
      fh.write(f"{tgt_line}\n")

def align_src_side(src_lines, tgt_lines, previous_n, seg_symbol):
  output = []
  i = 0
  for i in range(len(src_lines)):
    src_line = src_lines[i]
    tgt_line = tgt_lines[i]
    new_src_line = src_line
    for k in range(1, previous_n + 1):
      if i - k < 0:
        continue
      new_src_line = f"{src_lines[i - k]} {seg_symbol} {new_src_line}"
    output.append((new_src_line, tgt_line))
  return output

def align_both_side(src_lines, tgt_lines, previous_n, seg_symbol):
  output = []
  i = 0
  while i < len(src_lines):
    # Not enough to begin
    if (i + 1) <= previous_n:
      i += 1
      continue
    src_line = src_lines[i]
    tgt_line = tgt_lines[i]
    new_src_line = src_line
    new_tgt_line = tgt_line
    for k in range(1, previous_n + 1):
      new_src_line = f"{src_lines[i - k]} {seg_symbol} {new_src_line}"
      new_tgt_line = f"{tgt_lines[i - k]} {new_tgt_line}"
    output.append((new_src_line, new_tgt_line))
    # Update i
    i += previous_n + 1

  # Deal with left lines
  new_start = i - previous_n
  new_src_line = ""
  new_tgt_line = ""
  for j in range(new_start, len(src_lines)):
    src_line = src_lines[j]
    tgt_line = tgt_lines[j]
    if j == new_start:
      new_src_line = src_line
      new_tgt_line = tgt_line
    else:
      new_src_line = f"{new_src_line} {seg_symbol} {src_line}"
      new_tgt_line = f"{new_tgt_line} {tgt_line}"
  output.append((new_src_line, new_tgt_line))
  return output


if __name__ == "__main__":
  parser = argparse.ArgumentParser(
    description='Make context NMT dataset',
    formatter_class=argparse.ArgumentDefaultsHelpFormatter)
  parser.add_argument('-d', '--data_prefix', required=True, type=str)
  parser.add_argument('-s', '--src', required=True, type=str)
  parser.add_argument('-t', '--tgt', required=True, type=str)
  parser.add_argument('-p', '--previous_n', required=True, type=int)
  parser.add_argument('-o', '--out_dir', required=True, type=str)
  parser.add_argument('-b', '--both_context', required=True, type=int)

  args = parser.parse_args()
  args.both_context = bool(args.both_context)

  make_context_nmt_dataset(data_prefix=args.data_prefix,
                           src=args.src,
                           tgt=args.tgt,
                           out_dir=args.out_dir,
                           both_context=args.both_context,
                           previous_n=args.previous_n,
                           seg_symbol="$")
