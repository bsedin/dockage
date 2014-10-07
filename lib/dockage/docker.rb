require 'dockage'
require 'thor'
require 'open3'

module Dockage
  class Docker
    class << self
      def images
        invoke('images')
      end

      def pull(image)
        invoke("pull #{image}", attach_std: true)
      end

      def start
        invoke('start')
      end

      def stop(container)
        invoke("stop #{container}", catch_errors: true)
      end

      def destroy(container)
        invoke("rm #{container}", catch_errors: false)
      end

      def build
        invoke('build', attach_std: true)
      end

      def ps(name = nil, all = false)
        containers = []
        container_strings = invoke("ps --no-trunc #{all ? '-a ' : ''}", attach_std: false)
                              .split(/\n/)
        headers = container_strings.shift
        spaces = column_width = 0
        keys = {}
        headers.chars.each_with_index do |char, i|
          if i == (headers.size - 1) || (char !~ /\s/ && spaces > 1)
            keys.merge!(slice_column_from_string(headers, i, column_width))
            column_width = 0
          end
          spaces = char =~ /\s/ ? spaces + 1 : 0
          column_width += 1
        end

        container_strings.each do |container_string|
          container_hash           = Hash[keys.map { |k, v| [k, container_string[v[:start]..v[:stop]].strip] }]
          container_hash[:name]    = container_hash[:names].to_s.split(',').last
          container_hash[:running] = container_hash[:status].downcase.include?('up') ? true : false
          next if name && name != container_hash[:name]
          containers << container_hash
        end
        containers
      end

      def status(name = nil)
        output = ''

        containers = Dockage.settings.containers
        containers = containers.select { |con| con.name == name } if name

        active_containers = ps(name, true)
        containers.each do |container|
          output += "#{container[:name].to_s.bold.yellow} is "
          docker_container = active_containers.select { |con| con[:name] == container.name }.first
          if docker_container
            output += docker_container[:running] ? 'running'.green : 'not running'.red
          else
            output += 'not exists'.red
          end
          output += "\n"
        end

        output
      end

      def version
        invoke('version')
      end

      def shellinit
        "export #{env}"
      end

      def container_running?(name)
        ps(name).any?
      end

      def container_exists?(name)
        ps(name, true).any?
      end

      def run(image, opts = {})
        command = 'run'

        unless opts[:detach] == false
          command += ' -d'
        end

        if opts[:links]
          opts[:links].each do |link|
            command += " --link #{link}"
          end
        end

        if opts[:volumes]
          opts[:volumes].each do |volume|
            command += " -v #{volume}"
          end
        end

        if opts[:ports]
          opts[:ports].each do |port|
            command += " -p #{port}"
          end
        end

        command += " --name #{opts[:name]}" if opts[:name]
        command += " #{image}"
        command += " /bin/sh -c '#{opts[:cmd]}'" if opts[:cmd]

        invoke(command)
      end

      private

      def invoke(cmd, opts = {})
        command = "#{env} docker #{cmd}"
        puts 'executing ' + command.blue if Dockage.debug_mode
        if opts[:attach_std]
          output = sys_exec(command, opts[:catch_errors])
        else
          output = `#{command}`
        end
        puts output if Dockage.debug_mode
        output
      end

      def env
        if Dockage.settings.docker_host
          "DOCKER_HOST=#{Dockage.settings.docker_host}"
        end
      end

      def sys_exec(cmd, catch_errors = true)
        Open3.popen3(cmd.to_s) do |stdin, stdout, stderr|
          @in, @out, @err = stdin, stdout.gets, stderr.gets
          @in.close
          puts "\t#{@out.strip}" if @out && !@out.empty?
          if @err && !@err.strip.empty?
            puts 'Error:'
            puts "\t#{@err.strip.red}"
            @ruined = true
          end
        end
        exit 1 if catch_errors && @ruined
      end

      def slice_column_from_string(string, index, column_width)
        start = index - column_width
        stop = index < string.length - 1 ? (index - 1) : -1
        header_key = string[start..stop].strip
                                        .downcase
                                        .gsub(/\s/, '_')
                                        .to_sym

        { header_key => { start: start, stop: stop } }
      end
    end
  end
end
