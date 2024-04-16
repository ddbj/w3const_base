#!/usr/bin/env python3
# Obtain or Find the taxonomy division from flatfile
# getorganisminfFF.py -i <flatfile> -a <accession number>

import argparse
import sys
import subprocess
import re
import time
from Bio import SeqIO
from Bio import Entrez
import json

Entrez.email = 'tkosuge@nig.ac.jp'

def parseoption():
    parser = argparse.ArgumentParser(description='Showing organism, taxid, and taxonomy division of target entry in the flatfile')
    parser.add_argument('-i', required=True, metavar='gbff', help="GenBank-type flatfile as input")
    parser.add_argument('-a', required=True, metavar='accession', help="Accession number")
    parser.add_argument('-p', required=False, metavar='localtaxdumpdir', help="Indicate directory of taxonomy dump file")
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

divdic = dict()
def divisiondefine(privatetaxfiledir):
    with open(privatetaxfiledir + '/division.dmp', 'r') as f:
        divisiondat = f.readlines()
        for v in divisiondat:
            # print(v.split('\t|\t'))
            divdic[v.split('\t|\t')[0]] = {'code': v.split('\t|\t')[1], 'name': v.split('\t|\t')[2] }
    # print(divdic)

def taxprivatesrch(genusname, privatetaxfiledir):
    term = '\t' + genusname + '\t'
    command = 'grep -P "' + term + '" ' + privatetaxfiledir + '/names.dmp | cut -f 1' 
    res = subprocess.run(command, shell = True, capture_output = True, text = True)
    # 
    taxidaray = res.stdout.split()
    # # print(len(taxidaray))
    # for v in taxidaray:
    #     print(v)
    # print('------')
    resdivarray = []
    for v in taxidaray:
        command = 'grep -P "^' + v + '\t" ' + privatetaxfiledir + '/nodes.dmp | cut -f 9'
        res = subprocess.run(command, shell = True, capture_output = True, text = True)
        # print(res.stdout, end='')
        # print(divdic[res.stdout.replace('\n', '')]['name'])
        resdivarray.append(divdic[res.stdout.replace('\n', '')]['name'])
    return(resdivarray)

if __name__ == '__main__':
    options = parseoption()
    res = valfromsc(options.i, options.a)
    # print(res[0], res[1], res[2])
    resultdict = dict()
    resultdict['accession'] = options.a
    resultdict['organism'] = res[0]
    resultdict['taxid'] = int(res[1].replace('taxon:', ''))
    resultdict['tax_division'] = None
    if not res[2] or res[2].isspace() or res[2] == 'ENV':
        if re.search(r'bacteria|bacterium', res[0], re.I):
            resultdict['tax_division'] = 'Bacteria'
        if re.search('virus', res[0], re.I):
            resultdict['tax_division'] = 'Viruses'
        if re.search('vector', res[0], re.I):
            resultdict['tax_division'] = 'Synthetic and Chimeric'
        if not resultdict['tax_division']:
            if options.p is None:
                orgtemp = res[0].replace('uncultured ', '').replace(' environmental sample', '')
                orgsearch = re.sub(r'(^[A-Za-z]+).*', r'\1', orgtemp)
                # print(orgsearch)
                response = get_tax_id(orgsearch)
                # print(len(response))
                # Interval not to burden NCBI entrez server
                time.sleep(1)
                taxres = []
                for v in response:
                    taxres.append(get_tax_data(v))
                # Remove duplicates in the array
                taxres_a = list(dict.fromkeys(taxres))
                resultdict['tax_division'] = ' OR '.join(taxres_a)
            else:
                divisiondefine(options.p)
                orgtemp = res[0].replace('uncultured ', '').replace(' environmental sample', '')
                orgsearch = re.sub(r'(^[A-Za-z]+).*', r'\1', orgtemp)
                response = taxprivatesrch(orgsearch, options.p)
                response_a = list(dict.fromkeys(response))
                resultdict['tax_division'] = ' OR '.join(response_a)
    else:
        if res[2] == 'HUM':
            resultdict['tax_division'] = 'Primates'
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
    if not resultdict['tax_division']:
        resultdict['tax_division'] = 'Unknown'
    
    print(json.dumps(resultdict))
