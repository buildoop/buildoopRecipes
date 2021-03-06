#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

usage() {
  echo "
usage: $0 <options>
  Required not-so-options:
     --build-dir=DIR             path to Whirr dist.dir
     --prefix=PREFIX             path to install into

  Optional options:
     --doc-dir=DIR               path to install docs into [/usr/share/doc/whirr]
     --lib-dir=DIR               path to install Whirr home [/usr/lib/whirr]
  "
  exit 1
}

OPTS=$(getopt \
  -n $0 \
  -o '' \
  -l 'prefix:' \
  -l 'doc-dir:' \
  -l 'lib-dir:' \
  -l 'build-dir:' -- "$@")

if [ $? != 0 ] ; then
    usage
fi

eval set -- "$OPTS"
while true ; do
    case "$1" in
        --prefix)
        PREFIX=$2 ; shift 2
        ;;
        --build-dir)
        BUILD_DIR=$2 ; shift 2
        ;;
        --doc-dir)
        DOC_DIR=$2 ; shift 2
        ;;
        --lib-dir)
        LIB_DIR=$2 ; shift 2
        ;;
        --)
        shift ; break
        ;;
        *)
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
done

for var in PREFIX BUILD_DIR ; do
  if [ -z "$(eval "echo \$$var")" ]; then
    echo Missing param: $var
    usage
  fi
done

TARGET_RELEASE=target/releases/elasticsearch-1.7.2.tar.gz
SHARE_DIR=${SHARE_DIR:-/usr/share/elasticsearch}
SRC=${BUILD_DIR}/working/elasticsearch-1.7.2

mkdir ${BUILD_DIR}/working
tar xzf ${BUILD_DIR}/${TARGET_RELEASE} -C ${BUILD_DIR}/working

mkdir -p ${PREFIX}/${SHARE_DIR}

mkdir -p ${PREFIX}/${SHARE_DIR}/bin
install -p -m 755 ${SRC}/bin/elasticsearch ${PREFIX}/${SHARE_DIR}/bin
install -p -m 644 ${SRC}/bin/elasticsearch.in.sh ${PREFIX}/${SHARE_DIR}/bin
install -p -m 755 ${SRC}/bin/plugin ${PREFIX}/${SHARE_DIR}/bin

#libs
mkdir -p ${PREFIX}/${SHARE_DIR}/lib/sigar
install -p -m 644 ${SRC}/lib/*.jar ${PREFIX}/${SHARE_DIR}/lib
install -p -m 644 ${SRC}/lib/sigar/*.jar ${PREFIX}/${SHARE_DIR}/lib/sigar
install -p -m 644 ${SRC}/lib/sigar/libsigar-amd64-linux.so ${PREFIX}/${SHARE_DIR}/lib/sigar

# config
mkdir -p ${PREFIX}/etc/elasticsearch
install -m 644 ${SRC}/config/elasticsearch.yml ${PREFIX}/etc/elasticsearch/
install -m 644 ${SRC}/config/logging.yml ${PREFIX}/etc/elasticsearch/

# data
mkdir -p ${PREFIX}/lib/elasticsearch
mkdir -p ${PREFIX}/${SHARE_DIR}/plugins

# logs
mkdir -p ${PREFIX}/var/log/elasticsearch
mkdir -p ${PREFIX}/etc/logrotate.d/
install -m 644 ${RPM_SOURCE_DIR}/elasticsearch.logrotate ${PREFIX}/etc/logrotate.d/elasticsearch

# sysconfig and init
mkdir -p ${PREFIX}/etc/rc.d/init.d
mkdir -p ${PREFIX}/etc/sysconfig
install -m 755 ${RPM_SOURCE_DIR}/elasticsearch.init ${PREFIX}/etc/rc.d/init.d/elasticsearch
install -m 755 ${RPM_SOURCE_DIR}/elasticsearch.sysconfig ${PREFIX}/etc/sysconfig/elasticsearch

mkdir -p ${PREFIX}/var/run/elasticsearch
mkdir -p ${PREFIX}/var/lib/elasticsearch
mkdir -p ${PREFIX}/lock/subsys/elasticsearch


