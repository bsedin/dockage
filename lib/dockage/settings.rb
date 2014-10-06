require 'hashie'

module Dockage
  class Settings < Hashie::Mash
    def initialize(config_path = 'dockage.yml')
      raise DockageConfigNotFound unless File.exist? config_path
      load_config config_path
    end

    private

    def load_config(config_file)
      Hashie::Mash.load config_file
    end
  end
end
