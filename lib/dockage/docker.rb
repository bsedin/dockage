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

      def ps(args)
        invoke("ps", args)
      end

      def version
        invoke('version')
      end

      private

      def invoke(cmd, args)
        `#{env} docker #{cmd} #{args}`
      end

      def env
        if Dockage.settings.docker_host && Dockage.settings.docker_port
          "DOCKER_HOST=tcp://#{Dockage.settings.docker_host}:#{Dockage.settings.docker_port}"
        end
      end
    end
  end
end
