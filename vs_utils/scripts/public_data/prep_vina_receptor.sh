#!/bin/bash
######################################
# Prepare receptors for AutoDock Vina.
######################################
input_filename=''
add_atoms='all'
keep_heterogens='none'
pH='7.4'
while getopts 'hi:a:k:p:' flag
do
  case "${flag}" in
    h) echo "usage: vina_prep.sh -i input_filename"
       echo ""
       echo "options:"
       echo "-a     atoms to add [default: all]"
       echo "-k     heterogens to keep [default: none]"
       echo "-p     pH of added hydrogens [default: 7.4]"
       echo ""
       echo "see the pdbfixer manual for details"
       exit
       ;;
    i) input_filename=${OPTARG} ;;
    a) add_atoms=${OPTARG} ;;
    k) keep_heterogens=${OPTARG} ;;
    p) pH=${OPTARG} ;;
    *) echo "Unexpected option ${flag}"; exit 1 ;;
  esac
done

if [[ -z ${input_filename} ]]
then
  echo "Must provide input filename"
  exit 1
fi

# process PDB with pdbfixer
fixed_filename=$(mktemp)
echo pdbfixer ${input_filename} \
    --add-atoms=${add_atoms} \
    --keep-heterogens=${keep_heterogens} \
    --ph=${pH} \
    --output=${fixed_filename}
pdbfixer ${input_filename} \
    --add-atoms=${add_atoms} \
    --keep-heterogens=${keep_heterogens} \
    --ph=${pH} \
    --output=${fixed_filename}

# create PDBQT with obabel (-xr treats the molecule as rigid)
output_basename=$(basename ${input_filename} | sed 's/\..*$//g')
echo obabel -i pdb ${fixed_filename} -O ${output_basename}.pdbqt -xr
obabel -i pdb ${fixed_filename} -O ${output_basename}.pdbqt -xr

# cleanup
rm ${fixed_filename}
