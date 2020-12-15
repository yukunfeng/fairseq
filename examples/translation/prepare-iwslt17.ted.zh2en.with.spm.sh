#!/usr/bin/env bash
#
set -x

SCRIPTS=/home/lr/yukun/OpenNMT-py/data/mosesdecoder/scripts
NORM_PUNC="$SCRIPTS/tokenizer/normalize-punctuation.perl"

URL="https://wit3.fbk.eu/archive/2017-01-trnted//texts/en/zh/en-zh.tgz"
GZ=en-zh.tgz

if [ ! -d "$SCRIPTS" ]; then
    echo "Please set SCRIPTS variable correctly to point to Moses scripts."
    exit
fi

src=zh
tgt=en
lang=en-zh
# prep=spm.iwslt17.ted.zh2en
prep=cbowenspm.iwslt17.ted.zh2en
tmp=$prep/tmp
orig=iwslt17.ted.zh2en.orig

mkdir -p $orig $tmp $prep

# echo "Downloading data from ${URL}..."
# cd $orig
# wget "$URL"

# if [ -f $GZ ]; then
    # echo "Data successfully downloaded."
# else
    # echo "Data not successfully downloaded."
    # exit
# fi

# tar zxvf $GZ
# cd ..

# Removing tags in train data...
for l in $src $tgt; do
    f=train.tags.$lang.$l
    f_tag_removed=train.$lang.$l

    cat $orig/$lang/$f | \
    grep -v '<reviewer' | \
    grep -v '<translator' | \
    grep -v '<doc' | \
    grep -v '</doc>' | \
    grep -v '<url>' | \
    grep -v '<speaker>' | \
    grep -v '<talkid>' | \
    grep -v '<keywords>' | \
    sed -e 's/<title>//g' | \
    sed -e 's/<\/title>//g' | \
    sed -e 's/<description>//g' | \
    sed -e 's/<\/description>//g' | \
    sed -e 's/TED Talk Subtitles and Transcript://g' > $tmp/$f_tag_removed
    echo ""
done

# Preprocessing English part
f_tgt_tag_removed=train.$lang.$tgt
f_tgt_tok=train.tok.$lang.$tgt
cat $tmp/$f_tgt_tag_removed | \
    perl $NORM_PUNC -l $tgt > $tmp/$f_tgt_tok

# Pre-processing valid/test data for English part
for o in `ls $orig/$lang/IWSLT17.TED*.$tgt.xml`; do
    fname=${o##*/}
    f=$tmp/${fname%.*}
    echo $o $f
    grep '<seg id' $o | \
    sed -e 's/<seg id="[0-9]*">\s*//g' | \
    sed -e 's/\s*<\/seg>\s*//g' | \
    perl $NORM_PUNC -l $tgt  > $f
    echo ""
done

# Pre-processing valid/test data for Chinese part
for o in `ls $orig/$lang/IWSLT17.TED*.$src.xml`; do
    fname=${o##*/}
    f=$tmp/${fname%.*}
    echo $o $f
    grep '<seg id' $o | \
    sed -e 's/<seg id="[0-9]*">\s*//g' | \
    sed -e 's/\s*<\/seg>\s*//g' > $f
    echo ""
done

# Creating test
for l in $src $tgt; do
    cat $tmp/IWSLT17.TED.tst2010.$lang.$l \
        $tmp/IWSLT17.TED.tst2011.$lang.$l \
        $tmp/IWSLT17.TED.tst2012.$lang.$l \
        $tmp/IWSLT17.TED.tst2013.$lang.$l \
        $tmp/IWSLT17.TED.tst2014.$lang.$l \
        $tmp/IWSLT17.TED.tst2015.$lang.$l \
        > $tmp/test.$l
done
# for l in $src $tgt; do
    # cat $tmp/IWSLT17.TED.tst2015.$lang.$l \
        # > $tmp/test.$l
# done

# Creating valid
for l in $src $tgt; do
    mv $tmp/IWSLT17.TED.dev2010.$lang.$l $tmp/valid.$l
done

# Creating train
mv $tmp/$f_tgt_tok $tmp/train.$tgt
mv $tmp/train.$lang.$src $tmp/train.$src

# wiki glove bpe
# for L in $src $tgt; do
    # for f in train.$L valid.$L test.$L; do
        # echo "apply spm to ${f}..."
        # python ./pretrained_bpemb/apply_spm.py -m ./pretrained_bpemb/$L.wiki.bpe.vs25000.model  -i $tmp/$f > $prep/$f
    # done
# done

# 
L=$src
for f in train.$L valid.$L test.$L; do
    echo "apply spm to ${f}..."
    python ./pretrained_bpemb/spm_apply.py -m ./pretrained_bpemb/glovebpemb/$L.wiki.bpe.vs25000.model  -i $tmp/$f > $prep/$f
done
L=$tgt
for f in train.$L valid.$L test.$L; do
    echo "apply spm to ${f}..."
    python ./pretrained_bpemb/spm_apply.py -m ./pretrained_bpemb/cbowbpemb/WestburyLab.wikicorp.201004.model -i $tmp/$f > $prep/$f
done
