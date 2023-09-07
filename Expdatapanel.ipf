#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma igorversion=7.00
#pragma version=1.0
//Xiangrui Liu, 2021-09-10. 12031049@mail.sustech.edu.cn. 
//2023-04-11, Update the data load and simple plot for .dat file from PPMS, Quantum Design
Menu "Extended Procedures"
	"Expdatapanel/3", Expdatapanel()
End

Window Expdatapanel() : Panel
	PauseUpdate; Silent 1		// building window...
	make/o/T/n=0 expdatalistwave
	make/o/n=0 expdataselwave
	string/g expdatatype= "XRD"
	NewPanel /W=(1384,119,1650,600)
	Button button0,pos={12.00,9.00},size={85.00,44.00},proc=ButtonProc_newexpdatapath,title="NewPath"
	Button button0,font="Times New Roman",fSize=20
	Button button1,pos={108.00,29.00},size={70.00,25.00},proc=ButtonProc_expupdate,title="Update"
	Button button1,font="Times New Roman",fSize=16
	PopupMenu popup0,pos={104.00,7.00},size={80.00,21.00},proc=PopMenuProc_expdatatype,title="Type"
	PopupMenu popup0,font="Times New Roman",fSize=16
	PopupMenu popup0,mode=1,popvalue="XRD",value= #"\"XRD;XRDras;PPMS-VSM;PPMS-Res;XMCD(SSRF07U);XMCD(SSRF08U)\""
	ListBox list0,pos={11.00,58.00},size={245.00,280.00},font="Times New Roman"
	ListBox list0,fSize=16,listWave=root:expdatalistwave,selWave=root:expdataselwave
	ListBox list0,mode= 9
	Button button2,pos={195.00,11.00},size={57.00,32.00},proc=ButtonProc_EXPDATALOAD,title="Load"
	Button button2,font="Times New Roman",fSize=16
	Button button3,pos={12.00,361.00},size={75.00,35.00},proc=ButtonProc_EXPPPMSview,title="PPMSview"
	Button button3,font="Times New Roman",fSize=14
	Button button4,pos={92.00,361.00},size={85.00,35.00},proc=ButtonProc_EXPPPMSseperation,title="Separation"
	Button button4,font="Times New Roman",fSize=16
	Button button5,pos={180.00,361.00},size={80.00,35.00},proc=ButtonProc_EXPPPMSplot,title="PPMSplot"
	Button button5,font="Times New Roman",fSize=16
	GroupBox group0,pos={6.00,341.00},size={257.00,62.00},title="PPMS"
	GroupBox group0,font="Times New Roman",fSize=16
	Button button6,pos={10.00,405.00},size={86.00,36.00},proc=ButtonProc_xmcdpanelfunc,title="XMCDPanel"
	Button button6,font="Times New Roman",fSize=14
	Button button7,pos={100.00,405.00},size={110.00,35.00},proc=ButtonProc_xrdmultipleplot,title="XRDmultipleplot"
	Button button7,font="Times New Roman",fSize=14

EndMacro


Function ButtonProc_newexpdatapath(ctrlName) : ButtonControl
	String ctrlName
	String/g expfolderpath
	newpath/O expfolderpath
	if(V_flag)
		return -1 //user cancel
	endif
	pathinfo expfolderpath
	Updateexpdatafolder()
End

Function PopMenuProc_expdatatype(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	String/g expdatatype=popStr
End

Function Updateexpdatafolder()
	string/g expfolderpath
	string/g expdatatype
	wave/T expdatalistwave
	wave expdataselwave
	string filenamelist, templist, datatype
	variable filenum, i
	if(stringmatch(expdatatype,"XRD")==1)
		datatype=".xy"
	elseif(stringmatch(expdatatype,"XRDras")==1)
		datatype=".ras"
	elseif(stringmatch(expdatatype,"PPMS-VSM")==1)
		datatype=".dat"
	elseif(stringmatch(expdatatype,"PPMS-Res")==1)
		datatype=".dat"
	elseif(stringmatch(expdatatype,"XMCD(SSRF07U)")==1)
		datatype=".cvs"
	elseif(stringmatch(expdatatype,"XMCD(SSRF08U)")==1)
		datatype=".txt"
	endif
	
	filenamelist=indexedfile(expfolderpath,-1,datatype)
	templist=sortlist(filenamelist,";",16)
	filenum=itemsinlist(filenamelist)
	redimension/N=(filenum) expdatalistwave
	redimension/N=(filenum) expdataselwave
	for (i=1; i<filenum+1; i+=1)
		expdatalistwave[i-1]=Stringfromlist(i-1, templist)
	endfor
End

Function ButtonProc_expupdate(ctrlName) : ButtonControl
	String ctrlName
	Updateexpdatafolder()
End

Function ButtonProc_EXPDATALOAD(ctrlName) : ButtonControl
	String ctrlName
	String/g expdatatype, expfolderpath
	String datatype, currentwavename, XMCDfilename, Reslist
	wave/T expdatalistwave
	wave expdataselwave
	variable i=0, size, j
	variable index=dimsize(expdatalistwave,0)	
	if(stringmatch(expdatatype,"XRD")==1)
		datatype=".xy"
	elseif(stringmatch(expdatatype,"XRDras")==1)
		datatype=".ras"
	elseif(stringmatch(expdatatype,"PPMS-VSM")==1)
		datatype=".DAT"
	elseif(stringmatch(expdatatype,"PPMS-Res")==1)
		datatype=".DAT"
	elseif(stringmatch(expdatatype,"XMCD(SSRF07U)")==1)
		datatype=".cvs" // this only serves for XMCD data collected at SSRF BL07U
		elseif(stringmatch(expdatatype,"XMCD(SSRF08U)")==1)
		datatype=".txt" // this only serves for XMCD data collected at SSRF BL08U
	endif
	
	if(stringmatch(expdatatype,"XRD")==1)
	for(i=0; i<index; i+=1)
		if(expdataselwave[i]!=0)
			currentwavename=removeending(expdatalistwave[i],datatype)
			loadwave/O/G/M/Q/N=xywave/P=expfolderpath expdatalistwave[i]
			wave xywave0
			if(stringmatch(currentwavename,"*Omega*")==1)
				string xrdwavename=removeending(currentwavename, "_2-Theta_Omega")
			else
				xrdwavename=removeending(currentwavename, "_Theta_2-Theta")
			endif
			duplicate/O xywave0, $xrdwavename
			wave currentXRDwave=$xrdwavename
			Display; DelayUpdate
			AppendtoGraph currentXRDwave[][1] vs currentXRDwave[][0]
			size=dimsize(currentXRDwave,0)
			duplicate/o/R=[0,size-1][1] currentXRDwave, temp
			variable topvalue=wavemax(temp)
			SetAxis left 0, 1.1*topvalue
			TextBox/C/N=text0/F=0/B=1/A=MC "\\F'Times New Roman'\\Z24"+xrdwavename
			XRDdataplot()
		endif
	endfor	
		killwaves xywave0, temp
	endif
	
	if(stringmatch(expdatatype,"XRDras")==1)
	for(i=0; i<index; i+=1)
		if(expdataselwave[i]!=0)
			currentwavename=removeending(expdatalistwave[i],datatype)
			loadwave/O/G/ENCG=2/Q/M/N=xywave/P=expfolderpath expdatalistwave[i]
			wave xywave0
			if(stringmatch(currentwavename,"*Omega*")==1)
				xrdwavename=removeending(currentwavename, "_2-Theta_Omega")
			else
				xrdwavename=removeending(currentwavename, "_Theta_2-Theta")
			endif
			duplicate/O xywave0, $xrdwavename
			wave currentXRDwave=$xrdwavename
			Display; DelayUpdate
			AppendtoGraph currentXRDwave[][1] vs currentXRDwave[][0]
			size=dimsize(currentXRDwave,0)
			duplicate/o/R=[0,size-1][1] currentXRDwave, temp
			topvalue=wavemax(temp)
			SetAxis left 0, 1.1*topvalue
			TextBox/C/N=text0/F=0/B=1/A=MC "\\F'Times New Roman'\\Z24"+xrdwavename
			XRDdataplot()
		endif
	endfor	
		killwaves xywave0, temp
	endif
	
	if(stringmatch(expdatatype,"PPMS-VSM")==1)
	for(i=0; i<index; i+=1)
		if(expdataselwave[i]!=0)
			currentwavename=removeending(expdatalistwave[i],datatype)
			loadwave/O/G/D/Q/W/L={0,0,0,1,3}/N=PPMSwave/P=expfolderpath expdatalistwave[i]
			wave PPMSwave0,PPMSwave1,PPMSwave2
			size=dimsize(PPMSwave0,0)
			make/O/N=(size,3) $currentwavename
			wave currentwave=$currentwavename
			currentwave[][0]=PPMSwave0[p]
			currentwave[][1]=PPMSwave1[p]/10000
			currentwave[][2]=PPMSwave2[p]
		endif
	endfor
	killwaves PPMSwave0,PPMSwave1,PPMSwave2
	endif
	
	if(stringmatch(expdatatype,"PPMS-Res")==1)
	for(i=0; i<index; i+=1)
		if(expdataselwave[i]!=0)
			currentwavename=removeending(expdatalistwave[i],datatype)
			loadwave/O/G/D/Q/W/L={0,0,0,1,0}/N=PPMSwave/P=expfolderpath expdatalistwave[i]
			Reslist=wavelist("PPMSwave*", ";" ,"DIMS:1")
			variable chnum=itemsinlist(Reslist)
		 //Temperature (K), Field (Oe), sample position (degrees), ch1-4 resistivity (Ohm) and excitation current (A)
		 //ch1-4 Standard deviation,	number of readings, ch1-4 resistance we drop out		
			wave PPMSwave1
			PPMSwave1/=10000
			size=dimsize(PPMSwave1,0)
			make/O/N=(size,(chnum-4)*0.5+3) $currentwavename
			wave currentwave=$currentwavename
			for(j=0; j<dimsize(currentwave,1); j+=1)
				wave wavej=$"PPMSwave"+num2str(j)
				currentwave[][j]=wavej[p]
			endfor
			for(j=0; j<chnum; j+=1)
				killwaves $"PPMSwave"+num2str(j)
			endfor
		Edit/K=0 $currentwavename
		endif
	endfor
	endif
	
	if(stringmatch(expdatatype,"XMCD(SSRF07U)")==1)
		for(i=0; i<index; i+=1)
		if(expdataselwave[i]!=0)
			prompt XMCDfilename "Please enter an legal filename!"
			doprompt "", XMCDfilename
			if(V_flag)
				return -1
			endif
			currentwavename=removeending(expdatalistwave[i],datatype)
			Loadwave/J/D/M/O/Q/L={0,0,0,2,5}/N=XMCDwave/P=expfolderpath expdatalistwave[i]
			wave XMCDwave0
			duplicate/O XMCDwave0, $XMCDfilename
			print "Load "+expdatalistwave[i]+" as "+XMCDfilename
		endif
		endfor
		killwaves XMCDwave0
	endif
	
	if(stringmatch(expdatatype,"XMCD(SSRF08U)")==1)
		for(i=0; i<index; i+=1)
		if(expdataselwave[i]!=0)
			prompt XMCDfilename "Please enter an legal filename!"
			doprompt "", XMCDfilename
			if(V_flag)
				return -1
			endif
			currentwavename=removeending(expdatalistwave[i],datatype)
			Loadwave/G/D/M/O/Q/L={0,28,0,0,9}/N=XMCDwave/P=expfolderpath expdatalistwave[i]
			wave XMCDwave0
			variable wavedim=dimsize(XMCDwave0,0)
			make/O/N=(wavedim, 4) $XMCDfilename
			wave currwave=$XMCDfilename
			currwave[][0]=XMCDwave0[p][0]
			currwave[][1]=XMCDwave0[p][6]
			currwave[][2]=XMCDwave0[p][7]
			currwave[][3]=XMCDwave0[p][8]
			print "Load "+expdatalistwave[i]+" as "+XMCDfilename
		endif
		endfor
		killwaves XMCDwave0
	endif
End

Function XRDdataplot()
	ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28,width=340.157,height=255.118
	ModifyGraph tick=2,mirror=1,standoff=0
	ModifyGraph lsize=2
	ModiFyGraph axThick=2
	ModifyGraph fSize=16,font="Times New Roman"
	ModifyGraph noLabel(left)=1
	Label bottom "\\F'Times New Roman'\\Z24 2θ (°)"
 	Label left "\\F'Times New Roman'\\Z24Intensity (arb. units.)"
End

Function ButtonProc_xrdmultipleplot(ctrlName) : ButtonControl
	String ctrlName
	String/g expdatatype
	String datatype, currentwavename
	wave/T expdatalistwave
	wave expdataselwave
	if(stringmatch(expdatatype,"XRD")==1)
		datatype=".xy"
	elseif(stringmatch(expdatatype,"XRDras")==1)
		datatype=".ras"
	else
		Abort "Please first show XRD data!"
	endif
	
	variable i=0, size, maxval=0, j=0
	variable index=dimsize(expdatalistwave,0)
	Display;
	for(i=0; i<index; i+=1)
		if(expdataselwave[i]!=0)
			currentwavename=removeending(expdatalistwave[i],datatype)
			if(stringmatch(currentwavename,"*Omega*")==1)
				string xrdwavename=removeending(currentwavename, "_2-Theta_Omega")
			else
				xrdwavename=removeending(currentwavename, "_Theta_2-Theta")
			endif
		wave currentxrdwave=$xrdwavename
		if(waveexists(currentxrdwave)!=1)
			printf "The data of %s hasn't been loaded!\r", xrdwavename
		else
			AppendtoGraph currentxrdwave[][1] vs currentxrdwave[][0]
			ModifyGraph offset($xrdwavename)={0,maxval}
			size=dimsize($xrdwavename,0)
			duplicate/o/R=[0,size-1][1] currentxrdwave, temp
			currentxrdwave[][1]/=wavemax(temp)
			maxval+=1.1
			j+=1
		endif
		
		endif
	endfor
	XRDdataplot()
	string ctnamestr
	prompt ctnamestr "Please choose the color table for multiple traces plot:" popup CTabList()
	doprompt "", ctnamestr
	if(V_flag)
		return -1
	endif
	colortab2wave $ctnamestr
	wave M_colors
	size=dimsize(M_colors,0)-1
	Legend/C/N=text0/F=0/A=MC/B=1
	for(i=0; i<j; i+=1)
		ModifyGraph/Z rgb[i]=(M_colors[size/j*i][0],M_colors[size/j*i][1],M_colors[size/j*i][2])
	endfor
	
	killwaves temp, M_colors
End



Function ButtonProc_EXPPPMSview(ctrlName) : ButtonControl
	String ctrlName
	String datatype=".DAT"
	string/g expdatatype
	wave expdataselwave
	wave/T expdatalistwave
	variable datasize=dimsize(expdataselwave,0)
	variable i
	for(i=0; i<datasize; i+=1)
		if(expdataselwave[i]!=0)
			wave currentwave=$removeending(expdatalistwave[i],datatype)
			if(waveexists(currentwave)==0)
				Abort "wave"+removeending(expdatalistwave[i],datatype)+"doesn't exists!"
			else
				Display; DelayUpdate
				AppendToGraph 'currentwave'[][0]
				ModifyGraph/Z rgb($removeending(expdatalistwave[i],datatype))=(0,0,65535)
				duplicate/o/R=[][0] currentwave, temp
				variable v1=wavemin(temp)
				variable v2=wavemax(temp)
				SetAxis left v1-0.2*(v2-v1), v2+0.2*(v2-v1)
				AppendToGraph/R 'currentwave'[][1]
				duplicate/o/R=[][1] currentwave, temp
				v1=wavemin(temp)
			   v2=wavemax(temp)
				SetAxis right v1-0.2*(v2-v1), v2+0.2*(v2-v1)
				ShowInfo
				PPMSviewplot()
			endif
		endif
	endfor
	killwaves temp
End

Function PPMSviewplot()
	ModifyGraph margin(left)=70,margin(bottom)=56,margin(right)=70,margin(top)=28,width=340.157,height=255.118
	ModifyGraph tick=2,mirror(bottom)=1
	ModifyGraph lsize=2, standoff=0, axThick=2
	ModifyGraph axRGB(left)=(0,0,65535),axRGB(right)=(65535,0,0)
	ModifyGraph fSize=16,font="Times New Roman"
	Label bottom "\\F'Times New Roman'\\Z24 Datanum"
 	Label left "\\K(0,0,65535)\\F'Times New Roman'\\Z24Temperature (K)"
 	Label right "\\K(65535,0,0)\\F'Times New Roman'\\Z24µ\\B0\\M\\F'Times New Roman'\\Z24H (T)"
End


Function ButtonProc_EXPPPMSseperation(ctrlName) : ButtonControl
	String ctrlName
	wave/T expdatalistwave
	wave expdataselwave
	string datatype=".DAT"
	string/g expdatatype
	variable datasize=dimsize(expdataselwave,0)
	variable i, j, k, count, size
	for(i=0; i<datasize; i+=1)
		if(expdataselwave[i]!=0)
			string wavenamestr=removeending(expdatalistwave[i],datatype)
			wave currentwave=$wavenamestr
			if(waveexists(currentwave)==0)
				Abort "wave"+removeending(expdatalistwave[i],datatype)+"doesn't exists!"
			else
				variable lsize=dimsize(currentwave,0)
				duplicate/O/R=[0,lsize-2][0] currentwave, temp1
				duplicate/O/R=[0,lsize-2][1] currentwave, temp2
				temp1=currentwave[p+1][0]-currentwave[p][0]
				temp2=currentwave[p+1][1]-currentwave[p][1]
				wavestats/q temp1
				variable v1=V_avg
				wavestats/q temp2
				variable v2=V_avg
				make/O seppnt
				seppnt[0]=0
				k=1
				for(j=0; j<lsize-1; j+=1)
					if(temp1[j]/v1-1>2000 || temp1[j]/v1-1<-2000)  
					// this condition is not general, for some cases it may separate the wave incorrectly
						seppnt[k]=j
						k+=1
					endif
				endfor
				seppnt[k]=lsize-1
				for(j=0; j<10; j+=1)
					if(seppnt[j+1]!=0)
						if(stringmatch(expdatatype,"PPMS-Res"))
							size=dimsize(currentwave,1)
							duplicate/O/R=[seppnt[j]+1,seppnt[j+1]][0] currentwave, $wavenamestr+num2str(j+1)+"Temp"
							duplicate/O/R=[seppnt[j]+1,seppnt[j+1]][1] currentwave, $wavenamestr+num2str(j+1)+"Field"
								for(count=1; count<=(size-3)/2; count+=1)
									duplicate/O/R=[seppnt[j]+1,seppnt[j+1]][2*count+1] currentwave, $wavenamestr+num2str(j+1)+"ch"+num2str(count)
								endfor
						else
							duplicate/O/R=[seppnt[j]+1,seppnt[j+1]][0,2] currentwave, $wavenamestr+num2str(j+1)
						endif
					endif
				endfor
				
			endif
			i=datasize
			killwaves temp1, temp2, seppnt
		endif
	endfor
End

Function ButtonProc_EXPPPMSplot(ctrlName) : ButtonControl
	String ctrlName
	String wavenamestring
	string/g expdatatype
	
	if(stringmatch(expdatatype, "PPMS-VSM"))
	prompt wavenamestring "Please choose the plot wave:" popup wavelist("*",";","DIMS:2,MAXCOLS:3,MINCOLS:3")
	doprompt "" wavenamestring
	if(V_flag)
		return -1
	endif
	wave currentwave=$wavenamestring
	duplicate/O/R=[][0] currentwave, temp
	duplicate/O/R=[][1] currentwave, temp1
	wavestats/Q temp
	if(V_sdev<0.01)
		Display; DelayUpdate
		AppendToGraph 'currentwave'[][2] vs 'currentwave'[][1]
		TextBox/C/N=text0/F=0/B=1/A=MC "\\F'Times New Roman'\\Z24 T="+num2str(V_avg)+" K"
		MHplot()
	else
		wavestats/Q temp1
		Display; DelayUpdate
		AppendToGraph 'currentwave'[][2] vs 'currentwave'[][0]
		TextBox/C/N=text0/F=0/B=1/A=MC "\\F'Times New Roman'\\Z24µ\\B0\\M\\F'Times New Roman'\\Z24H="+num2str(V_avg)+" T"
		MTplot()
	endif
	killwaves temp, temp1
	elseif(stringmatch(expdatatype,"PPMS-Res"))
		prompt wavenamestring "Please choose the plot wave:" popup wavelist("*ch*",";","")
		doprompt "" wavenamestring
		if(V_flag)
			return -1
		endif
		string plotstr=removeending(removeending(wavenamestring),"ch")
		wave Rwave=$wavenamestring
		wave fieldwave=$plotstr+"Field"
		wave Tempwave=$plotstr+"Temp"
		wavestats/Q Tempwave
		if(V_sdev<0.01)
			Display; Delayupdate
			AppendtoGraph Rwave vs fieldwave
			TextBox/C/N=text0/F=0/B=1/A=MC "\\F'Times New Roman'\\Z24 T="+num2str(V_avg)+" K"
			Label bottom "\\F'Times New Roman'\\Z24µ\\B0\\M\\F'Times New Roman'\\Z24H (T)"
			Rplot()
		else
			wavestats/Q temp1
			Display; DelayUpdate
			AppendToGraph Rwave vs Tempwave
			TextBox/C/N=text0/F=0/B=1/A=MC "\\F'Times New Roman'\\Z24µ\\B0\\M\\F'Times New Roman'\\Z24H="+num2str(V_avg)+" T"
			Label bottom "\\F'Times New Roman'\\Z24Temperature (K)"
			Rplot()
		endif
	endif
End

Function MHplot()
	ModifyGraph margin(left)=70,margin(bottom)=70,margin(right)=28,margin(top)=28,width=340.157,height=255.118
	ModifyGraph tick=2,mirror=1,standoff=0
	ModiFyGraph axThick=2
	ModifyGraph lsize=2
	ModifyGraph fSize=16,font="Times New Roman"
	Label bottom "\\F'Times New Roman'\\Z24µ\\B0\\M\\F'Times New Roman'\\Z24H (T)"
 	Label left "\\F'Times New Roman'\\Z24Moment (emu)"
End

Function MTplot()
	ModifyGraph margin(left)=70,margin(bottom)=70,margin(right)=28,margin(top)=28,width=340.157,height=255.118
	ModifyGraph tick=2,mirror=1,standoff=0
	ModiFyGraph axThick=2
	ModifyGraph lsize=2
	ModifyGraph fSize=16,font="Times New Roman"
	Label bottom "\\F'Times New Roman'\\Z24Temperature (K)"
 	Label left "\\F'Times New Roman'\\Z24Moment (emu)"
End

Function Rplot()
	ModifyGraph margin(left)=70,margin(bottom)=70,margin(right)=28,margin(top)=28,width=340.157,height=255.118
	ModifyGraph tick=2,mirror=1,standoff=0
	ModiFyGraph axThick=2
	ModifyGraph lsize=2
	ModifyGraph fSize=16,font="Times New Roman"
 	Label left "\\F'Times New Roman'\\Z24Resistance (Ω)"
End

Function ButtonProc_xmcdpanelfunc(ctrlName) : ButtonControl
	String ctrlName
	Execute "XMCDPanel()"
End

Window XMCDPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(1000,200,1320,600)
	String/g XMCDwavelist
	variable/g energychnum=0, backgrchnum=0, signalchnum=0
	variable/g xmcdbackgrcheck=0
	XMCDupdate()
	String/g currentxmcdwave=stringfromlist(0,XMCDwavelist)
	duplicate/O $currentxmcdwave, liveviewxmcd
	Button button0,pos={6.00,7.00},size={53.00,35.00},proc=ButtonProc_XMCDwaveupdate,title="Update"
	Button button0,font="Times New Roman",fSize=14
	PopupMenu popup0,pos={130,5},size={129.00,21.00},title="Viewdata"
	PopupMenu popup0,font="Times New Roman",fSize=14
	PopupMenu popup0,mode=1,value= #"XMCDwavelist",proc=PopMenuProc_xmcdviewdata
	Edit/W=(10,50,305,300)/HOST=#  liveviewxmcd
	ModifyTable format(Point)=1
	ModifyTable size=10
	ModifyTable width(Point)=30
	ModifyTable width(liveviewxmcd)=60
	ModifyTable statsArea=85
	RenameWindow #,T0
	SetActiveSubwindow ##
	CheckBox check0,pos={130.00,30.00},size={82.00,16.00},proc=CheckProc_xmcdbackgrcheck,title="background"
	CheckBox check0,font="Times New Roman",fSize=14,value= 0,side= 1
	SetVariable setvar0,pos={10.00,305.00},size={123.00,20.00},title="Energychannel",proc=SetVarProc_xmcdenergychnum
	SetVariable setvar0,font="Times New Roman",fSize=14,limits={0,3,1},value= _NUM:0
	SetVariable setvar1,pos={10.00,330.00},size={123.00,20.00},title="backgrchannel",proc=SetVarProc_xmcdbackgrchnum
	SetVariable setvar1,font="Times New Roman",fSize=14,limits={0,3,1},value= _NUM:0
	SetVariable setvar2,pos={10.00,355.00},size={123.00,20.00},title="signalchannel",proc=SetVarProc_xmcdsignalchnum
	SetVariable setvar2,font="Times New Roman",fSize=14,limits={0,3,1},value= _NUM:0
	Button button1 title="Export",proc=ButtonProc_xmcdexport,font="Times New Roman",fSize=14
	Button button1 pos={65,10},size={60,30}
	PopupMenu popup1,pos={190,340},size={129.00,21.00},title="C-"
	PopupMenu popup1,font="Times New Roman",fSize=14
	PopupMenu popup1,mode=1,value= #"XMCDwavelist",proc=PopMenuProc_xmcdCminus
	PopupMenu popup2,pos={190,315},size={129.00,21.00},title="C+"
	PopupMenu popup2,font="Times New Roman",fSize=14
	PopupMenu popup2,mode=1,value= #"XMCDwavelist",proc=PopMenuProc_xmcdCplus
	Button button2 title="CD",proc=ButtonProc_xmcd_CDcal,font="Times New Roman",fSize=14
	Button button2 pos={145,330},size={40,20}
EndMacro

Function ButtonProc_XMCDwaveupdate(ctrlName) : ButtonControl
	String ctrlName
	XMCDupdate()
End

Function XMCDupdate()
	String/g XMCDwavelist
	XMCDwavelist=wavelist("!*liveviewxmcd*",";","DIMS:2,MINCOLS:4,MAXCOLS:4")
End

Function PopMenuProc_xmcdviewdata(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	wave liveviewxmcd
	String/g currentxmcdwave=popStr
	duplicate/O $currentxmcdwave, liveviewxmcd
End

Function SetVarProc_xmcdenergychnum(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g energychnum=varNum
End

Function SetVarProc_xmcdbackgrchnum(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g backgrchnum=varNum
End

Function SetVarProc_xmcdsignalchnum(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g signalchnum=varNum
End

Function CheckProc_xmcdbackgrcheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	variable/g xmcdbackgrcheck=checked
End


Function ButtonProc_xmcdexport(ctrlName) : ButtonControl
	String ctrlName
	String/g currentxmcdwave
	variable/g energychnum, backgrchnum, signalchnum 
	variable/g xmcdbackgrcheck
	wave liveviewxmcd
	variable size=dimsize(liveviewxmcd,0)
	variable total, i, j, temp
	make/o/N=(size-2) $currentxmcdwave+"_energy",$currentxmcdwave+"_inten"
	wave energywave=$currentxmcdwave+"_energy"
	wave intenwave=$currentxmcdwave+"_inten"
	energywave=liveviewxmcd[p+2][energychnum]
	intenwave=liveviewxmcd[p+2][signalchnum]/liveviewxmcd[p+2][backgrchnum]
	if(xmcdbackgrcheck == 1)
		duplicate/O intenwave, $currentxmcdwave+"_inten_bg"
		wave intenbgwave=$currentxmcdwave+"_inten_bg"
		variable offset=wavemin(intenwave)
		duplicate/O intenwave, currentwave
		currentwave-=offset
		variable a1=currentwave[0]
		variable a2=currentwave[size-3]
		for(i=0; i<size-2; i+=1)
			total+=currentwave[i]
		endfor
		for(i=0; i<size-2; i+=1)
			temp=0
			for(j=i; j<size-2; j+=1)
				temp+=currentwave[j]
			endfor
		intenbgwave[i]=currentwave[i]-(a2+(a1-a2)*temp/total)
	endfor
	endif
	
	killwaves currentwave
End


Function PopMenuProc_xmcdCminus(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	String/g Cminus=popStr
End

Function PopMenuProc_xmcdCplus(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	String/g Cplus=popStr
End

Function ButtonProc_xmcd_CDcal(ctrlName) : ButtonControl
	String ctrlName
	String/g Cplus, Cminus
	String cdname
	variable/g xmcdbackgrcheck
	prompt cdname "Please enter the cd wave name:"
	doprompt "", cdname
	if(V_flag)
		return -1
	endif
	wave C1wave=$Cplus+"_inten"
	wave C2wave=$Cminus+"_inten"
	if(xmcdbackgrcheck == 1)
		wave C1wave=$Cplus+"_inten_bg"
		wave C2wave=$Cminus+"_inten_bg"
	endif
	
	wave energywave1=$Cplus+"_energy"
	wave energywave2=$Cminus+"_energy"
	if(waveexists(C1wave) != 1 || waveexists(C2wave) != 1)
		Abort "Please first export the chosen data!"
	endif
	
	duplicate/O C1wave, $cdname
	wave cdwave=$cdname
	cdwave=C1wave-C2wave
	Display; DelayUpdate
	AppendToGraph C1wave vs energywave1
	AppendToGraph C2wave vs energywave2
	AppendToGraph cdwave vs energywave1
	
	ModifyGraph margin(left)=70,margin(bottom)=70,margin(right)=28,margin(top)=28,width=340.157,height=255.118
	ModifyGraph tick=2,mirror=1,standoff=0
	ModifyGraph lsize=2, axThick=2
	ModifyGraph zero(left)=4,zeroThick(left)=1
	ModiFyGraph/Z axThick=2
	ModifyGraph noLabel(left)=1
	ModifyGraph fSize=16,font="Times New Roman"
	Label bottom "\\F'Times New Roman'\\Z24Energy (eV)"
 	Label left "\\F'Times New Roman'\\Z24Intensity (arb. units.)"
 	if(xmcdbackgrcheck == 0)
 		ModifyGraph rgb($Cplus+"_inten")=(65535,0,0)
 		ModifyGraph rgb($Cminus+"_inten")=(0,0,65535)
	else
		ModifyGraph rgb($Cplus+"_inten_bg")=(65535,0,0)
 		ModifyGraph rgb($Cminus+"_inten_bg")=(0,0,65535)
	endif 	

 	ModifyGraph mode($cdname)=7, rgb($cdname)=(0,65535,0)
 	ModifyGraph hbFill($cdname)=2, hBarNegFill($cdname)=2
 	Legend/C/N=text0/J/B=1/F=0 "\\F'Times New Roman'\\Z16"+cdname+"\r\\s(#0) C+\r\\s(#1) C-\r\\s(#2) CD"
End
