#pragma TextEncoding = "UTF-8"
#pragma igorversion=7.00
#pragma rtGlobals=1		

Function makerealspacemap()
	wave dataselwave 
	wave/T datalistwave
	string/g datatype
	variable num=dimsize(datalistwave, 0)
	variable xnum, ynum
	variable i, j
	
	prompt xnum "Enter the points along X directions:"
	prompt ynum "Enter the points along Y directions:"
	doprompt “”, xnum, ynum
	if(V_flag)
		return -1
	endif
	
	variable k=0
	do
	string namestr=removeending(datalistwave[0],datatype)
	k+=1
	while(dataselwave[k]==0)
	
	make/O/N=(dimsize($namestr,0), dimsize($namestr,1), xnum, ynum)/D realmap
	setscale/p x, dimoffset($namestr,0), dimdelta($namestr,0), realmap
	setscale/p y, dimoffset($namestr,1), dimdelta($namestr,1), realmap
	
	for(i=0; i<xnum; i+=1)
		for(j=0; j<ynum; j+=1)
		string currstr=removeending(datalistwave[k-1+i*ynum+j], datatype)
		wave currwave=$currstr
			realmap[][][i][j]=currwave[p][q]
	endfor
	endfor
	
	duplicate/O realmap, realmaptemp
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
	setscale/p x, 0, dimdelta(realmaptemp,2), real2Dmap
	setscale/p y, 0, dimdelta(realmaptemp,3), real2Dmap
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

Window real2Dmapshow(): Graph
	variable/g real2DX=0, real2DY=0
	variable/g real2DdE=0.2, real2DE=0
	variable/g real2Dmapcolorcheck=0, real2Dmapcolorgamma=1
	Display/W=(400,100,1300,700) /N=real2Dmapshow
	ControlBar 70

	Button button0,pos={12.00,7.00},size={67.00,37.00},proc=ButtonProc_realmapload,title="Load"
	Button button0,font="Times New Roman",fSize=16
	Button button1,pos={85.00,7.00},size={92.00,39.00},proc=ButtonProc_realmapXYscale,title="XYscale"
	Button button1,font="Times New Roman",fSize=20
	SetVariable setvar0,pos={183.00,14.00},size={70.00,22.00},proc=SetVarProc_real2DdE,title="dE"
	SetVariable setvar0,font="Times New Roman",fSize=16
	SetVariable setvar0,limits={-inf,inf,0.1},value= real2DdE
	PopupMenu popup0,pos={265.00,14.00},size={120.00,21.00},bodyWidth=100,proc=PopMenuProc_real2Dmapcolor
	PopupMenu popup0,mode=1,value= #"\"*COLORTABLEPOPNONAMES*\""
	CheckBox check0,pos={265.00,39.00},size={60.00,22.00},proc=CheckProc_real2Dmapcolorcheck,title="Invert"
	CheckBox check0,font="Times New Roman",fSize=20,value= 0
	SetVariable setvar1,pos={332.00,38.00},size={60.00,25.00},proc=SetVarProc_real2Dmapcolorgamma,title="γ"
	SetVariable setvar1,font="Times New Roman",fSize=20
	SetVariable setvar1,limits={0,inf,0.1},value= _NUM:1
	Button button2,pos={402.00,18.00},size={87.00,39.00},proc=ButtonProc_real2Dmap_newplot,title="New2Dplot"
	Button button2,font="Times New Roman",fSize=16

	AppendImage/L=realL/B=realB real2Dmap
	ModifyGraph freePos(realL)=0,freePos(realB)=0
	ModifyGraph axisEnab(realB) = {0,0.48}
	
	AppendImage/R=reciR/B=reciB EKcut
	ModifyGraph freePos(reciR)=0,freePos(reciB)=0
	ModifyGraph axisEnab(reciB) = {0.52,1}
	ModifyGraph tick=2,mirror(realB)=1,fSize=20,axThick=2,standoff=0,font="Arial"
	ModifyGraph lblPosMode=1,tickUnit(reciR)=1,tickUnit(reciB)=1;DelayUpdate
	Label realL "\\F'Arial'\\Z30Y";DelayUpdate
	Label realB "\\F'Arial'\\Z30X";DelayUpdate
	Label reciR "\\F'Arial'\\Z30\\f02k\\B//";DelayUpdate
	Label reciB "\\F'Arial'\\Z30\\f02E-E\\BF\\M\\f00\\Z30 (eV)"
	showinfo
	cursor/I/H=1/S=1/T=2/C=(0, 0, 65535) A real2Dmap, 0, 0
	cursor/I/H=2/S=1/T=2/C=(0, 65535, 0) B EKcut, 0, 0
	 live2Dmapplot()
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
	variable xdelta
	variable ydelta
	wave realmaptemp
	if(waveexists(realmaptemp)==0)
		Abort "Please first load the real space map first!"
	endif

	prompt xdelta "Enter the increment of X direction:"
	prompt ydelta "Enter the increment of Y direction:"
	doprompt "", xdelta, ydelta
	setscale/p z, 0, xdelta, realmaptemp
	setscale/p t, 0, ydelta, realmaptemp
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
	setscale/p x, 0, dimdelta(realmaptemp,2), real2Dmap
	setscale/p y, 0, dimdelta(realmaptemp,3), real2Dmap
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
