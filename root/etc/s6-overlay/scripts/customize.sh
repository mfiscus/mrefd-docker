#!/command/with-contenv bash

set -x

### Use environment variables to configure services

# If the first run completed successfully, we are done
if [ -e /.firstRunComplete ]; then
  exit 0

fi

# Make sure environment variables are set
if [ -z ${DASHBOARDURL:-} ]; then
  echo "DASHBOARDURL not set"
  exit 1

fi

# $1=Property
# $2=Value
function __edit_mrefd() {
    if [ ${#} -eq 2 ]; then
        local property=${1}
        local value=${2}

        sed -i "s'\(^${1}[[:blank:]]*\=[[:blank:]]*\)[[:print:]]*'\1${2}'g" ${MREFD_CONFIG_TMP_DIR}/mrefd.cfg

        return

    else
        exit 1

    fi

}

# install configuration files
if [[ -e ${MREFD_CONFIG_DIR:-} ]] && [[ -e ${MREFD_CONFIG_TMP_DIR:-} ]]; then
    __edit_mrefd "Callsign" "${CALLSIGN}"
    __edit_mrefd "Modules" "${MODULES}"
    __edit_mrefd "Port" "${PORT}"
    __edit_mrefd "PidPath" "${MREFD_CONFIG_DIR}/mrefd.pid"
    __edit_mrefd "XmlPath" "${MREFD_CONFIG_DIR}/mrefd.xml"
    __edit_mrefd "WhitelistPath" "${MREFD_CONFIG_DIR}/mrefd.whitelist"
    __edit_mrefd "BlacklistPath" "${MREFD_CONFIG_DIR}/mrefd.blacklist"
    __edit_mrefd "InterlinkPath" "${MREFD_CONFIG_DIR}/mrefd.interlink"
    __edit_mrefd "MultiClient" "${MULTICLIENT}"
    __edit_mrefd "DashboardURL" "${DASHBOARDURL}"
    __edit_mrefd "EmailAddr" "${EMAILADDR}"
    __edit_mrefd "Bootstrap" "${BOOTSTRAP}"
    __edit_mrefd "Country" "${COUNTRY}"
    __edit_mrefd "Sponsor" "${SPONSOR}"
    
    rm -f ${MREFD_CONFIG_TMP_DIR}/*d.mk # remove pre-compile configuration file
    cp -vupn ${MREFD_CONFIG_TMP_DIR}/* ${MREFD_CONFIG_DIR}/ # don't overwrite config files if they exist
    rm -rf ${MREFD_CONFIG_TMP_DIR}

fi

# set timezone
ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

touch /.firstRunComplete
echo "mrefd first run setup complete"
