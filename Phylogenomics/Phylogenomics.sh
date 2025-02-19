#!/bin/bash

#SBATCH --partition=
#SBATCH --mem=
#SBATCH --cpus-per-task=
#SBATCH --time=UNLIMITED

### Phylogenomics using BUSCO ###


## BUSCO

source activate BUSCO

busco -i Chromosome_Genomes -l mammalia_odb10 -m genome --cpu 64 -f -o BUSCO_Results

python busco2fasta.py -b BUSCO_Results -p 0.9


## MAFFT

mkdir -p MAFFT

source activate MAFFT

cd b2f_output

for FILE in *.faa; do

mafft "${FILE}" > ../MAFFT/MAFFT_"${FILE}"

done

cd ..


## Trim
# Note: used sed to replace "." with ":" in all headers as anything after a ":" is removed in trimAl. This keeps headings the same for each species which is needed for accurate concatenation.

mkdir -p trimAl

source activate trimAl

cd MAFFT

for FILE in *; do

sed -i "s/\./:/g" "${FILE}"

trimal -in "${FILE}" -out ../trimAl/trimAl_"${FILE}" -gt 0.8 -st 0.001 -resoverlap 0.75 -seqoverlap 80

done

cd ..


## Concatenate alignments

catfasta2phyml-master/catfasta2phyml.pl --concatenate -f trimAl/*.faa > Concat_FAA.fasta 2> partitions.txt


## IQ-TREE

source activate IQ-TREE

iqtree -s Concat_FAA.fasta -m TEST -bb 1000
