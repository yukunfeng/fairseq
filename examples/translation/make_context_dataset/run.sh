set -x

# Make NMT dataset for cjcoref.
array=(train valid test)
for filename in "${array[@]}"
do
    python ./make_context_nmt_dataset.py \
        --data_prefix "$HOME/fairseq/examples/translation/iwslt15.ted.zh2en.spm.orig/$filename" \
        --src "zh" \
        --tgt "en" \
        --previous_n 5 \
        --both_context 1 \
        --out_dir "$HOME/cjcoref/input_data/iwslt17" \
        --seg_symbol '[SEP]' \
        --src_jieba
done

# Make NMT dataset for fairseq.
# array=(train valid test)
# for filename in "${array[@]}"
# do
    # python ./make_context_nmt_dataset.py \
        # --data_prefix "~/fairseq/examples/translation/iwslt17.ted.zh2en/$filename" \
        # --src "zh" \
        # --tgt "en" \
        # --previous_n 2 \
        # --both_context 1 \
        # --out_dir "~/fairseq/examples/translation/contextlized_both_prevn2_iwslt17.ted.zh2en"
# done


# Sample test
# python ./make_context_nmt_dataset.py \
    # --data_prefix "./sample_data_for_context_dataset/sample" \
    # --src "en" \
    # --tgt "zh" \
    # --previous_n 1 \
    # --both_context 1 \
    # --out_dir "./sample_out"
