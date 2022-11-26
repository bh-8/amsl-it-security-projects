#!/bin/bash

#SBATCH --partition=TODO                  #cluster partition
#SBATCH --time=2048                       #minutes to timeout (assuming max. 8 mins per picture: 2048mins = ~1.5d)
#SBATCH --output=slurm-stego.out          #specity out file
#SBATCH --nodes=4                         #request 4 nodes
#SBATCH --ntasks=4                        #4 executions
#SBATCH --cpus-per-task=1                 #1 execution per node
#SBATCH --wait                            #wait for all jobs to finish

srun ./stego-attrib -n 256 -m OFFSET -d   #offset depending on node

#EOF