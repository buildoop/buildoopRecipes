#!/bin/sh

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
     --build-dir=DIR             path to dist.dir
     --prefix=PREFIX             path to install into

  Optional options:
     --lib-dir=DIR               path to install Kafka home [/usr/lib/kafka]
     --installed-lib-dir=DIR     path where lib-dir will end up on target system
     --bin-dir=DIR               path to install bins [/usr/bin]
     ... [ see source for more similar options ]
  "
  exit 1
}

OPTS=$(getopt \
  -n $0 \
  -o '' \
  -l 'prefix:' \
  -l 'lib-dir:' \
  -l 'installed-lib-dir:' \
  -l 'bin-dir:' \
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
        --lib-dir)
        LIB_DIR=$2 ; shift 2
        ;;
        --installed-lib-dir)
        INSTALLED_LIB_DIR=$2 ; shift 2
        ;;
        --bin-dir)
        BIN_DIR=$2 ; shift 2
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

LIB_DIR=${LIB_DIR:-/usr/lib/kafka}
INSTALLED_LIB_DIR=${INSTALLED_LIB_DIR:-/usr/lib/kafka}
CONF_DIR=${CONF_DIR:-/etc/kafka/conf.dist}

install -d -m 0755 $PREFIX/$LIB_DIR
install -d -m 0755 $PREFIX/$LIB_DIR/libs
install -d -m 0755 $PREFIX/$LIB_DIR/bin
install -d -m 0755 $PREFIX/var/lib/kafka

cp -ra ${BUILD_DIR}/core/build/libs/*.jar $PREFIX/$LIB_DIR/libs
cp -ra ${BUILD_DIR}/clients/build/libs/*.jar $PREFIX/$LIB_DIR/libs
cp -ra ${BUILD_DIR}/contrib/build/libs/*.jar $PREFIX/$LIB_DIR/libs
cp -ra ${BUILD_DIR}/examples/build/libs/*.jar $PREFIX/$LIB_DIR/libs
cp -ra ${BUILD_DIR}/contrib/hadoop-consumer/build/libs/*.jar $PREFIX/$LIB_DIR/libs
cp -ra ${BUILD_DIR}/contrib/hadoop-producer/build/libs/*.jar $PREFIX/$LIB_DIR/libs
cp -ra ${BUILD_DIR}/core/build/dependant-libs-2.10.4/*.jar $PREFIX/$LIB_DIR/libs
rm $PREFIX/$LIB_DIR/libs/slf4j-log4j12-1.6.1.jar
cp -ra ${BUILD_DIR}/bin/*.sh $PREFIX/$LIB_DIR/bin
ln -s /etc/kafka/conf $PREFIX/$LIB_DIR/config 

# Get slf4j-log4j12.jar to avoid StaticBindingError (KAFKA-1354)
#cd ${RPM_SOURCE_DIR}
#wget http://central.maven.org/maven2/org/slf4j/slf4j-log4j12/1.7.2/slf4j-log4j12-1.7.2.jar
#cp slf4j-log4j12-1.7.2.jar $PREFIX/$LIB_DIR/libs
#cd -

# Copy in the configuration files
install -d -m 0755 $PREFIX/$CONF_DIR
cp -a ${RPM_SOURCE_DIR}/conf.dist/* $PREFIX/$CONF_DIR
# cp -a ${BUILD_DIR}/config/* $PREFIX/$CONF_DIR
cd $PREFIX/etc/kafka
ln -s conf.dist conf

