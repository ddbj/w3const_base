#!/bin/bash

SIF="/home/w3const/work-kosuge/constbase.sif"
LOG="/home/w3const/work-kosuge/log/get-blastdb.log"

[ -e ${LOG} ] || touch ${LOG}
# singularity exec --bind /home/ddbjshare ${SIF} getblastdb_ncbi.sh > ${LOG}
singularity exec --bind /lustre9/open/shared_data/blastdb/:/home/w3constshare,/home/ddbjshare ${SIF} getblastdb_ncbi.sh > ${LOG}
date +%m%d-%H%M >> ${LOG}
