set -x

# Preprocess/binarize the data
dataname="iwslt17.zh2en"
base_str="rawimpldoc"
# base_str="nodocseg_bpecode"
# base_str="debug"

TEXT=$HOME/nmtdataset/$dataname/after_bpe

save_dir="${base_str}${dataname}.checkpoints"
DATA="data-bin/${base_str}${dataname}"
tensor_dir="${base_str}${dataname}.tensorlog"

# Split src and tgt
src=$(python -c "print('$dataname'.split('.')[1].split('2')[0])")
tgt=$(python -c "print('$dataname'.split('.')[1].split('2')[1])")

fairseq-preprocess --source-lang $src --target-lang $tgt \
    --trainpref $TEXT/train --validpref $TEXT/valid --testpref $TEXT/test \
    --destdir $DATA \
    --workers 20 \
    --dataset-impl raw \


    # --max-tokens 4096 \
    # --num-workers 1 \
fairseq-train $DATA \
    --arch transformer_iwslt_de_en --share-decoder-input-output-embed \
    --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0.0 \
    --lr 5e-4 --lr-scheduler inverse_sqrt --warmup-updates 4000 \
    --dropout 0.3 --weight-decay 0.0001 \
    --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
    --max-tokens 12288 \
    --log-interval 10000000000 \
    --eval-bleu \
    --eval-bleu-args '{"beam": 5, "max_len_a": 1.2, "max_len_b": 10}' \
    --eval-bleu-detok moses \
    --eval-bleu-remove-bpe \
    --eval-bleu-print-samples \
    --best-checkpoint-metric bleu --maximize-best-checkpoint-metric \
    --keep-last-epochs 1 \
    --save-dir "$save_dir" \
    --max-epoch 30 \
    --seed 234 \
    --dataset-impl raw \
    --left-pad-source "False" \


fairseq-generate $DATA \
    --path $save_dir/checkpoint_last.pt \
    --batch-size 128 --beam 5 --remove-bpe \
    --dataset-impl raw \


