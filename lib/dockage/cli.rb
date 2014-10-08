require 'dockage'
require 'thor'
require 'colorize'

module Dockage
  class CLI < Thor

    def initialize(*)
      super
      Dockage.verbose_mode = options[:debug] || !!options[:verbose]
      Dockage.debug_mode   = !!options[:debug]
      Dockage.force_mode   = !!options[:force]
    end

    default_task :help
    class_option 'verbose',  type: :boolean, banner: 'Enable verbose output mode', aliases: '-v'
    class_option 'debug',  type: :boolean, banner: 'Enable debug output mode'
    class_option 'quiet',  type: :boolean, banner: 'Suppress all output', aliases: '-q'
    class_option 'force',  type: :boolean, banner: 'Run actions with force', aliases: '-f'

    desc 'status [CONTAINER]', 'Show status overall or specified container'
    def status(name = nil)
      find_container(name) if name
      puts Dockage::Docker.shell.status(name)
    end

    desc 'init', 'Create example config file'
    def init
      Dockage.create_example_config
    end

    desc 'up [CONTAINER]', 'Create and run specified [CONTAINER] or all configured containers'
    def up(name = nil)
      find_containers(name).each do |container|
        puts "Bringing up #{container.name.yellow.bold}"
        Dockage::Docker.shell.stop(container.name)
        Dockage::Docker.shell.destroy(container.name)
        Dockage::Docker.shell.pull(container.image) if container.keep_fresh
        Dockage::Docker.shell.run(container.image, container.to_hash(symbolize_keys: true))
      end
    end

    desc 'reload [CONTAINER]', 'Reload specified [CONTAINER] or all configured containers'
    def reload(name = nil)
      find_containers(name).each do |container|
        puts "Reloading #{container.name.yellow.bold}"
        Dockage::Docker.shell.stop(container.name)
        Dockage::Docker.shell.destroy(container.name)
        Dockage::Docker.shell.pull(container.image) if container.keep_fresh
        Dockage::Docker.shell.run(container.image, container.to_hash(symbolize_keys: true))
      end
    end


    desc 'provide CONTAINER', 'Run provision scripts on specified CONTAINER'
    def provide(name)
      container = find_container(name)
      Dockage.error("SSH is not configured for #{container.name.bold}") unless container.ssh
      Dockage::Docker.shell.provide(container.to_hash(symbolize_keys: true))
    end

    desc 'destroy [CONTAINER]', 'Destroy specified [CONTAINER] or all configured containers'
    def destroy(name = nil)
      find_containers(name).each do |container|
        Dockage::Docker.shell.stop(container.name)
        Dockage::Docker.shell.destroy(container.name)
      end
    end

    desc 'ssh CONTAINER', 'SSH login to CONTAINER'
    def ssh(name)
      container = find_container(name)
      Dockage.error("SSH is not configured for #{container.name.bold}") unless container.ssh
      Dockage::SSH.connect(container.ssh.to_hash(symbolize_keys: true))
    end

    desc 'shellinit', 'export DOCKER_HOST variable to current shell'
    def shellinit
      puts Dockage::Docker.shell.shellinit
    end

    desc 'version', 'dockage and docker versions'
    def version
      puts <<CMD
#{'Dockage'.bold}:
\tGem version #{Dockage::VERSION}
#{'Docker'.bold}:
\t#{Dockage::Docker.shell.version.gsub(/\n/, "\n\t")}
CMD
    end

    protected

    def find_containers(name = nil)
      if name
        Dockage.settings.containers.select { |x| x.name.to_s == name.to_s }
      else
        Dockage.settings.containers
      end
    end

    def find_container(name = nil)
      container = find_containers(name).first
      Dockage.error("There is no settings for container #{name.bold}") if !container
      container
    end
  end
end
