#!/bin/sh
set -x

# Prepare the same datasets as the one used in HAN_NMT. Note the dataset has
# been preprocessed.

data_dir="./iwslt15.ted.zh2en.spm.orig"

src=zh
tgt=en

prep=spm.iwslt15.ted.zh2en
mkdir -p $prep

for L in $src $tgt; do
    for f in $data_dir/train.$L $data_dir/test.$L $data_dir/valid.$L; do
        echo "apply spm to ${f}..."
        python ./pretrained_bpemb/apply_spm.py -m ./pretrained_bpemb/$L.wiki.bpe.vs25000.model  -i $f > "$prep/$(basename $f)"
    done
done
