module Dockage
  class SSH
    class << self
      SSH_OPTS = %w( StrictHostKeyChecking=no UserKnownHostsFile=/dev/null )

      def execute(opts)
        if opts[:provider]
          set_ssh_command(opts)
          opts[:provider].each do |provider|
            provider[:inline] && execute = "#{@command} #{provider[:inline]}"
            provider[:script] && execute = "cat #{provider[:script]} | #{@command}"
            execute.blue if Dockage.debug_mode
            system(execute)
          end
        end
      end

      def connect(opts)
        set_ssh_command(opts)
        @command.blue if Dockage.debug_mode
        system(@command)
        exit 0
      end

      def set_ssh_command(opts)
        raise SSHOptionsError if !opts[:login] || !opts[:host]
        return if @command
        @command = which_ssh
        @command += SSH_OPTS.map { |opt| " -o #{opt}" }.join if SSH_OPTS.any?
        @command += " -i #{opts[:identity_file]}" if opts[:identity_file]
        @command += " #{opts[:login]}@#{opts[:host]}"
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
