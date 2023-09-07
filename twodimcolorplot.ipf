#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
Function twodimcolorplot()
	string str1, str2, newstr, loadstr
	variable factor=1
	variable gam=1
	prompt str1 "Please choose polarized wave1:" popup wavelist("*",";","DIMS:2;!*color*")
	prompt str2 "Please choose polarized wave2:" popup wavelist("*",";","DIMS:2;!*color*")
	prompt newstr "Please enter the new wave name:"
	prompt factor "Please enter the norm factor:(=1 for CD and Sherman function for spin ARPES plot)"
	prompt loadstr "Load the two dimensional color scale wave?" popup "Yes;No"
	prompt gam "Enter the gamma value for color plot:"
	doprompt "", str1, str2, newstr, factor, loadstr, gam 
	if(V_Flag)
		return -1
	endif
	
	if(gam<=1)
		gam=1
	endif
	duplicate/O $str1, temp1
	duplicate/O $str2, temp2
	duplicate/O $str1, difflabel, Intlabel
	difflabel=(temp1-temp2)/(temp1+temp2)/factor
	Intlabel=(temp1+temp2)/2
	
	variable Int0=wavemin(Intlabel), Int1=wavemax(Intlabel)
	variable diff0=wavemin(difflabel), diff1=wavemax(difflabel)	
	variable xsize, ysize, xdelta, ydelta, xoff, yoff
	
	xsize=dimsize(Intlabel,0); ysize=dimsize(Intlabel,1)
	xdelta=dimdelta(Intlabel,0); ydelta=dimdelta(Intlabel,1)
	xoff=dimoffset(Intlabel,0); yoff=dimoffset(Intlabel,1)
	make/O/N=(xsize, ysize,3) $newstr
	wave newwave=$newstr
	SetScale /P x, xoff, xdelta, "", newwave 
	SetScale /P y, yoff, ydelta, "", newwave 
	variable i, j
	variable diff=min(abs(diff0),abs(diff1))
	variable diff2=diff
	prompt diff2 "The polarization between "+str1+" and "+str2+" is "+num2str(diff0)+" to "+num2str(diff1)+". Please enter the polarization scale for plot (<= 1):"
	doprompt "", diff2
	if(V_flag)
		return -1
	endif
	if(diff2>1||diff2<-1)
		diff2=1
	endif
	
	for(i=0; i<xsize; i+=1)
		for(j=0; j<ysize; j+=1)
	 		if(difflabel[i][j]>=0)
	 			if(difflabel[i][j]>abs(diff2))
	 				difflabel[i][j]=abs(diff2)	
	 			endif	
	 			newwave[i][j][0]=((1-difflabel[i][j]/diff2)*((Int1-Intlabel[i][j])/(Int1-Int0))^gam+difflabel[i][j]/diff2)*65535
	 			newwave[i][j][1]=((Int1-Intlabel[i][j])/(Int1-Int0))^gam*65535
	 			newwave[i][j][2]=((Int1-Intlabel[i][j])/(Int1-Int0))^gam*65535
	 		else
	 			if(difflabel[i][j]<-abs(diff2))
	 				difflabel[i][j]=-abs(diff2)	
	 			endif
	 			newwave[i][j][0]=((Int1-Intlabel[i][j])/(Int1-Int0))^gam*65535
	 			newwave[i][j][1]=((Int1-Intlabel[i][j])/(Int1-Int0))^gam*65535
	 			newwave[i][j][2]=((1+difflabel[i][j]/diff2)*((Int1-Intlabel[i][j])/(Int1-Int0))^gam-difflabel[i][j]/diff2)*65535
	 		endif	 	
	 	endfor
	endfor 
	Display; Delayupdate
	AppendImage $newstr
	twodimcolorplotset()
	duplicate/O Intlabel, $newstr+"_Int"
	Display; Delayupdate
	AppendImage $newstr+"_Int"
	twodimcolorplotset()
	ModifyImage $newstr+"_Int" ctab= {*,*,Grays,1}
	if(stringmatch(loadstr,"Yes"))
		twodimcolorscalegeneration(abs(diff2), gam)
	endif
	killwaves temp1, temp2, difflabel, Intlabel 
End

Function twodimcolorplotset()
	ModifyGraph/Z tick=2
	ModifyGraph/Z mirror=1
	ModifyGraph/Z font="Times New Roman"
	ModifyGraph/Z fSize=20, fStyle=1
	ModifyGraph/Z standoff=0 
	ModifyGraph swapXY=1, zero(left)=4, axThick=2
	Label/Z left "\\F'Times New Roman'\\Z24\f02E-E\BF\M\F'Times New Roman'\\Z24\f00 (eV)"
	Label/Z bottom "\\F'Times New Roman'\\Z24\f00k\B//\M\F'Times New Roman'\\Z24 (Å\S-1\M\F'Times New Roman'\\Z24)"
	ModifyGraph margin(left)=70,margin(bottom)=56,margin(right)=28,margin(top)=28,width=269.291,height=340.157
End

Function twodimcolorscalegeneration(diffscale, gam)
	variable diffscale, gam
	variable j
	make/O/N=(101,101,3) twodimcolorscale
	for(j=0; j<=50; j+=1)
		twodimcolorscale[][j][0]=((100-p)/100)^gam*65535
		twodimcolorscale[][j][1]=((100-p)/100)^gam*65535
		twodimcolorscale[][j][2]=(j/50*((100-p)/100)^gam+(50-j)/50)*65535
	endfor
	for(j=51; j<=100; j+=1)
		twodimcolorscale[][j][0]=((2-j/50)*((100-p)/100)^gam+(j-50)/50)*65535
		twodimcolorscale[][j][1]=((100-p)/100)^gam*65535
		twodimcolorscale[][j][2]=((100-p)/100)^gam*65535
	endfor
	wave twodimcolorscale
	Display; Delayupdate
	AppendImage twodimcolorscale
	ModifyGraph tick=2,mirror=1,axThick=2,standoff=0
	ModifyGraph noLabel(bottom)=1, tick(bottom)=3
	SetScale/I y -diffscale,+diffscale,"", twodimcolorscale
	ModifyGraph fSize(left)=20,font(left)="Times New Roman"
	ModifyGraph margin(left)=56,margin(bottom)=28,margin(right)=28,margin(top)=28,width=226.772,height=170.079
End