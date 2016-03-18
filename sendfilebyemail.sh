#!/usr/bin/env python2
'''
usage: sendfileby.sh [ "optional subject" ] <destination email> <file names separated by spaces>...
Customized by Gabriel Orozco
last update: 2015-08-01 made the subject and the body optional.

'''

import smtplib, os, sys, stat, re
from email.MIMEMultipart import MIMEMultipart
from email.MIMEBase import MIMEBase
from email.MIMEText import MIMEText
from email.Utils import COMMASPACE, formatdate
from email import Encoders
import fileinput
import string

email_regex = re.compile(r"[a-zA-Z0-9._%-+]+@[a-zA-Z0-9._%-]+.[a-zA-Z]{2,6}")

def send_mail(send_from, send_to, subject, body, files=[], server="localhost"):
    assert isinstance(send_to, list) 
    assert isinstance(files, list) 

    msg = MIMEMultipart()
    msg['From'] = send_from
    msg['To'] = COMMASPACE.join(send_to)
    msg['Date'] = formatdate(localtime=True)
    msg['Subject'] = subject

    msg.attach( MIMEText(body) )

    for f in files:
        if f != "/dev/null":
           part = MIMEBase('application', "octet-stream")
           part.set_payload( open(f,"rb").read() )
           Encoders.encode_base64(part)
           part.add_header('Content-Disposition', 'attachment; filename="%s"' % os.path.basename(f))
           msg.attach(part)

#    smtp = smtplib.SMTP(server)
    smtp = smtplib.SMTP("smtp.163.com")
    smtp.login("sdscls@163.com","13706927006")
    smtp.sendmail(send_from, send_to, msg.as_string())
    smtp.close()

USERNAME = os.popen("whoami").read().rstrip('\n')
HOSTNAME = os.popen("hostname").read().rstrip('\n')
server   = "localhost"

# check if STDIN is piped (in such case take the body from that input)
mode = os.fstat(sys.stdin.fileno()).st_mode
if stat.S_ISFIFO(mode):
    body = string.join(sys.stdin.readlines(), " ")
else:
    body = "Files attached."

#send_from = USERNAME


to_arg_number = 1
files_arg_number_start_from = 2

#send_from = USERNAME
send_from = "sdscls@163.com"

if email_regex.match(sys.argv[2]):
    to_arg_number = 2
    files_arg_number_start_from = 3
    subject   = sys.argv[1]
else:
    subject   = "Files from " + USERNAME + "@" + HOSTNAME

send_to   = sys.argv[to_arg_number].split(',')
files     = sys.argv[files_arg_number_start_from:]

#Debug by James, Xu
print ('Email list format:', send_to)
print ('File list format:', files)

send_mail(send_from, send_to, subject, body, files, server)

