FROM alpine:latest
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk add --no-cache ca-certificates icu gcompat

#WORKDIR /init
COPY TwitchDropsBot/ /init
COPY S302/ /S302
COPY S302/steamcommunityCA.pem /usr/local/share/ca-certificates/steamcommunityCA.crt
RUN update-ca-certificates

RUN chmod +x /init/
RUN chmod +x /S302/

CMD ["/S302/entryprint.sh"]
