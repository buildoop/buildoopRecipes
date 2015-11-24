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

%define python_storm_version 0.9.2
%define python_storm_release 1.3.0%{?dist}

Name:    python-storm
Version: %{python_storm_version}
Release: %{python_storm_release}
Vendor: Keedio
Packager: Systems <systems@keedio.com>
Group: Applications/Engineering
Summary: Python-storm.
License: ASL 2.0
Source0: storm.git.tar.gz
Source1: install_python-storm.sh
URL: http://github.com/apache/storm

%define python_storm_dir /usr/lib64/python2.6/site-packages/

%description
Python-storm. 

%prep
%setup -q -n storm.git

%install
%__rm -rf $RPM_BUILD_ROOT
sh %{SOURCE1} \
          --build-dir=. \
          --prefix=$RPM_BUILD_ROOT

%files
%{python_storm_dir}

%clean
%__rm -rf $RPM_BUILD_ROOT
