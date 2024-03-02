FROM nixos/nix:latest AS builder

COPY . /tmp/build
WORKDIR /tmp/build
COPY build/libs/*.jar app.jar

RUN nix \
    --extra-experimental-features "nix-command flakes" \
    --option filter-syscalls false \
    develop --verbose

RUN mkdir /tmp/nix-store-closure
RUN cp -R $(nix-store -qR $(which java)) /tmp/nix-store-closure

FROM scratch

WORKDIR /app

COPY --from=builder /tmp/nix-store-closure /nix/store
COPY --from=builder /tmp/build/build/libs/*.jar /app/app.jar
ENTRYPOINT ["java","-jar","/app/app.jar"]

#FROM eclipse-temurin:21
#VOLUME /tmp
#COPY build/libs/*.jar app.jar
#EXPOSE "8080:8080"
#ENTRYPOINT ["java","-jar","/app.jar"]
