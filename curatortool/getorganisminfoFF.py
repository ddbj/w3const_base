#!/usr/bin/env python3
# Obtain organism, taxid, division from source feature from target accession in the flatfile
# getorganisminfFF.py -i <flatfile> -a <accession number>

import argparse
import sys
import re
from Bio import SeqIO
from Bio import Entrez
import json

Entrez.email = 'tkosuge@nig.ac.jp'

def parseoption():
    parser = argparse.ArgumentParser(description='Showing organism, taxid, and taxonomy division of target entry in the flatfile')
    parser.add_argument('-i', required=True, metavar='gbff', help="GenBank-type flatfile as input")
    parser.add_argument('-a', required=True, metavar='accession', help="Accession number")
    args = parser.parse_args()
    return args

def valfromsc(ff, acc):
    for record in SeqIO.parse(ff, 'genbank'):
        # desc = record.description
        # seq = record.seq
        accn = re.sub(r'\.[#0-9]', '', record.id)
        if accn == acc:
            # print(record.annotations['taxonomy'])
            # print(record)
            r = record.annotations['data_file_division']
            for feat in record.features:
                if feat.type == 'source':
                    return(feat.qualifiers['organism'][0], feat.qualifiers['db_xref'][0], r)
                    # for k in feat.qualifiers.keys():
                    #     print(k)
                    #     print(feat.qualifiers[k][0])

def get_tax_id(species):
    search = Entrez.esearch(term = species, db = "taxonomy", retmode = "xml")
    record = Entrez.read(search)
    return record['IdList']

def get_tax_data(taxid):
    search = Entrez.efetch(id = taxid, db = "taxonomy", retmode = "xml")
    return Entrez.read(search)[0]['Division']

if __name__ == '__main__':
    options = parseoption()
    res = valfromsc(options.i, options.a)
    # print(res[0], res[1], res[2])
    resultdict = {}
    resultdict['organism'] = res[0]
    resultdict['taxid'] = int(res[1].replace('taxon:', ''))
    if not res[2] or res[2].isspace() or res[2] == 'ENV':
        orgtemp = res[0].replace('uncultured ', '').replace(' environmental sample', '')
        orgsearch = re.sub(r'(^[A-Za-z]+).*', r'\1', orgtemp)
        # print(orgsearch)
        response = get_tax_id(orgsearch)
        # print(len(response))
        taxres = []
        for v in response:
            taxres.append(get_tax_data(v))
        resultdict['tax_division'] = ' OR '.join(taxres)
    else:
        if res[2] == 'PRI':
            resultdict['tax_division'] = 'Primates'
        if res[2] == 'ROD':
            resultdict['tax_division'] = 'Rodents'
        if res[2] == 'MAM':
            resultdict['tax_division'] = 'Mammals'
        if res[2] == 'VRT':
            resultdict['tax_division'] = 'Vertebrates'
        if res[2] == 'INV':
            resultdict['tax_division'] = 'Invertebrates'
        if res[2] == 'PLN':
            resultdict['tax_division'] = 'Plants and Fungi'
        if res[2] == 'BCT':
            resultdict['tax_division'] = 'Bacteria'
        if res[2] == 'VRL':
            resultdict['tax_division'] = 'Viruses'
        if res[2] == 'PHG':
            resultdict['tax_division'] = 'Phages'
        if res[2] == 'SYN':
            resultdict['tax_division'] = 'Synthetic and Chimeric'
    print(json.dumps(resultdict))
