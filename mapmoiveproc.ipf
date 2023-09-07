#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function mapmoviegeneration()
	wave threeDmap, livecurveZY
	variable zoff=dimoffset(threeDmap,2)
	variable zdelta=dimdelta(threeDmap,2)
	variable zsize=dimsize(threeDmap,2)
	variable i=0
	variable/g deltaZ,threedimmapZ
	dowindow/f NewMapwindow
	newmovie/f=10
	threedimmapZ=zoff
	modifygraph/Z/W=NewMapwindow offset(livecurveZY)={threedimmapZ,0}
	
	do
	threedimmapZ+=deltaZ
	modifygraph/Z/W=NewMapwindow offset(livecurveZY)={threedimmapZ,0}
	DoUpdate; Sleep/S 0.1
	dowindow/f NewMapwindow
	Addmovieframe
	i+=deltaZ/zdelta

	while(i<zsize)
	
	closemovie
End