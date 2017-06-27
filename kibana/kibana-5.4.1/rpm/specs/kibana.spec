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

%define confdir /etc/%{name}/conf
%define kibana_name kibana
%define kibana_home /usr/lib/kibana
%define kibana_user kibana
%define kibana_user_home /var/lib/kibana
%define kibana_group kibana

%define kibana_version 5.4.1
%define kibana_release 2.0.0%{?dist}
%define debug_package %{nil}

#Deleted 4, only one version
Name:           %{kibana_name}
Version:        %{kibana_version}
Release:        %{kibana_release}
Summary:        Kibana is a web tool to visualize and represent elasticsearch data

Group:          Applications/web
License:        ASL 2.0
URL:            http://www.elasticsearch.org/overview/kibana/
Vendor:	        Keedio	
Packager:	Carlos Alvarez <calvarez@keedio.org>
Source0:        %{kibana_name}-%{kibana_version}-linux-x86_64.tar.gz

#Patch0: 	kibana-scripts-paths.patch
Source1:	install_kibana.sh
Source2:        kibana.service	
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-%(%{__id_u} -n)
BuildArch:      x86_64 

#AutoReqProv: 	no

%description
Kibana is a web tool to visualize and represent elasticsearch data

%prep
%setup -n %{kibana_name}-%{kibana_version}-linux-x86_64
#%patch0 -p1

%build

%clean
rm -rf %{buildroot}

%install
bash %{SOURCE1} \
          --prefix=$RPM_BUILD_ROOT \
	   --build-dir=$PWD

# Install init script
init_file=${RPM_BUILD_ROOT}/etc/systemd/system/kibana.service
%__cp %{SOURCE2} $init_file
chmod 644 $init_file

%pre
# create kibana group
if ! getent group kibana >/dev/null; then
  groupadd -r kibana
fi

# create kibana user
if ! getent passwd kibana >/dev/null; then
  useradd -r -g kibana -d %{kibana_user_home} -s /sbin/nologin -c "Kibana user" -M -r -g %{kibana_group} --home %{kibana_user_home} %{kibana_user}
fi

%post
systemctl enable kibana 

%preun
/sbin/service kibana stop > /dev/null
systemctl disable kibana

%postun 
if [ $1 -ge 1 ]; then
  /sbin/service kibana condrestart > /dev/null
fi
%files
%defattr(-,%{kibana_user},%{kibana_group})
%dir %attr(755, %{kibana_user},%{kibana_group}) %{kibana_home}
%{kibana_home}/*
%attr(0644,root,root) /etc/systemd/system/kibana.service 
%config(noreplace) /etc/kibana/*
%{kibana_user_home}
%attr(0755,kibana,kibana)/var/log/kibana
%changelog