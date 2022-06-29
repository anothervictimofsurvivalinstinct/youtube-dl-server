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
        ffmpeg \
        python3 \
        py3-pip \
        s6 \
        build-base \
        libressl-dev \
        libffi-dev \
        python3-dev
        
COPY ./requirements.txt ./ 
RUN python3 -m pip install -r requirements.txt

# Create User that program can run as and chown the working directory. Reduces the possibility of files being written as root:root

ENV UNAME abc
ENV UID 1000
ENV GID 1000
#RUN addgroup -g $GID -o $UNAME
#RUN adduser -m -u $UID -g $GID -o -s /bin/bash $UNAME
RUN addgroup -S abc && adduser -S abc -G abc
#RUN chown -R abc:abc /app

# Environment variables

ENV APPNAME YDS
ENV ADMINUSER admin
ENV PASSWORD youtube
# Copy the rest of the app
COPY --chown=abc:abc . .

# RUN python3 ./setup.py --appname=${APPNAME} --username=${ADMINUSER} --password=${PASSWORD}

# Need to add in supervisord to make daemon work?

# Port 8080 is exposed, people can adjust which port forwards to this
EXPOSE 8080
# ENTRYPOINT ["gunicorn", "--workers 4", "--threads 4", "--bind 0.0.0.0:8080", "wsgi:app"]
# ENTRYPOINT ["./startup.sh", "${APPNAME}", "${ADMINUSER}", "${PASSWORD}"]
# Can't use form above as variables don't get injected.
# ENTRYPOINT exec ./startup.sh ${APPNAME} ${ADMINUSER} ${PASSWORD}

# make the start script executable
RUN chmod +x ./startup.sh

# Directly referencing the variables in Bash now
ENTRYPOINT ["./startup.sh"]

# Needed because gunicorn doesn't execute in the correct environment
# CMD ["./startup.sh"]
