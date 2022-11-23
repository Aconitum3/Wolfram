FROM wolframresearch/wolframengine:13.0.1

USER root

COPY requirements.txt ./
RUN pip install --upgrade pip \
  && pip install -r requirements.txt

RUN apt-get update && apt-get install -y git \
  && git clone https://github.com/WolframResearch/WolframLanguageForJupyter.git \
  && mkdir /home/mountpoint

WORKDIR /home/mountpoint

EXPOSE 8888

CMD jupyter lab --ip=0.0.0.0 --port=8888 --allow-root