#!/usr/bin/python3
from notmuch import *
import os
import sys 

db = Database(path=None, mode=Database.MODE.READ_WRITE)
for line in sys.stdin: 
  line=line.rstrip('\n')
  if not os.path.isfile(line): 
    print('"'+line+'" does not exist!')
    continue
  print('"'+line+'"')
  print(db.remove_message(line))
  print(db.add_message(line))
db.close()



