set -x

python ./make_context_nmt_dataset.py \
    --data_prefix "./sample_data_for_context_dataset/sample" \
    --src "en" \
    --tgt "zh" \
    --previous_n 4 \
    --out_dir "./sample_out"
