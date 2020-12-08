import argparse
import sentencepiece as spm

if __name__ == "__main__":
  parser = argparse.ArgumentParser(
    description='Apply sentencepiece model to raw text',
    formatter_class=argparse.ArgumentDefaultsHelpFormatter)
  parser.add_argument('-m',
                      '--model',
                      help='model path of sentencepiece',
                      required=True)
  parser.add_argument('-i',
                      '--input_file',
                      help='path of input_file',
                      required=True)
  args = parser.parse_args()

  model = args.model
  sp = spm.SentencePieceProcessor(model_file=model)

  with open(args.input_file, 'r') as fh:
    for line in fh:
      line_out = sp.encode(line, out_type=str)
      line_out = " ".join(line_out)
      print(line_out)
