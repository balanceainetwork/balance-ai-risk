FROM python:3.8


RUN apt-get update -y && \  
    apt-get install -y libclips libclips-dev clips-common clips && \
    apt-get install -y python3-pip python3-dev   


COPY ./requirements.txt /requirements.txt


WORKDIR /

RUN pip3 install -r requirements.txt --use-pep517 --prefer-binary

COPY . /

RUN adduser --disabled-password --gecos '' gunicorn\  
  && chown -R gunicorn:gunicorn app.py

USER gunicorn

ENTRYPOINT [ "/bin/bash", "/launcher.sh"] 


