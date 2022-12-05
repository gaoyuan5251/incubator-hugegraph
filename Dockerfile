#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FROM openjdk:11-slim

LABEL maintainer="HugeGraph Docker Maintainers <dev@hugegraph.apache.org>"

ENV JAVA_OPTS="-XX:+UnlockExperimentalVMOptions -XX:+UseContainerSupport -XX:MaxRAMPercentage=50 -XshowSettings:vm"

COPY . /hugegraph/hugegraph-server
WORKDIR /hugegraph/hugegraph-server

# 1. Install environment
RUN set -x \
    && apt-get -q update \
    && apt-get -q install -y --no-install-recommends --no-install-suggests \
       dumb-init \
       procps \
       curl \
       lsof \
    && apt-get clean

# 2. Init HugeGraph Sever
RUN set -e \
    && cd /hugegraph/hugegraph-server/ \
    && sed -i "s/^restserver.url.*$/restserver.url=http:\/\/0.0.0.0:8080/g" ./conf/rest-server.properties \
    && ./bin/init-store.sh

EXPOSE 8080

ENTRYPOINT [ "/usr/bin/dumb-init", "--" ]
CMD ["bin/start-hugegraph.sh"]
