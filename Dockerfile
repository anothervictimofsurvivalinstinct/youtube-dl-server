FROM alpine:3.15 AS base

# Split up these lines so Docker can cache them.
RUN apk add \
        #ffmpeg \
        #python3 \
        py3-pip \
        #s6 \
        build-base \
        libressl-dev \
        libffi-dev \
        python3-dev
        
#adding an env to keep it from complaining about where it's installed
ENV PATH="/root/.local/bin:$PATH"
RUN python3 -m pip install --user wheel flask yt-dlp flask-session gunicorn


FROM alpine:3.15

# Folder we're keeping the app in
WORKDIR /app
# Where videos download by default
VOLUME /app/downloads
# It is a very good idea to put this somewhere else
VOLUME /app/db

# To prevent tzdata ruining the build process
ENV TZ=Australia/Melbourne
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Split up these lines so Docker can cache them. Add s6 to use in the start script.
RUN apk add \
    python3 \
    ffmpeg \
    py3-setuptools \
    py3-pip \
    s6

#adding to ease in updating withing the container
COPY ./requirements.txt ./ 
#requests doesn't get moved over for some reason so adding it here
RUN python3 -m pip install --user requests
#python env path taken from the build image and used here as builders aren't needed    
COPY --from=base /root/.local /root/.local
ENV PATH="/root/.local/bin:$PATH"

# Create User that program can run as and chown the working directory. Reduces the possibility of files being written as root:root    
#ENV UNAME abc
#ENV UID 1000
#ENV GID 1000
#RUN addgroup -g $GID -o $UNAME
#RUN adduser -m -u $UID -g $GID -o -s /bin/bash $UNAME
#RUN addgroup -S abc && adduser -S abc -G abc
#RUN chown -R abc:abc /app

# Environment variables

ENV APPNAME YDS
ENV ADMINUSER admin
ENV PASSWORD youtube
# Copy the rest of the app
#COPY --chown=abc:abc . .
COPY . .

# Port 8080 is exposed, people can adjust which port forwards to this
EXPOSE 8080

# make the start script executable
RUN chmod +x ./startup.sh

# Directly referencing the variables in Bash now
ENTRYPOINT ["./startup.sh"]
