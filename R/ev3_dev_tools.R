#   Simple tools to:
#   -start Rserve via ssh
#   -upload file via scp
#   -run command via ssh 
#
#   Prerequsities: 
#   -R and Rserve installed on EV3
#   -remote connections enabled for Rserve on EV3
#   -ssh client installed on PC and in the system path (e.g. www.openssh.org/ for Windows)
#   -ssh keys for user of PC stored on EV3, same PC/EV3 user (doesn't ask for password)
#   -ssh connected at least once from command line (so machine trusted)
#
#   Copyright (c) 2014 - Bartosz Meglicki
# 
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#  
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

startRemoteRserve=function(host)
{
  cmd=paste("ssh -n -f", host, "nohup R CMD Rserve --no-save > /dev/null 2>&1 &")
  system(cmd)
}

upload=function(local_path, scp_path)
{
  command=paste("scp", local_path, scp_path )
  system(command)  
}

run=function(host, command)
{
  cmd=paste("ssh", host, command)
  system(cmd, intern=TRUE)  
}

prepare_ev3=function(ip, ev3_home_path, script_file, connection_retries=20)
{
  library(RSclient)  
  try(run(ip, "mkdir ~/R")) #may warn if directory already exists  
      
  print("Starting Rserve on EV3. Be patient.")
  startRemoteRserve(ip)
  Sys.sleep(3)
  
  con=NULL
  
  for(i in 1:connection_retries)
  {
    con=try(RS.connect(ip)) # will fail if: remote Rserve connections are disabled on EV3 (default!), or server not started yet
    if(is(con, "RserveConnection"))
      break    
    else
      print(paste(i, ": waiting for Rserve to start on EV3"))
    
    Sys.sleep(5) 
  }
    
  if(is(con, "RserveConnection"))
    print("Connected to Rserve on EV3")      
  else  
    stop("Unable to connect to EV3 Rserve.\nIs it installed? Are remote connections enabled?")
  
  scp_path=paste(ip, ":~/R/", sep="")
  print("Uploading ev3dev.R to EV3")
  upload(paste(ev3_home_path, "ev3dev.R", sep=""), scp_path)  
  print("Evaluating ev3dev.R on EV3")          
  RS.eval( con, quote(source("~/R/ev3dev.R") ))
  
  #Eval the script
  
  print(paste("Uploading", script_file, "to EV3"))
  upload(script_file, scp_path)
    
  print(paste("Evaluating", script_file, "on EV3"))      
  script_path=paste("~/R/", basename(script_file), sep="")  
  RS.eval(con, as.call(list(quote(source), script_path)), lazy=FALSE)
  
  print("Ready to work")
  con    
}