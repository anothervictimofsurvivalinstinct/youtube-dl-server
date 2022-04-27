# yt-dlp-server

#### (A modified version of katznboyz original that was a modified version of [manbearwiz's youtube-dl-server](https://github.com/manbearwiz/youtube-dl-server). This project is still in the beta stages, so deploy it at your own risk.)

*This is a work in progress as I change things from the original*

![](https://i.imgur.com/oWHtkp1.png?raw=true)

## What is new in this version?

- YT-DLP instead of youtube-dl as the backend downloader
- You can now specify where to download the videos on the server you are downloading to, which helps simplifiy adding videos to media servers such as Plex or Jellyfin.
- Built in metadata tagging. The downloader will now apply the appropriate metadata to media you download (artist/author/title) so that you dont need to deal with tagging everything once its downloaded. This also helps simplify adding videos to media servers.
- All of the files are hosted locally. Previously, youtube-dl-server reached out to CDNs on the internet for web assets, however this new version has everything included locally. This means that you don't need to be reliant on external CDNs and you are in full control of your files.
- This new version has error pages. The old version had no error pages, which can lead to some user confusion in the instance of a server side error.
- /q has been renamed to /queue so that users know what page they are at, instead of being confused by what "q" means.
- A download progess page where you can view the status of pending, current, past, and failed downloads (the history page at /history). This page refreshes live, so the status of your downloads will update every 3 seconds.
- Authentication by local user accounts, so that you can restrict who is using the application and prevent unauthorized people from using your bandwidth to download videos.
- Specific error messages and better error handling.
- Added the ability to "subscribe" to channels/playlists, where the subscription daemon that runs in the background every x hours will download new videos in the playlist/channel. The subscriptions can be added through the /subscriptions webpage and it can be configured to run every x hours by using crontab, or another scheduling program.
- You can use proxies for downloading videos at the home page. Currently, you can add as many proxies as you want, however I haven't been able to test this feature out. This is an experimental feature.

## What is coming?

#### In the works right now:

- A few visual changes
- A docker image for Raspbian, pre-built images on docker hub

#### In the future:

- Support for downloading videos with captions (currently having issues with this, help would be appreciated).
- Support for (pleasant) mobile device viewing (currently the only mobile devices that this app works on are tablets).

## How do I set this up?

#### Required Programs (the method of installation vaires by distro):

Install the required packages with apt-get:

`sudo apt-get install ffmpeg python3 python3-pip`

Install the requrired modules with pip:

`python3 -m pip install -r requirements.txt`

#### Non-Docker Install Instructions:

Pre setup-warning: The user this program is running under should have r/w access to **EVERY** directory that is being referenced. That means the current directory you are installing in, and any external server download directories you are downloading to.

1. Run `setup.py` with Python>=3.6 (below 3.6 isn't tested yet). Make sure to use a strong password for your admin account, to ensure that nobody can log on without your permission.
2. Once you have ran the setup program, without an error, run the Flask application by running `gunicorn3 --workers 4 --threads 4 --bind 0.0.0.0:8080 wsgi:app`. You can change the host to `127.0.0.1` if you only want the application to work on your computer, but running it as `0.0.0.0` allows others to access the app. You can also change the port from `8080` to something else; `8080` is just the default (warning: port `80` may already be taken by your Apache installation).

#### Docker Install Instructions: 

1. `docker build -t victim/youtube-dl-server:latest .`
2. ```
    docker run -d -p 8080:8080 \
    --name=ytdlpserv \
    -v /path/to/downloaded/vids:/app/downloads \
    -v /path/to/database:/app/db \
    -e APPNAME=YDS \
    -e ADMINUSER=admin \
    -e PASSWORD=youtube \
    -e TZ=Australia/Melbourne \
    victim/youtube-dl-server:latest
    ```

*For raspbian you can build specifying the armhf Dockerfile*:
`docker build -f Dockerfile.armhf -t victim/youtube-dl-server:latest .`

The environment variables are:  
* APPNAME - the name you want the application to have (default: YDS)
* ADMINUSER - the name of the admin user (default: admin)
* PASSWORD - the password for the admin user (default: youtube)
* TZ - for the timezone. Not actually sure if this is going to work.

And the volumes are:  
\# Where downloaded videos should go  
`- /opt/youtubedownloads:/app/downloads`  
\# Where the database is  
`- /opt/database:/app/db`

The docker image exposes port 8080 for the webserver.

#### Docker-Compose install: ####

1. Change necessaries in the docker-compose file such as storage location, ports and passwords
2. build image to use locally: `docker build -t victim/youtube-dl-server:latest .`
3. docker-compose up -d 

### Updating within the Docker container ###

things break with youtube downloads so yt-dlp occassionally needs to be updated which you can do like so:

1. Exec into the running container: `docker exec -it *container_name_you_used* /bin/bash`
2. then update the python... stuff: `python3 -m pip install --upgrade -r requirements.txt`
3. You may or may not have to restart the container but it's always good to do so anyway so you don't run into issues: `docker restart *container_name_you_used*`

## Having an issue?

Leave an issue on this page as the original is being re-written in C++ and I don't do that.

## Known issues:

- Downloading certain videos with the ultra high format will lead to a missing codec error if you play it on windows.
--this isn't really an issue with yt-dlp it's an issue with windows itself - ie you need to download a compatible codec or use a video player like VLC that comes with a bunch of codecs already installed.

## Want to contribute?

There are some things that still need to be added, and if you want to help out it would be appreciated! Here is a list of some of the needed bits:

- A new favicon for the application
- Known issue fixes
- Unknown issue fixes

## Disclaimers

- I am not a network security professional. If you run this application exposed to the internet, then you run it at your own risk. Do not use common/reused passwords for this application. I am a singular person, and there may be bugs in this program. Do not allow it to fail badly by not following common sense.
- I am not in charge of how people use this application. I created this application for people to use, however the way that people may use it does not reflect on my original intentions/beliefs.
- Any damages caused by this application to any party are not the responsibility of me as the creator, and they are either the responsibility of the person hosting the app, or the user of the app.
- **READ THE LICENSE**
