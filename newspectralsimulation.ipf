#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function newsimpanel()
	dowindow/f spectralpanel
	if(V_Flag!=1)
		Execute "spectralpanel()"	
	endif
End

Window spectralpanel() : Panel

	variable/g simk1=0, simk2=0.5
	variable/g simE1=-0.5, simE2=0.1
	variable/g simT=10, simkT=0.86
	variable/g d0=5
	variable/g g0=0.01
	variable/g simk0=0, simalpha=0, simE0=0
	variable/g dispindicator=0
	variable/g FLselfalpha=0, FLselfbeta=0
	variable/g MFLselflambda=0, MFLselfwc=0
	variable/g epselfImsigma=0, epselfwp=0
	variable/g simselfoption=1
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(250,120,490,580) 
	SetVariable setvar0,pos={10.00,10.00},size={60.00,22.00},proc=SetVarProcspectralk1
	SetVariable setvar0,font="Times New Roman",fSize=16,limits={-inf,inf,0.1},value= _NUM:0
	SetVariable setvar1,pos={160.00,10.00},size={60.00,22.00},proc=SetVarProcspectralk2
	SetVariable setvar1,font="Times New Roman",fSize=16,limits={-inf,inf,0.1},value= _NUM:0.5
	TitleBox title0,pos={75.00,5.00},size={78.00,34.00},title="< k (Å\\S-1\\M) <",fixedSize=1,size={78,30}
	TitleBox title0,font="Times New Roman",fSize=16,anchor= MC
	SetVariable setvar2,pos={10.00,40.00},size={60.00,22.00},proc=SetVarProcspectralE1
	SetVariable setvar2,font="Times New Roman",fSize=16,limits={-inf,inf,0.1},value= _NUM:-0.5
	SetVariable setvar3,pos={155.00,40.00},size={60.00,22.00},proc=SetVarProcspectralE2
	SetVariable setvar3,font="Times New Roman",fSize=16,limits={-inf,inf,0.1},value= _NUM:0.1
	TitleBox title1,pos={75.00,40.00},size={75.00,27.00},title="< E (eV) <"
	TitleBox title1,font="Times New Roman",fSize=16,anchor= MC
	SetVariable setvar4,pos={10.00,70.00},size={75.00,22.00},title="T (K)",limits={0,inf,0},value= _NUM:10
	SetVariable setvar4,font="Times New Roman",fSize=16,proc=SetVarProcspectralT
	SetVariable setvar5,pos={90,70},size={115.00,22.00},title="kBT (meV)",limits={0,inf,0},value= _NUM:0.86
	SetVariable setvar5,font="Times New Roman",fSize=16,proc=SetVarProcspectralkT
	SetVariable setvar6,pos={5.00,115.00},title="ImΣ\\B0\\M (meV)",size={120,25},bodyWidth=45,value= _NUM:5,limits={0,inf,0}
	SetVariable setvar6,font="Times New Roman",fSize=16,proc=SetVarProcspectrald0
	SetVariable setvar7,pos={10.00,145.00},size={119.00,22.00},bodyWidth=45,title="Gausswidth",limits={0,inf,0},value= _NUM:0.01
	SetVariable setvar7,font="Times New Roman",fSize=16,proc=SetVarProcspectralg0
	TabControl tab0,pos={5.00,190.00},size={200.00,100.00}
	TabControl tab0,labelBack=(0,0,65535,38550),font="Times New Roman",fSize=12
	TabControl tab0,fStyle=0,tabLabel(0)="Linear",tabLabel(1)="parabolic",tabLabel(2)="Diraccone",value= 0
	TabControl tab0,proc=TabProcsimulatindispersion
	TitleBox tab0_title title="α(k-kf)",pos={15,215},anchor=MC,font="Times New Roman",frame=5,fSize=16,fstyle=1,fColor=(65535,65535,65535)
	SetVariable tab0_var1,pos={15.00,250.00},size={50.00,22.00},title="α"
	SetVariable tab0_var1,font="Times New Roman",fSize=16,limits={-inf,inf,0},value= simalpha,proc=SetVarProc_tab0var1
	SetVariable tab0_var2,pos={75.00,250.00},size={60.00,22.00},title="kf"
	SetVariable tab0_var2,font="Times New Roman",fSize=16,limits={-inf,inf,0},value= simk0,proc=SetVarProc_tab0var2
	Button button0,pos={135.00,100.00},size={85.00,35.00},title="Simulation"
	Button button0,font="Times New Roman",fSize=16,fStyle=1,proc=Buttonproc_newspectrasimu
	TitleBox title2,pos={5.00,295.00},size={150.00,30.00},title="FL: αω + iβ[ω\\S2\\M+(πk\\BB\\MT)\\S2\\M]"
	TitleBox title2,font="Times New Roman",fSize=14,anchor= MC,fixedSize=1
	SetVariable setvar8,pos={10.00,330.00},size={50.00,18.00},proc=SetVarProcsimFLselfalpha,title="α"
	SetVariable setvar8,font="Times New Roman",limits={0,inf,0},value= _NUM:0
	SetVariable setvar9,pos={70.00,330.00},size={50.00,18.00},proc=SetVarProcsimFLselfbeta,title="β"
	SetVariable setvar9,font="Times New Roman",limits={-inf,0,0},value= _NUM:0
	TitleBox title3,pos={5.00,350.00},size={200.00,25.00},title="MFL: λ[ωln(x/ω\\Bc\\M) - iπ/2 x]; x=max(ω, T)"
	TitleBox title3,font="Times New Roman",anchor= MC,fixedSize=1
	SetVariable setvar10,pos={10.00,380.00},size={50.00,18.00},proc=SetVarProcsimMFLselflambda,title="λ"
	SetVariable setvar10,font="Times New Roman",limits={0,inf,0},value= _NUM:0
	SetVariable setvar11,pos={65.00,380.00},size={80.00,20.00},proc=SetVarProcsimMFLselfwc,title="ω\\Bc\\M (meV)"
	SetVariable setvar11,font="Times New Roman",limits={0,inf,0},value= _NUM:0
	TitleBox title4,pos={5.00,405.00},size={64.00,23.00},title="\\f02e-p\\f00 couple: "
	TitleBox title4,font="Times New Roman",anchor= MC
	SetVariable setvar12,pos={70.00,405.00},size={90.00,20.00},title="ImΣ\\Bep \\M(meV)",proc=SetVarProcsimepselfImsigma
	SetVariable setvar12,font="Times New Roman",limits={0,inf,0},value= _NUM:0
	SetVariable setvar13,pos={165.00,405.00},size={70.00,20.00},proc=SetVarProcsimepselfwp,title="Ω\\Bp\\M (meV)"
	SetVariable setvar13,font="Times New Roman",limits={0,inf,0},value= _NUM:0
	PopupMenu popup0,pos={160.00,300.00},size={70.00,21.00},bodyWidth=70,proc=PopMenuProc_simselfenergyoption
	PopupMenu popup0,font="Times New Roman",mode=1,popvalue="none",value= #"\"none;FL;MFL;e-p;FL+e-p;FL+MFL\""
	Button button1,pos={140.00,140.00},size={70.00,30.00},proc=ButtonProc_spectrasimuexport,title="Export"
	Button button1,font="Times New Roman",fSize=16,fStyle=1

EndMacro

Function SetVarProcspectralk1(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g simk1=varNum
End

Function SetVarProcspectralk2(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g simk2=varNum
End

Function SetVarProcspectralE1(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g simE1=varNum
End

Function SetVarProcspectralE2(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g simE2=varNum
End

Function SetVarProcspectralT(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g simT=varNum
	SetVariable setvar5 value= _NUM:0.086*simT
End

Function SetVarProcspectralkT(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g simkT=varNum
	SetVariable setvar4 value= _NUM:simkT/0.086
End

Function SetVarProcspectrald0(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g d0=varNum
End

Function SetVarProcspectralg0(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g g0=varNum
End

Function SetVarProcsimFLselfalpha(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g FLselfalpha=varNum
End

Function SetVarProcsimFLselfbeta(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g FLselfbeta=varNum
End

Function SetVarProcsimMFLselflambda(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g MFLselflambda=varNum
End

Function SetVarProcsimMFLselfwc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g MFLselfwc=varNum
End

Function SetVarProcsimepselfImsigma(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g epselfImsigma=varNum
End

Function SetVarProcsimepselfwp(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g epselfwp=varNum
End

Function PopMenuProc_simselfenergyoption(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable/g simselfoption=popNum
End


///////////////////////////////////////tab to generate different types dispersion/////////////////////////////////////////////
Function TabProcsimulatindispersion(ctrlName,tabNum) : TabControl
	String ctrlName
	Variable tabNum
	variable istab0, istab1, istab2
	variable/g dispindicator=0 
	variable/g simk0, simalpha, simE0
	//tab0
	TitleBox tab0_title title="α(k-kf)",pos={15,215},anchor=MC,font="Times New Roman",frame=5,fSize=16,fstyle=1,fColor=(65535,65535,65535)
	SetVariable tab0_var1,pos={15.00,250.00},size={50.00,22.00},title="α"
	SetVariable tab0_var1,font="Times New Roman",fSize=16,limits={-inf,inf,0},value= simalpha,proc=SetVarProc_tab0var1
	SetVariable tab0_var2,pos={75.00,250.00},size={60.00,22.00},title="kf"
	SetVariable tab0_var2,font="Times New Roman",fSize=16,limits={-inf,inf,0},value= simk0,proc=SetVarProc_tab0var2
	//tab1
	TitleBox tab1_title title="α(k-k0)\\S2\\M+E0",pos={10,215},anchor=MC,font="Times New Roman",frame=5,fSize=16,fstyle=1,fColor=(65535,65535,65535)
	TitleBox tab1_title fixedSize=1,size={95,30}
	SetVariable tab1_var1,pos={15.00,250.00},size={50.00,22.00},title="α"
	SetVariable tab1_var1,font="Times New Roman",fSize=16,limits={-inf,inf,0},value=simalpha,proc=SetVarProc_tab1var1
	SetVariable tab1_var2,pos={75.00,250.00},size={60.00,22.00},title="k0"
	SetVariable tab1_var2,font="Times New Roman",fSize=16,limits={-inf,inf,0},value=simk0,proc=SetVarProc_tab1var2
	SetVariable tab1_var3,pos={140.00,250.00},size={60.00,22.00},title="E0"
	SetVariable tab1_var3,font="Times New Roman",fSize=16,limits={-inf,inf,0},value=simE0,proc=SetVarProc_tab1var3
	//tab2
	TitleBox tab2_title title="±α|k-k0|+ED",pos={10,215},anchor=MC,font="Times New Roman",frame=5,fSize=16,fstyle=1,fColor=(65535,65535,65535)
	TitleBox tab2_title fixedSize=1,size={95,30}
	SetVariable tab2_var1,pos={15.00,250.00},size={50.00,22.00},title="α"
	SetVariable tab2_var1,font="Times New Roman",fSize=16,limits={-inf,inf,0},value=simalpha,proc=SetVarProc_tab2var1
	SetVariable tab2_var2,pos={75.00,250.00},size={60.00,22.00},title="k0"
	SetVariable tab2_var2,font="Times New Roman",fSize=16,limits={-inf,inf,0},value=simk0,proc=SetVarProc_tab2var2
	SetVariable tab2_var3,pos={140.00,250.00},size={60.00,22.00},title="ED"
	SetVariable tab2_var3,font="Times New Roman",fSize=16,limits={-inf,inf,0},value=simE0,proc=SetVarProc_tab2var3
	
	string s0=ControlNamelist("",";","tab0_*")
	ModifyControlList s0, disable=!(tabNum==0)
	string s1=ControlNamelist("",";","tab1_*")
	ModifyControlList s1, disable=!(tabNum==1)
	string s2=ControlNamelist("",";","tab2_*")
	ModifyControlList s2, disable=!(tabNum==2)
	
	return 0
End


Function SetVarProc_tab0var1(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g simalpha=varNum
End


Function SetVarProc_tab0var2(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g simk0=varNum
End

Function SetVarProc_tab1var1(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g simalpha=varNum
End

Function SetVarProc_tab1var2(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g simk0=varNum
End


Function SetVarProc_tab1var3(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g simE0=varNum
End

Function SetVarProc_tab2var1(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g simalpha=varNum
End

Function SetVarProc_tab2var2(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g simk0=varNum
End

Function SetVarProc_tab2var3(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g simE0=varNum
End
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////New dispersion and spectra generation///////////////////////////////////////////////////////////////
Function ButtonProc_newspectrasimu(ctrlName) : ButtonControl
	String ctrlName
	variable xsize, ysize
	variable/g simk1, simk2, simE1, simE2
	 
	ysize=(simk2-simk1)*1000+1
	xsize=(simE2-simE1)*1000+1
	make/O/N=(xsize,ysize) spectralsimu
	spectralsimu[][]=0
	make/O/N=(ysize) baredispersion
	setscale/I x simE1, simE2, "", spectralsimu
	setscale/I y simk1, simk2, "", spectralsimu
	setscale/I x simk1, simk2, "", baredispersion
	
	newdispersiongeneration()
	FDdistributionsim()
	gaussdistributionsim()
	
	wavestats/Q spectralsimu 
	variable V1=V_avg
	spectralsimu+=gnoise(V1/20)
	newspectralplot()
End


Function newdispersiongeneration()
	wave spectralsimu, baredispersion
	variable/g d0
	variable/g dispindicator, simselfoption
	variable/g FLselfalpha, FLselfbeta,	MFLselflambda, MFLselfwc, epselfImsigma, epselfwp, simkT
	variable/g simalpha, simE0, simk0
	controlinfo/W=spectralpanel tab0
	dispindicator=V_value
	if(dispindicator==0)  // linear dispersion, all types self energy can be coupled into the dispersion simulation
		switch(simselfoption)
			case 1:
				spectralsimu[][]=1/pi*(d0/1000)/((x-linear(simalpha,simk0,y))^2+(d0/1000)^2)
			break;
			case 2:
				spectralsimu[][]=1/pi*(d0/1000+FLImsigma(FLselfbeta,simkT/1000,x))/((x-linear(simalpha,simk0,y)-FLResigma(FLselfalpha,x))^2+(d0/1000+FLImsigma(FLselfbeta,simkT/1000,x))^2)
			break;
			case 3:
				spectralsimu[][]=1/pi*(d0/1000+MFLImsigma(MFLselflambda,simkT/1000,x))/((x-linear(simalpha,simk0,y)-MFLResigma(MFLselflambda,simkT/1000,MFLselfwc/1000,x))^2+(d0/1000+MFLImsigma(MFLselflambda,simkT/1000,x))^2)
			break;
			case 4:
				epselfenergygeneration()
				wave epResigma, epImsigma
				spectralsimu[][]=1/pi*(d0/1000+epImsigma[p])/((x-linear(simalpha,simk0,y)-epResigma[p])^2+(d0/1000+epImsigma[p])^2)
			break;
			case 5:
				epselfenergygeneration()
				wave epResigma, epImsigma
				spectralsimu[][]=1/pi*(d0/1000+epImsigma[p]+FLImsigma(FLselfbeta,simkT/1000,x))/((x-linear(simalpha,simk0,y)-epResigma[p]-FLResigma(FLselfalpha,x))^2+(d0/1000+epImsigma[p]+FLImsigma(FLselfbeta,simkT/1000,x))^2)
			break;
			case 6:
				spectralsimu[][]=1/pi*(d0/1000+MFLImsigma(MFLselflambda,simkT/1000,x)+FLImsigma(FLselfbeta,simkT/1000,x))/((x-linear(simalpha,simk0,y)-MFLResigma(MFLselflambda,simkT/1000,MFLselfwc/1000,x)-FLResigma(FLselfalpha,x))^2+(d0/1000+MFLImsigma(MFLselflambda,simkT/1000,x)+FLImsigma(FLselfbeta,simkT/1000,x))^2)
			break;
			default:
		endswitch
	baredispersion[]=linear(simalpha,simk0,x)
		
	elseif(dispindicator==1) // parabolic dispersion, only FL self energy is coupled into the dispersion simulation
		switch(simselfoption)
			case 1:
				spectralsimu[][]=1/pi*(d0/1000)/((x-parabolic(simalpha, simk0, simE0, y))^2+(d0/1000)^2)
			break;
			case 2:
				spectralsimu[][]=1/pi*(d0/1000+FLImsigma(FLselfbeta,simkT/1000,x))/((x-parabolic(simalpha, simk0, simE0, y)-FLResigma(FLselfalpha,x))^2+(d0/1000+FLImsigma(FLselfbeta,simkT/1000,x))^2)
			break;	
			default:
				Abort "No this type self energy for parabolic dispersion!"
			break;		
		endswitch
		
		baredispersion[]=parabolic(simalpha, simk0, simE0, x)
	elseif(dispindicator==2)
		switch(simselfoption)
			case 1:
			spectralsimu[][]=1/pi*(d0/1000)/((x-Diraccone(simalpha, simk0, simE0, y))^2+(d0/1000)^2)
			spectralsimu[][]+=1/pi*(d0/1000)/((x-Diraccone(-simalpha, simk0, simE0, y))^2+(d0/1000)^2)
			break;
			case 2:
			spectralsimu[][]=1/pi*(d0/1000+FLImsigma(FLselfbeta,simkT/1000,x))/((x-Diraccone(simalpha, simk0, simE0, y)-FLResigma(FLselfalpha,x))^2+(d0/1000+FLImsigma(FLselfbeta,simkT/1000,x))^2)
			spectralsimu[][]+=1/pi*(d0/1000+FLImsigma(FLselfbeta,simkT/1000,x))/((x-Diraccone(-simalpha, simk0, simE0, y)-FLResigma(FLselfalpha,x))^2+(d0/1000+FLImsigma(FLselfbeta,simkT/1000,x))^2)
			break;
			default:
				Abort "No this type self energy for parabolic dispersion!"
			break;
		endswitch
		baredispersion[]=Diraccone(simalpha, simk0, simE0, x)
	endif
	
End

static Function FLResigma(a1, x)
	variable a1, x
	variable f
	f=-a1*x
	return f
end

static Function FLImsigma(a1, a2, x)
	variable a1, a2, x
	variable f
	f=-a1*(x^2+(pi*a2)^2)
	return f
end

static Function MFLResigma(a1,a2,a3,x)
	variable a1, a2, a3, x
	variable f
	f=a1*(-x)*ln(max(-x,a2)/a3)
	return f
end

static Function MFLImsigma(a1,a2,x)
	variable a1, a2, x
	variable f
	f=a1*pi/2*max(-x,a2)
	return f
end

Function epselfenergygeneration()
	variable/g simE1, simE2
	variable/g epselfImsigma, epselfwp
	variable xsize, i ,j
	xsize=(simE2-simE1)*1000+1
	make/o/n=(xsize) epResigma, epImsigma
	setscale/I x simE1, simE2, "", epResigma
	setscale/I x simE1, simE2, "", epImsigma

	epImsigma[]=epselfImsigma/1000*1/(exp((x+epselfwp/1000)/(epselfwp/1000/4))+1)
	epResigma[]=0
	
	for(j=0; j<xsize; j+=1)
		for(i=0; i<xsize; i+=1)
		if(i!=j)
			epResigma[j]+=1/pi*epImsigma[i]/(j-i)
		endif
		endfor
		if(epResigma[j]<0)
			epResigma[j]=0
		endif
	endfor
	
	variable a0=wavemax(epResigma)
	
	epResigma[]=a0*(epselfwp/1000/2)^2/((x+epselfwp/1000)^2+(epselfwp/1000/2)^2)
	epResigma[x2pnt(epResigma,-epselfwp/1000),]-=a0/epselfwp*200*(pnt2x(epResigma,p)+epselfwp/1000)
	for(j=0; j<xsize; j+=1)
		if(epResigma[j]<0)
			epResigma[j]=0
		endif
	endfor
	
End

static Function linear(a1, a2, y)
	variable a1, a2, y
	variable f
	f= a1*(y-a2)
	return f
End	

static Function parabolic(a1, a2, a3, y)
	variable a1, a2, a3,  y
	variable f
	f=a1*(y-a2)^2+a3
	return f
End

static Function Diraccone(a1, a2, a3, y)
	variable a1, a2, a3,  y
	variable f
	f=a1*abs(y-a2)+a3
	return f
End


static Function FDdistributionsim()
	wave spectralsimu
	variable/g simkT
	spectralsimu[][]*=1/(exp(x/simkT*1000)+1)
	
End

static Function gaussdistributionsim()
	wave spectralsimu
	variable/g g0
	variable xsize, ysize, i,j
	xsize=dimsize(spectralsimu,0)
	ysize=dimsize(spectralsimu,1)
	
	make/O/N=(xsize) gausstemp1, temp1
	make/O/N=(ysize) gausstemp2, temp2
	duplicate/O spectralsimu, temp
	setscale/I x -1, 1, "", gausstemp1, gausstemp2
	gausstemp1[]=1/(sqrt(2*pi)*g0)*exp(-(x^2/(2*g0^2)))
	gausstemp2[]=1/(sqrt(2*pi)*g0)*exp(-(x^2/(2*g0^2)))
	for(i=0; i< ysize; i+=1)
		temp1[]=spectralsimu[p][i]
		convolve/A gausstemp1, temp1
		temp[][i]+=temp1[p]
	endfor

	for(j=0; j< xsize; j+=1)
		temp2[]=spectralsimu[j][p]
		convolve/A gausstemp2, temp2
		temp[j][]+=temp2[q]
	endfor
	
	duplicate/O temp, spectralsimu
	killwaves temp, temp1, temp2, gausstemp1, gausstemp2
End


Function newspectralplot()
	variable/g simk1, simk2, simE1, simE2
	dowindow/f newspectraplot
	if(V_flag!=1)
		Execute "spectraplotmacro()"
	else
		SetAxis/Z bottom simk1,simk2
		SetAxis/Z left simE1,simE2
	endif
End

Window spectraplotmacro()
	variable/g simk1, simk2, simE1, simE2
	Display/W=(400,100,700,350) /N=newspectraplot; Delayupdate
	AppendImage spectralsimu
	Appendtograph/vert baredispersion
	ModifyGraph mode=3,marker=8,msize=1.5,mrkThick=1
	ModifyGraph swapXY=1,margin(left)=70,margin(bottom)=56,margin(right)=28,margin(top)=28,width=255.118,height=340.157
	ModifyImage/Z spectralsimu ctab= {*,*,Terrain,1}
	ModifyGraph/Z tick=2,zero=4,mirror=1,fStyle=1,fSize=16,axThick=2
	ModifyGraph/Z zeroThick=3,standoff=0,font="Times New Roman"
	SetAxis bottom simk1,simk2
	SetAxis left simE1,simE2
	Label left "\\F'Times New Roman'\\Z24\\f02 E-E\\BF\\M\\f00\\F'Times New Roman'\\Z24 (eV)"
	Label bottom "\\F'Times New Roman'\\Z24\\f02k \\f00(Å\\S-1\\M\\F'Times New Roman'\\Z24)"
End



Function ButtonProc_spectrasimuexport(ctrlName) : ButtonControl
	String ctrlName
	String newwavenamestr
	variable/g simk1, simk2, simE1, simE2
	wave spectralsimu, baredispersion
	
	prompt newwavenamestr, "Please enter the wave name:"
	doprompt "", newwavenamestr
	if(V_flag)	
		return -1
	endif
	duplicate/O spectralsimu, $newwavenamestr+"_spectra"
	duplicate/O baredispersion, $newwavenamestr+"_disp"
	wave newspectra=$newwavenamestr+"_spectra"
	wave newdisp=$newwavenamestr+"_disp"
	Display;DelayUpdate
	AppendImage newspectra
	Appendtograph/vert newdisp
	ModifyGraph mode=3,marker=8,msize=1.5,mrkThick=1
	ModifyGraph swapXY=1,margin(left)=70,margin(bottom)=56,margin(right)=28,margin(top)=28,width=255.118,height=340.157
	ModifyImage/Z '' ctab={*,*,Terrain,1}
	ModifyGraph/Z tick=2,zero=4,mirror=1,fStyle=1,fSize=16,axThick=2
	ModifyGraph/Z zeroThick=3,standoff=0,font="Times New Roman"
	SetAxis bottom simk1,simk2
	SetAxis left simE1,simE2
	Label left "\\F'Times New Roman'\\Z24\\f02 E-E\\BF\\M\\f00\\F'Times New Roman'\\Z24 (eV)"
	Label bottom "\\F'Times New Roman'\\Z24\\f02k \\f00(Å\\S-1\\M\\F'Times New Roman'\\Z24)"
End	
