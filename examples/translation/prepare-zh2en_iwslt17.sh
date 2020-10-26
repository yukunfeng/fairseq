#!/usr/bin/env bash
#
set -x

SCRIPTS=/home/lr/yukun/OpenNMT-py/data/mosesdecoder/scripts
NORM_PUNC="$SCRIPTS/tokenizer/normalize-punctuation.perl"
TOKENIZER=$SCRIPTS/tokenizer/tokenizer.perl
TRUECASE_TRAINER="$SCRIPTS/recaser/train-truecaser.perl"
TRUECASE="$SCRIPTS/recaser/truecase.perl"
LC=$SCRIPTS/tokenizer/lowercase.perl
CLEAN=$SCRIPTS/training/clean-corpus-n.perl
BPEROOT=subword-nmt/subword_nmt
BPE_TOKENS=32000

URL="https://wit3.fbk.eu/archive/2017-01-trnted//texts/en/zh/en-zh.tgz"
GZ=en-zh.tgz

if [ ! -d "$SCRIPTS" ]; then
    echo "Please set SCRIPTS variable correctly to point to Moses scripts."
    exit
fi

src=zh
tgt=en
lang=en-zh
prep=iwslt17.tokenized.zh-en
tmp=$prep/tmp
orig=orig

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
    perl $NORM_PUNC -l $tgt | \
    perl $TOKENIZER -threads 8 -l $tgt > $tmp/$f_tgt_tok

#### Train truecaser and truecase
tcase_model="$tmp/truecase-model.$tgt"
$TRUECASE_TRAINER -model $tcase_model -corpus $tmp/$f_tgt_tok
f_tgt_tcase_tok="train.tcase.tok.$lang.$tgt"
$TRUECASE < $tmp/$f_tgt_tok > $tmp/$f_tgt_tcase_tok -model $tcase_model

# Segment the Chinese part
f_src_tag_removed=train.$lang.$src
f_src_tok=train.tok.$lang.$src
python -m jieba -d ' ' < $tmp/$f_src_tag_removed > $tmp/$f_src_tok

perl $CLEAN -ratio 1.5 $tmp/train.tags.$lang.tok $src $tgt $tmp/train.tags.$lang.clean 1 175

# Pre-processing valid/test data for English part
for o in `ls $orig/$lang/IWSLT17.TED*.$tgt.xml`; do
    fname=${o##*/}
    f=$tmp/${fname%.*}
    echo $o $f
    grep '<seg id' $o | \
    sed -e 's/<seg id="[0-9]*">\s*//g' | \
    sed -e 's/\s*<\/seg>\s*//g' | \
    perl $NORM_PUNC -l $tgt | \
    perl $TOKENIZER -threads 8 -l $tgt | \
    perl $TRUECASE -model $tcase_model > $f
    echo ""
done

# Pre-processing valid/test data for Chinese part
for o in `ls $orig/$lang/IWSLT17.TED*.$src.xml`; do
    fname=${o##*/}
    f=$tmp/${fname%.*}
    echo $o $f
    grep '<seg id' $o | \
    sed -e 's/<seg id="[0-9]*">\s*//g' | \
    sed -e 's/\s*<\/seg>\s*//g' | \
    python -m jieba -d ' '  > $f
    echo ""
done

# Creating test
# for l in $src $tgt; do
    # cat $tmp/IWSLT17.TED.tst2010.$lang.$l \
        # $tmp/IWSLT17.TED.tst2011.$lang.$l \
        # $tmp/IWSLT17.TED.tst2012.$lang.$l \
        # $tmp/IWSLT17.TED.tst2013.$lang.$l \
        # $tmp/IWSLT17.TED.tst2014.$lang.$l \
        # $tmp/IWSLT17.TED.tst2015.$lang.$l \
        # > $tmp/test.$l
# done
for l in $src $tgt; do
    cat $tmp/IWSLT17.TED.tst2015.$lang.$l \
        > $tmp/test.$l
done

# Creating valid
for l in $src $tgt; do
    mv $tmp/IWSLT17.TED.dev2010.$lang.$l $tmp/valid.$l
done

# Creating train
mv $tmp/$f_tgt_tcase_tok $tmp/train.$tgt
mv $tmp/$f_src_tok $tmp/train.$src


# Create BPE sequences
TRAIN=$tmp/train.$lang
BPE_CODE=$prep/code
rm -f $TRAIN
for l in $src $tgt; do
    cat $tmp/train.$l >> $TRAIN
done

echo "learn_bpe.py on ${TRAIN}..."
python $BPEROOT/learn_bpe.py -s $BPE_TOKENS < $TRAIN > $BPE_CODE

for L in $src $tgt; do
    for f in train.$L valid.$L test.$L; do
        echo "apply_bpe.py to ${f}..."
        python $BPEROOT/apply_bpe.py -c $BPE_CODE < $tmp/$f > $prep/$f
    done
done
