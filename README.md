# ANTFARM-PLUGINS

ANTFARM (Advanced Network Toolkit For Assessments and Remote Mapping) is a
passive network mapping application that utilizes output from existing network
examination tools to populate its OSI-modeled database. This data can then be
used to form a ‘picture’ of the network being analyzed.

ANTFARM can also be described as a data fusion tool that does not directly
interact with the network. The analyst can use a variety of passive or active
data gathering techniques, the outputs of which are loaded into ANTFARM and
incorporated into the network map. Data gathering can be limited to completely
passive techniques when minimizing the risk of disrupting the operational
network is a concern.

This library provides the plugin architecture and plugins for use by the
ANTFARM-CORE library. This project should be forked by developers when they want
to add new plugins for packaging into the ANTFARM-PLUGINS gem.

More detailed information for each plugin is provided via the ANTFARM-PLUGINS
man page (`gem man antfarm-plugins`).

## HOW TO WRITE A PLUGIN

The requirements for a plugin are as follows:

* Plugin must belong to the Antfarm::Plugin namespace
* Below the Antfarm::Plugin namespace, namespacing must follow the directory
  structure of the location of the plugin
* Plugin must include the Antfarm::Plugin module
* Plugin must provide a hash that describes the plugin and an array of hashes
  that describe possible plugin options to 'super' in the constructor
** Required description options are :name, :desc, and :author
** Required parameter options are :name, :desc, :type, :default and :required
* Plugin must implement a 'run' method that accepts a single hash parameter
** The single hash parameter will contain options provided as described in the
   constructor

Here is a very simple example plugin located at 'plugins/custom/foo-bar.rb':

    module Antfarm
      module Plugin
        module Custom
          class FooBar
            include Antfarm::Plugin

            def initialize
              super( { :name => 'Foo Bar Plugin',
                       :desc => 'This plugin does nothing',
                       :author => 'Me <me@you.com>' },
                    [{ :name => :input_file,
                       :desc => 'File that has data in it',
                       :type => String,
                       :required => true },
                     { :name => :use,
                       :desc => 'To use or not to use' }
                   ])
            end

            def run(options)
              # options[:input_file] will contain a string
              # options[:use] will either be true or false, depending on whether or
              # not the user provided the flag
              
              # TODO: do something!
              # Database models can be used like so:
              #   Antfarm::Model::IpInterface.create :address => 'w.x.y.z'
            end
          end
        end
      end
    end

Note that for optional parameters, if a type is not provided it is assumed to be
a flag (true if the flag is provided, false if not). Obviously the default will
be false and it is not required.

## VERSIONING INFORMATION

This project uses the major/minor/bugfix method of versioning, similar to the
ANTFARM-CORE project. Note that the major version number for this project will
always match the major version number for the ANTFARM-CORE project. Any changes
to existing plugins or the addition of new plugins will result in the minor
version number changing.

## COPYRIGHT

Copyright (2008-2010) Sandia Corporation. Under the terms of Contract
DE-AC04-94AL85000 with Sandia Corporation, the U.S. Government retains certain
rights in this software.

This library is free software; you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation; either version 2.1 of the License, or (at your option) any
later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along
with this library; if not, write to the Free Software Foundation, Inc., 59
Temple Place, Suite 330, Boston, MA 02111-1307 USA.
