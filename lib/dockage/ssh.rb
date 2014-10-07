module Dockage
  class SSH
    class << self
      SSH_OPTS = %w( StrictHostKeyChecking=no UserKnownHostsFile=/dev/null )

      def connect(opts)
        fail SSHOptionsError if !opts[:login] || !opts[:host]
        command = "#{which_ssh}"
        command += ' ' + SSH_OPTS.map { |opt| "-o #{opt}" }.join(' ') if SSH_OPTS.any?
        command += " #{opts[:login]}@#{opts[:host]}"
        puts command.blue if Dockage.debug_mode
        system(command)
        exit 0
      end

      private

      def which_ssh
        Dockage.which('ssh')
      end
    end
  end
end
