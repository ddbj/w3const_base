### NCBI Blast db downloader, getblastdb_ncbi.sh and makeUniVec_blastdb.sh, are running @a012

~~~@a12:/home/w3const/work-kosuge/task/get-blastdb.sh
#!/bin/bash

SIF="/home/w3const/work-kosuge/constbase.sif"
LOG="/home/w3const/work-kosuge/log/get-blastdb.log"

[ -e ${LOG} ] || touch ${LOG}
singularity exec --bind /home/ddbjshare ${SIF} getblastdb_ncbi.sh > ${LOG}
date +%m%d-%H%M >> ${LOG}
~~~

~~~@a012:/home/w3const/work-kosuge/task/get-UniVec.sh 
#!/bin/bash

SIF="/home/w3const/work-kosuge/constbase.sif"
LOG="/home/w3const/work-kosuge/log/get-UniVec.log"

[ -e ${LOG} ] || touch ${LOG}
singularity exec ${SIF} makeUniVec_blastdb.sh > ${LOG}
date +%m%d-%H%M >> ${LOG}
~~~
