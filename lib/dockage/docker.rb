require 'open3'
require 'dockage'

module Dockage
  module Docker

    autoload :Parse,  'dockage/docker/parse'
    autoload :Shell,  'dockage/docker/shell'

    class << self
      def shell
        @shell ||= Shell.new
      end
    end

  end
end
