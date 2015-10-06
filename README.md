# maildir-decrypt

A collection of scripts that can be used to

* convert pgp encrypted email files into clear text email files (preferably in a maildir folder)
* automatically replace encrypted email files in a maildir with the corresponding decrypted files
* update the notmuch database by indexing the changed content

This "works for me". These scripts are potentially dangerous and can destroy / delete your emails. 
This is why I don't write down a tutorial here. Read the scripts, understand what they do, do backups, test the scripts first in a mode that does not modify your source maildir folders...

Patches are welcome :-)

