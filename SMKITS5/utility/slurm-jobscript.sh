#!/bin/bash

#SBATCH --partition=vl-parcio             #cluster partition
#SBATCH --time=2048                       #minutes to timeout (assuming max. 8 mins per picture: 2048mins = ~1.5d)
#SBATCH --output=slurm-stego.out          #specity out file
#SBATCH --nodes=4                         #request nodes
#SBATCH --ntasks=4                        #executions
#SBATCH --cpus-per-task=1                 #1 execution per node
#SBATCH --wait                            #wait for all jobs to finish

srun ./stego-attrib --size 1 --offset 0 --delete
srun ./stego-attrib --size 1 --offset 1 --delete
srun ./stego-attrib --size 1 --offset 2 --delete
srun ./stego-attrib --size 1 --offset 3 --delete

#EOF