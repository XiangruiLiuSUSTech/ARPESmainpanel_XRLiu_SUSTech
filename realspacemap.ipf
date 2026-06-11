#pragma TextEncoding = "UTF-8"
#pragma igorversion=7.00
#pragma rtGlobals=1		

//update by 2026-06-11: Add the reverse order for real space map, and exchange E-k dimension;

Function makerealspacemap()
	wave dataselwave 
	wave/T datalistwave
	string/g datatype
	variable num=dimsize(datalistwave, 0)
	variable xnum, ynum
	variable i, j
	string realspacemaploadstr, realspacemapwave 
	
	prompt realspacemaploadstr "2D E-k cuts load or 4D data sheet ?", popup "2D cuts;4D data"
	doprompt "", realspacemaploadstr
	if(V_flag)
		return -1
	endif
	
	if(stringmatch(realspacemaploadstr,"4D data")==1)
		prompt realspacemapwave "Load the 4D real space map data (energy for dim0, angle for dim1, x and y for dim2 and dim3):", popup wavelist("*", ";", "DIMS:4")
		doprompt "", realspacemapwave
		if(V_flag)
			return -1
		endif
		duplicate/O $realspacemapwave, realmaptemp
	else
	prompt xnum "Enter the points along X directions:"
	prompt ynum "Enter the points along Y directions:"
	doprompt “”, xnum, ynum
	if(V_flag)
		return -1
	endif
	
	variable k=0 //load 2D E-k cuts from the datalist
	do
	string namestr=removeending(datalistwave[0],datatype)
	k+=1
	while(dataselwave[k]==0)
	
	make/O/N=(dimsize($namestr,0), dimsize($namestr,1), xnum, ynum)/D realmap
	setscale/p x, dimoffset($namestr,0), dimdelta($namestr,0), realmap
	setscale/p y, dimoffset($namestr,1), dimdelta($namestr,1), realmap
	
	for(j=0; j<ynum; j+=1)
		for(i=0; i<xnum; i+=1)
		string currstr=removeending(datalistwave[j*xnum+i], datatype)
		wave currwave=$currstr
		multithread	realmap[][][i][j]=currwave[p][q]
	endfor
	endfor
	duplicate/O realmap, realmaptemp
	
	endif
	real2Dmapgen()
	real2DmapEKgen()
	Execute "real2Dmapshow()"
End

Function real2Dmapgen()
	wave realmaptemp
	variable xsize, ysize
	xsize=dimsize(realmaptemp,2)
	ysize=dimsize(realmaptemp,3)
	
	make/O/N=(xsize, ysize) real2Dmap
	setscale/p x, dimoffset(realmaptemp,2), dimdelta(realmaptemp,2), real2Dmap
	setscale/p y, dimoffset(realmaptemp,3), dimdelta(realmaptemp,3), real2Dmap
	real2Dmap[][]=realmaptemp[dimsize(realmaptemp,0)/2][dimsize(realmaptemp,1)/2][p][q]
End

Function real2DmapEKgen()
	wave realmaptemp
	variable Esize=dimsize(realmaptemp,0)
	variable ksize=dimsize(realmaptemp,1)
	make/O/N=(Esize, ksize) EKcut
	setscale/p x, dimoffset(realmaptemp,0), dimdelta(realmaptemp,0), EKcut
	setscale/p y, dimoffset(realmaptemp,1), dimdelta(realmaptemp,1), EKcut
	EKcut[][]=realmaptemp[p][q][0][0]
End

Window real2Dmapshow() : Graph
	//wave M_colors
	variable/g real2DdE = 0.1
	duplicate/O M_colors, real2Dmapcolortab
	PauseUpdate; Silent 1		// building window...
	Display /W=(400,106,1300,706)
	AppendImage/B=realB/L=realL real2Dmap
	ModifyImage real2Dmap ctab= {*,*,real2Dmapcolortab,0}
	AppendImage/B=reciB/R=reciR EKcut
	ModifyImage EKcut ctab= {*,*,real2Dmapcolortab,0}
	ModifyGraph tick=2
	ModifyGraph mirror(realB)=1
	ModifyGraph font="Arial"
	ModifyGraph fSize=20
	ModifyGraph standoff=0
	ModifyGraph axThick=2
	ModifyGraph lblPosMode=1
	ModifyGraph tickUnit(reciR)=1,tickUnit(reciB)=1
	ModifyGraph freePos(realL)=0
	ModifyGraph freePos(realB)=0
	ModifyGraph freePos(reciR)=0
	ModifyGraph freePos(reciB)=0
	ModifyGraph axisEnab(realB)={0,0.48}
	ModifyGraph axisEnab(reciB)={0.52,1}
	Label realL "\\F'Arial'\\Z30Y"
	Label realB "\\F'Arial'\\Z30X"
	Label reciR "\\F'Arial'\\Z30\\f02k\\B//"
	Label reciB "\\F'Arial'\\Z30\\f02E-E\\BF\\M\\f00\\Z30 (eV)"
	Cursor/P/I/S=1/H=1/T=2/C=(0,0,65535) A real2Dmap 4,4;Cursor/P/I/S=1/H=2/T=2/C=(0,65535,0) B EKcut 531,517
	ShowInfo
	ControlBar 70
	Button button0,pos={12.00,7.00},size={67.00,37.00},proc=ButtonProc_realmapload,title="Load"
	Button button0,font="Times New Roman",fSize=16
	Button button1,pos={85.00,7.00},size={92.00,39.00},proc=ButtonProc_realmapXYscale,title="XYscale"
	Button button1,font="Times New Roman",fSize=20
	Button button3,pos={500.00,20.00},size={80.00,35.00},proc=ButtonProc_real2Dmap_XYreorder,title="XYreorder"
	Button button3,fSize=16

	SetVariable setvar0,pos={183.00,14.00},size={70.00,22.00},proc=SetVarProc_real2DdE,title="dE"
	SetVariable setvar0,font="Times New Roman",fSize=16
	SetVariable setvar0,limits={-inf,inf,0.1},value= real2DdE
	PopupMenu popup0,pos={285.00,14.00},size={100.00,23.00},bodyWidth=100,proc=PopMenuProc_real2Dmapcolor
	PopupMenu popup0,mode=1,value= #"\"*COLORTABLEPOPNONAMES*\""
	CheckBox check0,pos={265.00,39.00},size={65.00,23.00},proc=CheckProc_real2Dmapcolorcheck,title="Invert"
	CheckBox check0,font="Times New Roman",fSize=20,value= 0
	SetVariable setvar1,pos={332.00,38.00},size={60.00,26.00},proc=SetVarProc_real2Dmapcolorgamma,title="γ"
	SetVariable setvar1,font="Times New Roman",fSize=20
	SetVariable setvar1,limits={0,inf,0.1},value= _NUM:1
	Button button2,pos={402.00,18.00},size={87.00,39.00},proc=ButtonProc_real2Dmap_newplot,title="New2Dplot"
	Button button2,font="Times New Roman",fSize=16
	SetWindow kwTopWin,hook(maphook)=real2Dmaphook
	
EndMacro

Function ButtonProc_realmapload(ctrlName) : ButtonControl
	String ctrlName
	string realmapstr
	prompt realmapstr "Load the real map wave:", popup, wavelist("*", ";", "DIMS:4")
	doprompt "", realmapstr
	if(V_flag)
		return -1
	endif
	
	duplicate/O $realmapstr, realmaptemp
   live2Dmapplot()
End

Function ButtonProc_realmapXYscale(ctrlName) : ButtonControl
	String ctrlName
	variable xdelta, xoffset=0
	variable ydelta, yoffset=0
	wave realmaptemp
	if(waveexists(realmaptemp)==0)
		Abort "Please first load the real space map first!"
	endif

	prompt xdelta "Enter the increment of X direction:"
	prompt xoffset "Enter the offset of X direction:"
	prompt ydelta "Enter the increment of Y direction:"
	prompt yoffset "Enter the offset of Y direction:"
	doprompt "", xdelta, ydelta, xoffset, yoffset
	if(V_flag)
		return -1	
	endif
	setscale/p z, xoffset, xdelta, realmaptemp
	setscale/p t, yoffset, ydelta, realmaptemp
	
	real2Dmapgen()
	real2DmapEKgen()
	live2Dmapplot()
End

Function SetVarProc_real2DdE(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g real2DdE = varNum
End


Function live2Dmapplot()
	variable/g real2DX, real2DY, real2DE, real2DdE
	setwindow real2Dmapshow, hook(maphook)=real2Dmaphook
	wave realmaptemp
	variable Esize=dimsize(realmaptemp,0)
	variable ksize=dimsize(realmaptemp,1)
	make/O/N=(Esize, ksize) EKcut
	setscale/p x, dimoffset(realmaptemp,0), dimdelta(realmaptemp,0), EKcut
	setscale/p y, dimoffset(realmaptemp,1), dimdelta(realmaptemp,1), EKcut
	EKcut[][]=realmaptemp[p][q][real2DX][real2DY]
	
	variable xsize=dimsize(realmaptemp,2)
	variable ysize=dimsize(realmaptemp,3)
	make/O/N=(xsize, ysize) real2Dmap
	setscale/p x, dimoffset(realmaptemp,2), dimdelta(realmaptemp,2), real2Dmap
	setscale/p y, dimoffset(realmaptemp,3), dimdelta(realmaptemp,3), real2Dmap
	variable Emin=real2DE-real2DdE/2
	variable Emax=real2DE+real2DdE/2
	variable h1=min(scaletoindex(realmaptemp,Emin,0), scaletoindex(realmaptemp,Emax,0))
	variable h2=max(scaletoindex(realmaptemp,Emin,0), scaletoindex(realmaptemp,Emax,0))
	
	sumdimension/D=1/dest=newtemp realmaptemp
	real2Dmap[][]=0
	variable i
	for(i=h1; i<h2; i+=1)
		real2Dmap[][]+=newtemp[i][p][q]
	endfor
	//killwaves newtemp
End

Function real2Dmaphook(s)
	struct WMWinhookstruct &s
	variable/g real2DX, real2DY, real2DE
	variable hookresult=0
	
	switch(s.eventcode)
		case 7://cursor moved
			real2DX=pcsr(A)
			real2DY=qcsr(A)
			hookresult=1
			
			real2DE=xcsr(B)
			hookresult=1
		break
		
	endswitch
	real2Dmapgen()
	real2DmapEKgen()
	live2Dmapplot()
	return hookresult
End

Function PopMenuProc_real2Dmapcolor(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	colortab2wave $popstr
	real2Dmapcolorsetfunc()
End



Function CheckProc_real2Dmapcolorcheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	variable/g real2Dmapcolorcheck=checked
	real2Dmapcolorsetfunc()
End


Function SetVarProc_real2Dmapcolorgamma(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	variable/g real2Dmapcolorgamma=varNum
	real2Dmapcolorsetfunc()
End

Function real2Dmapcolorsetfunc()
	wave real2Dmapcolortab, M_colors, real2Dmap, EKcut
	variable/g real2Dmapcolorgamma, real2Dmapcolorcheck
	variable size
	duplicate/O M_colors, real2Dmapcolortab
	size=dimsize(real2Dmapcolortab,0)
	real2Dmapcolortab[][]=M_colors[size*(p/size)^real2Dmapcolorgamma][q]
	if(real2Dmapcolorcheck == 1)
      ModifyImage/Z real2Dmap ctab={*,*,real2Dmapcolortab,1}
      ModifyImage/Z EKcut ctab={*,*,real2Dmapcolortab,1}
   else
      ModifyImage/Z real2Dmap ctab={*,*,real2Dmapcolortab,0}
      ModifyImage/Z EKcut ctab={*,*,real2Dmapcolortab,0}
   endif

End

Function ButtonProc_real2Dmap_newplot(ctrlName) : ButtonControl
	String ctrlName
	wave real2Dmap, real2Dmapcolortab
	string newplotstr
	variable/g real2Dmapcolorgamma, real2Dmapcolorcheck
	
	prompt newplotstr "Enter the name for new 2D plot:"
	doprompt "", newplotstr
	if(V_flag)
		return -1
	endif
	
	duplicate/O real2Dmap, $newplotstr
	wave newplotwave=$newplotstr
	
	Display;DelayUpdate
	AppendImage newplotwave
	Label left "\\F'Arial'\\Z30Y";DelayUpdate
	Label bottom "\\F'Arial'\\Z30X";DelayUpdate
	ModifyGraph tick=2,mirror=1,fSize=16,standoff=0,font="Arial",axThick=2
	ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28,width=283.465,height={Plan,1,left,bottom}
	if(real2Dmapcolorcheck == 1)
      ModifyImage/Z $newplotstr ctab={*,*,real2Dmapcolortab,1}
   else
      ModifyImage/Z $newplotstr ctab={*,*,real2Dmapcolortab,0}
   endif
End


Function ButtonProc_real2Dmap_XYreorder(ctrlName) : ButtonControl
	String ctrlName
	wave realmap, realmaptemp
	variable xsize, ysize, i, j
	string reordermode, logtext, newmapname
	prompt reordermode "Please Choose the reorder mode for realspace map:" popup "X;Y;S-shape;E-k"
	prompt newmapname "Please enter the name for new map:"
	doprompt "", reordermode, newmapname
	
	if(V_flag)
		return -1
	endif
	duplicate/O realmaptemp, temp1
	xsize=dimsize(temp1,2)
	ysize=dimsize(temp1,3)
	if(stringmatch(reordermode,"S-shape"))
	//reshape the S-order real space scan: even data point along Y, keep unchanged; odd data pont along Y, reverse order along X
		for(i=0; i<ysize; i+=1)
			if(mod(i,2))
				multithread temp1[][][][i]=realmaptemp[p][q][xsize-1-r][i]
			else
				multithread temp1[][][][i]=realmaptemp[p][q][r][i]
			endif
		endfor
		logtext="reverse the order of realmap data for S-shaped scan\r"
	elseif(stringmatch(reordermode,"X"))
		multithread temp1[][][][]=realmaptemp[p][q][xsize-1-r][s]  //just reverse order of data along X direction
		logtext="reverse the order of realmap data along X direction\r"
	elseif(stringmatch(reordermode,"Y"))
		multithread temp1[][][][]=realmaptemp[p][q][r][ysize-1-s]	  //just reverse order of data along Y direction
		logtext="reverse the order of realmap data along Y direction\r"
		
	else
	variable Esize=dimsize(realmaptemp,0)
	variable ksize=dimsize(realmaptemp,1)
	make/O/N=(ksize,Esize,dimsize(realmaptemp,2),dimsize(realmaptemp,3)) temp1
	temp1[][][][]=realmaptemp[q][p][r][s]
	
	setscale/P x, dimoffset(realmaptemp,1), dimdelta(realmaptemp,1), temp1
	setscale/P y, dimoffset(realmaptemp,0), dimdelta(realmaptemp,0), temp1
	setscale/P z, dimoffset(realmaptemp,2), dimdelta(realmaptemp,2), temp1
	setscale/P t, dimoffset(realmaptemp,3), dimdelta(realmaptemp,3), temp1
	endif
	
	duplicate/O temp1, $newmapname
	duplicate/O $newmapname, realmaptemp
	Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
	
	real2Dmapgen()
	real2DmapEKgen()
	live2Dmapplot()
	killwaves temp1
End