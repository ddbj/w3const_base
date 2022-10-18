#!/usr/bin/env python3
# coding: utf-8
# 
# For >python3.6
# To show the usage
# sendgmail_w3const.py --help
#
# 1. Create a credential file to run the script.
#  mkdir -m 700 ~/.sendgmail_w3const
#  echo 'GmailAccount:ApplicationPassword' > ~/.sendgmail_w3const/account
#  chmod 400 ~/.sendgmail_w3const/account
# 2. Create a whitelist
#  touch ~/.sendgmail_w3const/whitelist; chmod 600 ~/.sendgmail_w3const/whitelist

import argparse
import os
import sys
import smtplib
from smtplib import SMTPException
from email.message import EmailMessage

# Host, port
host, port = 'smtp.gmail.com', 587

#
def accountinfo():
    try:
        with open(os.environ['HOME'] + '/.sendgmail_w3const/account', 'r', encoding = 'utf-8') as f:
            info = f.read().split(':')
        return info
    except FileNotFoundError:
        print('~/.sendgmail_w3const/account is not found. Create it as indicated below.')
        print('')
        print('mkdir -m 700 -p ~/.sendgmail_w3const')
        print('echo GmailAccount:ApplicationPassword > ~/.sendgmail_w3const/account')
        print('chmod 400 ~/.sendgmail_w3const/account')
        sys.exit()

def parseoption():
    parser = argparse.ArgumentParser()
    parser.add_argument('--sj', required=True, metavar='subject', help="e.g. 'Email title'")
    parser.add_argument('--to', required=True, metavar='email', help='To address e.g. email; elail1,email2,...')
    parser.add_argument('--body', required=True, metavar='file', help='A file of email body')
    parser.add_argument('--cc', metavar='email', help='Cc address e.g. email; elail1,email2,...')
    parser.add_argument('--bcc', metavar='email', help='Bcc address e.g. email; email1,email2,...')
    parser.add_argument('--att', metavar='file', help='Attachment file (text-type only) e.g. file; file1,file2,... ')
    args = parser.parse_args()
    return args

def chkwhite(e):
    try:
        with open(os.environ['HOME'] + '/.sendgmail_w3const/whitelist', 'r', encoding = 'utf-8') as f:
            white = []
            white = f.read().split('\n')
        white2 = [x for x in white if x]
        # print('Whitelist email: ', end='')
        # print(white2)
        c = 0
        for v in e:
            if v not in white2:
                print(v + ' is not found in the whitelist file.')
                c += 1
        return c
    except FileNotFoundError:
        print('~/.sendgmail_w3const/whitelist is not found. Create it as follows.')
        print('')
        print('mkdir -m 700 -p ~/.sendgmail_w3const')
        print('touch ~/.sendgmail_w3const/whitelist; chmod 600 ~/.sendgmail_w3const/whitelist')
        print('Write an email address in each line.')
        sys.exit()

def sendemail(account, pwd, subject, to, body, cc, bcc, attach):
    msg = EmailMessage()
    msg['Subject'] = subject
    msg['From'] = account
    msg['To'] = to
    if cc:
        msg["Cc"] = cc
    if bcc:
        msg["Bcc"] = bcc
    # Email body
    msg.set_content(body)
    # Attachment file
    if attach != '':
        attaches = attach.split(',')
        for fi in attaches:
            attachname = os.path.basename(fi)
            with open(fi, 'rb') as f:
                dat = f.read()
                msg.add_attachment(dat, maintype='text', subtype='plain', filename=attachname)
    #
    try:
        with smtplib.SMTP(host, port, timeout=30) as gmail:
            gmail.ehlo()
            gmail.starttls()
            gmail.login(account, pwd)
            gmail.send_message(msg)
            # gmail.quit() # Can omit the quit() under with block:
        print('Email has been sent')
    except SMTPException:
        print('Authentication failure')
        sys.exit()

def main():
    accnt = accountinfo()
    opt = parseoption()
    emails = []
    emails = opt.to.split(',')
    if opt.cc:
        emails += opt.cc.split(',')
    if opt.bcc:
        emails += opt.bcc.split(',')
    # print(emails)
    chk = chkwhite(emails)
    if chk == 0:
        with open(opt.body, 'r', encoding = 'utf-8') as fbody:
            if opt.att:
                sendemail(accnt[0], accnt[1], opt.sj, opt.to, fbody.read(), opt.cc, opt.bcc, opt.att)
            else:
                sendemail(accnt[0], accnt[1], opt.sj, opt.to, fbody.read(), opt.cc, opt.bcc, '')

if __name__ == '__main__':
    main()
