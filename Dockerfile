# Base image
FROM fssc/fermibottle

# Set the working directory inside the container
WORKDIR /fermihips

# Use root to install packages and copy files
USER root

# Install Java 17
RUN yum install -y java-17-openjdk java-17-openjdk-devel && \
    yum clean all
# RUN yum install -y java-17-openjdk java-17-openjdk-devel \
#     python3 python3-pip && \
#     yum clean all

# Set JAVA_HOME and update PATH
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH="$JAVA_HOME/bin:$PATH"

# Create user 'fermi' with UID 9001 and home dir
# RUN useradd --no-create-home -u 9001 fermi

# Required for conda activation
# SHELL ["/bin/bash", "-c"]

# Upgrade reproject in 'fermi' env
# RUN source /opt/anaconda/etc/profile.d/conda.sh && \
#     conda activate fermi && \
#     pip install --upgrade reproject

# Copy scripts and tools into the image
COPY scripts/run_all.sh .
COPY scripts/run_one_band.sh .
COPY scripts/download_latest_diffuse.sh .
COPY scripts/fermiTools_step.sh .
COPY scripts/create_healpix.py .
# COPY scripts/convert_hpx2wcs.py .
COPY scripts/Hipsgen.jar .
COPY scripts/run_hipsgen.sh .
COPY scripts/run_hipsgen_concat.sh .

# Create newdata and working directories
RUN mkdir -p /fermihips/newdata
RUN mkdir -p /fermihips/working

# Ensure scripts are executable
# RUN chmod +x *.sh 
RUN chmod +x *.sh && \
    chown -R 9001:9001 /fermihips
    

# Use bash shell that activates conda env directly
SHELL ["/bin/bash", "-c"]

CMD ["bash", "-c", "source /opt/anaconda/etc/profile.d/conda.sh && conda activate fermi && exec bash"]
