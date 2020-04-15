@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  cassy-server startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%..

@rem Add default JVM options here. You can also use JAVA_OPTS and CASSY_SERVER_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS=

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto init

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto init

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:init
@rem Get command-line arguments, handling Windows variants

if not "%OS%" == "Windows_NT" goto win9xME_args

:win9xME_args
@rem Slurp the command line arguments.
set CMD_LINE_ARGS=
set _SKIP=2

:win9xME_args_slurp
if "x%~1" == "x" goto execute

set CMD_LINE_ARGS=%*

:execute
@rem Setup the command line

set CLASSPATH=%APP_HOME%\lib\cassy.jar;%APP_HOME%\lib\cassandra-all-3.11.4.jar;%APP_HOME%\lib\guice-4.2.2.jar;%APP_HOME%\lib\googleapis-common-protos-0.0.3.jar;%APP_HOME%\lib\grpc-alts-1.13.2.jar;%APP_HOME%\lib\grpc-services-1.13.2.jar;%APP_HOME%\lib\grpc-grpclb-1.13.2.jar;%APP_HOME%\lib\grpc-protobuf-1.13.2.jar;%APP_HOME%\lib\protobuf-java-util-3.6.0.jar;%APP_HOME%\lib\airline-0.6.jar;%APP_HOME%\lib\ohc-core-j8-0.4.4.jar;%APP_HOME%\lib\ohc-core-0.4.4.jar;%APP_HOME%\lib\grpc-netty-1.13.2.jar;%APP_HOME%\lib\grpc-stub-1.13.2.jar;%APP_HOME%\lib\grpc-protobuf-lite-1.13.2.jar;%APP_HOME%\lib\grpc-core-1.13.2.jar;%APP_HOME%\lib\giraffe-ssh-0.10.0.jar;%APP_HOME%\lib\giraffe-core-0.10.0.jar;%APP_HOME%\lib\giraffe-fs-base-0.10.0.jar;%APP_HOME%\lib\guava-27.1-jre.jar;%APP_HOME%\lib\logback-classic-1.2.3.jar;%APP_HOME%\lib\aws-java-sdk-s3-1.11.560.jar;%APP_HOME%\lib\picocli-4.0.1.jar;%APP_HOME%\lib\proto-google-common-protos-1.0.0.jar;%APP_HOME%\lib\netty-tcnative-boringssl-static-2.0.7.Final.jar;%APP_HOME%\lib\sqlite-jdbc-3.27.2.1.jar;%APP_HOME%\lib\dnsjava-2.1.9.jar;%APP_HOME%\lib\snappy-java-1.1.1.7.jar;%APP_HOME%\lib\lz4-1.3.0.jar;%APP_HOME%\lib\compress-lzf-0.8.4.jar;%APP_HOME%\lib\commons-cli-1.1.jar;%APP_HOME%\lib\thrift-server-0.3.7.jar;%APP_HOME%\lib\cassandra-thrift-3.11.4.jar;%APP_HOME%\lib\libthrift-0.9.2.jar;%APP_HOME%\lib\aws-java-sdk-kms-1.11.560.jar;%APP_HOME%\lib\aws-java-sdk-core-1.11.560.jar;%APP_HOME%\lib\httpclient-4.5.5.jar;%APP_HOME%\lib\commons-codec-1.10.jar;%APP_HOME%\lib\reporter-config3-3.0.3.jar;%APP_HOME%\lib\reporter-config-base-3.0.3.jar;%APP_HOME%\lib\commons-lang3-3.5.jar;%APP_HOME%\lib\commons-math3-3.2.jar;%APP_HOME%\lib\concurrentlinkedhashmap-lru-1.4.jar;%APP_HOME%\lib\antlr-3.5.2.jar;%APP_HOME%\lib\ST4-4.0.8.jar;%APP_HOME%\lib\antlr-runtime-3.5.2.jar;%APP_HOME%\lib\log4j-over-slf4j-1.7.7.jar;%APP_HOME%\lib\jcl-over-slf4j-1.7.7.jar;%APP_HOME%\lib\metrics-jvm-3.1.5.jar;%APP_HOME%\lib\metrics-core-3.1.5.jar;%APP_HOME%\lib\slf4j-api-1.7.25.jar;%APP_HOME%\lib\jackson-mapper-asl-1.9.2.jar;%APP_HOME%\lib\jackson-core-asl-1.9.2.jar;%APP_HOME%\lib\json-simple-1.1.jar;%APP_HOME%\lib\high-scale-lib-1.0.6.jar;%APP_HOME%\lib\snakeyaml-1.12.jar;%APP_HOME%\lib\jbcrypt-0.3m.jar;%APP_HOME%\lib\stream-2.5.2.jar;%APP_HOME%\lib\logback-core-1.2.3.jar;%APP_HOME%\lib\jna-4.2.2.jar;%APP_HOME%\lib\jamm-0.3.0.jar;%APP_HOME%\lib\joda-time-2.8.1.jar;%APP_HOME%\lib\sigar-1.6.4.jar;%APP_HOME%\lib\ecj-4.4.2.jar;%APP_HOME%\lib\caffeine-2.2.6.jar;%APP_HOME%\lib\jctools-core-1.2.1.jar;%APP_HOME%\lib\asm-5.0.4.jar;%APP_HOME%\lib\failureaccess-1.0.1.jar;%APP_HOME%\lib\listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar;%APP_HOME%\lib\jsr305-3.0.2.jar;%APP_HOME%\lib\checker-qual-2.5.2.jar;%APP_HOME%\lib\error_prone_annotations-2.2.0.jar;%APP_HOME%\lib\j2objc-annotations-1.1.jar;%APP_HOME%\lib\animal-sniffer-annotations-1.17.jar;%APP_HOME%\lib\javax.inject-1.jar;%APP_HOME%\lib\aopalliance-1.0.jar;%APP_HOME%\lib\jmespath-java-1.11.560.jar;%APP_HOME%\lib\protobuf-java-3.6.0.jar;%APP_HOME%\lib\netty-codec-http2-4.1.25.Final.jar;%APP_HOME%\lib\netty-handler-proxy-4.1.25.Final.jar;%APP_HOME%\lib\gson-2.7.jar;%APP_HOME%\lib\re2j-1.2.jar;%APP_HOME%\lib\sshj-0.27.0.jar;%APP_HOME%\lib\hibernate-validator-4.3.0.Final.jar;%APP_HOME%\lib\disruptor-3.0.1.jar;%APP_HOME%\lib\fastutil-6.5.7.jar;%APP_HOME%\lib\httpcore-4.4.9.jar;%APP_HOME%\lib\hppc-0.5.4.jar;%APP_HOME%\lib\jflex-1.6.0.jar;%APP_HOME%\lib\snowball-stemmer-1.3.0.581.1.jar;%APP_HOME%\lib\concurrent-trees-2.4.0.jar;%APP_HOME%\lib\commons-logging-1.2.jar;%APP_HOME%\lib\ion-java-1.0.2.jar;%APP_HOME%\lib\jackson-databind-2.6.7.2.jar;%APP_HOME%\lib\jackson-dataformat-cbor-2.6.7.jar;%APP_HOME%\lib\grpc-context-1.13.2.jar;%APP_HOME%\lib\opencensus-contrib-grpc-metrics-0.12.3.jar;%APP_HOME%\lib\opencensus-api-0.12.3.jar;%APP_HOME%\lib\netty-codec-http-4.1.25.Final.jar;%APP_HOME%\lib\netty-handler-4.1.25.Final.jar;%APP_HOME%\lib\netty-codec-socks-4.1.25.Final.jar;%APP_HOME%\lib\netty-codec-4.1.25.Final.jar;%APP_HOME%\lib\netty-transport-4.1.25.Final.jar;%APP_HOME%\lib\bcpkix-jdk15on-1.60.jar;%APP_HOME%\lib\bcprov-jdk15on-1.60.jar;%APP_HOME%\lib\jzlib-1.1.3.jar;%APP_HOME%\lib\eddsa-0.2.0.jar;%APP_HOME%\lib\validation-api-1.0.0.GA.jar;%APP_HOME%\lib\jboss-logging-3.1.0.CR2.jar;%APP_HOME%\lib\ant-1.7.0.jar;%APP_HOME%\lib\jackson-annotations-2.6.0.jar;%APP_HOME%\lib\jackson-core-2.6.7.jar;%APP_HOME%\lib\netty-buffer-4.1.25.Final.jar;%APP_HOME%\lib\netty-resolver-4.1.25.Final.jar;%APP_HOME%\lib\ant-launcher-1.7.0.jar;%APP_HOME%\lib\netty-common-4.1.25.Final.jar

@rem Execute cassy-server
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %CASSY_SERVER_OPTS%  -classpath "%CLASSPATH%" com.scalar.cassy.server.CassyServer %CMD_LINE_ARGS%

:end
@rem End local scope for the variables with windows NT shell
if "%ERRORLEVEL%"=="0" goto mainEnd

:fail
rem Set variable CASSY_SERVER_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
if  not "" == "%CASSY_SERVER_EXIT_CONSOLE%" exit 1
exit /b 1

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
