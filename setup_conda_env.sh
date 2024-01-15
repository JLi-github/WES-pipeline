#!/bin/bash

# conda deactivate

my_conda_env=$1;

check_active_environment=$(echo $CONDA_DEFAULT_ENV)

echo Currently active conda environment is $check_active_environment

if [[ "$check_active_environment" == "" ]]
then
	
	echo "No conda environment is loaded. Loading $my_conda_env conda environment"
	eval "$(conda shell.bash hook)"
	conda activate $my_conda_env
	
elif [[ "$check_active_environment" == "$my_conda_env" ]]
then
	
	echo "$my_conda_env conda environment is active"
	
elif [[ "$check_active_environment" != "" ]] && [[ "$check_active_environment" != "$my_conda_env" ]]
then
	
	echo Some other environment is active. Deactivating ...
	conda deactivate
	echo Activating $my_conda_env conda environment
	eval "$(conda shell.bash hook)"
	conda activate $my_conda_env
	
fi
