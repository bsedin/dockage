require 'fileutils'

module Dockage
  class SSH
    class << self
      SSH_OPTS = %w( StrictHostKeyChecking=no UserKnownHostsFile=/dev/null )

      def execute(provision, opts)
        return Dockage.logger('Nothing to provide') unless provision
        set_ssh_command(opts)
        Dockage.logger("Provisioning #{ provision.map{ |k,v| "#{k.to_s.yellow}: #{v}" }.join }")
        execute = "echo #{provision[:inline]} | #{@command}" if provision[:inline]
        if provision[:script]
          Dockage.error("File #{provision[:script].bold} is not exist") unless File.exist?(provision[:script])
          execute = "cat #{provision[:script]} | #{@command}"
        end
        Dockage.verbose(execute)
        system(execute)
      end

      def connect(opts)
        set_ssh_command(opts)
        Dockage.debug(@command)
        system(@command)
        exit 0
      end

      def set_ssh_command(opts)
        raise SSHOptionsError if !opts[:login] || !opts[:host]
        return if @command
        @command = which_ssh
        @command += SSH_OPTS.map { |opt| " -o #{opt}" }.join if SSH_OPTS.any?
        @command += " -A" if opts[:forward_agent]
        @command += " #{opts[:login]}@#{opts[:host]}"
        @command += " -p #{opts[:port]}" if opts[:port]
        @command += " -q" unless Dockage.verbose_mode
        if identity_key(opts[:identity_key])
          @command += " -i #{identity_key(opts[:identity_key])[:file]}"
          #@command += " ; rm #{identity_key(opts[:identity_key])[:file]}" if identity_key(opts[:identity_key])[:temporary]
        end
      end

      private

      def identity_key(identity_string = nil)
        return unless identity_string
        if identity_string.include?("BEGIN RSA PRIVATE KEY")
          return @identity_key if @identity_key && @identity_key[:identity_string] == identity_string && File.exist?(@identity_key[:file])
          temporary_file = File.expand_path(".ssh_identity")
          File.write(temporary_file, identity_string)
          FileUtils.chmod(0600, temporary_file)
          @identity_key ||= { file: temporary_file, temporary: true, identity_string: identity_string }
        end
        @identity_key ||= { file: identity_string, temporary: false, identity_string: nil }
      end

      def which_ssh
        Dockage.which('ssh')
      end

      def which_ssh_add
        Dockage.which('ssh-add')
      end
    end
  end
end
