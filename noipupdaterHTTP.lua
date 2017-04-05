--FloVid IoT
--Script para actualizar de manera automática la IP pública de una cuenta de no-ip, usando whatismyipaddress.com para saber la IP pública
--www.flovid.com.mx

function wmipa() 
  http.get("http://bot.whatismyipaddress.com", nil, function(code, ip)
      if (code < 0) then
        print("HTTP whatismyipaddress request failed")
      else
        if file.open("IP.txt") then
          file.open("IP.txt", "r")
          ip_old = string.sub(file.readline(),1,-2)
          file.close()
          if ip == ip_old then
            print("No IP change, still: "..ip)
          else
            print("IP change from "..ip_old.." to: "..ip)
            file.open("IP.txt", "w")
            file.writeline(ip)
            file.close()
            noip(ip)
          end
        else
          file.open("IP.txt", "w")
          file.writeline(ip)
          file.close()
          print("Getting public IP: "..ip)
          noip(ip)
        end 
      end
  end)
end

function noip(dir)
  http.get("http://dynupdate.no-ip.com/nic/update?hostname=your.domain.something&myip="..dir, --Change domain name 
    "Host: dynupdate.no-ip.com\r\n"
    .."Authorization: Basic your_user:your_password\r\n" --user:password in base 64
    .."User-Agent: Flovid/1.0 desarrollo@flovid.com.mx\r\n" --Define who maintains the request
    .."\r\n", function(code, data)
    if (code < 0) then
      print("HTTP no-ip request failed")
    else
      print("IP "..dir.." updated on no-ip")
    end
  end) 
end

wmipa()

tmr.alarm(1, 300000, 1, function() wmipa() end) --Check every 5 minutes if you have changed the IP (3000000 ms)
