#!/bin/bash

export PYTHONUNBUFFERED=TRUE

HTTP_PORT=8081
DEBUG="0"

  while getopts 'hdp:' flag; do
    case "${flag}" in
      h)
        echo "options:"
        echo "-h        show brief help"
        echo "-d        debug mode, no nginx or uwsgi, direct start with 'python3 app.py'"
        echo "-p HTTP_PORT run at specific port (default 8081)"
        exit 0
        ;;
      d)
        DEBUG="1"
        ;;
      p)
        HTTP_PORT=${OPTARG}
        ;;
      *)
        break
        ;;
    esac
  done

if [[ "$DEBUG" = "1" ]]; then
  echo "Running app in debug mode!"
  python3 app.py
else
  echo "Running RISK MODEL in production mode!"
  #
  # for Docker -> gunicorn  --workers=8 --worker-tmp-dir /dev/shm -b :$HTTP_PORT app
  gunicorn  --workers=8 -b :$HTTP_PORT app
fi
