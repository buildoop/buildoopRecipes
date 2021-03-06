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
%define lib_flume /usr/lib/flume
%define flume_enrichment_interceptor_base_version 0.0.8
%define flume_enrichment_interceptor_release 1.3.0%{?dist}
%define etc_flume /etc/flume/conf

%if  %{?suse_version:1}0

# Only tested on openSUSE 11.4. le'ts update it for previous release when confirmed
%if 0%{suse_version} > 1130
%define suse_check \# Define an empty suse_check for compatibility with older sles
%endif

# SLES is more strict and check all symlinks point to valid path
# But we do point to a hadoop jar which is not there at build time
# (but would be at install time).
# Since our package build system does not handle dependencies,
# these symlink checks are deactivated
%define __os_install_post \
    %{suse_check} ; \
    /usr/lib/rpm/brp-compress ; \
    %{nil}

%define alternatives_cmd update-alternatives
%global initd_dir %{_sysconfdir}/rc.d

%else
%define alternatives_cmd alternatives
%global initd_dir %{_sysconfdir}/rc.d/init.d

%endif

Name: flume-enrichment-interceptor 
Version: %{flume_enrichment_interceptor_base_version}
Release: %{flume_enrichment_interceptor_release}
Summary: Its  a flume interceptor  to enrich event body with custom data  
URL: https://github.com/keedio/CacheableInterceptor
Vendor: Keedio
Packager: Alessio Comisso <acomisso@keedio.org>
Group: Development/Libraries
Buildroot: %{_topdir}/INSTALL/%{name}-%{version}
BuildArch: noarch
License: APL2
Source0: flume-enrichment-interceptor-skeleton.git.tar.gz
Source1: rpm-build-stage
Source2:  install_flume-enrichment-interceptor.sh 
Requires: flume

%if  0%{?mgaversion}
Requires: bsh-utils
%else
Requires: sh-utils
%endif

%description 
"This project provides an interceptor to enrich event body with custom data. The implementation consist of:

EnrichedEventBody: represents enriched event body. The enriched event will have 2 attributes: extraData and message. extraData will be fed with the custom data set in the configuration file (see below) while message will preserve the original event body string. The enriched event is then serialized to a JSON object.
EnrichmentInterceptor: implements the Flume interceptor interface. The intercept() method will add the custom data to the original event body and serialize it back as a JSON string.
JSONStringSerializer: the JSON serializer"

%prep
%setup -n flume-enrichment-interceptor-skeleton.git

%build
sh %{SOURCE1}

%install
%__rm -rf $RPM_BUILD_ROOT
sh %{SOURCE2} \
          --build-dir=. \
          --prefix=$RPM_BUILD_ROOT

%files 
%defattr(644,root,root,755)
%dir %{lib_flume}
%{lib_flume}/plugins.d

%dir %{etc_flume}
%config(noreplace) %{etc_flume}/*

