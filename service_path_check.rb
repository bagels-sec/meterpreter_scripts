## service_path_check     #
## Written by Barry Malone# 
## twitter: @bagels_sec   #
###########################
print_line("\n")
cmd_list = ["wmic service WHERE \"NOT Pathname LIKE '%System32%'\" get PathName"]
bin_path_arr = []

def inspect_services(session,cmds,service_bin_array)
  ex_cmd = ''
  session.response_timeout=120
  cmds.each do |cmd|
    begin
      ex_cmd = session.sys.process.execute("cmd.exe /c #{cmd}", nil, {'Hidden' => true, 'Channelized' => true})
      print_status("Interesting Service Binary Paths\n")
      while(d = ex_cmd.channel.read)
        d = d.gsub("PathName","").strip()
        d = d.split("\n")
        d.each do |x|
          service_bin_array << x
          print_line("#{x}")
        end
      end
      ex_cmd.channel.close
      ex_cmd.close
    rescue ::Exception => e
      print_error("Error Running Commands #{cmd}: #{e.class} #{e}")
    end
  end
end

def check_icacls_perms(session,service_bin_array)
  print("\n")
  print_status("Checking For Writable Directories\n")
  service_bin_array.each do |i|
    format_dirname = i.gsub(".exe","").rpartition('\\').first.gsub('"',"")
    icacls_check = session.sys.process.execute("cmd.exe /c icacls \"#{format_dirname}\" ", nil, {'Hidden' => true, 'Channelized' => true})
    while(i = icacls_check.channel.read)
      print_status("#{i}")
    end
  end
end

inspect_services(client,cmd_list,bin_path_arr)
check_icacls_perms(client,bin_path_arr)
