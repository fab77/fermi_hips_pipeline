# Base image
FROM fssc/fermibottle:25.05.13.1.arm64

# Set the working directory inside the container
WORKDIR /fermihips

# Use root to install packages and copy files
USER root


# COPY environment.yml .
# RUN /bin/bash -c "source /opt/anaconda/etc/profile.d/conda.sh && \
#     conda activate fermi && \
#     conda env update -n fermi -f environment.yml"
# -----------------------------
# Update fermi conda environment
# -----------------------------
COPY environment.yml /tmp/environment.yml

RUN /bin/bash -lc "conda env update -n fermi -f /tmp/environment.yml && conda clean -afy"


# Install Java 17
RUN yum install -y java-17-openjdk java-17-openjdk-devel && \
    yum clean all

# Set JAVA_HOME and update PATH
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH="$JAVA_HOME/bin:$PATH"

# Copy scripts and tools into the image
COPY scripts/run_fermihips.sh .
COPY scripts/fermiTools_step.sh .
COPY scripts/create_healpix.py .
COPY scripts/Hipsgen.jar .
COPY scripts/run_hipsgen.sh .
COPY scripts/run_hipsgen_concat.sh .

RUN chmod +x /fermihips/*.sh

# Create newdata and working directories
RUN mkdir -p /fermihips/newdata/diffuse
RUN mkdir -p /fermihips/newdata/spacecraft
RUN mkdir -p /fermihips/working
RUN mkdir -p /fermihips/hips

# Ensure scripts are executable
# RUN chmod +x *.sh 
RUN chmod +x *.sh && \
    chown -R 9001:9001 /fermihips
    

# Use bash shell that activates conda env directly
# SHELL ["/bin/bash", "-c"]
# ENV PATH="/opt/anaconda/envs/fermi/bin:$PATH"

# ENTRYPOINT ["/bin/bash", "-c", "source /opt/anaconda/etc/profile.d/conda.sh && conda activate fermi && cd /fermihips && exec \"$@\"", "--"]
# ENTRYPOINT ["/fermihips/run_fermihips.sh"]
# WORKDIR /fermihips
# CMD ["bash"]
CMD ["/fermihips/run_fermihips.sh"]