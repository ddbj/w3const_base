#!/usr/bin/env python3
# Convert csv/tsv to json format
# convCSV2Json.py <tsv file>
# 
import json
import csv
import sys

def createjson(infile):
    with open(infile, 'r') as f:
        reader = csv.DictReader(f, delimiter='\t')
        list = [row for row in reader]
        json.dump(list, sys.stdout, sort_keys=True, indent=4, separators=(',', ': '))
        # with open('result.json', 'w') as f:
        #     json.dump(list, f, sort_keys=True, indent=4, separators=(',', ': '))
        
if __name__ == '__main__':
    arg1 = sys.argv[1]
    createjson(arg1)
