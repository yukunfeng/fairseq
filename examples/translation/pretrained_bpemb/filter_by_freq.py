import argparse
from collections import Counter

if __name__ == "__main__":
  parser = argparse.ArgumentParser(
    description='',
    formatter_class=argparse.ArgumentDefaultsHelpFormatter
  )
  parser.add_argument('-i', '--input', required=True, type=str)
  parser.add_argument('-o', '--output', required=True, type=str)
  parser.add_argument('-v', '--vocab_size', required=True, type=int)
  args = parser.parse_args()

  counter = Counter()
  lines = [
    counter.update(line.strip().split())
    for line in open(args.input, 'r').readlines()
  ]
  pairs = counter.most_common()
  original_vocab_size = len(pairs)
  print(f"original_vocab_size: {original_vocab_size}")
  exit(0)
  unwanted_vocab = {}
  for word, freq in pairs[args.vocab_size:]:
    unwanted_vocab[word] = 1

  # Start to filtering
  with open(args.input, 'r') as rf, open(args.output, 'w') as wf:
    for line in rf:
      line = line.strip()
      tokens = line.split()
      filtered_tokens = []
      for token in tokens:
        if token not in unwanted_vocab:
          filtered_tokens.append(token)
        else:
          filtered_tokens.append("<unk>")

      new_line = " ".join(filtered_tokens)
      wf.write(f"{new_line}\n")
