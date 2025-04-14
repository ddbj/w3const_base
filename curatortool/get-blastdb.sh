#!/bin/bash

SIF="/home/w3const/work-kosuge/constbase.sif"
LOG="/home/w3const/work-kosuge/log/get-blastdb.log"

[ -e ${LOG} ] || touch ${LOG}
singularity exec --bind /home/ddbjshare ${SIF} getblastdb_ncbi.sh > ${LOG}