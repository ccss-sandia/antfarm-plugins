module Antfarm
  module Plugin
    module Cisco
      class ParseInterfaces
        include Antfarm::Plugin

        def initialize
          super({ :name   => 'Parse Interfaces',
                  :desc   => 'Parse Cisco IOS configuration file, looking for IP interfaces',
                  :author => 'Bryan T. Richardson <btricha>' },
                [ { :name     => :input_file,
                    :desc     => 'Cisco IOS config file',
                    :type     => String,
                    :required => true }
                ])
        end

        def run(options)
          begin
            puts options[:input_file]

            pix_version_regexp   = Regexp.new('^PIX Version ((\d+)\.(\d+)\((\d+)\))')
            hostname_regexp      = Regexp.new('^hostname (\S+)')
            iface_regexp         = Regexp.new('^interface')
            ipv4_regexp          = Regexp.new('((\d){1,3}\.(\d){1,3}\.(\d){1,3}\.(\d){1,3})')
            ip_addr_regexp       = Regexp.new('^ip address (\S+) %s %s' % [ipv4_regexp, ipv4_regexp])
            iface_ip_addr_regexp = Regexp.new('^\s*ip address %s %s' % [ipv4_regexp, ipv4_regexp])

            pix_version   = nil
            hostname      = nil
            iface_ips     = Array.new
            capture_iface = false

            File.open(options[:input_file]) do |file|
              file.each do |line|
                # Get PIX IOS version
                unless pix_version
                  if version = pix_version_regexp.match(line)
                    pix_version = version[2].to_i
                  end
                end

                # Get hostname
                unless hostname
                  if name = hostname_regexp.match(line)
                    hostname = name[1]
                  end
                end
                
                # Get interface IP addresses
                if pix_version == 6
                  if ip_addr = ip_addr_regexp.match(line)
                    iface_ips << "#{ip_addr[2]}/#{ip_addr[7]}"
                  end
                elsif capture_iface
                  if line.strip! == "!"
                    capture_iface = false
                  else
                    if ip_addr = iface_ip_addr_regexp.match(line)
                      iface_ips << "#{ip_addr[1]}/#{ip_addr[6]}"
                      capture_iface = false
                    end
                  end
                else
                  if iface = iface_regexp.match(line)
                    capture_iface = true
                  end
                end
              end
            end

            iface_ips.uniq!
            iface_ips.each do |address|
              ip_iface = Antfarm::Model::IpInterface.new :address => address
              ip_iface.node_name = hostname if hostname
              ip_iface.node_device_type = "Layer 3 Device"
              
              unless ip_iface.save
                ip_iface.errors.each_full do |msg|
                  puts msg
                end
              end
            end
          rescue Errno::ENOENT
            puts "The file '#{options[:input_file]}' doesn't exist"
          rescue Exception => e
            puts e
            puts e.backtrace.join("\n")
          end
        end
      end
    end
  end
end
