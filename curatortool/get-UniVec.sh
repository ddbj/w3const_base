#!/bin/bash

SIF="/home/w3const/work-kosuge/constbase.sif"
LOG="/home/w3const/work-kosuge/log/get-UniVec.log"

[ -e ${LOG} ] || touch ${LOG}
singularity exec ${SIF} makeUniVec_blastdb.sh > ${LOG}
date +%m%d-%H%M >> ${LOG}
