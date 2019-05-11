FROM campsych/concerto-platform

ENV EFSENDPOINT=""

RUN apt update && apt-get install -y nfs-common

ADD entry-cmd.sh /entry-cmd.sh

CMD /entry-cmd.sh
