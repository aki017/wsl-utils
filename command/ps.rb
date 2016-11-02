require "json"

module WslUtils
  class Ps < Thor
    desc "ps OPTS", "ps"
    def ps(option="")
      filter_user=!option.chars.include?("a")
      show_all=option.chars.include?("u")
      data=`/mnt/c/Windows/System32/reg.exe query "HKEY_CURRENT_USER\\Volatile Environment" /v USERNAME`
      user=data.lines.select{|l| l.split[0]=="USERNAME"}.first.split[-1]

      json=`/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -Command 'Get-WmiObject -Class win32_process | % { $p=$_;$owner=$p.GetOwner();@{ "INFO"=$p;"USER"=$owner.User; "DOMAIN"=$owner.Domain;}; }|ConvertTo-Json' 2>/dev/null`
      doc = JSON.parse(json)
      procs = filter_user ? doc.select{|p| p["USER"]==user} : doc

      data = {}
      if show_all
        data["USER"]= ->(i){ i["USER"] }
      end
      data["PID"] = ->(i){ i["INFO"]["ProcessId"] }
      data["TTY"] = ->(i){ "" }
      if show_all
        # ExecutionState, Status is always null
        data["STAT"]= ->(i){ "" }
      end
      data["TIME"]= ->(i){ Time.at((i["INFO"]["KernelModeTime"].to_i+i["INFO"]["UserModeTime"].to_i)/10000000).getgm.strftime("%H:%M:%S") }
      data["CMD"] = ->(i){ i["INFO"]["Name"] }

      # DateTime.parse(i["CreationDate"]).strftime("%Y-%m-%d %H:%M:%S"),
      render_table data.keys, procs.map{|i| data.map{|k, v| v.call(i)} }
    end

    default_task :ps

    private
    def render_table(heading, body)
      rows = [heading, *body]
      width = []
      rows.first.size.times do |i|
        width[i] = rows.map{|row| row[i].to_s.size}.max
      end

      rows.each do |row|
        row.each_with_index do |col, index|
          print " "
          print col.to_s.rjust(width[index])
        end
        puts
      end
    end
  end
end
