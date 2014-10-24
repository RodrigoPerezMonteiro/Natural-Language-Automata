#!/bin/bash

SYM=data.syms

rm -rf workdir;
rm -rf results;

echo -e "----------------------\n"
echo "Compiling automatos ...";

mkdir -p workdir;
mkdir -p results;
mkdir -p workdir/num_A_R
mkdir -p workdir/num_R_A
mkdir -p workdir/dat_A_R
mkdir -p workdir/dat_R_A
mkdir -p workdir/compiled_test

for AUTOMATA in $(ls source); do

NAME=`echo $AUTOMATA | cut -d'.' --complement -f2-`
echo "Generating fsm: $NAME";
fsmcompile -t -i $SYM -o $SYM -F workdir/$NAME-R-A.fsm < source/$AUTOMATA
fsminvert -F workdir/$NAME-A-R.fsm workdir/$NAME-R-A.fsm

done

cd workdir;

echo "Generating pdf: conversor-num-R-A..."
fsmconcat milhares-R-A.fsm centenas-R-A.fsm dezenas-R-A.fsm unidades-R-A.fsm > conversor-num-R-A.fsm
fsmdraw -i ../$SYM -o ../$SYM < conversor-num-R-A.fsm | dot -Tpdf > conversor-num-R-A.pdf

echo "Generating pdf: conversor-num-A-R..."
fsmconcat milhares-A-R.fsm centenas-A-R.fsm dezenas-A-R.fsm unidades-A-R.fsm > conversor-num-A-R.fsm
fsmdraw -i ../$SYM -o ../$SYM < conversor-num-A-R.fsm | dot -Tpdf > conversor-num-A-R.pdf

echo "Generating pdf: conversor-dat-R-A..."
fsmconcat milhares-A-R.fsm centenas-A-R.fsm dezenas-A-R.fsm unidades-A-R.fsm > anos-A-R.fsm
fsmconcat dezenas-A-R.fsm unidades-A-R.fsm > meses-A-R.fsm
fsmconcat dezenas-A-R.fsm unidades-A-R.fsm > dias-A-R.fsm
fsmconcat dias-A-R.fsm barra-A-R.fsm meses-A-R.fsm barra-A-R.fsm anos-A-R.fsm > conversor-dat-A-R.fsm
fsmdraw -i ../$SYM -o ../$SYM < conversor-dat-A-R.fsm | dot -Tpdf > conversor-dat-A-R.pdf

echo "Generating pdf: conversor-dat-A-R..."
fsmconcat milhares-R-A.fsm centenas-R-A.fsm dezenas-R-A.fsm unidades-R-A.fsm > anos-R-A.fsm
fsmconcat dezenas-R-A.fsm unidades-R-A.fsm > meses-R-A.fsm
fsmconcat dezenas-R-A.fsm unidades-R-A.fsm > dias-R-A.fsm
fsmconcat dias-R-A.fsm barra-R-A.fsm meses-R-A.fsm barra-R-A.fsm anos-R-A.fsm > conversor-dat-R-A.fsm
fsmdraw -i ../$SYM -o ../$SYM < conversor-dat-R-A.fsm | dot -Tpdf > conversor-dat-R-A.pdf


for TESTE in $(ls ../test); do

NAME=`echo $TESTE | cut -d'.' --complement -f2-`
echo "Generating test: $TESTE"
fsmcompile -t -i ../$SYM -o ../$SYM -F compiled_test/$NAME.fsm < ../test/$TESTE
fsmdraw -i ../$SYM -o ../$SYM < compiled_test/$NAME.fsm | dot -Tpdf > compiled_test/$NAME.pdf

done

mv *dat-R-A* dat_R_A
mv *R-A* num_R_A
mv *dat-A-R* dat_A_R
mv *A-R* num_A_R

echo "----------------------"
echo "Running tests";

fsmcompose compiled_test/teste-1-Arabe.fsm num_A_R/conversor-num-A-R.fsm > ../results/result-teste-1-Arabe.fsm
fsmcompose compiled_test/teste-1-Romano.fsm num_R_A/conversor-num-R-A.fsm > ../results/result-teste-1-Romano.fsm
fsmcompose compiled_test/teste-3998-Arabe.fsm num_A_R/conversor-num-A-R.fsm > ../results/result-teste-3998-Arabe.fsm
fsmcompose compiled_test/teste-3998-Romano.fsm num_R_A/conversor-num-R-A.fsm > ../results/result-teste-3998-Romano.fsm
fsmcompose compiled_test/teste-Rodrigo-Arabe.fsm dat_A_R/conversor-dat-A-R.fsm > ../results/result-teste-Rodrigo-Arabe.fsm
fsmcompose compiled_test/teste-Rodrigo-Romano.fsm dat_R_A/conversor-dat-R-A.fsm > ../results/result-teste-Rodrigo-Romano.fsm
fsmcompose compiled_test/teste-Guilherme-Arabe.fsm dat_A_R/conversor-dat-A-R.fsm > ../results/result-teste-Guilherme-Arabe.fsm
fsmcompose compiled_test/teste-Guilherme-Romano.fsm dat_R_A/conversor-dat-R-A.fsm > ../results/result-teste-Guilherme-Romano.fsm

cd ..

for TESTE in $(ls results); do

NAME=`echo $TESTE | cut -d'.' --complement -f2-`
echo "Generating results (pdf): $TESTE"

fsmdraw -i $SYM -o $SYM < results/$NAME.fsm | dot -Tpdf > results/$NAME.pdf

done

echo "----------------------"
echo "DONE"
