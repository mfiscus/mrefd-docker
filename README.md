# URFd Docker Image

This Ubuntu Linux based Docker image allows you to run [n7tae's](https://github.com/n7tae) [URFd](https://github.com/n7tae/urfd) without having to configure any files or compile any code.

This is a currently a single-arch image and will only run on amd64 devices.

| Image Tag             | Architectures           | Base Image         | 
| :-------------------- | :-----------------------| :----------------- | 
| latest, ubuntu        | amd64                   | Ubuntu 22.04       | 

## Compatibility

urfd-docker requires certain variables be defined in your docker run command or docker-compose.yml (recommended) so it can automate the configuration upon bootup.
```bash
CALLSIGN=your_callsign
EMAIL=your@email.com
URL=your_domain.com
XLXNUM=XLX000
```

**For for cross-mode transcoding support you must also run a separate instance of [tcd-docker](https://github.com/kk7mnz/tcd-docker)

## Usage

Command Line:

```bash
docker run --name=urfd -v /opt/urfd:/config -e "CALLSIGN=your_callsign" -e "EMAIL=your@email.com" -e "URL=your_domain.com" -e "XLXNUM=XLX000" mfiscus/urfd:latest
```

Using [Docker Compose](https://docs.docker.com/compose/) (recommended):

```yml
version: '3.8'

services:
  urfd:
    image: mfiscus/urfd:latest
    container_name: urfd
    hostname: urfd_container
    environment:
      # only set CALLHOME to true once your are certain your configuration is correct
      # make sure you backup your callinghome.php file (which should be located on the docker host in /opt/urfd/) 
      CALLHOME: 'false' 
      CALLSIGN: 'your_callsign'
      EMAIL: 'your@email.com'
      URL: 'your_domain.com'
      PORT: '80'
      XLXNUM: 'XLX000'
      COUNTRY: 'United States'
      DESCRIPTION: 'My urfd-docker reflector'
      # Define how many modules you require
      MODULES: '4'
      # Name your modules however you like (container only supports naming first 4)
      MODULEA: 'Main'
      MODULEB: 'D-Star'
      MODULEC: 'DMR'
      MODULED: 'YSF'
      TZ: 'UTC'
    networks:
      - proxy
    volumes:
      # local directory where state and config files (including callinghome.php) will be saved
      - /opt/urfd:/config
    restart: unless-stopped
```

Using [Docker Compose](https://docs.docker.com/compose/) with [ambed-docker](https://github.com/mfiscus/ambed-docker) (support for cross-mode transcoding):

```yml
version: '3.8'

services:
  ambed:
    image: mfiscus/ambed:latest
    container_name: ambed
    hostname: ambed_container
    networks:
      - proxy
    privileged: true
    restart: unless-stopped

  urfd:
    image: mfiscus/urfd:latest
    container_name: urfd
    hostname: urfd_container
    depends_on:
      ambed:
        condition: service_healthy
        restart: true
    environment:
      # only set CALLHOME to true once your are certain your configuration is correct
      # make sure you backup your callinghome.php file (which should be located on the docker host in /opt/urfd/) 
      CALLHOME: 'false' 
      CALLSIGN: 'your_callsign'
      EMAIL: 'your@email.com'
      URL: 'your_domain.com'
      PORT: '80'
      XLXNUM: 'XLX000'
      COUNTRY: 'United States'
      DESCRIPTION: 'My urfd-docker reflector'
      # Define how many modules you require
      MODULES: '4'
      # Name your modules however you like (container only supports naming first 4)
      MODULEA: 'Main'
      MODULEB: 'D-Star'
      MODULEC: 'DMR'
      MODULED: 'YSF'
      TZ: 'UTC'
    networks:
      - proxy
    volumes:
      # local directory where state and config files (including callinghome.php) will be saved
      - /opt/urfd:/config
    restart: unless-stopped
```

Using [Docker Compose](https://docs.docker.com/compose/) with [ambed-docker](https://github.com/mfiscus/ambed-docker) and [traefik](https://github.com/traefik/traefik) (reverse proxy):

```yml
version: '3.8'

services:
  traefik:
    image: traefik:latest
    container_name: "traefik"
    hostname: traefik_container
    # Enables the web UI and tells Traefik to listen to docker
    command:
      - --api.insecure=true
      - --providers.docker=true
      - --providers.docker.exposedbydefault=false
      # logging
      - --accesslog=true
      #- --log.level=DEBUG
      - --accesslog.filepath=/var/log/traefik.log
      - --accesslog.bufferingsize=100
      # create entrypoints
      - --entrypoints.www.address=:80/tcp
      - --entrypoints.traefik.address=:8080/tcp
      # urfd
      - --entrypoints.urfd-http.address=:80/tcp
      - --entrypoints.urfd-repnet.address=:8080/udp
      - --entrypoints.urfd-repnet.udp.timeout=86400s
      - --entrypoints.urfd-urfcore.address=:10001/udp
      - --entrypoints.urfd-urfcore.udp.timeout=86400s
      - --entrypoints.urfd-interlink.address=:10002/udp
      - --entrypoints.urfd-interlink.udp.timeout=86400s
      - --entrypoints.urfd-ysf.address=:42000/udp
      - --entrypoints.urfd-ysf.udp.timeout=86400s
      - --entrypoints.urfd-dextra.address=:30001/udp
      - --entrypoints.urfd-dextra.udp.timeout=86400s
      - --entrypoints.urfd-dplus.address=:20001/udp
      - --entrypoints.urfd-dplus.udp.timeout=86400s
      - --entrypoints.urfd-dcs.address=:30051/udp
      - --entrypoints.urfd-dcs.udp.timeout=86400s
      - --entrypoints.urfd-dmr.address=:8880/udp
      - --entrypoints.urfd-dmr.udp.timeout=86400s
      - --entrypoints.urfd-mmdvm.address=:62030/udp
      - --entrypoints.urfd-mmdvm.udp.timeout=86400s
      - --entrypoints.urfd-icom-terminal-1.address=:12345/udp
      - --entrypoints.urfd-icom-terminal-1.udp.timeout=86400s
      - --entrypoints.urfd-icom-terminal-2.address=:12346/udp
      - --entrypoints.urfd-icom-terminal-2.udp.timeout=86400s
      - --entrypoints.urfd-icom-dv.address=:40000/udp
      - --entrypoints.urfd-icom-dv.udp.timeout=86400s
      - --entrypoints.urfd-yaesu-imrs.address=:21110/udp
      - --entrypoints.urfd-yaesu-imrs.udp.timeout=86400s
    ports:
      # traefik ports
      - 80:80/tcp # The www port
      - 8080:8080/tcp # The Web UI (enabled by --api.insecure=true)
      # urfd ports
      - 80:80/tcp # http
      - 8080:8080/udp # repnet
      - 10001:10001/udp # urfcore
      - 10002:10002/udp # urf interlink
      - 42000:42000/udp # ysf
      - 30001:30001/udp # dextra
      - 20001:20001/udp # dplus
      - 30051:30051/udp # dcs
      - 8880:8880/udp # dmr
      - 62030:62030/udp # mmdvm
      - 12345:12345/udp # icom terminal 1
      - 12346:12346/udp # icom terminal 2
      - 40000:40000/udp # icom dv
      - 21110:21110/udp # yaesu imrs
    networks:
      - proxy
    volumes:
      # So that Traefik can listen to the Docker events
      - /var/run/docker.sock:/var/run/docker.sock:ro
    restart: unless-stopped

  ambed:
    image: mfiscus/ambed:latest
    container_name: ambed
    hostname: ambed_container
    depends_on:
      traefik:
        condition: service_started
    networks:
      - proxy
    privileged: true
    restart: unless-stopped

  urfd:
    image: mfiscus/urfd:latest
    container_name: urfd
    hostname: urfd_container
    depends_on:
      traefik:
        condition: service_started
      ambed:
        condition: service_healthy
        restart: true
    labels:
      - "traefik.urfd-http.rule=HostRegexp:your_domain.com,{catchall:.*}"
      - "traefik.urfd-http.priority=1"
      - "traefik.urfd-http=urfd-urfd-http"
      - "traefik.docker.network=docker_proxy"
      # Explicitly tell Traefik to expose this container
      - "traefik.enable=true"
      # The domain the service will respond to
      - "traefik.http.routers.urfd-http.rule=Host(`your_domain.com`)"
      # Allow request only from the predefined entry point named "urfd-http"
      - "traefik.http.routers.urfd-http.entrypoints=urfd-http"
      # Specify port urfd http port
      - "traefik.http.services.urfd-http.loadbalancer.server.port=80"
      # test alternate http port
      - "traefik.http.routers.urfd-http.service=urfd-http"
      # UDP routers
      # repnet
      - "traefik.udp.routers.urfd-repnet.entrypoints=urfd-repnet"
      - "traefik.udp.routers.urfd-repnet.service=urfd-repnet"
      - "traefik.udp.services.urfd-repnet.loadbalancer.server.port=8080"
      # urfcore
      - "traefik.udp.routers.urfd-urfcore.entrypoints=urfd-urfcore"
      - "traefik.udp.routers.urfd-urfcore.service=urfd-urfcore"
      - "traefik.udp.services.urfd-urfcore.loadbalancer.server.port=10001"
      # urf interlink
      - "traefik.udp.routers.urfd-interlink.entrypoints=urfd-interlink"
      - "traefik.udp.routers.urfd-interlink.service=urfd-interlink"
      - "traefik.udp.services.urfd-interlink.loadbalancer.server.port=10002"
      # urfd-ysf
      - "traefik.udp.routers.urfd-ysf.entrypoints=urfd-ysf"
      - "traefik.udp.routers.urfd-ysf.service=urfd-ysf"
      - "traefik.udp.services.urfd-ysf.loadbalancer.server.port=42000"
      # urfd-dextra
      - "traefik.udp.routers.urfd-dextra.entrypoints=urfd-dextra"
      - "traefik.udp.routers.urfd-dextra.service=urfd-dextra"
      - "traefik.udp.services.urfd-dextra.loadbalancer.server.port=30001"
      # urfd-dplus
      - "traefik.udp.routers.urfd-dplus.entrypoints=urfd-dplus"
      - "traefik.udp.routers.urfd-dplus.service=urfd-dplus"
      - "traefik.udp.services.urfd-dplus.loadbalancer.server.port=20001"
      # dcs
      - "traefik.udp.routers.urfd-dcs.entrypoints=urfd-dcs"
      - "traefik.udp.routers.urfd-dcs.service=urfd-dcs"
      - "traefik.udp.services.urfd-dcs.loadbalancer.server.port=30051"
      # dmr
      - "traefik.udp.routers.urfd-dmr.entrypoints=urfd-dmr"
      - "traefik.udp.routers.urfd-dmr.service=urfd-dmr"
      - "traefik.udp.services.urfd-dmr.loadbalancer.server.port=8880"
      # mmdvm
      - "traefik.udp.routers.urfd-mmdvm.entrypoints=urfd-mmdvm"
      - "traefik.udp.routers.urfd-mmdvm.service=urfd-mmdvm"
      - "traefik.udp.services.urfd-mmdvm.loadbalancer.server.port=62030"
      # icom-terminal-1
      - "traefik.udp.routers.urfd-icom-terminal-1.entrypoints=urfd-icom-terminal-1"
      - "traefik.udp.routers.urfd-icom-terminal-1.service=urfd-icom-terminal-1"
      - "traefik.udp.services.urfd-icom-terminal-1.loadbalancer.server.port=12345"
      # icom-terminal-2
      - "traefik.udp.routers.urfd-icom-terminal-2.entrypoints=urfd-icom-terminal-2"
      - "traefik.udp.routers.urfd-icom-terminal-2.service=urfd-icom-terminal-2"
      - "traefik.udp.services.urfd-icom-terminal-2.loadbalancer.server.port=12346"
      # icom-dv
      - "traefik.udp.routers.urfd-icom-dv.entrypoints=urfd-icom-dv"
      - "traefik.udp.routers.urfd-icom-dv.service=urfd-icom-dv"
      - "traefik.udp.services.urfd-icom-dv.loadbalancer.server.port=40000"
      # yaesu-imrs
      - "traefik.udp.routers.urfd-yaesu-imrs.entrypoints=urfd-yaesu-imrs"
      - "traefik.udp.routers.urfd-yaesu-imrs.service=urfd-yaesu-imrs"
      - "traefik.udp.services.urfd-yaesu-imrs.loadbalancer.server.port=21110"
    environment:
      # only set CALLHOME to true once your are certain your configuration is correct
      # make sure you backup your callinghome.php file (which should be located on the docker host in /opt/urfd/) 
      CALLHOME: 'false' 
      CALLSIGN: 'your_callsign'
      EMAIL: 'your@email.com'
      URL: 'your_domain.com'
      PORT: '80'
      XLXNUM: 'XLX000'
      COUNTRY: 'United States'
      DESCRIPTION: 'My urfd-docker reflector'
      # Define how many modules you require
      MODULES: '4'
      # Name your modules however you like (container only supports naming first 4)
      MODULEA: 'Main'
      MODULEB: 'D-Star'
      MODULEC: 'DMR'
      MODULED: 'YSF'
      TZ: 'UTC'
    networks:
      - proxy
    volumes:
      # local directory where state and config files (including callinghome.php) will be saved
      - /opt/urfd:/config
    restart: unless-stopped
```

## Parameters

The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side.

* `-v` - maps a local directory used for backing up state and configuration files (including callinghome.php) **required**
* `-e` - used to set environment variables in the container

## License

Copyright (C) 2016 Jean-Luc Deltombe LX3JL and Luc Engelmann LX1IQ 
Copyright (C) 2023 mfiscus

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the [GNU General Public License](./LICENSE) for more details.
