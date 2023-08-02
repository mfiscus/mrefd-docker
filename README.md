# MREFd Docker Image

This Ubuntu Linux based Docker image allows you to run [n7tae's](https://github.com/n7tae) [URFd](https://github.com/n7tae/mrefd) without having to configure any files or compile any code.

This is a currently a single-arch image and will only run on amd64 devices.

| Image Tag             | Architectures           | Base Image         | 
| :-------------------- | :-----------------------| :----------------- | 
| latest, ubuntu        | amd64                   | Ubuntu 22.04       | 

## Compatibility

mrefd-docker requires certain variables be defined in your docker run command or docker-compose.yml (recommended) so it can automate the configuration upon bootup.
```bash
CALLSIGN=your_callsign
EMAIL=your@email.com
URL=your_domain.com
XLXNUM=XLX000
```

**For for cross-mode transcoding support you must also run a separate instance of [mrefd-docker](https://github.com/kk7mnz/tcd-docker)

## Usage

Command Line:

```bash
docker run --name=mrefd -v /opt/mrefd:/config -e "CALLSIGN=M17-???" -e "EMAIL=your@email.com" -e "URL=your_domain.com" mfiscus/mrefd:latest
```

Using [Docker Compose](https://docs.docker.com/compose/) (recommended):

```yml
version: '3.8'

services:
  mrefd:
    image: mfiscus/mrefd:latest
    container_name: mrefd
    hostname: mrefd_container
    environment:
      # only set CALLHOME to true once your are certain your configuration is correct
      # make sure you backup your callinghome.php file (which should be located on the docker host in /opt/mrefd/) 
      CALLHOME: 'false' 
      CALLSIGN: 'your_callsign'
      EMAIL: 'your@email.com'
      URL: 'your_domain.com'
      PORT: '80'
      XLXNUM: 'XLX000'
      COUNTRY: 'United States'
      DESCRIPTION: 'My mrefd-docker reflector'
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
      - /opt/mrefd:/config
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

  mrefd:
    image: mfiscus/mrefd:latest
    container_name: mrefd
    hostname: mrefd_container
    depends_on:
      ambed:
        condition: service_healthy
        restart: true
    environment:
      # only set CALLHOME to true once your are certain your configuration is correct
      # make sure you backup your callinghome.php file (which should be located on the docker host in /opt/mrefd/) 
      CALLHOME: 'false' 
      CALLSIGN: 'your_callsign'
      EMAIL: 'your@email.com'
      URL: 'your_domain.com'
      PORT: '80'
      XLXNUM: 'XLX000'
      COUNTRY: 'United States'
      DESCRIPTION: 'My mrefd-docker reflector'
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
      - /opt/mrefd:/config
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
      # mrefd
      - --entrypoints.mrefd-http.address=:80/tcp
      - --entrypoints.mrefd-repnet.address=:8080/udp
      - --entrypoints.mrefd-repnet.udp.timeout=86400s
      - --entrypoints.mrefd-urfcore.address=:10001/udp
      - --entrypoints.mrefd-urfcore.udp.timeout=86400s
      - --entrypoints.mrefd-interlink.address=:10002/udp
      - --entrypoints.mrefd-interlink.udp.timeout=86400s
      - --entrypoints.mrefd-ysf.address=:42000/udp
      - --entrypoints.mrefd-ysf.udp.timeout=86400s
      - --entrypoints.mrefd-dextra.address=:30001/udp
      - --entrypoints.mrefd-dextra.udp.timeout=86400s
      - --entrypoints.mrefd-dplus.address=:20001/udp
      - --entrypoints.mrefd-dplus.udp.timeout=86400s
      - --entrypoints.mrefd-dcs.address=:30051/udp
      - --entrypoints.mrefd-dcs.udp.timeout=86400s
      - --entrypoints.mrefd-dmr.address=:8880/udp
      - --entrypoints.mrefd-dmr.udp.timeout=86400s
      - --entrypoints.mrefd-mmdvm.address=:62030/udp
      - --entrypoints.mrefd-mmdvm.udp.timeout=86400s
      - --entrypoints.mrefd-icom-terminal-1.address=:12345/udp
      - --entrypoints.mrefd-icom-terminal-1.udp.timeout=86400s
      - --entrypoints.mrefd-icom-terminal-2.address=:12346/udp
      - --entrypoints.mrefd-icom-terminal-2.udp.timeout=86400s
      - --entrypoints.mrefd-icom-dv.address=:40000/udp
      - --entrypoints.mrefd-icom-dv.udp.timeout=86400s
      - --entrypoints.mrefd-yaesu-imrs.address=:21110/udp
      - --entrypoints.mrefd-yaesu-imrs.udp.timeout=86400s
    ports:
      # traefik ports
      - 80:80/tcp # The www port
      - 8080:8080/tcp # The Web UI (enabled by --api.insecure=true)
      # mrefd ports
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

  mrefd:
    image: mfiscus/mrefd:latest
    container_name: mrefd
    hostname: mrefd_container
    depends_on:
      traefik:
        condition: service_started
      ambed:
        condition: service_healthy
        restart: true
    labels:
      - "traefik.mrefd-http.rule=HostRegexp:your_domain.com,{catchall:.*}"
      - "traefik.mrefd-http.priority=1"
      - "traefik.docker.network=docker_proxy"
      # Explicitly tell Traefik to expose this container
      - "traefik.enable=true"
      # The domain the service will respond to
      - "traefik.http.routers.mrefd-http.rule=Host(`your_domain.com`)"
      # Allow request only from the predefined entry point named "mrefd-http"
      - "traefik.http.routers.mrefd-http.entrypoints=mrefd-http"
      # Specify port mrefd http port
      - "traefik.http.services.mrefd-http.loadbalancer.server.port=80"
      # test alternate http port
      - "traefik.http.routers.mrefd-http.service=mrefd-http"
      # UDP routers
      # repnet
      - "traefik.udp.routers.mrefd-repnet.entrypoints=mrefd-repnet"
      - "traefik.udp.routers.mrefd-repnet.service=mrefd-repnet"
      - "traefik.udp.services.mrefd-repnet.loadbalancer.server.port=8080"
      # urfcore
      - "traefik.udp.routers.mrefd-urfcore.entrypoints=mrefd-urfcore"
      - "traefik.udp.routers.mrefd-urfcore.service=mrefd-urfcore"
      - "traefik.udp.services.mrefd-urfcore.loadbalancer.server.port=10001"
      # urf interlink
      - "traefik.udp.routers.mrefd-interlink.entrypoints=mrefd-interlink"
      - "traefik.udp.routers.mrefd-interlink.service=mrefd-interlink"
      - "traefik.udp.services.mrefd-interlink.loadbalancer.server.port=10002"
      # mrefd-ysf
      - "traefik.udp.routers.mrefd-ysf.entrypoints=mrefd-ysf"
      - "traefik.udp.routers.mrefd-ysf.service=mrefd-ysf"
      - "traefik.udp.services.mrefd-ysf.loadbalancer.server.port=42000"
      # mrefd-dextra
      - "traefik.udp.routers.mrefd-dextra.entrypoints=mrefd-dextra"
      - "traefik.udp.routers.mrefd-dextra.service=mrefd-dextra"
      - "traefik.udp.services.mrefd-dextra.loadbalancer.server.port=30001"
      # mrefd-dplus
      - "traefik.udp.routers.mrefd-dplus.entrypoints=mrefd-dplus"
      - "traefik.udp.routers.mrefd-dplus.service=mrefd-dplus"
      - "traefik.udp.services.mrefd-dplus.loadbalancer.server.port=20001"
      # dcs
      - "traefik.udp.routers.mrefd-dcs.entrypoints=mrefd-dcs"
      - "traefik.udp.routers.mrefd-dcs.service=mrefd-dcs"
      - "traefik.udp.services.mrefd-dcs.loadbalancer.server.port=30051"
      # dmr
      - "traefik.udp.routers.mrefd-dmr.entrypoints=mrefd-dmr"
      - "traefik.udp.routers.mrefd-dmr.service=mrefd-dmr"
      - "traefik.udp.services.mrefd-dmr.loadbalancer.server.port=8880"
      # mmdvm
      - "traefik.udp.routers.mrefd-mmdvm.entrypoints=mrefd-mmdvm"
      - "traefik.udp.routers.mrefd-mmdvm.service=mrefd-mmdvm"
      - "traefik.udp.services.mrefd-mmdvm.loadbalancer.server.port=62030"
      # icom-terminal-1
      - "traefik.udp.routers.mrefd-icom-terminal-1.entrypoints=mrefd-icom-terminal-1"
      - "traefik.udp.routers.mrefd-icom-terminal-1.service=mrefd-icom-terminal-1"
      - "traefik.udp.services.mrefd-icom-terminal-1.loadbalancer.server.port=12345"
      # icom-terminal-2
      - "traefik.udp.routers.mrefd-icom-terminal-2.entrypoints=mrefd-icom-terminal-2"
      - "traefik.udp.routers.mrefd-icom-terminal-2.service=mrefd-icom-terminal-2"
      - "traefik.udp.services.mrefd-icom-terminal-2.loadbalancer.server.port=12346"
      # icom-dv
      - "traefik.udp.routers.mrefd-icom-dv.entrypoints=mrefd-icom-dv"
      - "traefik.udp.routers.mrefd-icom-dv.service=mrefd-icom-dv"
      - "traefik.udp.services.mrefd-icom-dv.loadbalancer.server.port=40000"
      # yaesu-imrs
      - "traefik.udp.routers.mrefd-yaesu-imrs.entrypoints=mrefd-yaesu-imrs"
      - "traefik.udp.routers.mrefd-yaesu-imrs.service=mrefd-yaesu-imrs"
      - "traefik.udp.services.mrefd-yaesu-imrs.loadbalancer.server.port=21110"
    environment:
      # only set CALLHOME to true once your are certain your configuration is correct
      # make sure you backup your callinghome.php file (which should be located on the docker host in /opt/mrefd/) 
      CALLHOME: 'false' 
      CALLSIGN: 'your_callsign'
      EMAIL: 'your@email.com'
      URL: 'your_domain.com'
      PORT: '80'
      XLXNUM: 'XLX000'
      COUNTRY: 'United States'
      DESCRIPTION: 'My mrefd-docker reflector'
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
      - /opt/mrefd:/config
    restart: unless-stopped
```

## Parameters

The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side.

* `-v` - maps a local directory used for backing up state and configuration files (including callinghome.php) **required**
* `-e` - used to set environment variables in the container

## License

Copyright (C) 2020-2022 Thomas A. Early N7TAE
Copyright (C) 2023 mfiscus KK7MNZ

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the [GNU General Public License](./LICENSE) for more details.
