FROM jenkins/jenkins:lts
USER 0
#Must use root to install the cacerts
COPY ./local/certs/* /usr/local/share/ca-certificates/corp-certs/
RUN update-ca-certificates
USER 1000