require 'hashie'

module Dockage
  class Settings

    class << self
      def load(config_path = 'dockage.yml')
        raise DockageConfigNotFound unless File.exist? config_path
        Hashie::Mash.load config_path
      end
    end

  end
end
