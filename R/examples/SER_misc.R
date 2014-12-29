CalibrateRotationOnce=function(con, go=1000)
{  
  RS.eval(con, Command(gyro, "RESET"))
  Sys.sleep(1)
  print(RS.eval(con, Value(gyro)))
  
  control=list(lgo=go, rgo=-go, lt=0L, rt=0L, pps.sp=300L)
  
  r=data.frame(RS.eval(con, as.call(list(quote(DriveSafely2), control)), lazy=FALSE))
  
  deg=(r$head[2]-r$head[1])/100
  if(deg<0)
    deg=180+(180+deg)
  
  enc=((r$lpos[2]-r$lpos[1])-(r$rpos[2]-r$rpos[1]))/2
  enc_per_deg=enc/deg
  c(enc_per_deg, deg, go)
}

CalibrateRotation=function(con, go=1000)
{
  encs_per_deg=matrix(data = 0, nrow = length(go),ncol = 3, dimnames = list(c(), c("encs_per_deg", "deg", "go")))
  
  times=length(go)
  
  for(i in 1:times)  
    encs_per_deg[i,]=CalibrateRotationOnce(con, go[i])    
  encs_per_deg
}

Radian=function(degree){ degree*pi/180 }
Degree=function(radian){ radian*180/pi }

Rotate=function(con, degree, control=list(lgo=DegToPos(degree), rgo=-DegToPos(degree), lt=0L, rt=0L, pps.sp=300L, get.readings=FALSE))
{  
  data.frame(RS.eval(con, as.call(list(quote(DriveSafely2), control)), lazy=FALSE))
}

ScanSurroundings=function(con, radius=38)
{
  read=data.frame(Rotate(con, degree=370, control=list(lgo=DegToPos(360), rgo=-DegToPos(360), lt=0L, rt=0L, pps.sp=150L, get.readings=TRUE)))
  read$radian=Radian(read$head/100)
  plot(0,0, xlim=c(-100,100), ylim=c(-100,100), asp=1, col="red")
  
  x= radius*sin(seq(from=0, to=2*pi, by=0.05))
  y= radius*cos(seq(from=0, to=2*pi, by=0.05))
  lines(x,y, col="red")    
  
  x= read$inf*sin(read$radian)
  y= read$inf*cos(read$radian)  
  points(x, y, col="blue")      
  read
}

DistanceFromInfraredModel=function(con, inf_cut=38, inf_cut_up=98)
{
  path=Go(con, control=list(lt=0L, rt=0L, ldc.thr=100L, rdc.thr=100L, pps.sp=50L, get.readings=TRUE))  
  path$dist=(path$lpos+path$rpos)/2
  path=path[path$inf>inf_cut,]
  path=path[1:which(path$inf==inf_cut_up)[1],]
  
  l1=lm(path$dist ~ path$inf + I(path$inf^2)+I(path$inf^3), data=path)
  l1  
}

Go=function(con, control=list(inf.up=70L, inf.down=35L, lt=0L, rt=0L, inf.var.thr=2L, ldc.thr=50L, rdc.thr=50L, pps.sp=300L, get.readings=FALSE))
{  
  data.frame(RS.eval(con, as.call(list(quote(DriveSafely2), control)), lazy=FALSE))
}


