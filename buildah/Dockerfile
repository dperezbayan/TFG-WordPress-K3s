FROM jenkins/jenkins:lts

USER root

RUN apt-get update && \
    apt-get install -y buildah uidmap fuse-overlayfs && \
    apt-get clean

# Permite al usuario Jenkins usar sudo sin contraseña
RUN echo 'jenkins ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER jenkins
