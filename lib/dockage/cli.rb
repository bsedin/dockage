require 'dockage'
require 'thor'
require 'colorize'
require 'open3'

module Dockage
  class CLI < Thor

    def initialize(*)
      super
      Dockage.debug_mode = true if options[:verbose]
    end

    default_task :help
    class_option 'verbose',  type: :boolean, banner: 'Enable verbose output mode', aliases: '-v'
    class_option 'quiet',  type: :boolean, banner: 'Suppress all output', aliases: '-q'

    desc 'status [CONTAINER]', 'Show status overall or specified container'
    def status(name = nil)
      puts Dockage::Docker.status(name)
    end

    desc 'init', 'Create example config file'
    def init
      Dockage.create_example_config
    end

    desc 'up [CONTAINER]', 'Create and run specified [CONTAINER] or all configured containers'
    def up(name = nil)
      containers(name).each do |container|
        puts "Bringing up #{container.name.yellow.bold}"
        Dockage::Docker.stop(container.name) if Dockage::Docker.container_running?(container.name)
        Dockage::Docker.destroy(container.name) if Dockage::Docker.container_exists?(container.name)
        Dockage::Docker.pull(container.image)
        Dockage::Docker.run(container.image, container.to_hash(symbolize_keys: true))
      end
    end

    desc 'provide CONTAINER', 'Run provision scripts on specified CONTAINER'
    def provide(name)
      containers(name)
    end

    desc 'destroy [CONTAINER]', 'Destroy specified [CONTAINER] or all configured containers'
    def destroy(name = nil)
      containers(name).each do |container|
        Dockage::Docker.stop(container.name) if Dockage::Docker.container_running?(container.name)
        Dockage::Docker.destroy(container.name) if Dockage::Docker.container_exists?(container.name)
      end
    end

    desc 'ssh CONTAINER', 'SSH login to CONTAINER'
    def ssh(name)
      Dockage::SSH.connect(containers(name).first
                                           .ssh
                                           .to_hash(symbolize_keys: true)
                          )
    end

    desc 'shellinit', 'export DOCKER_HOST variable to current shell'
    def shellinit
      puts Dockage::Docker.shellinit
    end

    desc 'version', 'dockage and docker versions'
    def version
      puts <<CMD
#{'Dockage'.bold}:
\tGem version #{Dockage::VERSION}
#{'Docker'.bold}:
\t#{Dockage::Docker.version.gsub(/\n/, "\n\t")}
CMD
    end

    protected

    def containers(name = nil)
      if name && Dockage.settings.containers
        Dockage.settings.containers.select { |x| x.name.to_s == name.to_s }
      else
        Dockage.settings.containers
      end
    end
  end
end
