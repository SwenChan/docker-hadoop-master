FROM swenchancn/alpine-java:8
MAINTAINER swenchan

USER root
RUN apk add --no-cache libstdc++ curl which tar sudo openssh rsync
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
# download and extract should download
COPY hadoop /usr/local/hadoop
COPY conf /root/conf
ENV HADOOP_PREFIX=/usr/local/hadoop \
    HADOOP_COMMON_HOME=/usr/local/hadoop \
    HADOOP_HDFS_HOME=/usr/local/hadoop \
    HADOOP_MAPRED_HOME=/usr/local/hadoop \
    HADOOP_YARN_HOME=/usr/local/hadoop \
    HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop
# set sshd without passwd
RUN echo "Protocol 2" >> /etc/ssh/sshd_config && \
    echo "HostKey /etc/ssh/ssh_host_rsa_key" >> /etc/ssh/sshd_config && \
    echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    echo "Port 22" >> /etc/ssh/sshd_config
ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config && chown root:root /root/.ssh/config
# add some env to this place for config
RUN sed s/HOSTNAME/localhost/ /root/conf/core-site.xml.template > ${HADOOP_CONF_DIR}/core-site.xml
RUN sed s/REPL_NUM/1/ /root/conf/hdfs-site.xml.template > ${HADOOP_CONF_DIR}/hdfs-site.xml

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 10020 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 22
