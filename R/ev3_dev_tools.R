#   Simple tools to:
#   -start Rserve via ssh
#   -upload file via scp
#   -run command via ssh 
#
#   Prerequsities: 
#   -R and Rserve installed on EV3
#   -remote connections enabled for Rserve on EV3
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