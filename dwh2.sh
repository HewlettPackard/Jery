#!/bin/bash
export ORACLE_HOME=/home/oracle/client11gr2
export LD_LIBRARY_PATH=/home/oracle/client11gr2/lib:/lib:/usr/lib:/usr/openwin/lib:/usr/td/lib:/usr/ucblib:/usr/local/lib:/home/oracle/client/11gr2/lib
export PYTHONPATH=/usr/yann/dwh2.3/lib

python /usr/yann/dwh2.3/dwh2.py
