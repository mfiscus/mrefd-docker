# MREFd Docker Image

This Ubuntu Linux based Docker image allows you to run [n7tae's](https://github.com/n7tae) [URFd](https://github.com/n7tae/mrefd) without having to configure any files or compile any code.

This is a currently a single-arch image and will only run on amd64 devices.

| Image Tag             | Architectures           | Base Image         | 
| :-------------------- | :-----------------------| :----------------- | 
| latest, ubuntu        | amd64                   | Ubuntu 22.04       | 

## Compatibility

mrefd-docker requires certain variables be defined in your docker run command or docker-compose.yml (recommended) so it can automate the configuration upon bootup.  

```bash
CALLSIGN="M17-???"
DASHBOARDURL="https://YourDashboard.net"
EMAILADDR="you@SomeDomain.net"

```
## Usage

Command Line:  

```bash
docker run --name=mrefd -v /opt/mrefd:/config -e "CALLSIGN=M17-???" -e "DASHBOARDURL="https://YourDashboard.net" -e "EMAILADDR="you@SomeDomain.net" mfiscus/mrefd:latest
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
      TZ: 'UTC'
      EMAILADDR: 'your@email.com'
      COUNTRY: 'US'
      DASHBOARDURL: 'your_domain.com'
      PORT: '80'
      CALLSIGN: 'M17-???'
      MODULES: 'A'
      SPONSOR: 'Chandler Hams'
      MULTICLIENT: 'true'
      BOOTSTRAP: 'xlx757.openquad.net'
    volumes:
      - /opt/mrefd:/config
    restart: unless-stopped
```

Using [Docker Compose](https://docs.docker.com/compose/) with [gomrefdash](https://github.com/kc1awv/gomrefdash):

```yml
version: '3.8'

services:
  mrefd:
    image: mfiscus/mrefd:latest
    container_name: mrefd
    hostname: mrefd_container
    environment:
      TZ: 'UTC'
      EMAILADDR: 'your@email.com'
      COUNTRY: 'US'
      DASHBOARDURL: 'your_domain.com'
      PORT: '80'
      CALLSIGN: 'M17-???'
      MODULES: 'A'
      SPONSOR: 'My Ham Radio Club'
      MULTICLIENT: 'false' # must be enabled when behind proxy
      BOOTSTRAP: 'xlx757.openquad.net'
    networks:
      - proxy
    volumes:
      - /opt/mrefd:/config
    restart: unless-stopped

  gomrefdash:
    image: dbehnke/gomrefdash:latest
    container_name: gomrefdash
    hostname: gomrefdash_container
    user: 1000:1000
    volumes:
      - /opt/mrefd/mrefd.xml:/var/log/mrefd.xml
      - /opt/mrefd/mrefd.pid:/var/run/mrefd.pid
      - /opt/mrefd/callsign_country.csv:/var/callsign_country.csv
    environment:
      GOMREFDASH_HOSTPORT: ":8080"
      GOMREFDASH_IPV4: "mrefd"          # Reflector IPv4 address
      GOMREFDASH_IPV6: "NONE"  # Reflector IPv6 address (if none, use NONE)
      GOMREFDASH_REFRESH: "20"            # Page refresh in seconds
      GOMREFDASH_LASTHEARD: "20"          # Number of stations to display in Last Heard
      GOMREFDASH_EMAIL: "your@email.com" # email address to contact about the reflector
      GOMREFDASH_MREFFILE: "/var/log/mrefd.xml" # where the mrefd.xml is mounted
      GOMREFDASH_MREFPIDFILE: "/var/run/mrefd.pid" # where the mrefd.pid is mounted
      #- GOMREFDASH_SUBPATH: "/reflector" # uncomment e.g. /reflector would be http://yourhostname/reflector
      GOMREFDASH_CALLSIGNCOUNTRYFILE: "/var/callsign_country.csv" # path to callsign_country.csv file
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
