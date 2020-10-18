#!/bin/sh
set -x

# Prepare the same datasets as the one used in HAN_NMT. Note the dataset has
# been preprocessed.

data_dir="$HOME/HAN_NMT/preprocess_TED_zh-en/zh-en-ted-preprocessed/"

src=zh
tgt=en

BPEROOT=subword-nmt/subword_nmt
BPE_TOKENS=32000

tmp=tmp
prep=iwslt15.ted.zh2en
mkdir -p $tmp $prep

TRAIN=$tmp/train.zh-en
BPE_CODE=$prep/code
rm -f $TRAIN
for l in $src $tgt; do
    cat $data_dir/corpus.tc.$l >> $TRAIN
done

echo "learn_bpe.py on ${TRAIN}..."
python $BPEROOT/learn_bpe.py -s $BPE_TOKENS < $TRAIN > $BPE_CODE

for L in $src $tgt; do
    for f in $data_dir/corpus.tc.$L $data_dir/IWSLT15.TED.dev2010.tc.$L $data_dir/IWSLT15.TED.tst2010_2013.tc.$L; do
        echo "apply_bpe.py to ${f}..."
        python $BPEROOT/apply_bpe.py -c $BPE_CODE < $f > "$prep/$(basename $f)"
    done
done
