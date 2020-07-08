FROM gradle:jdk8

RUN git clone https://github.com/scalar-labs/kelpie.git kelpie && \
    cd kelpie && ./gradlew installDist && \ 
    cd .. && \
    mv /home/gradle/kelpie/build/install/kelpie/bin/* /usr/local/bin/ && \
    mv /home/gradle/kelpie/build/install/kelpie/lib/* /usr/local/lib/ && \
    rm -rf kelpie

RUN git clone https://github.com/scalar-labs/kelpie-test.git kelpie-test && \
    cd kelpie-test/client-test && \
    gradle shadowJar

WORKDIR /home/gradle/kelpie-test/