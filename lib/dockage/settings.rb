require 'yaml'

module Dockage
  class Settings
    class << self
      def load(config_path = 'dockage.yml')
        raise DockageConfigNotFound unless File.exist? config_path
        deep_symbolize_keys(YAML.load_file(config_path))
      end

      private

      def deep_symbolize_keys(object)
        case object
        when Array
          object.map{ |v| deep_symbolize_keys(v) }
        when Hash
          result = {}
          object.each { |k,v| result[k.to_sym] = deep_symbolize_keys(v) }
          result
        else
          object
        end
      end
    end
  end
end
