FROM centos:7

RUN yum -y install java-11-openjdk-devel \
    && yum -y install kde-l10n-Chinese \
    && yum -y install glibc-common \
    && localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 \
    && cp -r -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone

ENV LC_ALL zh_CN.UTF-8
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk


# 将打包好的项目添加到镜像中
COPY vueblog-java/bin/service.sh /vueblog-java/bin/service.sh
COPY vueblog-java/target/vueblog-0.0.1-SNAPSHOT.jar /vueblog-java/vueblog-java.jar

# 添加脚本的执行权限
RUN chmod +x /vueblog-java/bin/service.sh
WORKDIR /vueblog-java

ENTRYPOINT ["bin/service.sh","start","vueblog-java.jar","--no-daemon"]
