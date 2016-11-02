require "yaml"

module WslUtils
  class Start < Thor
    desc "start", "start"
    def start(command="")
      WslUtils::Exec.new.invoke(:exec, ["powershell"], ["start #{command}"])
    end

    default_task :start
  end
end
