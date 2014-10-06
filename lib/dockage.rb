require 'dockage/version'

module Dockage
  autoload :Settings, 'dockage/settings'

  class DockageError          < StandardError; end
  class DockageConfigNotFound < DockageError; end
  class ProvideError          < DockageError; end
  class InstallError          < DockageError; end
  class InvalidOptionError    < DockageError; end

  class << self
    def root
      @root ||= Dir.pwd
    end

    def config_path
      File.join(root, 'dockage.yml')
    end

    def settings
      @settings ||= Settings.new(config_path)
    end
  end
end
