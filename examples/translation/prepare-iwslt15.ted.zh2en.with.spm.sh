#!/bin/sh
set -x

# Prepare the same datasets as the one used in HAN_NMT. Note the dataset has
# been preprocessed.

data_dir="./iwslt15.ted.zh2en.spm.orig"

src=zh
tgt=en

# prep=spm.iwslt15.ted.zh2en
prep=cbowenspm.iwslt15.ted.zh2en
mkdir -p $prep

# for L in $src $tgt; do
    # for f in $data_dir/train.$L $data_dir/test.$L $data_dir/valid.$L; do
        # echo "apply spm to ${f}..."
        # python ./pretrained_bpemb/spm_apply.py -m ./pretrained_bpemb/$L.wiki.bpe.vs25000.model  -i $f > "$prep/$(basename $f)"
    # done
# done
L=$src
for f in $data_dir/train.$L $data_dir/test.$L $data_dir/valid.$L; do
    echo "apply spm to ${f}..."
    python ./pretrained_bpemb/spm_apply.py -m ./pretrained_bpemb/glovebpemb/$L.wiki.bpe.vs25000.model  -i $f > "$prep/$(basename $f)"
done
L=$tgt
for f in $data_dir/train.$L $data_dir/test.$L $data_dir/valid.$L; do
    echo "apply spm to ${f}..."
    python ./pretrained_bpemb/spm_apply.py -m ./pretrained_bpemb/cbowbpemb/WestburyLab.wikicorp.201004.model -i $f > "$prep/$(basename $f)"
done
