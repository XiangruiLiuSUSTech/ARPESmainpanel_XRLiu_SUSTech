#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.3
#pragma Igorversion=7.00
//This procedure is a convenient way for you to append new images/curves and modify the graph plot style.
//The buttons in upper panel can append 2D image/X-Y trace in a new window.  
//The buttons in lower right panel is to plot graphs with colorbars and extended colors in igor. You can change the parameters to plot figures in your style and new colors.
//New contents for version 1.2: Add kz map correction button, which could remove the redundant part of rotated kzmap obtained by ALS procedure in Scientaprocedure.
//New contents for version 1.3: Add DA30 MAP correction button, which could remove the bad points in the map obtained in DA30 mode.
//Xiangrui Liu, 2021-09-15. Email:12031049@mail.sustech.edu.cn
Menu "Extended Procedures"
     "NewPlotPanel/2", CreateNewPlotPanel ()
End

Window CreateNewPlotPanel() : Panel
	variable/g ColorTableInvertCheck=1
	variable/g igorcolortabgammaval=1
	String/g plotstylelist
	make/o/n=(100,3) igorcolortabwave
	igorcolortabwave[][0,2]=661*p
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(1461,157,1842,675) as "Graphplotstyle"
	ModifyPanel cbRGB=(0,65535,0)
	SetDrawLayer UserBack
	SetDrawEnv linethick= 2
	DrawLine 1,124,467,124
	SetDrawEnv linethick= 2
	DrawLine 175,124,175,526
	Button button0,pos={207.00,6.00},size={160.00,53.00},proc=Get_plot_Imagewave,title="NewImageAppend"
	Button button0,font="Times New Roman",fSize=20
	Button button1,pos={208.00,62.00},size={162.00,52.00},proc=Get_plot_curvewaves,title="NewCurveAppend"
	Button button1,font="Times New Roman",fSize=20
	Button button5,pos={11.00,391.00},size={147.00,53.00},proc=EDCMDC_plot,title="EDCMDC plot"
	Button button5,font="Times New Roman",fSize=20,fColor=(65535,65535,0)
	Button button7,pos={5.00,163.00},size={147.00,66.00},proc=CreateNewColorTable,title="NewColor"
	Button button7,font="Times New Roman",fSize=24,fColor=(65535,0,65535)
	Button button8,pos={192.00,255.00},size={147.00,53.00},proc=k_Ecut_plot,title="k-E cut"
	Button button8,font="Times New Roman",fSize=24,fColor=(65535,0,0)
	Button button9,pos={192.00,308.00},size={147.00,54.00},proc=kx_kymap_plot,title="kx-ky map"
	Button button9,font="Times New Roman",fSize=24,fColor=(0,65535,0)
	Button button10,pos={192.00,362.00},size={147.00,52.00},proc=kz_map_plot,title="kz map"
	Button button10,font="Times New Roman",fSize=24,fColor=(0,0,65535)
	PopupMenu popup0,pos={192.00,169.00},size={147.00,21.00},bodyWidth=147,proc=PopMenuProc
	PopupMenu popup0,font="Times New Roman",fSize=12
	PopupMenu popup0,mode=1,value= #"\"*COLORTABLEPOP*\""
	CheckBox check0,pos={187.00,202.00},size={72.00,19.00},proc=Checkproc,title="Inverted"
	CheckBox check0,font="Times New Roman",fSize=16,fStyle=1,value= 1,side= 1
	TitleBox title2,pos={188.00,138.00},size={149.00,27.00},title="2D Plots in Igor Colors"
	TitleBox title2,labelBack=(65535,65535,65535),font="Times New Roman",fSize=16
	TitleBox title2,anchor= MC
	TitleBox title1,pos={12.00,132.00},size={142.00,27.00},title="2D Plot in New Color"
	TitleBox title1,labelBack=(65535,65535,65535),font="Times New Roman",fSize=16
	TitleBox title1,anchor= MC
	TitleBox title0,pos={10.00,10.00},size={180.00,35.00},title="New Graph Plots"
	TitleBox title0,labelBack=(65535,65535,65535),font="Times New Roman",fSize=24
	TitleBox title0,fStyle=1,anchor= MC
	Button button11,pos={192.00,427.00},size={147.00,66.00},proc=CreatenewCDPlotPanel,title="CD-ARPES plot"
	Button button11,font="Times New Roman",fSize=20
	Button button12,pos={15.00,289.00},size={145.00,50.00},proc=kzMapcorr,title="kz Map corr"
	Button button12,font="Times New Roman",fSize=24
	SetVariable setvar1,pos={187.00,229.00},size={70.00,22.00},proc=SetVarProcmin,title="min"
	SetVariable setvar1,font="Times New Roman",fSize=16,fStyle=1
	SetVariable setvar1,limits={-inf,inf,0},value= _NUM:0
	SetVariable setvar0,pos={269.00,229.00},size={70.00,22.00},proc=SetVarProcmax,title="max"
	SetVariable setvar0,font="Times New Roman",fSize=16,fStyle=1
	SetVariable setvar0,limits={-inf,inf,0},value= _NUM:0
	SetVariable setvar2,pos={5.00,237.00},size={80.00,22.00},proc=SetVarProc_plotxrangemin,title="Xmin"
	SetVariable setvar2,font="Times New Roman",fSize=16
	SetVariable setvar2,limits={-inf,inf,0},value= _NUM:0
	SetVariable setvar3,pos={87.00,237.00},size={80.00,22.00},proc=SetVarProc_plotxrangemax,title="Xmax"
	SetVariable setvar3,font="Times New Roman",fSize=16
	SetVariable setvar3,limits={-inf,inf,0},value= _NUM:0
	SetVariable setvar4,pos={5.00,264.00},size={80.00,22.00},proc=SetVarProc_yplotrangemin,title="Ymin"
	SetVariable setvar4,font="Times New Roman",fSize=16
	SetVariable setvar4,limits={-inf,inf,0},value= _NUM:0
	SetVariable setvar5,pos={87.00,263.00},size={80.00,22.00},proc=SetVarProc_plotyrangemax,title="Ymax"
	SetVariable setvar5,font="Times New Roman",fSize=16
	SetVariable setvar5,limits={-inf,inf,0},value= _NUM:0
	Button button13,pos={8.00,338.00},size={160.00,50.00},proc=DA30mapcor,title="DA30map corr"
	Button button13,font="Times New Roman",fSize=24
	SetVariable setvar6 title="γ",proc=SetVarProcgammaval,limits={0.5,inf,0.1},font="Times New Roman",fSize=16
	SetVariable setvar6 pos={275,200},size={70,22},value=igorcolortabgammaval
	Button button14,pos={10.00,60.0},size={110.00,40.00},proc=ButtonProc_Styleplot,title="Styleplot"
	Button button14,font="Times New Roman",fSize=24
	PopupMenu popup1,pos={120.00,75.00},size={26.00,23.00},proc=PopMenuProc_plotstylemacro
	PopupMenu popup1,font="Times New Roman",fSize=24,fStyle=1,mode=1,popvalue=" ",value= #"plotstylelist"

EndMacro

Proc CreatenewCDPlotPanel(ctrlName) : ButtonConrol
   String ctrlName
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(555,252,919,638) as "CD-ARPES Graphplotstyle"
	ModifyPanel cbRGB=(0,65535,32639)
	Button button0,pos={33.00,57.00},size={144.00,55.00},proc=Get_CD_LCP,title="C+   LCP"
	Button button0,font="Times New Roman",fSize=20
	Button button1,pos={184.00,57.00},size={144.00,55.00},proc=Get_CD_RCP,title="C-   RCP"
	Button button1,font="Times New Roman",fSize=20
	Button button2,pos={3.00,112.00},size={175.00,55.00},proc=Get_CD_RCPplusLCP,title="C+ + C-  LCP + RCP"
	Button button2,font="Times New Roman",fSize=20
	Button button3,pos={184.00,113.00},size={168.00,55.00},proc=Get_CD_RCPminusLCP,title="C+ - C-  LCP - RCP"
	Button button3,font="Times New Roman",fSize=20
	Button button4,pos={62.00,167.00},size={232.00,70.00},proc=Get_CD_Polarization,title="CD Polarization"
	Button button4,font="Times New Roman",fSize=24
	Button button5,pos={33.00,244.00},size={144.00,55.00},proc=k_Ecut_plot2,title="CD k-E cut"
	Button button5,font="Times New Roman",fSize=20,fColor=(65535,0,0)
	Button button6,pos={33.00,299.00},size={144.00,55.00},proc=kx_kymap_plot2,title="CD kx-ky map"
	Button button6,font="Times New Roman",fSize=20,fColor=(0,65535,0)
	TitleBox title0,pos={73.00,9.00},size={221.00,44.00},title="CD-ARPES Plot"
	TitleBox title0,labelBack=(65535,65535,65535),font="Times New Roman",fSize=32
	TitleBox title0,anchor= MC
	SetVariable setvar0,pos={270.00,304.00},size={71.00,22.00},proc=SetVarProcCDmax,title="max"
	SetVariable setvar0,font="Times New Roman",fSize=16,fStyle=1
	SetVariable setvar0,limits={-inf,inf,0},value= _NUM:0
	SetVariable setvar1,pos={189.00,304.00},size={70.00,22.00},proc=SetVarProcCDmin,title="min"
	SetVariable setvar1,font="Times New Roman",fSize=16,fStyle=1
	SetVariable setvar1,limits={-inf,inf,0},value= _NUM:0
	CheckBox check0,pos={213.00,263.00},size={72.00,19.00},proc=CheckprocCD,title="Inverted"
	CheckBox check0,font="Times New Roman",fSize=16,fStyle=1,value= 0,side= 1
	newdatafolder/O root:CD_plot
EndMacro

Function CreateNewColorTable (ctrlName) : ButtonControl
	String ctrlName
	String newcolortablewavename, extensioncolortablewavename
	variable/g igorcolortabgammaval

String extensioncolortable ="newCT:shuyunpurple;newCT:yulinblue;newCT:greenwhite;newCT:Macstyle;EPFL:ametrine;EPFL:isolum;EPFL:morgenstemning;LANL:AsymBlueGreenDivergent;LANL:AsymBlueOrangeDiv-15b2Asy;LANL:AsymBlueOrangeDiv-W5;"
       extensioncolortable +="LANL:Blue-8_31T1;LANL:BlueGreenDivergent;LANL:BlueTurquoise-8_31f;LANL:ExtendedCoolWarm;LANL:GreenGold;LANL:LinearGray4-BlueGreen;"
       extensioncolortable +="LANL:LinearGreen-9_17y;LANL:LinearYellow;LANL:MutedBlue-17b;LANL:MutedBlueGreen-upu3;LANL:OliveGreenToBlue;Matplotlib:Accent;"
       extensioncolortable +="Matplotlib:autumn;Matplotlib:Blues;Matplotlib:bone;Matplotlib:BrBG;Matplotlib:BuGn;Matplotlib:BuPu;Matplotlib:cool;Matplotlib:copper;"
       extensioncolortable +="Matplotlib:Dark2;Matplotlib:flag;Matplotlib:gist_earth;Matplotlib:gist_heat;Matplotlib:gist_ncar;Matplotlib:gist_rainbow;Matplotlib:gist_stern;"
       extensioncolortable +="Matplotlib:GnBu;Matplotlib:Greens;Matplotlib:hot;Matplotlib:hsv;Matplotlib:jet;Matplotlib:Oranges;Matplotlib:OrRd;Matplotlib:Paired;"
       extensioncolortable +="Matplotlib:Pastel1;Matplotlib:Pastel2;Matplotlib:pink;Matplotlib:piYG;Matplotlib:PRGn;Matplotlib:prism;Matplotlib:PuBu;Matplotlib:PuBuGn;"
       extensioncolortable +="Matplotlib:PuOr;Matplotlib:PuRd;Matplotlib:Purples;Matplotlib:RdBu;Matplotlib:RdGy;Matplotlib:RdPu;Matplotlib:RdYlBu;Matplotlib:RdYlGn;Matplotlib:Reds;"
       extensioncolortable +="Matplotlib:Set1;Matplotlib:Set2;Matplotlib:Set3;Matplotlib:spectral;Matplotlib:spring;Matplotlib:summer;Matplotlib:winter;Matplotlib:YlGn;"
       extensioncolortable +="Matplotlib:YlGnBu;Matplotlib:YlOrBr;Matplotlib:YlOrRd"
prompt newcolortablewavename "Please choose the extended Color Table Wave" popup extensioncolortable
doprompt "", newcolortablewavename
if(V_flag)  //user cancel
  return -1
endif

LoadWave/O/Q "D:Igor7:Color Tables:"+newcolortablewavename+".ibw"
splitstring/E=":.*" newcolortablewavename 
extensioncolortablewavename =ReplaceString(":", S_value, "")
duplicate/O $extensioncolortablewavename rawcolortab
plotcolortabandrangefunc()
killwaves $extensioncolortablewavename
End

Function PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable/g igorcolortabgammaval
	ColorTab2wave $popStr
	wave M_colors
   duplicate/O M_colors, rawcolortab
   killwaves M_colors
   plotcolortabandrangefunc()
End

Function SetVarProcgammaval(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g igorcolortabgammaval=varNum
	plotcolortabandrangefunc()
End

Function CheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	variable/g ColorTableInvertCheck=checked
	plotcolortabandrangefunc()
End

Function SetVarProcmax(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
   variable/g maxlimit
   maxlimit = varNum
End

Function SetVarProcmin(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
   variable/g minlimit
   minlimit = varNum
End

Function plotcolortabandrangefunc()
	variable/g maxlimit, minlimit, ColorTableInvertCheck, igorcolortabgammaval
	wave rawcolortab
	variable size
	duplicate/O rawcolortab, igorcolortablewave
	size=dimsize(rawcolortab,0)
	igorcolortablewave[][]=rawcolortab[size*(p/size)^igorcolortabgammaval][q]
End

Function Get_plot_Imagewave (ctrlName) : ButtonControl
String ctrlName
String Imagenameplot
variable/g maxlimit
variable/g minlimit
prompt Imagenameplot "Enter the 2D wave", popup wavelist("*",";","DIMS:2")
doprompt "",Imagenameplot
if(V_flag)
    return -1// User canceled
    endif
//if(waveexists($Imagenameplot)==0)
//  Abort "No such wave exists! Please enter the correct wave name."
//endif
wavestats/q $Imagenameplot
maxlimit=V_max
minlimit=V_min
SetVariable setvar0 value= maxlimit, win=CreateNewPlotPanel
SetVariable setvar1 value= minlimit, win=CreateNewPlotPanel
printf "minimal value of %s is:  %g\r", Imagenameplot, minlimit
printf "maximal value of %s is:  %g\r", Imagenameplot, maxlimit
Display;Delayupdate  
AppendImage $Imagenameplot
End



Function Get_plot_curvewaves (ctrlName) : ButtonControl
	String ctrlName
	String curvenameplotx, curvenameploty
	prompt curvenameplotx "Enter the X wave:", popup "calculated;"+wavelist("*",";","DIMS:1")
	prompt curvenameploty "Enter the Y wave:", popup wavelist("*",";","DIMS:1")
	doprompt "",curvenameplotx, curvenameploty
	
	if(V_flag)
    	return -1// User canceled
	endif
	if(stringmatch(curvenameplotx,"calculated")==1)
		Display $curvenameploty
	else
		if(dimsize($curvenameploty,0) != dimsize($curvenameplotx,0))
			Abort "The wave size of X and Y wave doesn't match!"
		endif
		Display $curvenameploty vs $curvenameplotx
	endif
End


Function Get_CD_LCP (ctrlName) : ButtonControl
String ctrlName
String LCP
prompt LCP "Enter the C+ wave:" popup wavelist("*",";","DIMS:2")
doprompt "",LCP
if(V_flag)
    return -1// User canceled
endif
if(waveexists(root:$LCP)==0)
 Abort "No such wave exists! Please enter the correct wave name."
endif
duplicate/O root:$LCP, root:CD_plot:LCP2D
duplicate/O root:$LCP, root:CD_plot:CDplus
End

Function Get_CD_RCP (ctrlName) : ButtonControl
String ctrlName
String RCP
prompt RCP "Enter the C- wave:" popup wavelist("*",";","DIMS:2")
doprompt "",RCP
if(V_flag)
    return -1// User canceled
    endif
if(waveexists(root:$RCP)==0)
 Abort "No such wave exists! Please enter the correct wave name."
endif
duplicate/O root:$RCP, root:CD_plot:RCP2D
duplicate/O root:$RCP, root:CD_plot:CDminus
End

Function Get_CD_RCPplusLCP (ctrlName) : ButtonControl
String ctrlName
setdatafolder root:CD_plot
wave LCP2D
wave RCP2D
wave CDplus
CDplus=RCP2D+LCP2D
Display;Delayupdate
AppendImage CDplus
ModifyImage/Z [0] ctab= {*,*,Grays,1}
	ModifyGraph/Z tick=2
	ModifyGraph/Z mirror=1
	ModifyGraph/Z font="Times New Roman"
	ModifyGraph/Z fSize=16
	ModifyGraph/Z fStyle=1
	ModifyGraph/Z standoff=0
	ModifyGraph swapXY=1 
	ModifyGraph zero(left)=4
	ModifyGraph axThick=2
	Label/Z left "\\F'Times New Roman'\\Z24\f02E-E\BF\M\F'Times New Roman'\\Z24\f00 (eV)"
	Label/Z bottom "\\F'Times New Roman'\\Z24\f00k\Bx\M\F'Times New Roman'\\Z24 (Å\S-1\M\F'Times New Roman'\\Z24)"
	ModifyGraph margin(left)=70,margin(bottom)=56,margin(right)=28,margin(top)=28,width=269.291,height=340.157
End

Function Get_CD_RCPminusLCP (ctrlName) : ButtonControl
String ctrlName
setdatafolder root:CD_plot
wave LCP2D
wave RCP2D
wave CDminus
CDminus=LCP2D-RCP2D
//Display;Delayupdate
//AppendImage CDminus
//ModifyImage/Z [0] ctab= {*,*,Grays,1}
//ModifyGraph/Z tick=2
//ModifyGraph/Z mirror=1
//ModifyGraph/Z font="Times New Roman"
//ModifyGraph/Z fSize=16
//ModifyGraph/Z fStyle=1
//ModifyGraph/Z standoff=0
//ModifyGraph zero(left)=4
//ModifyGraph swapXY=1 
//Label/Z left "\\F'Times New Roman'\\Z24\f02E-E\BF\M\F'Times New Roman'\\Z24\f00 (eV)"
//Label/Z bottom "\\F'Times New Roman'\\Z24\f00k\Bx\M\F'Times New Roman'\\Z24 (Å\S-1\M\F'Times New Roman'\\Z24)"
End

Function Get_CD_Polarization (ctrlName) : ButtonControl
String ctrlName
wave CDplus
wave CDminus
variable/g CDminlimit
variable/g CDmaxlimit
duplicate/O CDplus CD_Polarization
CD_Polarization=CDminus/CDplus
Display;Delayupdate
AppendImage CD_Polarization
wavestats/q CD_Polarization
CDmaxlimit=V_max
CDminlimit=V_min
SetVariable setvar1 value= CDminlimit
SetVariable setvar0 value= CDmaxlimit
variable/g ColorTableInvertCheck
printf "minimal value of CD_Polarization is:  %g\r",  CDminlimit
printf "maximal value of CD_Polarization is:  %g\r",  CDmaxlimit
End

Function SetVarProcCDmax(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g CDColorTableInvertCheck
   variable/g CDmaxlimit
   variable/g CDminlimit
   CDmaxlimit = varNum
   if (CDColorTableInvertCheck==1)
   PauseUpdate; Silent 1		// modifying window...
   ModifyImage/Z [0] ctab= {CDminlimit,CDmaxlimit, RedWhiteBlue ,1}
   else
   PauseUpdate; Silent 1		// modifying window...
   ModifyImage/Z [0] ctab= {CDminlimit,CDmaxlimit, RedWhiteBlue ,0}
   endif
End

Function SetVarProcCDmin(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g CDColorTableInvertCheck
   variable/g CDminlimit
   variable/g CDmaxlimit
   CDminlimit = varNum
   if (CDColorTableInvertCheck==1)
   PauseUpdate; Silent 1		// modifying window...
   ModifyImage/Z [0] ctab= {CDminlimit,CDmaxlimit, RedWhiteBlue ,1}
   else
   PauseUpdate; Silent 1		// modifying window...
   ModifyImage/Z [0] ctab= {CDminlimit,CDmaxlimit, RedWhiteBlue ,0}
   endif
End

Function CheckProccd(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	variable/g CDColorTableInvertCheck=checked
	variable/g CDminlimit
	variable/g CDmaxlimit
	if (CDColorTableInvertCheck==1)
     PauseUpdate; Silent 1		// modifying window...
     ModifyImage/Z [0] ctab= {CDminlimit,CDmaxlimit, RedWhiteBlue ,1}
   else
     PauseUpdate; Silent 1		// modifying window...
     ModifyImage/Z [0] ctab= {CDminlimit,CDmaxlimit, RedWhiteBlue ,0}
   endif
End


Function k_Ecut_plot (ctrlName) : ButtonControl
	String ctrlName
	wave igorcolortablewave
	variable/g minlimit
   variable/g maxlimit
   nvar ColorTableInvertCheck
if (ColorTableInvertCheck==1)
   PauseUpdate; Silent 1		// modifying window...
   ModifyImage/Z [0] ctab= {minlimit,maxlimit, igorcolortablewave ,1}
   else
   PauseUpdate; Silent 1		// modifying window...
   ModifyImage/Z [0] ctab= {minlimit,maxlimit,igorcolortablewave,0}
   endif
   ModifyGraph/Z tick=2
	ModifyGraph/Z mirror=1
	ModifyGraph/Z font="Times New Roman"
	ModifyGraph/Z fSize=16
	ModifyGraph/Z fStyle=1
	ModifyGraph/Z standoff=0
	ModifyGraph swapXY=1 
	ModifyGraph zero(left)=4
	ModifyGraph axThick=2
	Label/Z left "\\F'Times New Roman'\\Z24\f02E-E\BF\M\F'Times New Roman'\\Z24\f00 (eV)"
	Label/Z bottom "\\F'Times New Roman'\\Z24\f00k\B//\M\F'Times New Roman'\\Z24 (Å\S-1\M\F'Times New Roman'\\Z24)"
   ModifyGraph margin(left)=70,margin(bottom)=56,margin(right)=28,margin(top)=28,width=269.291,height=340.157
End

Proc k_Ecut_plot2 (ctrlName) : ButtonControl
String ctrlName
variable/g CDminlimit
variable/g CDmaxlimit
variable/g CDColorTableInvertCheck
if (CDColorTableInvertCheck==1)
   PauseUpdate; Silent 1		// modifying window...
   ModifyImage/Z [0] ctab= {CDminlimit,CDmaxlimit, RedWhiteBlue ,1}
   else
   PauseUpdate; Silent 1		// modifying window...
   ModifyImage/Z [0] ctab= {CDminlimit,CDmaxlimit, RedWhiteBlue ,0}
   endif
	ModifyGraph/Z tick=2
	ModifyGraph/Z mirror=1
	ModifyGraph/Z font="Times New Roman"
	ModifyGraph/Z fSize=16
	ModifyGraph/Z fStyle=1
	ModifyGraph/Z standoff=0
	ModifyGraph swapXY=1 
	ModifyGraph zero(left)=4
	ModifyGraph axThick=2
	Label/Z left "\\F'Times New Roman'\\Z24\f02E-E\BF\M\F'Times New Roman'\\Z24\f00 (eV)"
	Label/Z bottom "\\F'Times New Roman'\\Z24\f00k\B//\M\F'Times New Roman'\\Z24 (Å\S-1\M\F'Times New Roman'\\Z24)"
   ModifyGraph margin(left)=70,margin(bottom)=56,margin(right)=28,margin(top)=28,width=269.291,height=340.157
End

Function kx_kymap_plot (ctrlName) : ButtonControl
	String ctrlName
	wave igorcolortablewave
	variable/g minlimit
   variable/g maxlimit
   nvar ColorTableInvertCheck
if (ColorTableInvertCheck==1)
   PauseUpdate; Silent 1		// modifying window...
   ModifyImage/Z [0] ctab= {minlimit,maxlimit,igorcolortablewave,1}
   else
   PauseUpdate; Silent 1		// modifying window...
   ModifyImage/Z [0] ctab= {minlimit,maxlimit,igorcolortablewave,0}
   endif
	ModifyGraph/Z tick=2
	ModifyGraph/Z mirror=1
	ModifyGraph/Z font="Times New Roman"
	ModifyGraph/Z fSize=16
	ModifyGraph/Z fStyle=1
	ModifyGraph/Z standoff=0
	ModifyGraph zero=4
	ModifyGraph axThick=2
	Label/Z left "\\F'Times New Roman'\\Z24\f00k\By\M\F'Times New Roman'\\Z24 (Å\S-1\M\F'Times New Roman'\\Z24)"
	Label/Z bottom "\\F'Times New Roman'\\Z24\f00k\Bx\M\F'Times New Roman'\\Z24 (Å\S-1\M\F'Times New Roman'\\Z24)"
   ModifyGraph margin(left)=70,margin(bottom)=56,margin(right)=28,margin(top)=28,width=269.291,height=255.118
End

Proc kx_kymap_plot2 (ctrlName) : ButtonControl
 String ctrlName
 variable/g CDminlimit
 variable/g CDmaxlimit
 variable/g CDColorTableInvertCheck
if (CDColorTableInvertCheck==1)
   PauseUpdate; Silent 1		// modifying window...
   ModifyImage/Z [0] ctab= {CDminlimit,CDmaxlimit, RedWhiteBlue ,1}
   else
   PauseUpdate; Silent 1		// modifying window...
   ModifyImage/Z [0] ctab= {CDminlimit,CDmaxlimit, RedWhiteBlue ,0}
   endif
	ModifyGraph/Z tick=2
	ModifyGraph/Z mirror=1
	ModifyGraph/Z font="Times New Roman"
	ModifyGraph/Z fSize=16
	ModifyGraph/Z fStyle=1
	ModifyGraph/Z standoff=0
	ModifyGraph zero=4
	ModifyGraph axThick=2
	Label/Z left "\\F'Times New Roman'\\Z24\f00k\By\M\F'Times New Roman'\\Z24 (Å\S-1\M\F'Times New Roman'\\Z24)"
	Label/Z bottom "\\F'Times New Roman'\\Z24\f00k\Bx\M\F'Times New Roman'\\Z24 (Å\S-1\M\F'Times New Roman'\\Z24)"
   ModifyGraph margin(left)=70,margin(bottom)=56,margin(right)=28,margin(top)=28,width=269.291,height=255.118
End

Function kz_map_plot (ctrlName) : ButtonControl
	String ctrlName
	wave igorcolortablewave
	variable/g minlimit
   variable/g maxlimit
   nvar ColorTableInvertCheck
if (ColorTableInvertCheck==1)
   PauseUpdate; Silent 1		// modifying window...
   ModifyImage/Z [0] ctab= {minlimit,maxlimit,igorcolortablewave,1}
   else
   PauseUpdate; Silent 1		// modifying window...
   ModifyImage/Z [0] ctab= {minlimit,maxlimit,igorcolortablewave,0}
   endif
	ModifyGraph/Z tick=2
	ModifyGraph/Z mirror=1
	ModifyGraph/Z font="Times New Roman"
	ModifyGraph/Z fSize=16
	ModifyGraph/Z fStyle=1
	ModifyGraph/Z standoff=0
	//ModifyGraph swapXY=1
	ModifyGraph zero(left)=4
	Label/Z left "\\F'Times New Roman'\\Z24\f00k\Bz\M\F'Times New Roman'\\Z24 (π/c)"
	Label/Z bottom "\\F'Times New Roman'\\Z24\f00k\B//\M\F'Times New Roman'\\Z24 (π/a)"
	ModifyGraph axThick=2
   ModifyGraph margin(left)=70,margin(bottom)=56,margin(right)=28,margin(top)=28,width=255.118,height=340.157
End

Function EDCMDC_plot  (ctrlName) : ButtonControl
	String ctrlName
	String EDCorMDC
	prompt EDCorMDC, "EDC or MDC plot?" popup, "EDC;MDC"
	doprompt "", EDCorMDC
	if(V_flag)
		return -1 // user cancel
	endif
	
	PauseUpdate; Silent 1		// modifying window...
	ModifyGraph/Z tick=2
	ModifyGraph/Z mirror=1
	ModifyGraph/Z font="Times New Roman"
	ModifyGraph/Z fSize=16
	ModifyGraph/Z fStyle=1
	ModifyGraph/Z standoff=0
	ModifyGraph noLabel(left)=1
	ModifyGraph axThick=2
	Label/Z left "\\F'Times New Roman'\\Z24\f00Intensity (arb. units)"
	if(stringmatch(EDCorMDC,"EDC")==1)
		Label/Z bottom "\\F'Times New Roman'\\Z24\f02E-E\BF\M\F'Times New Roman'\\Z24\f00 (eV)"
	else
		Label/Z bottom "\\F'Times New Roman'\\Z24\f00k\B//\M\F'Times New Roman'\\Z24 (Å\S-1\M\F'Times New Roman'\\Z24)"
	endif
   ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28,width=340.157,height=255.118
End  

Function kzMapcorr (ctrlName) : ButtonControl
String ctrlName
String kzMap
variable kzdimension, kparadimension, kzmin, kzmax, kz1, kz2, kparamin, kparamax, kpara1, kpara2
variable la, lc, Ei, Ef, V0, Wfunc
// these variables correspond to lattice constant a , c, start and end photon energy of kz Map, Inner potential, work function
Wfunc = 4.5 
//Wfunc is the work function of ARPES analyzer. This value choose the same value as that in ScientaProcedure.
variable ee = 1.6*10^(-19)
variable em = 9.109*10^(-31)
variable hbar = 6.626*10^(-34)/(2*pi)
variable angstron = 10^(-10)
// these variables are physical constants
prompt kzMap "Choose the rotated kz Map:", popup wavelist("*",";","DIMS:2")
doprompt "", kzMap
if(V_flag)
	return -1 //user canceled
endif

kzdimension=dimsize ($kzMap,0)
kparadimension=dimsize ($kzMap,1)
kzmin = IndextoScale ($kzMap,0,0)
kzmax = IndextoScale ($kzMap,kzdimension-1,0)
kparamin = IndextoScale ($kzMap,0,1)
kparamax = IndextoScale ($kzMap,kparadimension-1,1)
duplicate/O $kzMap rawkzmap

prompt la "In-plane lattice constant a (Å):"
prompt lc "Out-plane lattice constant c (Å):"
prompt Ei "The start hv of kz Map:"
prompt Ef "The end hv of kz Map:"
prompt V0 "Inner potential (eV)"
doprompt "", la, lc, Ei, Ef, V0

if(V_flag)
	return -1 //user canceled
endif

kpara1=sqrt((Ei-Wfunc)/(Ef-Wfunc))*kparamin
kpara2=sqrt((Ei-Wfunc)/(Ef-Wfunc))*kparamax
kz1=sqrt(2*em/(hbar^2)*ee*(Ef+V0)-(kparamin*pi/(la*angstron))^2)*lc*angstron/pi
kz2=sqrt(2*em/(hbar^2)*ee*(Ef+V0)-(kparamax*pi/(la*angstron))^2)*lc*angstron/pi
variable kparaindex1=ScaletoIndex($kzMap,kpara1,1)
variable kparaindex2=ScaletoIndex($kzMap,kpara2,1)
variable i1, j1, i2, j2, i3, j3
variable currentkz,currentkpara,currentkzlim, currentkzlim2
for ( i1=0; i1<=kparaindex1; i1+=1 )
for ( j1=0; j1<kzdimension-1; j1+=1 )
	currentkz=IndextoScale(rawkzmap,j1,0)
	currentkpara=IndextoScale(rawkzmap,i1,1)
	currentkzlim=kz1+(kz1-kzmin)/(kparamin-kpara1)*(currentkpara-kparamin)
	if (currentkz < currentkzlim)
		rawkzmap[j1][i1]=0
	endif	
endfor
endfor

for ( i2=kparadimension-1; i2>=ScaletoIndex(rawkzmap,kpara2,1) ; i2-=1 )
for ( j2=0; j2<kzdimension-1; j2+=1 )
	currentkz=IndextoScale(rawkzmap,j2,0)
	currentkpara=IndextoScale(rawkzmap,i2,1)
	currentkzlim=kz2+(kz2-kzmin)/(kparamax-kpara2)*(currentkpara-kparamax)
	if (currentkz < currentkzlim)
		rawkzmap[j2][i2]=0
	endif	
endfor
endfor

for ( i3=0; i3<kparadimension-1; i3+=1 )
for ( j3=0; j3<kzdimension-1; j3+=1 )
	currentkz=IndextoScale(rawkzmap,j3,0)
	currentkpara=IndextoScale(rawkzmap,i3,1)
	if (2*em/(hbar^2)*ee*(Ei+V0-Wfunc)-(currentkpara*pi/(la*angstron))^2 >0)
		currentkzlim=sqrt(2*em/(hbar^2)*ee*(Ei+V0-Wfunc)-(currentkpara*pi/(la*angstron))^2)*lc*angstron/pi
	else
		currentkzlim=0
	endif
	currentkzlim2=sqrt(2*em/(hbar^2)*ee*(Ef+V0-Wfunc)-(currentkpara*pi/(la*angstron))^2)*lc*angstron/pi
	if (currentkz < currentkzlim || currentkz > currentkzlim2)
		rawkzmap[j3][i3]=0
	endif	
endfor
endfor
duplicate/O rawkzmap $kzMap+"mod"
killwaves rawkzmap
	Display;Delayupdate 
	AppendImage $kzMap+"mod"
	ModifyImage/Z [0] ctab={*,*,Grays,1}
	ModifyGraph/Z tick=2
	ModifyGraph/Z mirror=1
	ModifyGraph/Z font="Times New Roman"
	ModifyGraph/Z fSize=16
	ModifyGraph/Z fStyle=1
	ModifyGraph/Z standoff=0
	ModifyGraph swapXY=1
	ModifyGraph zero(left)=4
	ModifyGraph axThick=2
	Label/Z left "\\F'Times New Roman'\\Z24\f00k\Bz\M\F'Times New Roman'\\Z24 (π/c)"
	Label/Z bottom "\\F'Times New Roman'\\Z24\f00k\B//\M\F'Times New Roman'\\Z24 (π/a)"
   ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28,width=255.118,height=340.157
End

Function SetVarProc_plotxrangemin(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
   variable/g plotxmin=varNum, plotxmax
   SetAxis bottom plotxmin, plotxmax
End

Function SetVarProc_plotxrangemax(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
   variable/g plotxmax=varNum, plotxmin
   SetAxis bottom plotxmin, plotxmax
End

Function SetVarProc_yplotrangemin(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g plotymin=varNum, plotymax
   SetAxis left plotymin, plotymax
End

Function SetVarProc_plotyrangemax(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g plotymax=varNum, plotymin
   SetAxis left plotymin, plotymax
End

Function DA30mapcor(ctrlName) : ButtonControl
	String ctrlName
	String imagelist, imagename
	variable kxdimension, kydimension, kx, ky
	variable i, j, k, xmin, xmax, ymax, ymin, indexxmin, indexxmax, indexymin, indexymax
	variable/g maxlimit, minlimit, ColorTableInvertCheck
	wave DrawX, DrawY
	imagelist=imagenamelist("",";")
	imagename=stringfromlist(0,imagelist,";")
	
	duplicate/O $imagename rawmap
   kxdimension=dimsize(rawmap,0)
   kydimension=dimsize(rawmap,1)
   ymax=wavemax(DrawY)
   ymin=wavemin(DrawY)
   indexymin=Scaletoindex(rawmap,ymin,1)
   indexymax=Scaletoindex(rawmap,ymax,1)
   for(i=0; i<indexymin; i+=1)
   		rawmap[][i]=0
   endfor
   for(i=indexymax+1; i<kydimension; i+=1)
   		rawmap[][i]=0
   endfor
   
	for(i=indexymin; i<=indexymax; i+=1)
		ky=IndextoScale(rawmap,i,1)
		findlevels/Q/D=Ylevel DrawY, ky
		duplicate/O Ylevel, Xvalue
		Xvalue[]=DrawX[Ylevel[p]]
		xmin=wavemin(Xvalue)
		xmax=wavemax(Xvalue)
		for(j=0; j<kxdimension; j+=1)
			kx=Indextoscale(rawmap,j,0)
			if(kx<xmin || kx>xmax)
				rawmap[j][i]=0
			endif
		endfor
	endfor
	duplicate/O rawmap $imagename+"_mod"
	killwaves rawmap, Ylevel, Xvalue
	Display;Delayupdate  
	AppendImage $imagename+"_mod"
	ModifyGraph/Z tick=2
	ModifyGraph/Z mirror=1
	ModifyGraph/Z font="Times New Roman"
	ModifyGraph/Z fSize=16
	ModifyGraph/Z fStyle=1
	ModifyGraph/Z standoff=0
	ModifyGraph zero=4
	ModifyGraph axThick=2
	if (ColorTableInvertCheck==1)
   		PauseUpdate; Silent 1		// modifying window...
   		ModifyImage/Z [0] ctab= {minlimit,maxlimit,igorcolortablewave,1}
   else
   		PauseUpdate; Silent 1		// modifying window...
   		ModifyImage/Z [0] ctab= {minlimit,maxlimit,igorcolortablewave,0}
   endif
	Label/Z left "\\F'Times New Roman'\\Z24\f00k\By\M\F'Times New Roman'\\Z24 (Å\S-1\M\F'Times New Roman'\\Z24)"
	Label/Z bottom "\\F'Times New Roman'\\Z24\f00k\Bx\M\F'Times New Roman'\\Z24 (Å\S-1\M\F'Times New Roman'\\Z24)"
   ModifyGraph margin(left)=70,margin(bottom)=56,margin(right)=28,margin(top)=28,width=269.291,height=255.118

End

Function PopMenuProc_plotstylemacro(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	String/g plotstylelist, plotstylestr
	plotstylelist=macroList("*", ";", "WIN:Procedure")
	PopupMenu popup1,font="Times New Roman",fSize=24,fStyle=1,value= #"plotstylelist"
	plotstylestr=popStr
End


Function ButtonProc_Styleplot(ctrlName) : ButtonControl
	String ctrlName
	string/g plotstylestr
	string cmdstr= plotstylestr+"()"
	Execute cmdstr

End