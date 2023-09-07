#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
Function DFTbandload()
	newpath/Q/O DFTloadpath
	string datfilelist=indexedfile(DFTloadpath,-1,".dat")
	string labellist="none;"+indexedfile(DFTloadpath,-1,"????")
	string DFTbandfile, DFTklabel, DFTloadname
 
	prompt DFTloadname, "Enter the DFT calculated band name:"
	prompt DFTbandfile, "Choose the DFT band file:" popup datfilelist
	prompt DFTklabel, "Choose the DFT klabel file:" popup labellist
	doprompt "", DFTloadname, DFTbandfile, DFTklabel
	if(V_flag)
		return -1
	endif
	
	newdatafolder/O/S $DFTloadname
	loadwave/A/Q/G/D/L={0,0,0,0,2}/p=DFTloadpath DFTbandfile
	
	string bandlist=wavelist("wave*", ";", "")
	variable bandnum=itemsinlist(bandlist, ";")
	variable i, j, Elow, Ehigh
	Display;Delayupdate
	for(i=0; i< (bandnum+1)/2; i+=1)
		wave currentkwave=$"wave"+num2str(2*i)
		wave currentewave=$"wave"+num2str(2*i+1)
		duplicate/O currentkwave, $"momentum"+num2str(i)
		duplicate/O currentewave, $"energy"+num2str(i)
		AppendtoGraph $"energy"+num2str(i) vs $"momentum"+num2str(i)
		killwaves currentkwave, currentewave
	endfor
	//prompt Elow "Enter the low energy for plot:"
	//prompt Ehigh "Enter the high energy for plot:"
	//doprompt "", Elow, Ehigh
	//if(V_flag)
	//	return -1
	//endif
	if(stringmatch(DFTklabel,"none")!=1)
		loadwave/N/Q/J/K=0/V={" ", " $",0,1}/L={0,0,0,0,2}/p=DFTloadpath DFTklabel
	wave/T wave0, wave1
	
	j=0
	for(i=1; i<dimsize(wave0,0);i+=1)
		if(stringmatch(wave0[i], "")!=1)
			j+=1
		else
			break
		endif
	endfor
	make/T/O/N=(j) klabel
	make/O/N=(j) kpos
	
	for(i=1; i<=j;i+=1)
		klabel[i-1]=trimstring(wave0[i],1)
		kpos[i-1]=str2num(wave1[i])
	endfor
	
	killwaves wave0, wave1
	endif
	
	//SetAxis left Elow, Ehigh
	SetAxis left -3, 1
	Label left "\\F'Times New Roman'\\Z24\\f02E-E\\BF\\M\\f00 (eV)"
	ModifyGraph zero(left)=4,zeroThick(left)=2
	ModifyGraph mode=3,marker=8,msize=1,mrkThick=1
	ModifyGraph tick=2,mirror=1,fSize=24,axThick=2,standoff=0,font="Times New Roman"
	ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28,width=340.157,height=255.118
	if(stringmatch(DFTklabel,"none")!=1)
		ModifyGraph userticks(bottom)={:kpos,:klabel}
	else
		Label bottom "\\F'Times New Roman'\\Z24\\f00k (Å\\S-1\\M\\Z24)"
	endif
	setdatafolder root:
End

Function DFTbandorbital()
	string ywaveliststr, xwavestr, orbital
	variable i
	prompt orbital "Choose the orbital:" popup "s;p;d"
	doprompt "",orbital
	if(V_flag)
		return -1
	endif
		
	ywaveliststr=tracenamelist("",";",1)
	for(i=0; i<itemsinlist(ywaveliststr); i+=1)
		wave s=$"s"+num2str(i)
		wave px=$"px"+num2str(i)
		wave py=$"py"+num2str(i)
		wave pz=$"pz"+num2str(i)
		wave dxy=$"dxy"+num2str(i)
		wave dyz=$"dyz"+num2str(i)
		wave dzs=$"dzs"+num2str(i)
		wave dxz=$"dxz"+num2str(i)
		wave dxsys=$"dxsys"+num2str(i)
		
		if(stringmatch(orbital,"s"))
		duplicate/O s, orbitalwave
		orbitalwave=s
		elseif(stringmatch(orbital,"p"))
		duplicate/O px, orbitalwave
		orbitalwave=px+py+pz
		else
		duplicate/O dxy, orbitalwave
		orbitalwave=dxy+dyz+dzs+dxz+dxsys
		endif
		duplicate/O orbitalwave, $"size"+num2str(i)	
 		ModifyGraph zColor($"energy"+num2str(i))={$"size"+num2str(i),*,*,Red,1}

	endfor
	killwaves orbitalwave
End

Function pathbandtrack()
	string ywaveliststr, xwavestr, kstr, kpath, folderstr
	wave/T klabel
	wave kpos
	variable i, j, k, k1, k2, E1, E2
	
	ywaveliststr=tracenamelist("",";",1)
	kstr=""
	if(waveexists(klabel) && waveexists(kpos))
		variable knum=dimsize(klabel,0)
		for(i=0; i<knum-1; i+=1)
			kstr=Addlistitem(klabel[i]+"_"+klabel[i+1],kstr)
		endfor
		
		E1=-3; E2=1
		prompt kpath "Choose the high symmetry path:" popup kstr
		prompt E1 "Enter the minimum energy:"
		prompt E2 "Enter the maximum energy:"
		doprompt "", kpath, E1, E2
		if(V_flag)
			return -1
		endif
		for(i=0; i<knum-1; i+=1)
			if(stringmatch(klabel[i]+"_"+klabel[i+1], kpath))
				k1=kpos[i]
				k2=kpos[i+1]
			endif
		endfor
	else
		Abort "No momentum label and position wave!"
	endif

	j=0
	for(i=0; i<itemsinlist(ywaveliststr); i+=1)
		wave ywave=$stringfromlist(i, ywaveliststr, ";")
		if(wavemin(ywave)<=E2 && wavemax(ywave)>=E1)
			xwavestr=xwavename("", stringfromlist(i, ywaveliststr, ";"))
			wave xwave=$xwavestr
			duplicate/O ywave, $"energy"+kpath+num2str(j)
			duplicate/O xwave, $"momentum"+kpath+num2str(j)
			wave newywave=$"energy"+kpath+num2str(j)
			wave newxwave=$"momentum"+kpath+num2str(j)
			variable size=dimsize(newxwave,0)
			for(k=0; k<size; k+=1)
				if(newxwave[k]<k1 || newxwave[k]>k2)
					newxwave[k]=nan
					newywave[k]=nan
				endif
			endfor
			j+=1
		endif
	endfor
	
	string newwaveliststr=wavelist("energy"+kpath+"*",";","DIMS:1")
	size=itemsinlist(newwaveliststr)
	
	Display; Delayupdate
	for(k=0; k<size; k+=1)
		wave newywave=$stringfromlist(k,newwaveliststr)
		wave newxwave=$replacestring("energy",stringfromlist(k,newwaveliststr),"momentum")
		AppendtoGraph newywave vs newxwave
	endfor
	SetAxis left E1, E2
	Label left "\\F'Times New Roman'\\Z24\\f02E-E\\BF\\M\\f00 (eV)"
	ModifyGraph zero(left)=4,zeroThick(left)=2
	ModifyGraph mode=3,marker=8,msize=1,mrkThick=1
	ModifyGraph tick=2,mirror=1,fSize=24,axThick=2,standoff=0,font="Times New Roman"
	ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28
End



Function pathbandsymmetry()
	string pathbandstr=wavelist("energy*", ";", "win:")
	if(stringmatch(pathbandstr,""))
		Abort "Bring the graph of path band to top!"
	endif
	string kpathlabel=replacestring("energy", stringfromlist(0,pathbandstr,";"), "")
	splitstring/E=".*_" kpathlabel
	string k1=removeending(S_value,"_")
	string k2=removeending(replacestring(S_value, kpathlabel, ""))
	
	wave/T klabel
	wave kpos
	variable i, j, m1, m2, m0
	string k0
	for(i=0; i<dimsize(kpos,0); i+=1)
		if(stringmatch(klabel[i],k1)==1 && stringmatch(klabel[i+1],k2)==1)
			m1=kpos[i]; m2=kpos[i+1]
		endif
	endfor
	
	prompt k0 "Choose the symmetry point:" popup k1+";"+k2
	doprompt "", k0
	if(V_flag)
		return -1
	endif
	if(stringmatch(k0,k1))
		m0=m1
	else
		m0=m2
	endif
	j=itemsinlist(pathbandstr)
	for(i=0; i<j; i+=1)
		wave ywave=$stringfromlist(i,pathbandstr,";")
		wave xwave=$xwavename("",stringfromlist(i,pathbandstr,";"))
		xwave-=m0
		duplicate/O xwave, $xwavename("",stringfromlist(i,pathbandstr,";"))+"1"
		wave x1wave=$xwavename("",stringfromlist(i,pathbandstr,";"))+"1"
		x1wave*=-1
		appendtograph ywave vs x1wave
	endfor
	ModifyGraph mode=3,marker=8,msize=1,mrkThick=1
	SetAxis bottom m1-m2, m2-m1
End