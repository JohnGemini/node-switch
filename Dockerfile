FROM centos:7
COPY unschedule.py /root/unschedule.py
ADD slurm-17.11.7.tar.gz /root/
WORKDIR /root
RUN yum makecache fast && \
    yum install -y epel-release && \
    yum install -y epel-release && \
    yum install -y wget && \
    yum install -y perl && \
    yum install -y gcc && \
    yum install -y gcc-c++ && \
    yum install -y vim-enhanced && \
    yum install -y git && \
    yum install -y make && \
    yum install -y psmisc && \
    yum install -y bash-completion && \
    yum install -y python-devel && \
    yum install -y python-pip && \
    yum install -y munge && \
    yum install -y munge-devel && \
    pip install --no-cache-dir Cython nose && \
    pushd slurm-17.11.7 && \
    ./configure --enable-debug --prefix=/usr \
    --sysconfdir=/etc/slurm \
    --libdir=/usr/lib64 && \
    make install && \
    install -D -m644 contribs/slurm_completion_help/slurm_completion.sh /etc/profile.d/slurm_completion.sh && \
    popd && \
    rm -rf slurm-17.11.7 && \
    groupadd -r slurm --gid=202 && \
    useradd -r -g slurm --uid=202 slurm && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /tmp/*

VOLUME /etc/slurm
CMD ["python", "unschedule.py"]
