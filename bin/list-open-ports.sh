#!/bin/bash

# The output of the next command.
#
# LISTEN    0         4                127.0.0.1:5037          0.0.0.0:*     users:(("adb",pid=17705,fd=9))                                           
# LISTEN    0         32            192.168.42.1:53            0.0.0.0:*     users:(("dnsmasq",pid=1191,fd=6))                                        
# LISTEN    0         32           192.168.122.1:53            0.0.0.0:*     users:(("dnsmasq",pid=1169,fd=6))                                        

ss --listening --tcp --processes --numeric --no-header

# [ ] strip first three columns and the column before the last
# [ ] keep indentation of 4th column intact

