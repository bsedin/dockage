module Dockage
  module Docker
    class Shell

      DOCKER_DEFAULT_HOST = 'unix:///var/run/docker.sock'

      def initialize
        @env = "export DOCKER_HOST=#{Dockage.settings[:docker_host] || DOCKER_DEFAULT_HOST}"
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
          Dockage.logger("Container #{name.bold.yellow} is not running. Nothing to do")
          return
        end
        Dockage.logger("Stopping container #{name.bold.yellow}")
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
        Dockage.logger("Bringing up #{container[:name].yellow.bold}")
        return reload(container) if should_be_reload?(container)
        if container_running?(container[:name])
          Dockage.logger("Container #{container[:name].bold} is already up. Nothing to do")
          return
        end
        return start(container[:name]) if container_exists?(container[:name])
        pull(container[:image]) if container[:keep_fresh]
        run(container[:image], container)
        provide(container) if container[:provision]
      end

      def reload(container)
        return unless dependences_satisfied?(container)
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
        "export #{@env}"
      end

      def container_running?(name)
        ps(name).any?
      end

      def container_exists?(name)
        ps(name, true).any?
      end

      def run(image, opts = {})
        command = "run" \
          "#{opts[:detach]  == false || ' -d'}" \
          "#{opts[:links]   && opts[:links].map { |link| " --link #{link}" }.join}" \
          "#{opts[:volumes] && opts[:volumes].map { |volume| " -v #{volume}" }.join}" \
          "#{opts[:ports]   && opts[:ports].map { |port| " -p #{port}" }.join}" \
          "#{opts[:env]     && opts[:env].map { |env, val| " -e '#{env}=#{val}'"}.join}" \
          "#{opts[:name]    && " --name #{opts[:name]}"}" \
          " #{image}" \
          "#{opts[:cmd]     && " #{opts[:cmd]}"}"
        invoke(command)
      end

      private

      def dependences_satisfied?(container)
        return true unless container[:links] && container[:links].any?
        active_containers = ps
        container[:links].each do |link|
          dependency_name = link.split(':').first
          next if active_containers.select { |con| con[:name] == dependency_name }.any?
          dependency_container = Dockage.settings[:containers].select { |con| con[:name] == dependency_name }.first
          unless dependency_container
            Dockage.error("#{dependency_name.bold} is required for " \
                         "#{container[:name]} but does not specified " \
                         "in config file")
          end
          up(dependency_container)
        end
      end

      def should_be_reload?(container)
        return false unless container[:links]
        containers = ps(nil, true)
        return false unless containers.select { |con| con[:name] == container[:name] }.any?
        links = container[:links].map { |link| link.split(':').first }
        dependency_containers = containers.select { |con| links.include?(con[:name]) }
        dependency_containers.each do |dep_con|
          unless dep_con[:linked_with].include?(container[:name])
            Dockage.logger("Container #{container[:name].bold} has missing links and should be reloaded")
            return true
          end
        end
        false
      end

      def invoke(cmd, opts = {})
        command = "#{@env} && docker #{cmd}"
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
