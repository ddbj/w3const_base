#!/usr/bin/env python3
# parses gb flat file and output it as fasta
# convFF2Fasta.py <gb flatfile>
# 
import sys
import re
from Bio import SeqIO

out = sys.stdout

def seqfromff(ff):
    for record in SeqIO.parse(ff, 'genbank'):
        acc = re.sub(r'\.[#0-9]', '', record.id)
        record.id = acc
        # desc = record.description
        # seq = record.seq
        SeqIO.write(record, sys.stdout, "fasta")

if __name__ == '__main__':
    arg1 = sys.argv[1]
    seqfromff(arg1)
