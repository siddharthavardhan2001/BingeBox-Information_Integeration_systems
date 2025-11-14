FROM postgres:latest

RUN apt-get update && \
    apt-get install -y locales && \
    sed -i '/en_IN.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_IN.UTF-8

ENV LANG=en_IN.UTF-8
ENV LANGUAGE=en_IN:en
ENV LC_ALL=en_IN.UTF-8
