require 'fileutils'
require 'dockage/version'

module Dockage
  autoload :Settings, 'dockage/settings'
  autoload :Docker, 'dockage/docker'
  autoload :SSH, 'dockage/ssh'

  class DockageError          < StandardError; end
  class DockageConfigNotFound < DockageError; end
  class ProvideError          < DockageError; end
  class InstallError          < DockageError; end
  class InvalidOptionError    < DockageError; end
  class SSHOptionsError       < DockageError; end

  class << self
    attr_accessor :debug_mode

    def root
      @root ||= Dir.pwd
    end

    def config_path
      File.join(root, 'dockage.yml')
    end

    def settings
      @settings ||= Settings.load(config_path)
    end

    def create_example_config
      return puts 'docker.yml already exists' if File.exist? config_path
      FileUtils.cp File.expand_path('../dockage/templates/dockage.yml', __FILE__), config_path
      puts 'Created example config dockage.yml'
    end

    def which(executable)
      if File.file?(executable) && File.executable?(executable)
        executable
      elsif ENV['PATH']
        path = ENV['PATH'].split(File::PATH_SEPARATOR).find do |p|
          File.executable?(File.join(p, executable))
        end
        path && File.expand_path(executable, path)
      end
    end
  end
end
