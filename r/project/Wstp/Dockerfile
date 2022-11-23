FROM wolframresearch/wolframengine

USER root

COPY PortOpen.wls ./
COPY wstpserver.conf ./
COPY .bash_profile /root/
COPY .bashrc /root/

#RUN source /root/.bash_profile
CMD /usr/local/Wolfram/WolframEngine/13.0/SystemFiles/Links/WSTPServer/wstpserver