FROM ubuntu:plucky AS builder

RUN apt-get update && apt-get upgrade --yes
RUN apt-get install --yes --no-install-recommends wget unzip coreutils openjdk-24-jdk

ENV GRADLE_HOME=/opt/gradle
WORKDIR /home/gradle

# gradle
COPY gradle/ ./gradle/
COPY gradlew ./
COPY gradle.properties ./
COPY settings.gradle ./

RUN set -o errexit -o nounset
RUN echo "Testing Gradle installation"
RUN ./gradlew --version

COPY app/ ./app/

RUN ./gradlew assemble --no-daemon  --info --stacktrace


FROM ubuntu:plucky AS runner

RUN apt-get update && apt-get upgrade --yes
RUN apt-get install --yes --no-install-recommends openjdk-24-jre

WORKDIR /home/gradle

COPY --from=builder /home/gradle/gradle gradle
COPY --from=builder /home/gradle/.gradle .gradle
COPY --from=builder /home/gradle/gradlew .
COPY --from=builder /home/gradle/gradle.properties .
COPY --from=builder /home/gradle/settings.gradle .
COPY --from=builder /home/gradle/app ./app

USER root
RUN ./gradlew run --info --stacktrace

CMD ["./gradlew", "run"]
