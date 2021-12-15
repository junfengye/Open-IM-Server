FROM golang:1.15 as build

ENV GO111MODULE=on \
    GOPROXY=https://goproxy.cn,direct

# Set up the working directory
WORKDIR /Open-IM-Server

# go mod
COPY go.mod go.sum ./
RUN go mod download

# add all files to the container
COPY . .

WORKDIR /Open-IM-Server/script

RUN chmod +x *.sh && \
    /bin/sh -c ./build_all_service.sh

#Blank image Multi-Stage Build
FROM debian:11.1

ENV TZ=Asia/Shanghai \
    LANG=C.UTF-8

RUN sed -i s/deb.debian.org/mirrors.aliyun.com/g /etc/apt/sources.list && \
    apt update && \
    apt install -y ca-certificates tzdata procps net-tools gawk && \
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

#Copy scripts files and binary files to the blank image
COPY --from=build /Open-IM-Server/script /Open-IM-Server/script
COPY --from=build /Open-IM-Server/bin /Open-IM-Server/bin

# 42233 -> demo server
# 10000 -> api server
# 17788 -> gateway websocket server
# 10100 -> user rpc server
# 10200 -> friend rpc server
# 10300 -> chat rpc server
# 10400 -> gateway rpc server
# 10500 -> group rpc server
# 10600 -> auth rpc server
# 10700 -> push rpc server
EXPOSE 42233 10000 17778 10100 10200 10300 10400 10500 10600 10700

VOLUME ["/Open-IM-Server/logs", "/Open-IM-Server/config"]

WORKDIR /Open-IM-Server/script

CMD ["./docker_start_all.sh"]
