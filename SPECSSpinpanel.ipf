#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//This panel works for load and process the spin-resolved itx data exported from SPECS Prodigy v4.130.1, Astraios 190 analyzer and 3D VLEED detector.
//Xiangrui Liu, 2026-08-20. xrliu1998@sjtu.edu.cn
//For latest updates, related information and other related (maybe useful) procedures, please go to the Github link below.
//https://github.com/XiangruiLiuSUSTech/ARPESmainpanel_XRLiu_SUSTech

Window AstraiosSpin() : Panel
	dowindow/f AstraiosSpin
	if(V_flag==0)
	PauseUpdate; Silent 1		// building window...
	make/o/T/n=0 spindatalistwave
	make/o/n=0 spindataselwave
	String/g root:spinfolderpath
	string/g root:spindataset="root;"
	NewPanel /W=(1000,271,1230,643)
	Button button0,pos={15.00,305.00},size={75.00,30.00},proc=ButtonProc_SPECSSpinsum,title="SpinSum"
	Button button0,font="Arial",fSize=14
	Button button1,pos={14.00,5.00},size={81.00,35.00},proc=ButtonProc_spindatapath,title="Data Path"
	Button button1,font="Times New Roman",fSize=16
	Button button2,pos={103.00,8.00},size={58.00,26.00},proc=ButtonProc_spinupdate,title="Update"
	Button button2,font="Times New Roman",fSize=16
	Button button3,pos={16.00,272.00},size={55.00,27.00},proc=ButtonProc_Spinload,title="Load"
	Button button3,font="Times New Roman",fSize=16
	Button button3 help={"Only loads one dimensional itx format spin data exported from SPECS Prodigy v4.130.1"}
	Button button4,pos={95.00,305.00},size={65.00,30.00},proc=ButtonProc_spinrawdata,title="rawdata"
	Button button4,font="Times New Roman",fSize=16
	Button button5,pos={165.00,305.00},size={60.00,30.00},proc=ButtonProc_Spinstatistics,title="Statistics"
	Button button5,font="Times New Roman",fSize=16

	ListBox list0,pos={15.00,45.00},size={195.00,220.00},font="Times New Roman"
	ListBox list0,fSize=14,listWave=root:spindatalistwave
	ListBox list0,selWave=root:spindataselwave,mode= 9
	PopupMenu popup0,pos={75.00,275.00},size={142.00,23.00},bodyWidth=100,title="dataset",proc=PopMenuProc_spindatasetchoose
	PopupMenu popup0,font="Times New Roman",fSize=14
	PopupMenu popup0,mode=1,popvalue="root",value= #"root:spindataset"
	endif
EndMacro


Function ButtonProc_spindatapath(ctrlName) : ButtonControl
	String ctrlName
	String/g root:spinfolderpath
	newpath/O spinfolderpath
	if(V_flag)
		return -1 //user cancel
	endif
	pathinfo spinfolderpath
	svar spinfolderpath=S_path
	Updatespinfolder()
End

Function Updatespinfolder()
	string/g root:spinfolderpath
	string datatype=".itx" //only serves for itx format data exported from SPECS Prodigy
	wave/T spindatalistwave
	wave spindataselwave
	string filenamelist, templist
	variable filenum, i
	
	setdatafolder root:
	filenamelist=indexedfile(spinfolderpath,-1,datatype)
	templist=sortlist(filenamelist,";",16)
	filenum=itemsinlist(filenamelist)
	redimension/N=(filenum) spindatalistwave
	redimension/N=(filenum) spindataselwave
	for (i=1; i<filenum+1; i+=1)
		spindatalistwave[i-1]=Stringfromlist(i-1, templist)
	endfor
End

Function ButtonProc_spinupdate(ctrlName) : ButtonControl
	String ctrlName
	Updatespinfolder()
End


Function ButtonProc_Spinload(ctrlName) : ButtonControl
	String ctrlName
	string/g root:spinfolderpath
	string datatype=".itx" 
	string logtext
	string spindatasetname
 	variable ref
 	string spinrotator, spincoil
 	string s1
	string/g root:spindataset
	wave/T spindatalistwave
	wave spindataselwave
	variable i, j, loadnum=0, k=0
	pathinfo spinfolderpath
	
	prompt spindatasetname "Please Enter the name for this spin dataset:"
	prompt spinrotator "Please Set the spin rotator:" popup "+1;-1"
	prompt spincoil "Please Choose the spin coil:" popup "1;2"
	doprompt "", spindatasetname, spinrotator, spincoil
	if(V_flag)
		return -1
	endif
		
	variable index=dimsize(spindatalistwave,0)	
	for(i=0; i<index; i+=1)
		if(spindataselwave[i]!=0)
			loadnum+=1
		endif
	endfor	
	
	dowindow/f exp_logbook
	if(V_flag==0)
		NewNotebook/W=(200,150,800,500)/F=0/ENCG=1/N=exp_logbook
	endif

	for(i=0; i<index; i+=1)
			if(spindataselwave[i]!=0)
				newdatafolder/O/S itxload
				string currentwavename=removeending(spindatalistwave[i],datatype)
				loadwave/T/O/Q/P=spinfolderpath spindatalistwave[i]
				string itxfilename=getindexedobjname("root:itxload:",1,0)
				duplicate/O root:itxload:$itxfilename, root:$currentwavename
				string itxloadstr="root:itxload"
				killdatafolder/Z $itxloadstr	
				
				open/R/P=spinfolderpath ref as spindatalistwave[i]
				string commentstr=""
				for(j=0; j<100; j+=1)
					FReadLine ref, s1
					if(stringmatch(s1,"*User comment*")==1)
						commentstr+=s1
					endif
				endfor
				close/A
				note root:$currentwavename, commentstr //copy the comments made in SPECS Prodigy
				logtext="Load "+currentwavename+datatype+" from "+S_path+"to root:"+spindatasetname+"\r" 
				Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
		endif
	endfor
	
	newdatafolder/O/S $spindatasetname
	
	variable/g $spindatasetname+"_spinrotator"=str2num(spinrotator)
	variable/g $spindatasetname+"_spincoil"=str2num(spincoil)
	if(str2num(spincoil)==1)
		logtext="The measured spin polarization is Sz; positive is Sz, negative is -Sz;\r"
	else
		if(str2num(spinrotator)==1)
			logtext="The measured spin polarization is Sx-Sy; positive is (-Sx+Sy)/sqrt(2), negative is (Sx-Sy)/sqrt(2);\r"
		else
			logtext="The measured spin polarization is Sx+Sy; positive is (Sx+Sy)/sqrt(2), negative is (-Sx-Sy)/sqrt(2);\r"
		endif
	endif
	string/g $spindatasetname+"_spinvector"=logtext
	Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
	logtext="----------The data load process end--------------\r\r"
	Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
	
	
	string lp1=getdatafolder(1)
	setdatafolder root:
	for(i=0; i<index; i+=1)
		if(spindataselwave[i]!=0)
			currentwavename=removeending(spindatalistwave[i],datatype)
			if(waveexists($currentwavename))
				string lp2=lp1+currentwavename
				movewave root:$currentwavename, $lp2
			endif
		endif
	endfor
	svar newstr = spindataset
	newstr=newstr+spindatasetname+";"
	svar spindataset=newstr

End

Function PopMenuProc_spindatasetchoose(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	string/g root:spindataset
	svar newspinset=root:spindataset
	if(stringmatch(popStr,"root"))
		setdatafolder root:
	else
	string currentfolder="root:"+popStr
		if(datafolderexists(currentfolder))
			setdatafolder $currentfolder
		else
			newspinset=removefromlist(popStr,newspinset)
			setdatafolder root:
			svar spindataset=newspinset
		endif
	endif
End


Function ButtonProc_SPECSSpinsum(ctrlName) : ButtonControl
	String ctrlName

	string datatype=".itx"
	variable waveindex, loopnum, profilenum=8, i, j, spinwavenum, spinwavesize, spinwaveoffset, spinwavedelta
	variable Sherman= 0.30 //Sherman function for VLEED detector
	string spingroupname, profiletype, spin, logtext
	string spinwavelist="", spinwavelooplist="", templist=""
	controlinfo/W=AstraiosSpin popup0
	
	string currentdf=getdatafolder(1)
	if(stringmatch(currentdf,"*"+S_value+"*"))
	else
		Abort "Please set the current data folder to the choosen dataset !"
	endif	
	
	spinwavelist=wavelist("*",";","")
	spinwavenum=itemsinlist(spinwavelist)
	loopnum=floor(spinwavenum/profilenum)
	Prompt spingroupname "You have "+num2str(spinwavenum)+" waves in the subfolder to sumup spin.\nPlease Enter the name of spin group:"
	Prompt profilenum "Please Enter profiles in each loop:"
	Prompt profiletype "Please choose the profile type:" popup "+--+;-++-;"
	Prompt loopnum "Please Enter the number of loops:"
	Prompt Sherman "Please Enter the Sherman function:"
	doprompt "", spingroupname, profilenum, profiletype, loopnum, Sherman
	if(V_flag)
		return -1 
	endif
	
	if(mod(spinwavenum,loopnum*profilenum) != 0)
		Abort "Number of loops, profiles or waves is wrong ! Please retry."
	endif
	variable/g $S_value+"_Sherman"=Sherman
	string/g $S_value+"_loopprofile"=profiletype
	variable/g $S_value+"_loopnum"=loopnum
	
	spinwavesize=dimsize($stringfromlist(0,spinwavelist),0)
	spinwaveoffset=dimoffset($stringfromlist(0,spinwavelist),0)
	spinwavedelta=dimdelta($stringfromlist(0,spinwavelist),0)
	make/O/N=(spinwavesize) temp
	temp[]=0
	SetScale /P x, spinwaveoffset, spinwavedelta, temp
	
	for(i=1; i<=loopnum; i+=1)
		duplicate/O temp, $spingroupname+"_l"+num2str(i)+"Spinup"
		wave spinup=$spingroupname+"_l"+num2str(i)+"Spinup"
		duplicate/O temp, $spingroupname+"_l"+num2str(i)+"Spindown"
		wave spindown=$spingroupname+"_l"+num2str(i)+"Spindown"
		duplicate/O temp, $spingroupname+"_l"+num2str(i)+"Spinpol"
		wave spinpol=$spingroupname+"_l"+num2str(i)+"Spinpol"
		
		for(j=0; j< profilenum; j+=1)
		 	duplicate/O $stringfromlist((i-1)*profilenum+j, spinwavelist), $"looptemp"+num2str(j)
		endfor
		wave looptemp0, looptemp1, looptemp2, looptemp3, looptemp4, looptemp5, looptemp6, looptemp7
		if(stringmatch(profiletype,"+--+"))
			spinup=looptemp0+looptemp3+looptemp4+looptemp7
			spindown=looptemp1+looptemp2+looptemp5+looptemp6
		elseif(stringmatch(profiletype,"-++-"))
			spindown=looptemp0+looptemp3+looptemp4+looptemp7
			spinup=looptemp1+looptemp2+looptemp5+looptemp6
		endif
		
		spinwavelooplist=""
		spinpol=1/Sherman*(spinup-spindown)/(spinup+spindown)
	endfor
	
	duplicate/O temp, $spingroupname+"Spinup", $spingroupname+"Spindown", $spingroupname+"Spinpol"
	wave spinsumup=$spingroupname+"Spinup"
	wave spinsumdown=$spingroupname+"Spindown"
	wave spinsumpol=$spingroupname+"Spinpol"
	for(i=1; i<=loopnum; i+=1)
		wave spinup=$spingroupname+"_l"+num2str(i)+"Spinup"
		spinsumup+=spinup
		wave spindown=$spingroupname+"_l"+num2str(i)+"Spindown"
		spinsumdown+=spindown
	endfor
	spinsumpol=1/Sherman*(spinsumup-spinsumdown)/(spinsumup+spinsumdown)
	
	string spinvecstr=S_value+"_spinvector"
	if(exists(spinvecstr))
		svar newspinstr=$spinvecstr
		string str1=newspinstr
		if(stringmatch(newspinstr,"*Sz*"))
			str1="Sz"
		elseif(stringmatch(newspinstr,"*Polarization is Sx+Sy*"))
			str1="Sx+Sy"
		elseif(stringmatch(newspinstr,"*Polarization is Sx-Sy*"))
			str1="Sx-Sy"
		endif
	endif
	
	logtext="Sum up "+num2str(loopnum)+" loops of Spin data in "+S_value+" folder as "+spingroupname+"Spin \r" 
	logtext="Spin polarization vector is "+str1+";\r"
	logtext+="The Sherman function is set as "+num2str(Sherman)+" \r"
	Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
	
	killwaves temp, looptemp0, looptemp1, looptemp2, looptemp3, looptemp4, looptemp5, looptemp6, looptemp7
	Display/N=$S_value+"_loop"+num2str(loopnum)+"_plot"
	AppendtoGraph/L=left spinsumup, spinsumdown
	AppendtoGraph/L=leftnew spinsumpol
	
	Spinplot()
End

static Function Spinplot()
	
	ModifyGraph width=340.157,height=255.118
	ModifyGraph lsize=2
	ModifyGraph/Z rgb[0]=(65535,0,0),rgb[1]=(0,0,65535),rgb[2]=(2,39321,1)
	ModifyGraph/Z mode[2]=4,marker[2]=8,msize[2]=3,mrkThick[2]=1
	ModifyGraph axisEnab(left)={0,0.63},axisEnab(leftnew)={0.65,1}
	Label left "\\F'Arial'\\Z20 Intensity";DelayUpdate
	Label leftnew "\\F'Arial'\\Z20 Spin pol";DelayUpdate
	SetAxis leftnew -0.5,0.5
	ModifyGraph standoff(bottom)=0
	ModifyGraph freePos(leftnew)={0,kwFraction}
	ModifyGraph lblPos(left1)=55
	ModifyGraph zero(leftnew)=4,zeroThick(leftnew)=2
	ModifyGraph tick=2,mirror=1,fSize=14,axThick=2,font="Arial"
	DelayUpdate;
	ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28
	
	Legend/C/N=text0/F=0/B=1/A=MC
	string plotmode
	prompt plotmode "Please choose the plot mode: " popup "EDC;ADC;MDC"
	doprompt "", plotmode
	if(V_flag)	
		return -1
	endif
	
	if(stringmatch(plotmode,"EDC"))
		Label bottom "\\F'Arial'\\Z20 Energy (eV)"
		elseif(stringmatch(plotmode,"MDC"))
		Label bottom "\\F'Arial'\\Z20 k\B//\M\Z20 (Å\S-1\M\Z20)"
		else
		Label bottom "\\F'Arial'\\Z20 angle (deg)"
	endif
End



Function ButtonProc_spinrawdata(ctrlName) : ButtonControl
	String ctrlName
	variable lnum, i
	string spinupwavelist, spindownwavelist
	controlinfo/W=AstraiosSpin popup0
	
	string currentdf=getdatafolder(1)
	if(stringmatch(currentdf,"*"+S_value+"*"))
	else
		Abort "Please set the current data folder to the choosen dataset !"
	endif	
	
	spinupwavelist=wavelist("*Spinup",";", "")
	spindownwavelist=wavelist("*Spindown",";", "")
	lnum=itemsinlist(spinupwavelist)-1
	
	Display/N=$S_value+"_rawplot"
	for(i=0; i<lnum; i+=1)
		wave spinupwave=$stringfromlist(i,spinupwavelist)
		wave spindownwave=$stringfromlist(i,spindownwavelist)
		Appendtograph spinupwave, spindownwave
		Modifygraph rgb($stringfromlist(i,spinupwavelist))=(65535,0,0), rgb($stringfromlist(i,spindownwavelist))=(0,0,65535)
	endfor
	Spinrawplot()
End

static Function Spinrawplot()
	ModifyGraph width=340.157,height=255.118
	ModifyGraph lsize=2
	ModifyGraph/Z mode[2]=4,marker[2]=8,msize[2]=3,mrkThick[2]=1
	Label left "\\F'Arial'\\Z20 Intensity";DelayUpdate
	ModifyGraph standoff(bottom)=0
	ModifyGraph tick=2,mirror=1,fSize=14,axThick=2,font="Arial"
	ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28	
		
	TextBox/C/N=text0/F=0/B=1/A=MC "\\F'Arial'\\Z20\\s(#0)spinup\r\\s(#1)spindown"
	string plotmode
	prompt plotmode "Please choose the plot mode: " popup "EDC;ADC;MDC"
	doprompt "", plotmode
	if(V_flag)	
		return -1
	endif
	
	if(stringmatch(plotmode,"EDC"))
		Label bottom "\\F'Arial'\\Z20 Energy (eV)"
		elseif(stringmatch(plotmode,"MDC"))
		Label bottom "\\F'Arial'\\Z20 k\B//\M\Z20 (Å\S-1\M\Z20)"
		else
		Label bottom "\\F'Arial'\\Z20 angle (deg)"
	endif
End


Function ButtonProc_Spinstatistics(ctrlName) : ButtonControl
	String ctrlName
	String spinpolwavelist, logtext
	variable lnum, i, j, spinsize, Sherman
	string statmode
	
	controlinfo/W=AstraiosSpin popup0
	
	string currentdf=getdatafolder(1)
	if(stringmatch(currentdf,"*"+S_value+"*"))
	else
		Abort "Please set the current data folder to the choosen dataset !"
	endif	
	
	prompt statmode "Please choose the statistics calculation mode for "+S_value+" dataset: " popup "Poisson;loop statistics"
	doprompt "", statmode
	if(V_flag)
		return -1 //user cancel
	endif

	if(stringmatch(statmode,"loop statistics"))
	spinpolwavelist=wavelist("*Spinpol",";", "")
	lnum=itemsinlist(spinpolwavelist)-1
	spinsize=dimsize($stringfromlist(0,spinpolwavelist),0)
	
	make/O/N=(spinsize) Spin_sdev, Spin_sem
	make/O/N=(lnum) stattemp
	for(i=0; i<spinsize; i+=1)
		for(j=0; j<lnum; j+=1)
			wave currentwave=$stringfromlist(j,spinpolwavelist)
			stattemp[j]=	currentwave[i]
		endfor
		wavestats/q stattemp
		Spin_sdev[i]=V_sdev
		Spin_sem[i]=V_sem
	endfor
	
	duplicate/O Spin_sdev, $S_value+"Spin_sdev"
	duplicate/O Spin_sem, $S_value+"Spin_sem"
	Edit/K=0 $S_value+"Spin_sem"
	logtext="Calculate the standard derivation and standard error of the mean for "+num2str(lnum)+" loops of Spin data in "+S_value+" folder as Spin_sdev and Spin_sem; \r" 
	Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
	
	killwaves/Z stattemp, Spin_sdev, Spin_sem
	
	elseif(stringmatch(statmode,"Poisson"))
	
	nvar Shermantemp=$S_value+"_Sherman"
	if(nvar_exists(Shermantemp)!=1)
		prompt Sherman "Previous value stored when sum up is missing, please enter the Sherman function to calculate error bar:"
		doprompt "", Sherman
		if(V_flag)
			return -1 //user cancel
		endif
		Shermantemp=Sherman
	endif
	
	spinpolwavelist=wavelist("*Spinpol",";", "")
	lnum=itemsinlist(spinpolwavelist)-1
	
	wave spinupwave=$stringfromlist(lnum,wavelist("*Spinup",";", ""))
	//print stringfromlist(lnum,wavelist("*Spinpol",";", ""))
	wave spindownwave=$stringfromlist(lnum,wavelist("*Spindown",";", ""))
	wave spinpolwave=$stringfromlist(lnum,wavelist("*Spinpol",";", ""))
	
	duplicate/O spinpolwave, $S_value+"Spin_error"
	wave spinerrorwave=$S_value+"Spin_error"
	spinerrorwave=sqrt(2*(spinupwave^2+spindownwave^2))/(spinupwave+spindownwave)^(3/2)/shermantemp
	//Assume possion statistics for spinup and spindown independently, and Sherman function as a constant. Using error propagation formula to calculated error bar. 
	//Formula adapted from Yichen Zhang and et al. Observation of mirror-­ odd and mirror-­ even spin texture in ultrathin epitaxially strained RuO2 films. Sci. Adv. 12, eaec2917.
	
	Edit/K=0 $S_value+"Spin_error"
	logtext="Calculate the Poission distribution error for "+num2str(lnum)+" loops of Spin data in "+S_value+" folder as Spin_error; \r" 
	Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
	
	killwaves/Z spinupwave, spindownwave, spinpolwave
	endif
End




