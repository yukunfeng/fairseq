set -x

array=(train valid test)
for filename in "${array[@]}"
do
    python ./make_context_nmt_dataset.py \
        --data_prefix "~/fairseq/examples/translation/iwslt17.ted.zh2en/$filename" \
        --src "zh" \
        --tgt "en" \
        --previous_n 2 \
        --both_context 1 \
        --out_dir "~/fairseq/examples/translation/contextlized_both_prevn2_iwslt17.ted.zh2en"
done


# Sample test
# python ./make_context_nmt_dataset.py \
    # --data_prefix "./sample_data_for_context_dataset/sample" \
    # --src "en" \
    # --tgt "zh" \
    # --previous_n 1 \
    # --both_context 1 \
    # --out_dir "./sample_out"
