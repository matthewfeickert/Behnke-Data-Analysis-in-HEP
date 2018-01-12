# Closely following the Dockerfile from cernphsft/rootbinder
# c.f. https://github.com/cernphsft/rootbinder/blob/master/Dockerfile

FROM jupyter/scipy-notebook:cf6258237ff9

MAINTAINER Matthew Feickert <matthew.feickert@cern.ch>

# set up a user whose uid is 1000
ENV NB_USER scientist
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

USER root
RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# Make sure the contents of the repo are in ${HOME}
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

# Install a recent version of Jupyter Notebook
RUN pip install --no-cache-dir notebook==5.*

# Install ROOT prerequisites
RUN apt-get update
RUN apt-get install -y \
    libx11-6 \
    libxext6 \
    libxft2 \
    libxpm4

# Install ROOT additional libraries
RUN apt-get install -y \
    r-base \
    r-base-dev

# Install R packages
RUN R -e "install.packages(c('Rcpp','RInside'), repos = \"http://cran.case.edu\")"

# Download and install ROOT master
WORKDIR /opt
RUN wget http://root.cern.ch/notebooks/rootbinderdata/root.tar.gz
RUN tar xzf root.tar.gz
RUN rm root.tar.gz

USER main

# Set ROOT environment
ENV ROOTSYS         "/opt/root"
ENV PATH            "$ROOTSYS/bin:$ROOTSYS/bin/bin:$PATH"
ENV LD_LIBRARY_PATH "$ROOTSYS/lib:$LD_LIBRARY_PATH"
ENV PYTHONPATH      "$ROOTSYS/lib:PYTHONPATH"

# Set ROOT environment for Fastjet
ENV LD_LIBRARY_PATH "/opt/fastjet/lib:$LD_LIBRARY_PATH"
ENV ROOT_INCLUDE_PATH "/opt/fastjet/include"

# Customize the ROOTbook
RUN pip install --upgrade pip
RUN pip install metakernel
RUN mkdir -p                                 $HOME/.ipython/kernels
RUN cp -r $ROOTSYS/etc/notebook/kernels/root $HOME/.ipython/kernels
RUN mkdir -p                                 $HOME/.ipython/profile_default/static
RUN cp -r $ROOTSYS/etc/notebook/custom       $HOME/.ipython/profile_default/static

# Install PrettyTable in Anaconda
RUN conda install -c https://conda.anaconda.org/barnybug prettytable
