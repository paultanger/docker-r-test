# Base image https://hub.docker.com/u/rocker/
FROM rocker/rstudio:4.0.2

## Install extra R packages using requirements.R
## Specify requirements as R install commands e.g.
## 
## install.packages("<myfavouritepacakge>") or
## devtools::install("SymbolixAU/googleway")

## Copy requirements.R to container directory /tmp
COPY ./DockerConfig/requirements.R /tmp/requirements.R 
## install required libs on container
RUN Rscript /tmp/requirements.R

# create an R user
ENV USER rstudio

## Copy your working files over
## The $USER defaults to `rstudio` but you can change this at runtime
COPY ./scripts /home/$USER/scripts
COPY ./data /home/$USER/data

# run analysis (outside of Rstudio.. just do it)
# COPY ./scripts/process_file.R /tmp/process_file.R
# COPY ./data /tmp/data
# CMD Rscript /tmp/process_file.R