module WslUtils
  class Pwd < Thor
    desc "pwd", "pwd"
    def pwd 
      data=`/mnt/c/Windows/System32/reg.exe query "HKEY_CURRENT_USER\\Volatile Environment" /v USERPROFILE`
      user_profile=data.lines.select{|l| l.split[0]=="USERPROFILE"}.first.split[-1]
      pwd=`pwd`.strip
      case pwd.split("/")[1]
      when "mnt"
        drive = pwd[5].upcase
        print drive
        print ":"
        print pwd[6..-1].gsub("/","\\")
        puts
      when "home", "root"
        print user_profile
        print "\\AppData\\Local\\lxss"
        print pwd.gsub("/","\\")
        puts
      end
    end

    default_task :pwd
  end
end
