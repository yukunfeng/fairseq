set -x

model="./cbowbpemb/WestburyLab.wikicorp.201004.model"
input_dir="../cbowenspm.iwslt17.ted.zh2en"
output_dir="../worden.iwslt17.ted.zh2en/"
mkdir -p $output_dir

array=(train.en test.en valid.en)
for filename in "${array[@]}"
do
    input="${input_dir}/${filename}"
    output="${output_dir}/${filename}"

    spm_decode --model=$model \
        --input_format=piece < $input > $output
done
