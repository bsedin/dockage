module Dockage
  module Docker
    class Shell

      DOCKER_DEFAULT_HOST = 'unix:///var/run/docker.sock'

      def initialize
        @env = "DOCKER_HOST=#{Dockage.settings[:docker_host] || DOCKER_DEFAULT_HOST}"
      end

      def pull(image)
        invoke("pull #{image}", attach_std: true)
      end

      def start(name)
        if container_running?(name)
          Dockage.logger("Container #{name.bold.yellow} is already running")
          return
        end
        invoke("start #{name}", catch_errors: true)
      end

      def stop(name)
        unless container_running?(name)
          Dockage.logger("Container #{name.bold.yellow} is not running")
          return
        end
        invoke("stop #{name}", catch_errors: true)
      end

      def destroy(name)
        unless container_exists?(name)
          Dockage.logger("Container #{name.bold.yellow} not found")
          return
        end
        Dockage.logger("Destroying container #{name.bold.yellow}")
        invoke("rm #{name}", catch_errors: false)
      end

      def provide(container)
        raise SSHOptionsError unless container[:ssh]
        unless container_running?(container[:name])
          Dockage.error("Container #{container[:name].bold.yellow} is not running")
        end
        container[:provision].each do |provision|
          SSH.execute(provision, container[:ssh])
        end
      end

      def build
        invoke('build', attach_std: true)
      end

      def ps(name = nil, all = false)
        ps_output = invoke("ps --no-trunc #{all && '-a '}", attach_std: false).split(/\n/)
        containers = Parse.parse_docker_ps(ps_output)
        containers.reject! { |con| con[:name] != name } if name
        containers
      end

      def up(container)
        if container_running?(container[:name])
          Dockage.logger("Container #{container[:name].bold} is already up. Nothing to do")
          return
        end
        return start(container[:name]) if container_exists?(container[:name])
        pull(container[:image]) if container[:keep_fresh]
        run(container[:image], container)
      end

      def reload(container)
        stop(container[:name]) if container_running?(container[:name])
        destroy(container[:name]) if container_exists?(container[:name])
        up(container)
      end

      def status(name = nil)
        output = ''

        containers = Dockage.settings[:containers]
        containers = containers.select { |con| con[:name] == name } if name

        active_containers = ps(name, true)
        containers.each do |container|
          output += "#{container[:name].to_s.bold.yellow} is "
          docker_container = active_containers.select { |con| con[:name] == container[:name] }.first
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
        command = "run" \
          "#{opts[:detach] == false || ' -d'}" \
          "#{opts[:links]   && opts[:links].map { |link| " --link #{link}" }.join}" \
          "#{opts[:volumes] && opts[:volumes].map { |volume| " -v #{volume}" }.join}" \
          "#{opts[:ports]   && opts[:ports].map { |port| " -p #{port}" }.join}" \
          "#{opts[:name]    && " --name #{opts[:name]}"}" \
          " #{image}" \
          "#{opts[:cmd] && " /bin/sh -c '#{opts[:cmd]}'"}"
        invoke(command)
      end

      private

      def invoke(cmd, opts = {})
        command = "#{@env} docker #{cmd}"
        Dockage.verbose(command)
        if opts[:attach_std]
          output = sys_exec(command, opts[:catch_errors])
        else
          output = `#{command}`
        end
        Dockage.debug(output)
        output
      end

      def sys_exec(cmd, catch_errors = true)
        Open3.popen3(cmd.to_s) do |stdin, stdout, stderr|
          @in, @out, @err = stdin, stdout.gets, stderr.gets
          @in.close
          Dockage.verbose(@out.strip) if @out && !@out.empty?
          if @err && !@err.strip.empty?
            puts @err.strip.red
            @ruined = true
          end
        end
        exit 1 if catch_errors && @ruined
      end
    end
  end
end
