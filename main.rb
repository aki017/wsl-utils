require "thor"
Dir.glob(File.expand_path("../command/*", __FILE__)).each do |path|
  require path
end

module WslUtils
  class Core < Thor
    commands = []
    ObjectSpace.each_object(Class) do |k|
      commands << k if k.to_s.start_with?("WslUtils") && k != self
    end

    commands.each do |klass|
      command = klass.to_s.split("::").last.downcase
      desc command, command
      subcommand command, klass
    end

    desc "default command", "", :hide => true
    def help_or_exec(*args)
      if args.size == 0
        help
      else
        exec *args
      end
    end

    default_task :help_or_exec
  end
end

WslUtils::Core.start(ARGV, :invoked_via_subcommand => true)
