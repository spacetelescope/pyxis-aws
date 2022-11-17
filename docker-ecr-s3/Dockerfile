FROM debian:bullseye-slim
ENV DEV_HOME=/home/developer


RUN apt update && \
    apt upgrade --assume-yes && \
    ACCEPT_EULA=Y DEBIAN_FRONTEND=noninteractive && \
    apt install --assume-yes \
        wget \
        make \
        sudo \
        git \
        vim \
        python3 \
        python3-pip \
        python3-venv \
        gcc \
        tar \
        curl \
        time && \
    apt autoremove && \
    apt clean && \
    useradd --create-home --shell /bin/bash developer

COPY scrape.py /home/developer/.
RUN chown -R developer:developer /home/developer

USER developer
ENV PATH=/home/developer/venv/bin:${PATH}
ENV LD_LIBRARY_PATH=/home/developer/venv/LD_LIBRARY_PATH
WORKDIR /home/developer
RUN python3 -m venv /home/developer/venv && \
  pip install --upgrade pip && \
  pip install boto3

USER developer
WORKDIR /home/developer
CMD /bin/bash
