FROM rockylinux:9

ARG RPM_SOURCE
ARG SEM_VER_LP_BASE=5.8.0
ARG SEM_VER_LP_ENGLISH=5.8.0
ARG SEM_VER_CLASSIFICATION=5.10.3
ARG SEM_VER_SES=5.10.3
ARG SEM_VER_CONCEPTS=5.10.3
ARG SEM_VER_STUDIO=5.10.3

# Create and populate staging areas
RUN mkdir -p /tmp/yum /tmp/semaphore_rpms
COPY yum/ /tmp/yum/
COPY Semaphore_RPMs/ /tmp/semaphore_rpms/

# Set working directory to avoid ambiguity in `ls`
WORKDIR /tmp/semaphore_rpms

# Main install logic
RUN if [ "$RPM_SOURCE" = "LOCAL" ]; then \
        echo "Building image from local RPMs..."; \
        language_pack_base_rpm=$(ls | grep "^Semaphore-LanguagePack-Linux-Base.*\.rpm$") && \
        language_pack_english_rpm=$(ls | grep "^Semaphore-LanguagePack-Linux-English.*\.rpm$") && \
        classification_server_rpm=$(ls | grep "^Semaphore-ClassificationServer.*\.rpm$") && \
        semantic_enhancement_server_rpm=$(ls | grep "^Semaphore-SES.*\.rpm$") && \
        concepts_server_rpm=$(ls | grep "^Semaphore-ConceptsServer.*\.rpm$") && \
        studio_rpm=$(ls | grep "^Semaphore-Studio.*\.rpm$") && \
        yum -y --setopt=tsflags=nodocs update && \
        yum -y --setopt=tsflags=nodocs install \
            patch \
            jq \
            less \
            nmap \
            nc \
            procps \
            tar && \
        rpm --import https://yum.corretto.aws/corretto.key && \
        curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo && \
        yum -y --setopt=tsflags=nodocs install java-21-amazon-corretto-devel && \
        yum -y --setopt=tsflags=nodocs install \
            "/tmp/semaphore_rpms/$language_pack_base_rpm" \
            "/tmp/semaphore_rpms/$language_pack_english_rpm" \
            "/tmp/semaphore_rpms/$classification_server_rpm" \
            "/tmp/semaphore_rpms/$semantic_enhancement_server_rpm" \
            "/tmp/semaphore_rpms/$concepts_server_rpm" \
            "/tmp/semaphore_rpms/$studio_rpm" && \
        yum clean all && \
        rm -rf /var/cache/yum; \
    else \
        echo "Building image from RPMs in private repo..."; \
        mkdir -p /usr/local/semaphore-yum && \
        mv /tmp/yum/semaphore-yum.* /usr/local/semaphore-yum/ && \
        mv /tmp/yum/Semaphore.repo /etc/yum.repos.d/Semaphore.repo && \
        yum -y --setopt=tsflags=nodocs update && \
        yum -y --setopt=tsflags=nodocs install \
            patch \
            jq \
            less \
            nmap \
            nc \
            procps \
            tar && \
        rpm --import https://yum.corretto.aws/corretto.key && \
        curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo && \
        yum -y --setopt=tsflags=nodocs install java-21-amazon-corretto-devel && \
        yum -y --setopt=tsflags=nodocs install 'dnf-command(versionlock)' && \
        yum -y --setopt=tsflags=nodocs install \
            Semaphore-LanguagePack-Base-${SEM_VER_LP_BASE} \
            Semaphore-LanguagePack-English-${SEM_VER_LP_ENGLISH} \
            Semaphore-ClassificationServer-${SEM_VER_CLASSIFICATION} \
            Semaphore-SES-${SEM_VER_SES} \
            Semaphore-Concepts-${SEM_VER_CONCEPTS} \
            Semaphore-Studio-${SEM_VER_STUDIO} && \
        dnf -y versionlock add \
            Semaphore-LanguagePack-Base-${SEM_VER_LP_BASE} \
            Semaphore-LanguagePack-English-${SEM_VER_LP_ENGLISH} \
            Semaphore-ClassificationServer-${SEM_VER_CLASSIFICATION} \
            Semaphore-SES-${SEM_VER_SES} \
            Semaphore-Concepts-${SEM_VER_CONCEPTS} \
            Semaphore-Studio-${SEM_VER_STUDIO} && \
        dnf versionlock list && \
        yum clean all && \
        rm -rf /var/cache/yum; \
    fi

RUN rm -rf /tmp/semaphore_rpms /tmp/yum

# Reset working directory
WORKDIR /

# Patch to open 5059 admin service to all IPs
# COPY CLS/config.patch /opt/semaphore/CS/conf/config.patch
# RUN patch --directory /opt/semaphore/CS/conf --ignore-whitespace < /opt/semaphore/CS/conf/config.patch
# RUN patch --ignore-whitespace /opt/semaphore/CS/conf/config.xml /opt/semaphore/CS/conf/config.patch

# License

    COPY licence/semaphore_licence.txt /opt/semaphore/licence
    RUN chmod a+r /opt/semaphore/licence
    ENV SEMAPHORE_LICENCE_DIR /opt/semaphore

# Studio

    COPY docker/Studio/add-superadmin-publish-permission.sh /opt/semaphore
    RUN chmod 777 /opt/semaphore/add-superadmin-publish-permission.sh

    COPY docker/Studio/create-service.sh /opt/semaphore
    RUN chmod 777 /opt/semaphore/create-service.sh

    COPY docker/Studio/start-studio.sh /opt/semaphore/
    RUN chmod 777 /opt/semaphore/start-studio.sh

    COPY --from=semaphore_provisioning docker/Studio/studio-authentication.properties /opt/semaphore/studio/conf/

    COPY docker/Studio/upload-license.sh /opt/semaphore
    RUN chmod 777 /opt/semaphore/upload-license.sh

# Classification Server

    COPY docker/ClassificationServer/start-cs.sh /opt/semaphore
    RUN chmod 777 /opt/semaphore/start-cs.sh

# Semantic Enhancement Server

    COPY docker/SES/start-ses.sh /opt/semaphore
    RUN chmod 777 /opt/semaphore/start-ses.sh

    COPY docker/SES/SESservice.sh /opt/semaphore/SES/bin/SESservice.sh
    RUN chmod 777 /opt/semaphore/SES/bin/SESservice.sh

    # web.xml with CORS headers enabled
    COPY docker/SES/web.xml /opt/semaphore/SES/solr/server/ses-webapp/webapp/WEB-INF/web.xml

# Concept Server

    COPY docker/ConceptServer/marklogic.properties.template /opt/semaphore/concepts/conf/
    COPY docker/ConceptServer/start-cons.sh /opt/semaphore
    RUN chmod 777 /opt/semaphore/start-cons.sh

# All services

    COPY docker/create-marklogic-database-for-semaphore.sh /opt/semaphore
    RUN chmod 777 /opt/semaphore/create-marklogic-database-for-semaphore.sh

    COPY docker/start-services.sh /opt/semaphore
    RUN chmod 777 /opt/semaphore/start-services.sh

# TAR the directories and files under /var/opt/semaphore and /etc/opt/semaphore,
# These are our external state mount points. Using the tar.gz, we can initialize bind mount filesystem locations if necessary.
RUN cd / && tar cvzf sem_var_opt_sem.tgz /var/opt/semaphore/ && tar cvzf sem_etc_opt_sem.tgz /etc/opt/semaphore/   

# set path environment variable
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/semaphore

ENV SEMAPHORE_JVM_LIB=/usr/lib/jvm/java-21-amazon-corretto/lib/server/libjvm.so

EXPOSE 5058 5059
EXPOSE 5080
EXPOSE 5081
EXPOSE 5092
EXPOSE 8983 9983

VOLUME ["/var/opt/semaphore"]
VOLUME ["/etc/opt/semaphore"]

ENTRYPOINT ["/opt/semaphore/start-services.sh"]
