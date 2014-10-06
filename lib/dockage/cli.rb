require 'dockage'
require 'thor'

module Dockage
  class CLI < Thor
    # check_unknown_options!(:except => [:config, :exec])
    # stop_on_unknown_option! :exec

    default_task :help
    # class_option "no-color", type: :boolean, banner: "Disable colorization in output"
    class_option 'verbose',  type: :boolean, banner: 'Enable verbose output mode', aliases: '-v'

    desc 'status [CONTAINER]', 'Show status overall or specified container'
    def status(container = nil)
      # puts Dockage.settings
      # Docker.status container
    end

    desc 'init', 'Create example config file'
    def init
    end

    desc 'up [CONTAINER]', 'Create and run specified [CONTAINER] or all configured containers'
    def up(container = nil)
    end

    desc 'provide CONTAINER', 'Run provision scripts on specified CONTAINER'
    def provide(container)
    end
  end
end
