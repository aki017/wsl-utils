require "yaml"

module WslUtils
  class Exec < Thor
    desc "exec", "exec"
    def exec(command="", *args)
      paths = get_paths
      paths.each do |path|
        c = Dir.foreach(path).select{|fn|
          fn.downcase==command.downcase \
          || fn.downcase==command.downcase+".exe"
        }.first
        unless c.nil?
          Kernel.exec "#{path}/#{c}", *args
        end
      end
      $stderr.puts "win: command not found: #{command}"
    end

    default_task :exec

    private
    def uptime
      t = Time.now - IO.read('/proc/uptime').split[0].to_i
      t.sec % 2 ? t : t-1
    end

    # def cache_path
      # "/tmp/wslutils-#{uptime.to_i}"
    # end

    REG_KEY=[
      'HKEY_CURRENT_USER\Environment',
      'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
    ].freeze
    def get_paths
      # return YAML.load_file(cache_path) if File.exists?(cache_path)
      paths = REG_KEY.flat_map do |key|
        data = `/mnt/c/Windows/System32/reg.exe query '#{key}' /v Path`
        targets = data.lines[2].split[2].split(";")
        targets.map do |p|
          "/mnt/"+p.gsub("\\","/").sub(/.:/){|r| r[0].downcase}
        end
      end

      paths.map! do |path|
        begin
          path.split("/")[1..-1].inject("/") do |result, dir|
            File.join result, Dir.foreach(result).select{|d| d.downcase == dir.downcase}.first
          end
        rescue
        end
      end
      paths.compact!
      # File.write cache_path, YAML.dump(paths)
      paths
    end
  end
end
