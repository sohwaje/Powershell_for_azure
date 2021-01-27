#!/bin/sh

scp -P 16215 sigongweb@/home/sigongweb/jar/api/* /home/sigongweb/apps/api

/home/sigongweb/apps/bin/api-run.sh restart
