#!/usr/bin/env python3
# Reads vecscreen result stored as -outfmt 0 -text_output, and filter the results.
# 
# Usage: vecscrnfilter.py [-s|-m|-w] [alignment file]
#  '-s' outputs only 'Strong match'
#  '-m' outputs 'Moderate match' & 'Strong Match'
#  '-w' outputs 'Weak match' besides 'Moderate match' & 'Strong match'
#  They may contain 'Suspect origin' if included in the result

import re
import sys

def err():
    print(' Usage: vecscrnfilter.py [-s|-m|-w] [alignment file]')
    exit()

args = sys.argv
try:
    op1 = args[1]
    op2 = args[2]
except IndexError:
    err()
# check arguments
if not re.match(r'-s|-m|-w|-a', args[1]):
    print('Usage: vecscrnfilter.py [-s|-m|-w] [alignment file]')
    exit()

def filterres(array1, array2):
    t = array1.pop(0)
    query = t.replace('Query= ', '')
    t = array1.pop(0)
    length = t.replace('Length=', 'Length: ')
    dat = ', '.join(array1)
    t1 = re.sub(r', ([A-Z])', r'\n\1', dat)  # Separate the result by their match level
    # t2 = re.sub(r'([a-z]), ', r'\1: ', t1) # Replace 'xxx match, ' or 'xxx origin, ' with 'xxx match: ' or 'xxx origin: '
    tt1 = re.search(r'Strong match, (.+)', t1)
    tt2 = re.search(r'Moderate match, (.+)', t1)
    tt3 = re.search(r'Weak match, (.+)', t1)
    tt4 = re.search(r'Suspect origin, (.+)', t1)
    res = {}
    if tt1:
        res["strong"] = tt1.group(1)
    if tt2:
        res["moderate"] = tt2.group(1)
    if tt3:
        res["weak"] = tt3.group(1)
    if tt4:
        res["suspect"] = tt4.group(1)
    # Display result
    if array2[0] == "***** No hits found *****":
        return('', '')
    if args[1] == "-w":
        filteredsum = query + ', ' + length + '\t'
        for v in res.keys():
            filteredsum += v + ': ' + res[v] + '\t'
        filteredaln = ('\n'.join(array2))
        return(filteredsum, filteredaln)
        # print('---')
    if args[1] == "-m":
        if "moderate" in res.keys() or "strong" in res.keys():
            filteredsum = query + ', ' + length + '\t'
            for v in res.keys():
                if v != "weak":
                    filteredsum += v + ': ' + res[v] + '\t'
            filteredaln = ('\n'.join(array2))
            return(filteredsum, filteredaln)
            # print('---')
        else:
            return('', '')
    if args[1] == "-s":
        if "strong" in res.keys():
            filteredsum = query + ', ' + length + '\t'
            for v in res.keys():
                # if re.compile(r'(?!weak)').match(v) and re.compile(r'(?!moderate)').match(v):
                if v != "weak" and v != "moderate":
                    filteredsum += v + ': ' + res[v] + '\t'
            filteredaln = ('\n'.join(array2))
            return(filteredsum, filteredaln)
            # print('---')
        else:
            return('', '')

with open(args[2], 'r') as f:
    lines = f.readlines()
    l = len(lines)
    c = 0
    resary1 = []
    resary2 = []
    while c < l:
        chk1 = "off"
        chk2 = "off"
        if re.match('Database:', lines[c]):
            k = c + 3
            chk1 = "on"
            tmp1 = []
            tmp2 = []
            while k < l:
                if re.match('Query=', lines[k]):
                    chk1 = "off"
                    tmp1.insert(0, lines[k].replace('\n', ''))
                if re.match('Length=', lines[k]) and chk2 == "off":
                    chk2 = "on"
                    tmp1.insert(1, lines[k].replace('\n', ''))
                    k += 3
                if re.match('Lambda ', lines[k]):
                    chk2 == "off"
                    c = k
                    k = l - 1
                    resall = filterres(tmp1, tmp2)
                    resary1.append(resall[0])
                    resary2.append(resall[1])
                if chk1 == "on" and lines[k] != "\n":
                    tmp1.append(lines[k].replace('\t', '..').replace('\n', '')) # tab => '..', remove \n from end of the line
                if chk2 == "on":
                    tmp2.append(lines[k].replace('\n', ''))
                k += 1
        c += 1
# Display result
# Summary
    c1 =  'off'
    for v in resary1:
        if v != '':
            print(v)
            c1 = 'on'
# Alignment
    if c1 == 'on':
        c2 = 0
        print('\n------------------------------------------------------------')
        for v in resary1:
            if v != '':
                print('# ' + v.replace('\t', '\n'))
                print(resary2[c2])
                print()
            c2 += 1
