FROM debian:buster AS vzlogger-builder

RUN apt-get update
RUN apt-get -y install sudo build-essential git-core cmake pkg-config subversion libcurl4-openssl-dev libgnutls28-dev libsasl2-dev uuid-dev libtool libssl-dev libgcrypt20-dev libmicrohttpd-dev libltdl-dev libjson-c-dev libleptonica-dev libmosquitto-dev libunistring-dev dh-autoreconf

ADD https://github.com/volkszaehler/vzlogger/blob/master/etc/vzlogger.service /etc/systemd/system/vzlogger.service
ADD https://raw.githubusercontent.com/volkszaehler/vzlogger/master/install.sh /vzlogger/
RUN chmod a+x /vzlogger/install.sh

WORKDIR /vzlogger/

RUN ./install.sh

RUN ldd /usr/local/bin/vzlogger

FROM debian:buster

RUN apt-get update && apt-get install -y libcurl4 libatomic1 libsasl2-2 && apt-get clean

COPY --from=vzlogger-builder /usr/local/bin/vzlogger /usr/local/bin/
COPY --from=vzlogger-builder /usr/local/lib/libmbus.so.0 /usr/local/lib/ 
COPY --from=vzlogger-builder /usr/lib/x86_64-linux-gnu/libmosquitto.so.1 /usr/lib/x86_64-linux-gnu/
COPY --from=vzlogger-builder /usr/local/lib/static/libvz.a /usr/local/lib/static/ 
COPY --from=vzlogger-builder /usr/local/lib/static/libvz-api.a /usr/local/lib/static/ 
COPY --from=vzlogger-builder /usr/local/lib/static/libproto.a /usr/local/lib/static/ 

RUN ldd /usr/local/bin/vzlogger

ENTRYPOINT /usr/local/bin/vzlogger
