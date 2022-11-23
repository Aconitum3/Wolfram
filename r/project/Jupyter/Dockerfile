FROM python:3.7

RUN apt-get update && apt-get install -y \
    libzmq3-dev \
    r-base \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --upgrade pip
    					 
COPY requirements.txt .

RUN pip install -r requirements.txt

COPY Rkernel.R . 

RUN Rscript Rkernel.R

EXPOSE 8888

RUN mkdir /home/mountpoint

COPY WolframConnect.R .

WORKDIR /home/mountpoint

CMD jupyter lab --ip=0.0.0.0 --port=8888 --allow-root --no-browser