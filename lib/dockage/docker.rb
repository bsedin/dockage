require 'dockage'
require 'thor'

module Dockage
  class Docker
    class << self
      def images
        invoke('images')
      end

      def start
        invoke('start')
      end

      def stop
        invoke('stop')
      end

      def build
        invoke('build')
      end

      def status
        invoke('status')
      end

      def ps
        invoke('ps')
      end

      def version
        invoke('version')
      end

      private

      def invoke(cmd)
        `#{env} docker #{cmd}`
      end

      def env
        if Dockage::Settings.docker_host && Dockage::Settings.docker_port
          "DOCKER_HOST=tcp://#{Dockage::Settings.docker_host}:#{Dockage::Settings.docker_port}"
        end
      end
    end
  end
end
