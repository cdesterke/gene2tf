#!/usr/bin/sh
## Annotation of human genes:   1st column of text file needs to contain human gene symbol list
## Author: Christophe Desterke
## Version 1.0.1
## Date: November 30th, 2018
## Usage: sh gene2tf.sh humangene.txt

variable=${1}
if [ -z "${variable}" ]
then 
	echo "TEXTTAB file not passed as parameter"
	exit 1
fi

log_file="log_file.log" 

nom_fichier=$(echo $1 | sed -re 's/(.*).txt/\1/')

echo "analyse du ficher = $nom_fichier" >> $log_file

date >> $log_file





echo "TRANSCRPTION FACTORS human gene annotation" >> $log_file

echo "-------------------------------------">> $log_file

cat $1 | awk -v OFS="\t" '{print $1}' > input

awk -v OFS="\t" 'NR==FNR {h[$1] = $1; next} {print $1"\t"$2"\t"$3"\t"$4,h[$1]}' input DATABASES_GENES/TF4C.txt  > TF

sort -k2 TF > TF_sorted

awk '!arr[$5]++' TF_sorted > TF_uniq.txt
tail -n +2 TF_uniq.txt | sponge TF_uniq.txt
awk '{print $1,$2,$3,$4}' TF_uniq.txt > TF_annotation.txt

echo "Number of Transcription Factors in the list: " >> $log_file
wc -l TF_annotation.txt >> $log_file

echo  "HGNC_Symbol Class Tissue_Expression Ensembl_ID" > headers_TF.tsv
cat headers_TF.tsv TF_annotation.txt >> result_TF.txt
echo "-------------------------------------">> $log_file
sed 's/ /\t/g' result_TF.txt > TF_results.csv
cat TF_results.csv >> $log_file





cat log_file.log

mkdir RESULTS
mv log_file.log TF_results.csv RESULTS
cd RESULTS


mv TF_results.csv $(echo TF_results.csv | sed "s/\./".$nom_fichier"\./")

mv log_file.log $(echo log_file.log | sed "s/\./".$nom_fichier"\./")

cd .. 
mv RESULTS RESULTS_$nom_fichier

rm input 

rm TF_sorted
rm TF
rm TF_annotation.txt
rm TF_uniq.txt
rm result_TF.txt
rm headers_TF.tsv





exit 0
