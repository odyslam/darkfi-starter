FROM osminogin/tor-simple
COPY torrc /etc/tor/torrc
COPY run.sh /usr/local/bin/run.sh 
USER root
RUN chmod +x /usr/local/bin/run.sh
USER tor
ENTRYPOINT ["tor"]
