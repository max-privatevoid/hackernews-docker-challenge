FROM nixos/nix:latest AS builder

COPY . /tmp/build
WORKDIR /tmp/build

RUN nix \
    --extra-experimental-features "nix-command flakes" \
    --option filter-syscalls false \
    build --verbose

RUN mkdir /tmp/nix-store-closure
RUN cp -R $(nix-store -qR result/) /tmp/nix-store-closure

FROM scratch

WORKDIR /app

COPY --from=builder /tmp/nix-store-closure /nix/store
#COPY --from=builder /tmp/build/build/libs/*.jar /app/app.jar
COPY --from=builder /tmp/build/result /app
#ENTRYPOINT ["java","-jar","/app/app.jar"]
CMD ["/app/bin/app"]

#FROM eclipse-temurin:21
#VOLUME /tmp
#COPY build/libs/*.jar app.jar
#EXPOSE "8080:8080"
#ENTRYPOINT ["java","-jar","/app.jar"]
