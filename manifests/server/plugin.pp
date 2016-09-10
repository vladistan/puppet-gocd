# == Define: gocd::server::plugin
#
# Copyright 2016 Joshua M. Keyes <joshua.michael.keyes@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

define gocd::server::plugin (
  $url,
) {

  # wget from https://github.com/maestrodev/puppet-wget
  include wget

  validate_string($name)
  validate_string($url)

  $name_regex = '^[a-z0-9_-]{3,32}$'
  $name_error = "The plugin name '${name}' is not valid."


  validate_re($name, $name_regex, $name_error)

  $download_dir = '/tmp'


  $tmpzip = "${download_dir}/${name}.zip"

  wget::fetch { "s3-plugin-dl-${name}":
        source      => $url,
        destination => $tmpzip,
  }  ->
  file { $name:
    ensure => file,
    path   => "/var/lib/go-server/plugins/external/${name}.jar",
    source => $tmpzip,
    notify => Service[$::gocd::server::service_name],
  }
}
