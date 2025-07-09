#!/bin/bash
#CIS Hardening 
sudo apt install rsync
sudo systemctl unmask rsync.service
sudo systemctl start rsync.service
sudo systemctl enable rsync.service
sudo systemctl status rsync.service