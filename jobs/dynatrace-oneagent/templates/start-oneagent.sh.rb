#!/bin/bash

RUN_DIR="/var/vcap/sys/run/dynatrace-oneagent"

checkForInstaller() {
    local installerRetries=10

    #check if another installer is running
    while [[ $installerRetries -ge 0 ]]; do
        pgrep -f Dynatrace-OneAgent > /dev/null
        local installerFound=$?
        if [[ ! $installerFound ]]; then
            break
        elif [[ ! $installerFound ]] && [[ $installerRetries -lt 10 ]]; then
            break
        elif [[ $installerFound ]] && [[ $installerRetries -gt 0 ]]; then
            echo "Installer instance found running, waiting 30 seconds before retrying, $((installerRetries-1)) retries left"
            sleep 30
            installerRetries=$((installerRetries-1))
            continue
        elif [[ $installerFound ]] && [[ $installerRetries -lt 1 ]]; then
            echo "ERROR: Waiting for other installer to end took too long"
            exit 1
        fi

    done
}

setWatchdogPid() {
    local AGENT_WATCHDOG="oneagentwatchdog"

    echo "Setting ${AGENT_WATCHDOG} pid"
    watchdogPID=$(pgrep -f "${AGENT_WATCHDOG}")
    echo "${watchdogPID}" > "${RUN_DIR}/dynatrace-watchdog.pid"
}

checkForInstaller

/etc/init.d/oneagent start

setWatchdogPid
