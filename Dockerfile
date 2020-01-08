FROM registry.redhat.io/ubi8/ubi
MAINTAINER jjyoo@rockplace.co.kr
LABEL "RHEL8 reposync with Podman"
LABEL summary="RHEL8 base reposync image"

### Timezone
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#ENV container oci
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN mkdir -p /repo1 > /dev/null

### Package Update
RUN yum update -y > /dev/null

### Package Install
RUN yum install cronie createrepo yum-utils procps-ng -y > /dev/null
RUN yum repolist --disablerepo=* && \
    yum-config-manager --disable \* > /dev/null && \
    yum-config-manager --enable rhel-8-for-x86_64-baseos-rpms --enable rhel-8-for-x86_64-appstream-rpms --enable ansible-2.9-for-rhel-8-x86_64-rpms --enable fast-datapath-for-rhel-8-x86_64-rpms --enable rhel-8-for-x86_64-highavailability-rpms --enable rhel-8-for-x86_64-supplementary-rpms --enable rhel-8-for-x86_64-resilientstorage-rpms > /dev/null 
RUN yum clean all -y > /dev/null

### Cron Setting
# Seems like a container specific issue on Centos: https://github.com/CentOS/CentOS-Dockerfiles/issues/31 
RUN sed -i '/session    required   pam_loginuid.so/d' /etc/pam.d/crond

### Cron Add
ADD start-cron.txt /tmp/start-cron.txt
RUN crontab /tmp/start-cron.txt 
RUN rm -f /tmp/start-cron.txt

### reposync file Add
RUN mkdir -p /root/reposync
ADD rhel8_reposync.sh /root/reposync
ADD rhel8_channel.txt /root/reposync
RUN chmod +x /root/reposync/rhel8_reposync.sh

##custom entry point — needed by cron
COPY entrypoint /entrypoint
RUN chmod +x /entrypoint
ENTRYPOINT ["/entrypoint"]
