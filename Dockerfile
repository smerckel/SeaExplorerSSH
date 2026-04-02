FROM fedora:30
RUN dnf install -y openssh-clients && dnf clean all
#ENTRYPOINT ["ssh"]

