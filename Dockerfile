
FROM ubuntu:14.04
MAINTAINER Long Nguyen <longnguyen.mail@gmail.com>
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux
USER root
RUN echo -n  INITRD=no > /etc/environment
RUN mkdir -p /etc/container_environment
RUN echo -n no > /etc/container_environment/INITRD
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl
RUN dpkg-divert --local --rename --add /usr/bin/ischroot
RUN ln -sf /bin/true /usr/bin/ischroot
# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN bash -c "echo -e '#!/bin/bash\nexit 101' | install -m 755 /dev/stdin /usr/sbin/policy-rc.d"
RUN apt-get -y update && apt-get -y dist-upgrade
RUN apt-get install -y -q language-pack-en vim wget nano ca-certificates debian-keyring debian-archive-keyring
RUN apt-get update && apt-get install -y apt-transport-https
RUN echo 'deb http://private-repo-1.hortonworks.com/HDP/ubuntu14/2.x/updates/2.4.2.0 HDP main' >> /etc/apt/sources.list.d/HDP.list
RUN echo 'deb http://private-repo-1.hortonworks.com/HDP-UTILS-1.1.0.20/repos/ubuntu14 HDP-UTILS main'  >> /etc/apt/sources.list.d/HDP.list
RUN echo 'deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/azurecore/ trusty main' >> /etc/apt/sources.list.d/azure-public-trusty.list
RUN update-locale LANG=en_US.UTF-8
RUN dpkg-reconfigure locales
RUN apt-key update
#Install PPA for LibreOffice 4.4 and libsslAnchor link for: install ppa for libreoffice 44 and libssl
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:libreoffice/libreoffice-4-4
RUN add-apt-repository -y ppa:ondrej/php
#Install key for BigBlueButtonAnchor link for: install key for bigbluebutton
RUN wget http://ubuntu.bigbluebutton.org/bigbluebutton.asc -O- | apt-key add -
RUN echo "deb http://ubuntu.bigbluebutton.org/trusty-1-0/ bigbluebutton-trusty main" | tee /etc/apt/sources.list.d/bigbluebutton.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
RUN apt-get -y update
#Install ffmpegAnchor link for: install ffmpeg
RUN apt-get install -y libvpx1 libvorbisenc2 build-essential git-core checkinstall yasm texi2html libvorbis-dev libx11-dev libvpx-dev libxfixes-dev zlib1g-dev pkg-config netcat libncurses5-dev
ADD install-ffmpeg.sh .
RUN chmod +x install-ffmpeg.sh
RUN ./install-ffmpeg.sh
RUN ffmpeg -version
RUN apt-get install -y libpam-systemd policykit-1 colord policykit-1-gnome
#Install BigBlueButton
RUN apt-get install -y bigbluebutton

RUN apt-get install -y bbb-apps bbb-apps-deskshare bbb-apps-sip bbb-apps-video \
    bbb-client bbb-freeswitch bbb-red5 bbb-mkclean bbb-office bbb-playback-presentation \
    bbb-record-core  bbb-swftools

RUN apt-get install -y bbb-config bbb-check haveged
RUN rm -fr /usr/sbin/policy-rc.d
RUN apt-get install -y bbb-demo
RUN apt-get install -y bbb-check

RUN bbb-conf --setip meeting.getventive.com
RUN bbb-conf --enablewebrtc
RUN bbb-conf --clean
RUN bbb-conf --check

EXPOSE 80 9123 1935
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
