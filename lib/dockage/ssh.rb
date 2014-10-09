module Dockage
  class SSH
    class << self
      SSH_OPTS = %w( StrictHostKeyChecking=no UserKnownHostsFile=/dev/null )

      def execute(provision, opts)
        return Dockage.logger('Nothing to provide') unless provision
        set_ssh_command(opts)
        Dockage.logger("Provisioning #{ provision.map{ |k,v| "#{k.to_s.yellow}: #{v}" }.join }")
        execute = "#{@command} #{provision[:inline]}" if provision[:inline]
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
        @command += " -i #{opts[:identity_file]}" if opts[:identity_file]
        @command += " #{opts[:login]}@#{opts[:host]}"
        @command += " -p #{opts[:port]}" if opts[:port]
        @command += " -q" unless Dockage.verbose_mode
      end

      private

      def which_ssh
        Dockage.which('ssh')
      end

      def which_ssh_add
        Dockage.which('ssh-add')
      end
    end
  end
end
