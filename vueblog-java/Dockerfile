FROM bbc-registry.cn-hangzhou.cr.aliyuncs.com/docker/openjdk:11.0.16-jre

ENV LC_ALL zh_CN.UTF-8

# 将打包好的项目添加到镜像中
COPY vueblog-java/bin/service.sh /vueblog-java/bin/service.sh
COPY vueblog-java/target/vueblog-0.0.1-SNAPSHOT.jar /vueblog-java/vueblog-java.jar

# 添加脚本的执行权限
RUN chmod +x /vueblog-java/bin/service.sh
WORKDIR /vueblog-java

ENTRYPOINT ["bin/service.sh","start","vueblog-java.jar","--no-daemon"]
