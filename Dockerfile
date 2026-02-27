# Base image
FROM fssc/fermibottle:25.05.15.1.amd64

# Set the working directory inside the container
WORKDIR /fermihips

# Use root to install packages and copy files
USER root
# -----------------------------
# Update fermi conda environment
# -----------------------------
COPY environment.yml /tmp/environment.yml
RUN /bin/bash -lc "conda env update -n fermi -f /tmp/environment.yml && conda clean -afy"


# Install Java 17 <- MOVED INTO evironemnt.yml
#RUN yum install -y java-17-openjdk java-17-openjdk-devel && yum clean all
#RUN dnf -y makecache --refresh && \
#    dnf -y install java-17-openjdk java-17-openjdk-devel --setopt=timeout=120 --setopt=retries=5 && \
#    dnf clean all

# Set JAVA_HOME and update PATH
#ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV JAVA_HOME=/opt/anaconda/envs/fermi
ENV PATH="$JAVA_HOME/bin:$PATH"

# Copy scripts and tools into the image
COPY scripts/ /fermihips/

# Create newdata and working directories
RUN mkdir -p /fermihips/newdata/diffuse \
             /fermihips/newdata/spacecraft \
             /fermihips/working \
             /fermihips/hips

# Permissions
RUN chmod +x /fermihips/*.sh && chown -R 9001:9001 /fermihips

# Default command
CMD ["/fermihips/run_fermihips.sh"]
