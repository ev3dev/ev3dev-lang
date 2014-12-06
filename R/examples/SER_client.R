ip="192.168.1.10"
#ip="10.1.6.142"

# End of setup

library(RSclient)
source("../ev3_dev_tools.R") #UploadFile

# Connect to Rserve on EV3, upload the srcipt and source it
con=RS.connect(ip) 

UploadFile(con, "SER.R")
RS.eval(con, source("SER.R"))

# Now we are ready for work

RS.eval(con, FollowInfrared())

RS.eval(con, RemoteControl())


RS.close(con)
