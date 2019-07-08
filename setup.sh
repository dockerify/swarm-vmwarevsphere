#!/usr/bin/env bash

set -ex

function setup_swarm() {
  docker-machine create manager1 \
      --vmwarevsphere-vcenter "${VMWAREVSPHERE_VCENTER}" \
      --vmwarevsphere-datastore "${VMWAREVSPHERE_DATASTORE}" \
      --vmwarevsphere-username "${VMWAREVSPHERE_USERNAME}" \
      --vmwarevsphere-password "${VMWAREVSPHERE_PASSWORD}" \
      --driver "${MACHINE_DRIVER}" || true

  for i in {1..9}
  do
    docker-machine create worker$i \
      --vmwarevsphere-vcenter "${VMWAREVSPHERE_VCENTER}" \
      --vmwarevsphere-datastore "${VMWAREVSPHERE_DATASTORE}" \
      --vmwarevsphere-username "${VMWAREVSPHERE_USERNAME}" \
      --vmwarevsphere-password "${VMWAREVSPHERE_PASSWORD}" \
      --driver "${MACHINE_DRIVER}" || true
  done

  eval "$(docker-machine env manager1)"

  HOST_IP=$(docker-machine env manager1 | grep HOST | awk -F '//' '{print $2}' | awk -F ':' '{print $1}')
  TOKEN_MANAGER=$(docker-machine ssh manager1 docker swarm join-token manager | grep token | awk '{print $5}')
  TOKEN_WORKER=$(docker-machine ssh manager1 docker swarm join-token worker | grep token | awk '{print $5}')

  export MANAGER_IP="${HOST_IP}"
  export JOIN_TOKEN_MANAGER="${TOKEN_MANAGER}"
  export JOIN_TOKEN_WORKER="${TOKEN_WORKER}"

  docker-machine ssh manager1 docker swarm init --advertise-addr "${MANAGER_IP}" || true

  docker-machine ssh manager1 docker swarm join --token "${JOIN_TOKEN_MANAGER}" "${MANAGER_IP}":2377 || true

  for i in {1..9}
  do
    docker-machine ssh worker$i \
      docker swarm join --token "${JOIN_TOKEN_WORKER}" "${MANAGER_IP}":2377 || true
  done
}

function install_portainer() {
  docker-machine ssh manager1 \
    docker run --name=portainer -d -p 9000:9000 --privileged -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer || true
  echo "open portainer at http://${MANAGER_IP}:9000"
}

function install_visualizer() {
  docker-machine ssh manager1 \
    docker run --name=visualizer -d -p 5000:8080 -v /var/run/docker.sock:/var/run/docker.sock dockersamples/visualizer || true
  echo "open visualizer at http://${MANAGER_IP}:5000"
}

function main() {
  setup_swarm
  install_portainer
  install_visualizer
}

main
