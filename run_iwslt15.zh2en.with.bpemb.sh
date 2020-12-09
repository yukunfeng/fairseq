set -x

# Preprocess/binarize the data
TEXT=examples/translation/spm.iwslt15.ted.zh2en


save_dir="$(basename $TEXT).checkpoints"
DATA="data-bin/$(basename $TEXT)"

# fairseq-preprocess --source-lang zh --target-lang en \
    # --trainpref $TEXT/train --validpref $TEXT/valid --testpref $TEXT/test \
    # --destdir $DATA \
    # --workers 20

# fairseq-train $DATA \
    # --arch transformer_iwslt_emb_300 --share-decoder-input-output-embed \
    # --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0.0 \
    # --lr 5e-4 --lr-scheduler inverse_sqrt --warmup-updates 4000 \
    # --dropout 0.3 --weight-decay 0.0001 \
    # --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
    # --max-tokens 4096 \
    # --log-interval 10000000000 \
    # --eval-bleu \
    # --eval-bleu-args '{"beam": 5, "max_len_a": 1.2, "max_len_b": 10}' \
    # --eval-bleu-detok moses \
    # --eval-bleu-remove-bpe \
    # --eval-bleu-print-samples \
    # --best-checkpoint-metric bleu --maximize-best-checkpoint-metric \
    # --keep-last-epochs 1 \
    # --save-dir "$save_dir" \
    # --max-epoch 25

fairseq-generate $DATA \
    --path $save_dir/checkpoint_last.pt \
    --batch-size 128 --beam 5 --remove-bpe=sentencepiece
