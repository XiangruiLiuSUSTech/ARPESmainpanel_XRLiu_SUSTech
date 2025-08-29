#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=1 
#pragma igorversion=7.00
#pragma version=1.0
//Xiangrui Liu, 2021-12-15. 12031049@mail.sustech.edu.cn. Several function comes from the Scientaprocedure.ipf by Takeshi Kondo.
//For latest updates, related information and other related (maybe useful) procedures, please go to the Github link below.
//https://github.com/XiangruiLiuSUSTech/ARPESmainpanel_XRLiu_SUSTech
//email change to xrliu1998@sjtu.edu.cn

//I change the rtGlobals parameter to 1 to avoid the error while updating the live Image view window continuously. 
//Update by 2021-12-15: update the images in the list of mainpanel to the NewImagewindow via a variable control continuously.
//							 add a new button to cut the redundant slices of the cut.
//Update by 2022-02-17: Update the kzmap panel, previous kzmap rotation and modify functions now are in one button, constant 
//                      photon energy curve in kz-kpara map could be added in the map.  
//Update by 2022-03-08: Update the ImageAxisCorrPanel, cut correction for laser (low photon energy) is added. Different momentum range
//							 for different Ebs can be shown now.
//Update by 2022-05-12: Update the liveupdate function of NewImagewindow and NewMapwindow. 
//							 Minimum gradient method, FS map adjoint method and  spectral function simulation panel are added.
//							 Update the data load function for txt file. Now procedure could read the angle label of data collected from Scienta analyzer.
//Update by 2022-10-14: Update the liveupdate hook of NewImagewindow and NewMapwindow.
//                      Add the data load function for DA30 analyzer (bin file) and read the related information from "viewer.ini" file.
//Update by 2023-03-30: Add the data load function for txt format files from MBS-A1 analyzer and read the related information.
//							 Add polyAu normalization method and AreaSpectra method in NewMapwindow.
//Update by 2023-07-28: Add the kxky map rotation and kz map rotation in NewMapwindow. 
//Update by 2025-06-12: Add the data load function for itx format (data exported from SPECS Prodigy).
//Update by 2025-08-28: Add the data load function for hdf5 (.h5) format generated at SSRL.

Menu "Extended Procedures"
	"Mainpanel/1", Mainpanel()
	
End

/////////////////////////////////New Main Panel/////////////////////////////////////////

Window Mainpanel() : Panel
	PauseUpdate; Silent 1		// building window...
	make/o/T/n=0 datalistwave
	make/o/n=0 dataselwave
	make/O/N=(256,3) M_colors
	M_colors[][0,2]=p*257
	string/g datatype= ".txt"
	NewPanel /W=(1490,100,1800,580)
	SetDrawLayer UserBack
	SetDrawEnv linethick= 3.00
	DrawLine 0,350,305,350
	ModifyPanel cbRGB=(65535,65535,0)
	PopupMenu popup0,pos={135.00,3.00},size={105.00,21.00},proc=PopMenuProc_datatype,title="Data type"
	PopupMenu popup0,font="Times New Roman",fSize=16
	PopupMenu popup0,mode=2,popvalue=".txt",value= #"\".txt;.pxt;.xy;.ibw;.itx;SSRL;DA30;MBStxt\""
	Button button0,pos={16.00,5.00},size={110.00,45.00},proc=ButtonProc_newdatapath,title="Data Path"
	Button button0,font="Times New Roman",fSize=24,fColor=(0,65535,0)
	ListBox list0,pos={18.00,54.00},size={195.00,220.00},font="Times New Roman"
	ListBox list0,fSize=14,mode= 9,listWave=root:datalistwave,selWave=root:dataselwave
	Button button1,pos={135.00,25.00},size={60.00,25.00},proc=ButtonProc_update,title="Update"
	Button button1,font="Times New Roman",fSize=16
	Button button2,pos={10.00,285.00},size={70.00,30.00},proc=ButtonProc_dataexport,title="Load"
	Button button2,font="Times New Roman",fSize=20
	Button button3,pos={10,315},size={90.00,30.00},proc=ButtonProc_threedimconstruct,title="3D from 2D"
	Button button3,font="Times New Roman",fSize=16
	Button button4,font="Times New Roman",size={70,25},pos={220,25},proc=ButtonProc_2Dcorr,fSize=16,title="2D corr"
	Button button5 pos={220,50},size={60,20},proc=ButtonProc_multidimwaveexport,font="Times New Roman",fSize=16,title="Output"
	Button button6 title="New Image",pos={85,285},size={110,30},font="Times New Roman",fSize=20,proc=ButtonProc_NewImage,fstyle=1,fColor=(65535,0,0)
	Button button7 title=" New Map",font="Times New Roman",fSize=20, pos={100,315},size={100,30},proc=ButtonProc_NewMap,fstyle=1,fColor=(0,0,65534)
	Button button8 title="Ef - corr",font="Times New Roman",fSize=16,pos={220,70}, size={60,30},PROC=ButtonProc_Fermicorr
	Button button9 title="Norm",font="Times New Roman",fSize=16,pos={220,100}, size={60,30},PROC=ButtonProc_Norm
	Button button10 title="FS Rotate",pos={200,285},size={100,30},font="Times New Roman",fSize=22,proc=ButtonProc_FSrotate, fColor=(65535,43690,0)
	Button button11 title="Pi Angle",pos={220,400},size={80,30},font="Times New Roman",fSize=16,proc=ButtonProc_PiAngleCal
	Button button12 title="Cut Corr",pos={220,365},size={80,30},font="Times New Roman",fSize=16,proc=ButtonProc_ImAxisCorr
	Button button13 title="Curve fit",pos={220,130},size={80,30},font="Times New Roman",fSize=20,proc=ButtonProc_curvefit
	Button button14 title="kz Map",pos={200,315},size={100,30},font="Times New Roman",fSize=20,proc=ButtonProc_kzmaprotation,fColor=(0,65535,65535)
	Button button15 title="logbook",pos={220,165},size={80,30},font="Times New Roman",fSize=20,proc=ButtonProc_logbook
	Button button16 title="Symmetry",pos={220,435},size={80,30},font="Times New Roman",fSize=16,proc=ButtonProc_Symmetry
	Button button17 title="DrawPanel",pos={130,365},size={80,30},font="Times New Roman",fSize=16,proc=ButtonProc_DrawPanel
	Button button18 title="Analysis",pos={130,400},size={80,30},font="Times New Roman",fSize=16,proc=ButtonProc_AnalysisPanel
	Button button19 title="SelfEnergy",pos={130,435},size={80,30},font="Times New Roman",fSize=14,proc=ButtonProc_SelfEnergyPanel
	Button button20 title="Slicecut", pos={220,200},size={80,30},font="Times New Roman",fSize=20,proc=ButtonProc_Slicecut
	PopupMenu popup1,pos={10.00,385.00},size={80.00,21.00},bodyWidth=80,proc=PopMenuProc_newFuncs
	PopupMenu popup1,font="Times New Roman",fSize=16
	PopupMenu popup1,mode=1,popvalue=" ",value= #"\"curvature;minigr;FSjoint;simulation;realspacemap\""
	TitleBox title0,pos={12.00,355.00},size={77.00,27.00},title="NewFuncs"
	TitleBox title0,labelBack=(65535,65535,65535),font="Times New Roman",fSize=16,fStyle=1,anchor= MC
	Button button21,pos={220.00,235.00},size={80.00,25.00},proc=ButtonProc_cuttranspose,title="Cuttranspose",font="Times New Roman",fSize=12

	NewNotebook/W=(200,150,800,500)/F=0/ENCG=1/N=exp_logbook
	dowindow/f Mainpanel
EndMacro
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


Function ButtonProc_newdatapath(ctrlName) : ButtonControl
	String ctrlName
	String/g folderpath
	newpath/O folderpath
	if(V_flag)
		return -1 //user cancel
	endif
	pathinfo folderpath
	folderpath=S_path
	Updatefolder()
End

Function PopMenuProc_datatype(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	if(stringmatch(popStr,"DA30")==1)
		string/g datatype=".bin"
	elseif(stringmatch(popStr,"MBStxt")==1)
		string/g datatype=".txt"
	elseif(stringmatch(popStr,"SSRL")==1)
		string/g datatype=".h5"
	else
		String/g datatype=popStr
	endif
End

Function Updatefolder()
	string/g folderpath
	string/g datatype
	wave/T datalistwave
	wave dataselwave
	string filenamelist, templist
	variable filenum, i
	filenamelist=indexedfile(folderpath,-1,datatype)
	templist=sortlist(filenamelist,";",16)
	filenum=itemsinlist(filenamelist)
	redimension/N=(filenum) datalistwave
	redimension/N=(filenum) dataselwave
	for (i=1; i<filenum+1; i+=1)
		datalistwave[i-1]=Stringfromlist(i-1, templist)
	endfor
End

Function ButtonProc_update(ctrlName) : ButtonControl
	String ctrlName
	Updatefolder()
End


Function ButtonProc_dataexport(ctrlName) : ButtonControl
	//The load procedure for xy format files only serves for data file written by SPECS Prodigy software in Chang's Lab. 
	String ctrlName
	string/g datatype, folderpath
	wave/T datalistwave
	wave dataselwave
	variable i, j, loadnum=0, k=0
	string currentwavename, logtext
	variable ref	//serves for angle read when load txt file
	string s1, anglestr//serves for angle read when load txt file from Scienta analyzer
	string anoffstr, andelstr, eoffstr, edelstr // serves for angle and energy read when load txt file from MBS analyzer
	variable xyref // serves for information read when load xy file from SPECS Prodigy
	string sxy, PE, KE	//serves for pass energy read and energy correction when load xy file from SPECS Prodigy
	variable index=dimsize(datalistwave,0)	
	for(i=0; i<index; i+=1)
		if(dataselwave[i]!=0)
			loadnum+=1
		endif
	endfor	
	controlinfo/W=Mainpanel popup0
	make/O/N=(index) energyoffwave
	pathinfo folderpath
	dowindow/f exp_logbook
	if(V_flag==0)
		NewNotebook/W=(200,150,800,500)/F=0/ENCG=1/N=exp_logbook
	endif
	NewPanel/N=Loadprogress/w=(285,111,739,193)
   ValDisplay output, pos={18,32}, size={342,18}, limits={0,loadnum-1,0},barmisc={0,0}
   ValDisplay output, value=_NUM:0, highcolor=(0,65535,0), mode=3
   Button Stop, pos={375,32},size={50,20},title="Stop"
   DoUpdate/W=Loadprogress/E=1
	if (stringmatch(datatype,".txt")==1 && V_value==1)
		for(i=0; i<index; i+=1)
			if(dataselwave[i]!=0)
				k+=1
				currentwavename=removeending(datalistwave[i],datatype)
				loadwave/Q/G/D/M/O/P=folderpath/L={0,0,0,1,0}/A=$currentwavename datalistwave[i]
				loadwave/Q/G/D/M/O/P=folderpath/L={0,0,0,0,1}/A=$currentwavename+"x" datalistwave[i]
				duplicate/O $currentwavename+"0", $currentwavename 
				wave dimwave=$currentwavename+"x0"
				variable xoffset=dimwave[0]
				variable xdelta=dimwave[1]-dimwave[0]
				////////////////////////////////////////////////serves for angle read when load txt data from Scienta analyzer///////////////////////////////////////////////////////////
				open/R/P=folderpath ref as datalistwave[i]
				for(j=0; j<100; j+=1)
					FReadLine ref, s1
					if(stringmatch(s1,"Dimension 2 scale=*")==1)
						anglestr=s1			
					string s2=stringbykey("Dimension 2 scale", anglestr, "=")
					variable yoffset= str2num(stringfromlist(0,s2," "))
					variable ydelta= str2num(stringfromlist(1,s2," "))-str2num(stringfromlist(0,s2," "))
					setscale/P y yoffset, ydelta, $currentwavename
					
						break
					endif
				endfor
				close/A
				//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				setscale/P x xoffset, xdelta, $currentwavename
				
				energyoffwave[i]=xoffset
				logtext="Load "+currentwavename+datatype+" from "+S_path+"\r" 
				Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
				killwaves $currentwavename+"0", $currentwavename+"x0"
				ValDisplay output, value=_NUM:k,win=Loadprogress
				doupdate/W=Loadprogress
				if(V_flag == 2)  //User stop the output progress
					i = index+1
					print "User stop the data load progress!"
				endif
			endif
		endfor
		logtext="----------The data load process end--------------\r\r"
		Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
		killwindow Loadprogress
	endif
	
	if (stringmatch(datatype,".txt")==1 && V_value!=1)
		for(i=0; i<index; i+=1)
			if(dataselwave[i]!=0)
				k+=1
				currentwavename=removeending(datalistwave[i],datatype)
				loadwave/Q/G/D/M/O/P=folderpath/L={0,0,0,1,0}/A=$currentwavename datalistwave[i]
				loadwave/Q/G/D/M/O/P=folderpath/L={0,0,0,0,1}/A=$currentwavename+"x" datalistwave[i]
				duplicate/O $currentwavename+"0", $currentwavename 
				wave dimwave=$currentwavename+"x0"
				//xoffset=dimwave[0]
				//xdelta=dimwave[1]-dimwave[0]
				
				////////////////////////////////////////////////serves for angle read when load txt data from MBS A1 analyzer//////////////////////////////////////////////////////////
				open/R/P=folderpath ref as datalistwave[i]
				for(j=0; j<100; j+=1)
					FReadLine ref, s1
					if(stringmatch(s1,"Start K.E.*")==1)
						eoffstr=s1	
					endif
					if(stringmatch(s1,"Step Size*")==1)
						edelstr=s1	
					endif
					if(stringmatch(s1,"ScaleMult*")==1)
						andelstr=s1	
					endif
					if(stringmatch(s1,"ScaleMin*")==1)
						anoffstr=s1
					endif
				endfor
				
				close/A
				yoffset= str2num(stringbykey("ScaleMin", anoffstr, "\t"))
				ydelta=str2num(stringbykey("ScaleMult", andelstr, "\t"))
				xoffset=str2num(stringbykey("Start K.E.", eoffstr, "\t"))
				xdelta=str2num(stringbykey("Step Size", edelstr, "\t"))
				setscale/P y yoffset, ydelta, $currentwavename
				setscale/P x xoffset, xdelta, $currentwavename
				//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				energyoffwave[i]=xoffset
				logtext="Load "+currentwavename+datatype+" from "+S_path+"\r" 
				Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
				killwaves $currentwavename+"0", $currentwavename+"x0"
				ValDisplay output, value=_NUM:k,win=Loadprogress
				doupdate/W=Loadprogress
				if(V_flag == 2)  //User stop the output progress
					i = index+1
					print "User stop the data load progress!"
				endif
			endif
		endfor
		logtext="----------The data load process end--------------\r\r"
		Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
		killwindow Loadprogress
	endif
	
	
	if (stringmatch(datatype,".pxt")==1)
		for(i=0; i<index; i+=1)
			if(dataselwave[i]!=0)
				k+=1
				currentwavename=removeending(datalistwave[i],datatype)
				loaddata/T=aaa/Q/O/P=folderpath datalistwave[i]
				string pxtfilename=getindexedobjname("root:aaa:",1,0)
				duplicate/o root:aaa:$pxtfilename root:$currentwavename
				energyoffwave[i]=dimoffset($currentwavename,0)
				killdatafolder aaa
				logtext="Load "+currentwavename+datatype+" from "+S_path+"\r" 
				Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
				ValDisplay output, value=_NUM:k,win=Loadprogress
				doupdate/W=Loadprogress
				if(V_flag == 2)  //User stop the output progress
					i = index+1
					print "User stop the data load progress!"
				endif
			endif
		endfor
		logtext="----------The data load process end--------------\r\r"
		Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
		killwindow Loadprogress
	endif
	
	//load hdf5 file generated at SSRL
	if (stringmatch(datatype,".h5")==1 && V_value==6)
	make/O temp
	make/O/T txttemp
		for(i=0; i<index; i+=1)
			if(dataselwave[i]!=0)
				k+=1
				currentwavename=removeending(datalistwave[i],datatype)
				
				//open HDF5 file
				string filepath, grouppath
				variable fileID, groupID
				HDF5openfile/P=folderpath/R/Z fileID as datalistwave[i]
					
				if (V_flag != 0)
					Print "HDF5OpenFile failed"
					return -1
				endif
					
				HDF5OpenGroup /Z fileID, "Data", groupID
				if (V_flag != 0)
					Print "HDF5OpenGroup failed"
					HDF5CloseFile fileID
				return -1
				else						
					HDF5loaddata/O/Z/Q/N=count groupID, "Count"//load hdf5 data
					HDF5loaddata/O/Z/Q/N=Time0 groupID, "Time"// this is the data normalization wave
					wave Time0
					
					HDF5loaddata/O/A="Offset"/type=1/N=temp/Z/Q groupID, "Axes0"
					xoffset=temp[0]
					//for kz map, no offset value for Axes0, xoffset would be zer0
					HDF5loaddata/O/A="Delta"/type=1/N=temp/Z/Q groupID, "Axes0"
					xdelta=temp[0]
					HDF5loaddata/O/A="Offset"/type=1/N=temp/Z/Q groupID, "Axes1"
					yoffset=temp[0]
					HDF5loaddata/O/A="Delta"/type=1/N=temp/Z/Q groupID, "Axes1"
					ydelta=temp[0]
					
					setscale/P x, xoffset, xdelta, count
					setscale/P y, yoffset, ydelta, count
					if(wavedims(count)==3)
						HDF5loaddata/O/A="Offset"/type=1/N=temp/Z/Q groupID, "Axes2"
						variable zoffset=temp[0]
						HDF5loaddata/O/A="Delta"/type=1/N=temp/Z/Q groupID, "Axes2"
						variable zdelta=temp[0]
						setscale/P z, zoffset, zdelta, count
						HDF5loaddata/O/A="Label"/type=1/N=txttemp/Z/Q groupID, "Axes2"
						string zdimlab=txttemp[0]
					elseif(wavedims(count)==4)
						HDF5loaddata/O/A="Offset"/type=1/N=temp/Z/Q groupID, "Axes2"
						zoffset=temp[0]
						HDF5loaddata/O/A="Delta"/type=1/N=temp/Z/Q groupID, "Axes2"
						zdelta=temp[0]
						setscale/P z, zoffset, zdelta, count
						HDF5loaddata/O/A="Offset"/type=1/N=temp/Z/Q groupID, "Axes3"
						variable toffset=temp[0]
						HDF5loaddata/O/A="Delta"/type=1/N=temp/Z/Q groupID, "Axes3"
						variable tdelta=temp[0]
						setscale/P t, toffset, tdelta, count
						
						HDF5loaddata/O/A="Label"/type=1/N=txttemp/Z/Q groupID, "Axes2"
						zdimlab=txttemp[0]
						HDF5loaddata/O/A="Label"/type=1/N=txttemp/Z/Q groupID, "Axes3"
						string tdimlab=txttemp[0]
						
					endif
					
					duplicate/O count, $currentwavename
					wave datawave=$currentwavename
					datawave=datawave/Time0 //norm the data by Time wave in hdf5 file
				endif
				
				if(V_flag == 0)
					
				endif
				
				// Close the HDF5 group
				HDF5CloseGroup groupID
				// Close the HDF5 file
				HDF5CloseFile fileID
				
				logtext="Load "+currentwavename+datatype+" from "+S_path+"\r" 
				if(wavedims(count)==3)
					logtext+="the third dimension label is "+zdimlab+"\r"
				elseif(wavedims(count)==4)
					logtext+="the third dimension label is "+zdimlab+"\r"
					logtext+="the fourth dimension label is "+tdimlab+"\r"
				endif
				Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
				ValDisplay output, value=_NUM:k,win=Loadprogress
				doupdate/W=Loadprogress
				if(V_flag == 2)  //User stop the output progress
					i = index+1
					print "User stop the data load progress!"
				endif
			endif
		endfor
		logtext="----------The data load process end--------------\r\r"
		Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
		
		killwaves/Z temp, txttemp, count, Time0
		killwindow Loadprogress
		
	endif
	
	if(stringmatch(datatype,".xy")==1)
		for(i=0; i<index; i+=1)
			if(dataselwave[i]!=0)
				k+=1
				currentwavename=removeending(datalistwave[i],datatype)
				loadwave/O/G/M/Q/L={0,0,0,1,1}/N=xywave/P=folderpath datalistwave[i]
				wave xywave0
				variable xdim=dimsize(xywave0,0)
				loadwave/O/G/M/Q/L={0,0,xdim,0,1}/N=energy/P=folderpath datalistwave[i]
				string xylist=wavelist("xywave*",";","")
				wave energy0
				variable eoff=energy0[0]
				variable eend=energy0[xdim-1]
				variable aoff=-14.9856
				variable aend=14.9856
				// We use calibration file to correct the energy channel value in Specsprodigy, now it's not equal-spacing.
				// After installing Spin arm, the energy calibration fails in snap shot mode and we need kinetic energy and pass energy to calculated energy axis.
				if(eoff == eend)
					open/R/P=folderpath ref as datalistwave[i]
					for(j=0; j<40; j+=1)
						FReadLine ref, sxy
						if(stringmatch(sxy,"# Pass Energy:*")==1)
							PE=stringbykey("# Pass Energy", sxy, ":")
							variable passenergy= str2num(PE)
						endif
						if(stringmatch(sxy,"# Kinetic Energy:*")==1)
							KE=stringbykey("# Kinetic Energy", sxy, ":")
							variable kineticenergy = str2num(KE)
						endif
					endfor
					close/A
					eoff=kineticenergy-0.067/2*(48/27)*passenergy
					eend=kineticenergy+0.067/2*(48/27)*passenergy  // this calculation formula for Phoibos 150 analyzer comes from the manuscript by Martin J. M.@SPECS
					// the relation may change upon change of lens parameters; please update if necessary !!!
					aoff=-21
					aend=21				
					// angle scale for WASM mode is +-7 deg;
				endif
				//////////////////////////////////////////////////////////////////////////////////////////////////
				variable ydim=itemsinlist(xylist,";")
				make/O/N=(xdim,ydim) $currentwavename
				wave currentxywave=$currentwavename
				setscale/I x, eoff, eend, currentxywave
				setscale/I y, aoff, aend, currentxywave //This MCP angle step is read from xy file. You should correct its value once it changes.
				energyoffwave[i]=eoff
				for(j=0; j<ydim; j+=1)
					wave xywavename=$"xywave"+num2str(j)
					 currentxywave[][j]=xywavename[p]
				endfor
				logtext="Load "+currentwavename+datatype+" from "+S_path+"\r" 
				Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
				ValDisplay output, value=_NUM:k,win=Loadprogress
				doupdate/W=Loadprogress
				if(V_flag == 2)  //User stop the output progress
					i = index+1
					print "User stop the data load progress!"
				endif
			endif
		endfor
		for(j=0; j<ydim;j+=1)
			wave xywavename=$"xywave"+num2str(j)
			killwaves xywavename, energy0
		endfor
		logtext="----------The data load process end--------------\r\r"
		Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
		killwindow Loadprogress
	endif
	
	if(stringmatch(datatype,".ibw")==1)
		for(i=0; i<index; i+=1)
			if(dataselwave[i]!=0)
				k+=1
				newdatafolder/O/S ibwload
				currentwavename=removeending(datalistwave[i],datatype)
				loadwave/W/O/H/M/Q/P=folderpath datalistwave[i]
				string ibwfilename=getindexedobjname("root:ibwload:",1,0)
				duplicate/o root:ibwload:$ibwfilename, root:$currentwavename
				string ibwloadstr="root:ibwload"
				killdatafolder/Z $ibwloadstr			
				energyoffwave[i]=dimoffset($currentwavename,0)
				logtext="Load "+currentwavename+datatype+" from "+S_path+"\r" 
				Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
				ValDisplay output, value=_NUM:k,win=Loadprogress
				doupdate/W=Loadprogress
				if(V_flag == 2)  //User stop the output progress
					i = index+1
					print "User stop the data load progress!"
				endif
			endif
		endfor
		logtext="----------The data load process end--------------\r\r"
		Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
		killwindow Loadprogress
	endif
	
		if(stringmatch(datatype,".itx")==1)
		for(i=0; i<index; i+=1)
			if(dataselwave[i]!=0)
				k+=1
				newdatafolder/O/S itxload
				currentwavename=removeending(datalistwave[i],datatype)
				loadwave/T/O/Q/P=folderpath datalistwave[i]
				string itxfilename=getindexedobjname("root:itxload:",1,0)
				duplicate/o root:itxload:$itxfilename, root:$currentwavename
				string itxloadstr="root:itxload"
				killdatafolder/Z $itxloadstr			
				energyoffwave[i]=dimoffset($currentwavename,0)
				logtext="Load "+currentwavename+datatype+" from "+S_path+"\r" 
				Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
				ValDisplay output, value=_NUM:k,win=Loadprogress
				doupdate/W=Loadprogress
				if(V_flag == 2)  //User stop the output progress
					i = index+1
					print "User stop the data load progress!"
				endif
			endif
		endfor
		logtext="----------The data load process end--------------\r\r"
		Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
		killwindow Loadprogress
	endif
	
	if(stringmatch(datatype,".bin")==1)
		wave temp0
		for(i=0; i<index; i+=1)
			if(dataselwave[i]!=0)
				k+=1
				variable DAref, DAbin, kk
				string DAstr
				variable wdim, hdim, ddim, woff, hoff, doff, wdelta, hdelta, ddelta
				///////////////////////////read label and dim information for DA30 bin data////////////////
				open/R/P=folderpath DAref as "viewer.ini"
				for(j=0; j<30; j+=1)
					FReadLine DAref, DAstr
					if(stringmatch(DAstr,"width=*")==1)
						wdim=str2num(stringbykey("width",DAstr,"="))
					endif
					if(stringmatch(DAstr,"height=*")==1)
						hdim=str2num(stringbykey("height",DAstr,"="))
					endif
					if(stringmatch(DAstr,"depth=*")==1)
						ddim=str2num(stringbykey("depth",DAstr,"="))
					endif
					if(stringmatch(DAstr,"width_offset=*")==1)
						woff=str2num(stringbykey("width_offset",DAstr,"="))
					endif
					if(stringmatch(DAstr,"height_offset=*")==1)
						hoff=str2num(stringbykey("height_offset",DAstr,"="))
					endif
					if(stringmatch(DAstr,"depth_offset=*")==1)
						doff=str2num(stringbykey("depth_offset",DAstr,"="))
					endif
					if(stringmatch(DAstr,"width_delta=*")==1)
						wdelta=str2num(stringbykey("width_delta",DAstr,"="))
					endif
					if(stringmatch(DAstr,"height_delta=*")==1)
						hdelta=str2num(stringbykey("height_delta",DAstr,"="))
					endif
					if(stringmatch(DAstr,"depth_delta=*")==1)
						ddelta=str2num(stringbykey("depth_delta",DAstr,"="))
					endif
				endfor
				close/A
				
				make/O/N=(wdim,hdim,ddim) temp
				SetScale /p x, woff, wdelta, "Energy [eV]", temp
				SetScale /p y, hoff, hdelta, "ThetaX [deg]", temp
				SetScale /p z, doff, ddelta, "ThetaY [deg]", temp
				make/O/N=(wdim,hdim) temp1
				open/R/P=folderpath DAbin as datalistwave[i]
				for(kk=0; kk<ddim; kk+=1)
					fBinRead DAbin, temp1
					multithread temp[][][kk]=temp1[p][q]
				endfor
		
				close/A
				currentwavename=removeending(datalistwave[i],datatype)
				duplicate/O temp, $currentwavename
				/////////////////////////////////////////////////////////////////////////////////////////
				logtext="Load "+currentwavename+datatype+" from "+S_path+"\r" 
				Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
				ValDisplay output, value=_NUM:k,win=Loadprogress
				doupdate/W=Loadprogress
				if(V_flag == 2)  //User stop the output progress
					i = index+1
				print "User stop the data load progress!"
				endif
			endif
		killwaves temp1, temp
		endfor
		logtext="----------The data load process end--------------\r\r"
		Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
		killwindow Loadprogress

	endif	
End


Function ButtonProc_threedimconstruct(ctrlName) : ButtonControl
	String ctrlName
	wave/T datalistwave
	wave dataselwave
	string/g datatype
	string cubicmap, currentwavename, normcheck, logtext
	prompt cubicmap "Please enter the name for 3D map:"
	prompt normcheck "Please choose whether use the normalized wave:" popup, "No;Yes"
	doprompt "", cubicmap, normcheck
	if(V_flag)
     return -1 //User cancel
   endif
   
	variable index=dimsize(datalistwave,0)
	variable xdim,ydim,zdim,i,j,xoff,yoff,xdelta,ydelta
	zdim=0; j=0
	for(i=0; i<index; i+=1)
		if(dataselwave[i]!=0)
			zdim+=1
			xdim=dimsize($removeending(datalistwave[i],datatype),0)
			ydim=dimsize($removeending(datalistwave[i],datatype),1)
			xoff=dimoffset($removeending(datalistwave[i],datatype),0)
			xdelta=dimdelta($removeending(datalistwave[i],datatype),0)
			yoff=dimoffset($removeending(datalistwave[i],datatype),1)
			ydelta=dimdelta($removeending(datalistwave[i],datatype),1)
		endif
	endfor
	make/O/N=(xdim,ydim,zdim) $cubicmap
	wave threedimmap=$cubicmap
	setscale/P x xoff, xdelta, threedimmap
	setscale/P y yoff, ydelta, threedimmap
	dowindow/f exp_logbook
	if(V_flag==0)
		NewNotebook/W=(200,150,800,500)/F=0/ENCG=1/N=exp_logbook
	endif
	NewPanel/N=threedimMapprogress/w=(285,111,739,193)
   ValDisplay output, pos={18,32}, size={342,18},limits={0,zdim-1,0},barmisc={0,0}
   ValDisplay output, value=_NUM:0, highcolor=(0,65535,0), mode=3
   Button Stop, pos={375,32},size={50,20},title="Stop"
   DoUpdate/W=threedimMapprogress/E=1
	for(i=0; i<index; i+=1)
		if(dataselwave[i]!=0)
			if(stringmatch(normcheck,"Yes")==1)
				currentwavename=removeending(datalistwave[i],datatype)+"_nr"
			else
				currentwavename=removeending(datalistwave[i],datatype)
			endif
			wave currentwave=$currentwavename
				if(waveexists($currentwavename)==0)
					killwindow threedimMapprogress
					Abort "Please export the wave "+currentwavename+" !"
				endif
			threedimmap[][][j]=currentwave[ScaletoIndex(currentwave,IndextoScale(threedimmap,p,0),0)][q]
			if(j==0)
				logtext="Construct 3D map from "+currentwavename+ " to " 
				Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
			endif
			if(j==zdim-1)
				logtext=currentwavename+ "\r " 
				Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
			endif
			ValDisplay output, value=_NUM:j,win=threedimMapprogress
			doupdate/W=threedimMapprogress
			if(V_flag == 2)  //User stop the output progress
				i = index+1
				print "User stop the 3D Map construction progress!"
			endif
			j+=1
		endif
	endfor
	killwindow threedimMapprogress
	logtext="----------The 3D map construction process end--------------\r\r"
	Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext 
End


Function ButtonProc_2Dcorr(ctrlName) : ButtonControl
	String ctrlName
	variable offset, delta, i
	wave/T datalistwave
	wave dataselwave
	string currentwavename, corrdim
	string/g datatype
	prompt corrdim "Please choose the dimension to corr:" popup, "x;y"
	prompt offset "Please enter the offset value:"
	prompt delta "Please enter the delta value:"
	doprompt "", corrdim, offset, delta
	if(V_flag)
     return -1 //User cancel
   endif
   
	variable index=dimsize(datalistwave,0)
	for(i=0; i<index; i+=1)
		if(dataselwave[i]!=0)
			currentwavename=removeending(datalistwave[i],datatype)
			wave currentwave=$currentwavename
			if(stringmatch(corrdim,"x")==1)
				setscale/P x offset,delta, currentwave
			else
				setscale/P y offset,delta, currentwave
			endif
		endif
	endfor
End

Function ButtonProc_cuttranspose(ctrlName) : ButtonControl
	String ctrlName
	String wavestr, replacestr, logtext
	variable xoff, xdelta, yoff, ydelta, xsize, ysize, i
	wave energyoffwave
	wave/T datalistwave
	string/g datatype
	
	prompt wavestr "Choose the 2D cut wave to transpose:", popup wavelist("*", ";", "DIMS:2")
	prompt replacestr "Replace the previous wave?", popup "Yes;No"
	doprompt "", wavestr, replacestr
	if(V_flag)
		return -1 //user cancel
	endif
	
	duplicate/O $wavestr, temp
	xsize=dimsize(temp,0);ysize=dimsize(temp,1)
	xoff=dimoffset(temp,0);yoff=dimoffset(temp,1)
	xdelta=dimdelta(temp,0);ydelta=dimdelta(temp,1)
	
	make/N=(ysize,xsize) temp1
	temp1[][]=temp[q][p]
	setscale/P x yoff, ydelta, temp1
	setscale/P y xoff, xdelta, temp1
	if(stringmatch(replacestr,"Yes"))
		duplicate/O temp1, $wavestr
		
		logtext="transpose the wave "+wavestr+" and replace the former one \r"
		Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext 
	for(i=0; i<dimsize(datalistwave,0); i+=1)
		if(stringmatch(removeending(datalistwave[i],datatype),wavestr))
			energyoffwave[i]=yoff
		endif
	endfor	
		
	else
		duplicate/O temp1, $wavestr+"_tran"
		logtext="transpose the wave "+wavestr+" and output "+wavestr+"_tran as new wave \r"
		Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext 
	endif
	
	killwaves temp, temp1
	
End

Function ButtonProc_multidimwaveexport (ctrlName) : ButtonControl
	String ctrlName
	String pathName,multidimwave  
   prompt multidimwave "Choose the 3D or 2D wave to output:", popup "--------3D--------\r;"+wavelist("*",";","DIMS:3")+"--------2D--------\r;"+wavelist("*",";","DIMS:2")
	doprompt "",multidimwave
	if(V_flag)
    	return -1// User canceled
   endif
   
   duplicate/O $multidimwave outputwave
   variable NRow=Dimsize(outputwave,0)
   variable NColo=Dimsize(outputwave,1)
   variable NLayer
   if(wavedims(outputwave) == 3)
   		NLayer=Dimsize(outputwave,2)
   else
   		NLayer=1
   endif
   variable i
   String vNUM, together, dataname
   
   prompt dataname "Enter the output wave name:"
	doprompt "",dataname
	if(V_flag)
    	return -1// User canceled
   endif
   NewPath/O/C/Q temporaryPath
	pathName = "temporaryPath"
	
   make/o/N=(NRow,NColo) currentoutputwave
   if (wavedims(outputwave) == 2 )
   		together = dataname + ".txt"
   		currentoutputwave = outputwave[p][q]
   		Save /P=$pathName /J/O currentoutputwave as together
   	else
   NewPanel/N=OUTPUTprogress/w=(285,111,739,193)
   ValDisplay output, pos={18,32}, size={342,18}, limits={0,NLayer-1,0},barmisc={0,0}
   ValDisplay output, value=_NUM:0, highcolor=(0,65535,0), mode=3
   Button Stop, pos={375,32},size={50,20},title="Stop"
   DoUpdate/W=OUTPUTprogress/E=1

   for(i=1; i < NLayer+1; i+=1)	// Initialize variables;continue test
		sprintf vNum "%03d", i 
		together = dataname + vNum + ".txt"
		currentoutputwave = outputwave[p][q][i-1]
		Save /P=$pathName /J/O currentoutputwave as together
		ValDisplay output, value=_NUM:i,win=OUTPUTprogress
		doupdate/W=OUTPUTprogress
		if(V_flag == 2)  //User stop the output progress
			i = NLayer+1
			print "User stop the output progress!"
		endif
	endfor
	killwindow OUTPUTprogress
	endif
		
	variable xstart, xdelta, ystart, ydelta
	xstart=indextoscale(outputwave, 0, 0)
	xdelta=DimDelta(outputwave, 0)
	ystart=indextoscale(outputwave, 0, 1)
	ydelta=DimDelta(outputwave, 1)
	printf "x direction scales from %g with delta %g\r"  xstart, xdelta
	printf "y direction scales from %g with delta %g\r"  ystart, ydelta
	printf "%g 2D waves output\r" NLayer
	killwaves outputwave, currentoutputwave
End

Function Buttonproc_logbook(ctrlName) : ButtonControl
	String ctrlName
	dowindow/f exp_logbook
	if(V_flag==0)
		NewNotebook/W=(200,150,800,500)/F=0/ENCG=1/N=exp_logbook
	endif
End

Function ButtonProc_Slicecut(ctrlName) :  ButtonControl
	String ctrlName
	wave/T datalistwave
	wave dataselwave
	String/g datatype
	String logtext
	variable i, size, point1, point2
	prompt point1, "Please enter the start slice num:" 
	prompt point2, "Please enter the end slice num:" 
	doprompt "", point1, point2
	if(V_flag)
		return -1 // user cancel
	endif
	
	size=dimsize(dataselwave,0)
	dowindow/f exp_logbook
	if(V_flag==0)
		NewNotebook/W=(200,150,800,500)/F=0/ENCG=1/N=exp_logbook
	endif
	for(i = 0; i < size; i += 1)
		if(dataselwave[i] != 0)
			wave currentwave=$removeending(datalistwave[i], datatype)
			if(waveexists(currentwave) != 1)
				Print "wave" + removeending(datalistwave[i], datatype)+ " doesn't exists!"
			else
				variable columnsize=dimsize(currentwave,1)
				variable offset=IndextoScale(currentwave, point1, 1)
				variable delta=dimdelta(currentwave, 1)
				if (point2>=columnsize-1)
					point2=columnsize-1
				endif
				DeletePoints/M=1 point2+1, columnsize-point2-1, currentwave
				DeletePoints/M=1 0, point1, currentwave
				setscale/P y, offset, delta, "", currentwave
				logtext="Cut slices from num "+num2str(point1)+" to num "+num2str(point2)+" of "+removeending(datalistwave[i], datatype)+"\r"
				Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext 
			endif
		endif
	endfor
	logtext="----------The slicecut end--------------\r\r"
	Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext 
End

//////////////////////////////////////////Curve fit and correct////////////////////////////////
Function ButtonProc_Fermicorr(ctrlName) : ButtonControl
	String ctrlName
	wave/T datalistwave
	wave dataselwave, energyoffwave
	string currentwavename,logtext, wavecheck
	string/g datatype
	variable fermilevel, deltahv, i, j, xoff,xdelta
	variable index=dimsize(datalistwave,0)
	prompt wavecheck "Choose the fermi level correct mode:", popup, "EF subtract;fermi level wave;polyAu fit"
	doprompt "", wavecheck
	if(V_flag)
    	return -1// User canceled
   endif
   if(stringmatch(wavecheck,"EF subtract")==1)
	prompt fermilevel "Please enter the fermi level(eV):"
	prompt deltahv "Please enter the increment of photon energy (eV):(please set to zero except for kz map)"
	doprompt "", fermilevel, deltahv	
	if(V_flag)
    	return -1// User canceled
   endif
   
   dowindow/f exp_logbook
	if(V_flag==0)
		NewNotebook/W=(200,150,800,500)/F=0/ENCG=1/N=exp_logbook
	endif
	j=-1
	for(i=0; i<index; i+=1)
		if(dataselwave[i]!=0)
			j+=1
			currentwavename=removeending(datalistwave[i],datatype)
			wave currentwave=$currentwavename
			xoff=dimoffset(currentwave,0)
			xdelta=dimdelta(currentwave,0)
			setscale/P x, energyoffwave[i]-(fermilevel+j*deltahv), xdelta, currentwave
			logtext="The fermi level for "+currentwavename+" is "+num2str(fermilevel+j*deltahv)+" eV\r" 
			Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
		endif
	endfor
	elseif(stringmatch(wavecheck,"fermi level wave")==1)
		make/O/T/N=(numpnts(dataselwave),2) fermiwave
		fermiwave[][0]=datalistwave[p]
		NewPanel /W=(538,182,821,618)/N=fermiwaveedit
		Button button0,pos={100.00,385.00},size={80.00,30.00},title="Continue"
		Button button0,font="Times New Roman",fSize=16,fStyle=1,proc=ButtonProc_fermiwaveeditbutton
		Edit/W=(14,25,273,374)/HOST=#  fermiwave
		ModifyTable format(Point)=1
		ModifyTable statsArea=85
		RenameWindow #,T0
		SetActiveSubwindow ##
	pauseforuser fermiwaveedit
	
	dowindow/f exp_logbook
	if(V_flag==0)
		NewNotebook/W=(200,150,800,500)/F=0/ENCG=1/N=exp_logbook
	endif
	for(i=0; i<index; i+=1)
		if(dataselwave[i]!=0)
			currentwavename=removeending(datalistwave[i],datatype)
			wave currentwave=$currentwavename
			xoff=dimoffset(currentwave,0)
			xdelta=dimdelta(currentwave,0)
			variable fermilevelvalue
			if(stringmatch(fermiwave[i][1],"")==1)
				
			else
				fermilevelvalue=str2num(fermiwave[i][1])
				setscale/P x, energyoffwave[i]-fermilevelvalue, xdelta, currentwave
				logtext="The fermi level for "+currentwavename+" is "+num2str(fermilevelvalue)+" eV\r" 
				Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
			endif
		endif
	endfor
	
	elseif(stringmatch(wavecheck,"polyAu fit")==1)
	string AuEFwavestr
	prompt AuEFwavestr "Choose the fitted EF for poly Au:" popup wavelist("fit_*",";","MINROWS:101")
	doprompt "", AuEFwavestr
	if(V_flag)
		return -1
	endif
	wave EFwave=$AuEFwavestr
	dowindow/f exp_logbook
	if(V_flag==0)
		NewNotebook/W=(200,150,800,500)/F=0/ENCG=1/N=exp_logbook
	endif
	
	for(i=0; i<index; i+=1)
		if(dataselwave[i]!=0)
			currentwavename=removeending(datalistwave[i],datatype)
			wave currentwave=$currentwavename
			if(dimsize(currentwave,1)==dimsize(EFwave,0))
				xdelta=dimdelta(currentwave,0)
				setscale/P x, energyoffwave[i]-EFwave[0], xdelta, currentwave
				make/N=(dimsize(currentwave,0))/O temp
				for(j=0; j<dimsize(EFwave,0); j+=1)
					temp[]=currentwave[p][j]
					setscale/P x, energyoffwave[i]-EFwave[j], xdelta, temp
					currentwave[][j]=temp(x)
				endfor
				logtext="The fermi level for "+currentwavename+" corrected by poly Au fermi level from "+AuEFwavestr+"\r" 
				Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
			else
				logtext="The dimension size of "+currentwavename+" and poly Au fermi wave "+AuEFwavestr+" mismatch!\r" 
				Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
			endif
		endif
	endfor
	killwaves temp
	endif
	logtext="----------The fermi level correct end--------------\r\r"
	Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext 
End

Function ButtonProc_fermiwaveeditbutton(ctrlName) : ButtonControl
	String ctrlName
	killwindow fermiwaveedit
End

Function ButtonProc_Norm(ctrlName) : ButtonControl
	String ctrlName
	wave/T datalistwave
	wave dataselwave
	variable i, index, j, k, tempavg, xdim, ydim, avgstart, avgend, goldwavesize
	string currentwavename, normtype, logtext, polyAuwave
	string/g datatype
	index=dimsize(datalistwave,0)
	prompt normtype "Please choose the norm type:" popup, "1/area point;1/area energy;1/maxval;polyAu"
	doprompt "", normtype
	if(V_flag)
    	return -1// User canceled
   endif
   
   dowindow/f exp_logbook
	if(V_flag==0)
		NewNotebook/W=(200,150,800,500)/F=0/ENCG=1/N=exp_logbook
	endif
	if(stringmatch(normtype,"1/maxval")==1)
	for(i=0; i<index; i+=1)
		if(dataselwave[i]!=0)
			currentwavename=removeending(datalistwave[i],datatype)
			variable maxval=wavemax($currentwavename)
			duplicate/O $currentwavename $currentwavename+"_nr"
			wave currentnrwave=$currentwavename+"_nr"
			currentnrwave/=maxval
			logtext="Norm "+currentwavename+" by 1/maxval method to "+currentwavename+"_nr \r" 
			Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
		endif
	endfor
		logtext="----------The norm process end--------------\r\r"
		Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext 
	endif

	if(stringmatch(normtype,"1/area point")==1)
		dowindow/f NewScopewindow
		if(V_flag!=1)
			Abort "Please show the Scope window!"
		endif
		if (stringmatch(CsrWave(a,""),"") || stringmatch(CsrWave(b,""),"") || stringmatch(CsrXwave(A,""),"ScopeMX"))
       	Abort "Set A and B cursors on the EDC Scope Graph!"
  		endif
		avgstart=pcsr(A);avgend=pcsr(B)
	for(i=0; i<index; i+=1)
		if(dataselwave[i]!=0)
			currentwavename=removeending(datalistwave[i],datatype)
			duplicate/O $currentwavename $currentwavename+"_nr"
			wave currentnrwave=$currentwavename+"_nr"
			xdim=dimsize(currentnrwave,0)
			ydim=dimsize(currentnrwave,1)
			make/O/N=(xdim) temp
			for(j=0;j<ydim;j+=1)
				temp=currentnrwave[p][j]
				tempavg=faverage(temp,avgstart,avgend)
				currentnrwave[][j]/=tempavg
			endfor	
			logtext="Norm "+currentwavename+" by 1/area by point method to "+currentwavename+"_nr \r" 
			Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext		
		endif
	endfor
	killwaves temp
	logtext="----------The norm process end--------------\r\r"
	Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext 
	endif
	
	if(stringmatch(normtype,"1/area energy")==1)
		dowindow/f NewScopewindow
		if(V_flag!=1)
			Abort "Please show the Scope window!"
		endif
		if (stringmatch(CsrWave(a,""),"") || stringmatch(CsrWave(b,""),"") || stringmatch(CsrXwave(A,""),"ScopeEX"))
       	Abort "Set A and B cursors on the MDC Scope Graph!"
  		endif
		avgstart=pcsr(A);avgend=pcsr(B)
	for(i=0; i<index; i+=1)
		if(dataselwave[i]!=0)
			currentwavename=removeending(datalistwave[i],datatype)
			duplicate/O $currentwavename $currentwavename+"_nr"
			wave currentnrwave=$currentwavename+"_nr"
			xdim=dimsize(currentnrwave,0)
			ydim=dimsize(currentnrwave,1)
			make/O/N=(ydim) temp
			for(j=0;j<xdim;j+=1)
				temp=currentnrwave[j][p]
				tempavg=faverage(temp,avgstart,avgend)
				currentnrwave[j][]/=tempavg
			endfor	
			logtext="Norm "+currentwavename+" by 1/area by energy method to "+currentwavename+"_nr \r" 
			Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext		
		endif
	endfor
	killwaves temp
	logtext="----------The norm process end--------------\r\r"
	Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
	endif
	
	if(stringmatch(normtype,"polyAu")==1)
		prompt polyAuwave "Please select a polyAu wave:" popup wavelist("*gold*", ";", "DIMS:2")
		doprompt "", polyAuwave
		if(V_flag)
			return -1
		endif
		wave polyAu=$polyAuwave	
		goldwavesize=dimsize(polyAu,1)
		xdim=dimsize(polyAu,0)
		make/O/N=(goldwavesize) goldarea
		make/O/N=(xdim) temp
		for(j=0;j<goldwavesize;j+=1)
			temp[]=polyAu[p][j]
			goldarea[j]=faverage(temp)
		endfor
	
	for(i=0; i<index; i+=1)
		if(dataselwave[i]!=0)
			currentwavename=removeending(datalistwave[i],datatype)
			if(dimsize($currentwavename,1) == goldwavesize)
				duplicate/O $currentwavename $currentwavename+"_nr"
				wave currentnrwave=$currentwavename+"_nr"
				for(j=0; j<goldwavesize; j+=1)
					currentnrwave[][j]/=goldarea[j]
				endfor
			
				logtext="Norm "+currentwavename+" by polyAu method to "+currentwavename+"_nr \r" 
				Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
				else
				logtext="Size of "+currentwavename+" and polyAu wave mismatch, norm fail.\r" 
				Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
			endif
		endif
	endfor
		
		Display goldarea
		Label left "\\F'Arial'\\Z24Area";DelayUpdate
		Label bottom "\\F'Arial'\\Z24Slices";DelayUpdate
		ModifyGraph tick=2,mirror=1,fSize=16,axThick=2,standoff=0, lsize=2
		ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28,width=255,height=142
		TextBox/C/N=text0/F=0/B=1/A=MC "\\F'Arial'\\Z16"+polyAuwave+" area"
		killwaves temp
		logtext="----------The norm process end--------------\r\r"
		Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext 
	endif
End
//////////////////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////// Curve fit and analysis//////////////////////////////////////////////
Function ButtonProc_curvefit (ctrlName) : ButtonControl
	String ctrlName
	String Fitfunction, fitwave, fitwaveX
	variable pcsrA, pcsrB, w_0, w_1, w_2, w_3, w_4, w_5, w_6, w_7, w_8, w_9, w_10, w_11, w_12
	variable xwavedim, xwaveoff, xwavedelta
	wave W_sigma
	prompt Fitfunction "Please choose the fit function:" popup, "FermiDirac;Lor_onepeak;Lor_twopeak;Lor_fourpeak;Voigt_onepeak;Voigt_twopeak;gauss_twopeak"
	doprompt "", Fitfunction
	if(V_flag)
		return -1 // user cancel
	endif
	if (stringmatch(CsrWave(A,""),"") || stringmatch(CsrWave(B,""),""))
     Abort "Set A and B cursors on the trace!"
   endif
   if(stringmatch(CsrWave(A,""),CsrWave(B,""))!=1)
   	 Abort "Set A and B cursors on the same trace!"
   	endif
   	
   	fitwave=Csrwave(A,"")
   	fitwaveX=Csrxwave(B,"")
	if(waveexists($fitwaveX)==0)
		xwavedim=dimsize($fitwave,0)
		xwaveoff=dimoffset($fitwave,0)
		xwavedelta=dimdelta($fitwave,0)
		make/O/N=(xwavedim) fitxwave
		fitxwave=xwaveoff+p*xwavedelta
		fitwaveX="fitxwave"
	endif
	
   	if(stringmatch(Fitfunction,"FermiDirac")==1)
   		duplicate/O $fitwaveX FDX
   		duplicate/O $fitwave FDY
   		make/O/N=5 FDfitcoeff
   		make/O fit_FDY
   		wave FDfitcoeff
   		prompt w_0, "The fit function reads f=A+(B+C(x-Ef))/(exp(-(x-Ef)/kBT)+1). The background A:" 
  		Prompt w_1, "Height of curve B:"
  		Prompt w_2, "Fermi energy Ef(eV):"
  		Prompt w_3, "kBT (meV):"
  		prompt w_4, "the linear correct C:"
  		doprompt "", w_0, w_1, w_2, w_3, w_4
  		if(V_flag)
  			return -1  //user cancel
  		endif
  	FDfitcoeff={w_0, w_1, w_2, w_3/1000, w_4}	
  	pcsrA=pcsr(A,"") ; pcsrB=pcsr(B,"")
   FuncFit/q FermiDiracfitfunction, FDfitcoeff, FDY[pcsrA,pcsrB]/X=FDX/D
   duplicate/O W_sigma, FDdelta
   printf "The fermi level is %g±%g eV;\rThe kBT is %g±%g meV;\rThe linear correct is %g±%g\r", FDfitcoeff[2],FDdelta[2],FDfitcoeff[3]*1000,FDdelta[3]*1000,FDfitcoeff[4],FDdelta[4]
   
    dowindow/f FDfit
    if(V_flag!=0)
    	removefromgraph/Z/w=FDfit $"#0", $"#1"
    	AppendToGraph/W=FDfit FDY vs FDX 
	 	AppendToGraph/w=FDfit fit_FDY 
	 	Modifygraph rgb(fit_FDY)=(0,0,0)
    else
	 	Display /W=(309,48,723,580)/N=FDfit 
	 	AppendToGraph/W=FDfit FDY vs FDX 
	 	AppendToGraph/w=FDfit fit_FDY 
	 	Modifygraph rgb(fit_FDY)=(0,0,0)
	 endif
	 fitcurveplot()
   endif
   	
   	if(stringmatch(Fitfunction,"Lor_onepeak")==1)
   		duplicate/O $fitwaveX LorX
   		duplicate/O $fitwave LorY
   		make/O/N=4 Lorfitcoeff
   		make/O fit_LorY
   		wave Lorfitcoeff, fit_LorY
 		prompt w_0, "The fit function reads f=A+h/((x-p)^2+d^2). The background A:" 
  		Prompt w_1, "Peak height h:"
  		Prompt w_2, "Peak position p:" 
  		Prompt w_3, "Peak width d:"
  		doprompt "", w_0, w_1, w_2, w_3
  		if(V_flag)
    		return -1  //user cancel
  		endif
  		Lorfitcoeff={w_0, w_1*w_3^2, w_2, w_3}
  		pcsrA=pcsr(A,"") ; pcsrB=pcsr(B,"")
  		FuncFit/q onepeaklorfunction Lorfitcoeff LorY[pcsrA,pcsrB]/X=LorX/D
  		duplicate/O W_sigma, onepeaklordelta
 	 	printf "The peak position is %g±%g; the peak width is %g±%g;\r", Lorfitcoeff[2],onepeaklordelta[2], Lorfitcoeff[3],onepeaklordelta[3]
 	 	
 	 	dowindow/f Lorfit
 	 	if(V_flag!=0)
    		removefromgraph/Z/w=Lorfit $"#0", $"#1"
    		AppendToGraph/W=Lorfit LorY vs LorX 
	 		AppendToGraph/w=Lorfit fit_LorY 
	 		Modifygraph rgb(fit_LorY)=(0,0,0)
    	else
	 	 	Display /W=(309,48,723,580)/N=Lorfit 
	 	 	AppendToGraph/w=Lorfit LorY vs LorX 
	 	 	AppendToGraph/w=Lorfit fit_LorY 
	 	 	Modifygraph rgb(fit_LorY)=(0,0,0)
	 	 endif
		 fitcurveplot()
   	endif
   	
   	if(stringmatch(Fitfunction,"Lor_twopeak")==1)
   		duplicate/O $fitwaveX LortwopeakX
  		duplicate/O $fitwave LortwopeakY
  		make/O/N=7 Lortwopeakfitcoeff
  		make/O fit_LortwopeakY
  		wave Lortwopeakfitcoeff
   		 prompt w_0, "The fit function reads f=A+h1/((x-p1)^2+d1^2)+h2/((x-p2)^2+d2^2). The background A:" 
  		 Prompt w_1, "Peak1 height h1:"
		 Prompt w_2, "Peak1 position p1:" 
	    Prompt w_3, "Peak1 width d1:"
	    Prompt w_4, "Peak2 height h2:"
  	 	 Prompt w_5, "Peak2 position p2:" 
  		 Prompt w_6, "Peak2 width d2:"
  		doprompt "", w_0, w_1, w_2, w_3, w_4, w_5, w_6
  		if(V_flag)
   			return -1  //user cancel
  		endif
 		Lortwopeakfitcoeff={w_0, w_1*w_3^2, w_2, w_3, w_4*w_6^2, w_5, w_6}
 		pcsrA=pcsr(A,"") ; pcsrB=pcsr(B,"")
  		FuncFit/q twopeaklorfunction Lortwopeakfitcoeff LortwopeakY[pcsrA,pcsrB] /X=LortwopeakX /D
  		duplicate/O W_sigma, twopeaklordelta
  		printf "The peak1 position p1 is %g±%g; the peak1 width d1 is %g±%g;\r", Lortwopeakfitcoeff[2], twopeaklordelta[2],Lortwopeakfitcoeff[3],twopeaklordelta[3]
  		printf "The peak2 position p2 is %g±%g; the peak2 width d2 is %g±%g;\r", Lortwopeakfitcoeff[5], twopeaklordelta[5],Lortwopeakfitcoeff[6],twopeaklordelta[6]
  		
  		dowindow/f Lortwopeakfit
  		if(V_flag!=0)
  			removefromgraph/Z/w=Lortwopeakfit $"#0", $"#1"
    		AppendToGraph/W=Lortwopeakfit LortwopeakY vs LortwopeakX 
	 		AppendToGraph/w=Lortwopeakfit fit_LortwopeakY 
	 		Modifygraph rgb(fit_LortwopeakY)=(0,0,0)
	 	else
	 		Display /W=(309,48,723,580)/N=Lortwopeakfit 
	 		AppendToGraph/w=Lortwopeakfit LortwopeakY vs LortwopeakX
	 		AppendToGraph/w=Lortwopeakfit fit_LortwopeakY 
	 		Modifygraph rgb(fit_LortwopeakY)=(0,0,0)
	 	endif
	 	fitcurveplot()
	endif
	
	if(stringmatch(Fitfunction,"Lor_fourpeak")==1)
   		duplicate/O $fitwaveX LorfourpeakX
  		duplicate/O $fitwave LorfourpeakY
  		make/O/N=13 Lorfourpeakfitcoeff
  		make/O fit_LorfourpeakY
  		wave Lorfourpeakfitcoeff
  		prompt w_0, "The fit function reads f=A+h1/((x-p1)^2+d1^2)+h2/((x-p2)^2+d2^2)+h3/((x-p3)^2+d3^2)+h4/((x-p4)^2+d4^2). The background A:" 
  		Prompt w_1, "Peak1 height h1:"
  		Prompt w_2, "Peak1 position p1:" 
 		Prompt w_3, "Peak1 width d1:"
  		Prompt w_4, "Peak2 height h2:"
  		Prompt w_5, "Peak2 position p2:" 
  		Prompt w_6, "Peak2 width d2:"
  		doprompt "", w_0, w_1, w_2, w_3, w_4, w_5, w_6
  		Prompt w_7, "Peak3 height h3:"
  		Prompt w_8, "Peak3 position p3:" 
  		Prompt w_9, "Peak3 width d3:"
  		Prompt w_10, "Peak4 height h4:"
  		Prompt w_11, "Peak4 position p4:" 
  		Prompt w_12, "Peak4 width d4:"
  		doprompt "", w_7, w_8, w_9, w_10, w_11, w_12 
  		if(V_flag)
    		return -1  //user cancel
  		endif
 		Lorfourpeakfitcoeff={w_0, w_1*w_3^2, w_2, w_3, w_4*w_6^2, w_5, w_6, w_7*w_9^2, w_8, w_9, w_10*w_12^2, w_11, w_12}
  		pcsrA=pcsr(A,"") ; pcsrB=pcsr(B,"")
  		FuncFit/q fourpeaklorfunction Lorfourpeakfitcoeff LorfourpeakY[pcsrA,pcsrB] /X=LorfourpeakX /D
  		duplicate/O W_sigma, fourpeaklordelta
 	 	printf "The peak1 position p1 is %g±%g; the peak1 width d1 is %g±%g;\r", Lorfourpeakfitcoeff[2],fourpeaklordelta[2], Lorfourpeakfitcoeff[3],fourpeaklordelta[3]
  		printf "The peak2 position p2 is %g±%g; the peak2 width d2 is %g±%g;\r", Lorfourpeakfitcoeff[5],fourpeaklordelta[5], Lorfourpeakfitcoeff[6],fourpeaklordelta[6]
  		printf "The peak3 position p3 is %g±%g; the peak3 width d3 is %g±%g;\r", Lorfourpeakfitcoeff[8],fourpeaklordelta[8], Lorfourpeakfitcoeff[9],fourpeaklordelta[9]
  		printf "The peak4 position p4 is %g±%g; the peak4 width d4 is %g±%g;\r", Lorfourpeakfitcoeff[11], fourpeaklordelta[11],Lorfourpeakfitcoeff[12],fourpeaklordelta[12]
  		
  		dowindow/f Lorfourpeakfit
  		if(V_flag!=0)
  			removefromgraph/Z/w=Lorfourpeakfit $"#0", $"#1"
    		AppendToGraph/W=Lorfourpeakfit LorfourpeakY vs LorfourpeakX 
	 		AppendToGraph/w=Lorfourpeakfit fit_LorfourpeakY 
	 		Modifygraph rgb(fit_LorfourpeakY)=(0,0,0)
	 	else
	 		Display /W=(309,48,723,580)/N=Lorfourpeakfit 
	 		AppendToGraph/w=Lorfourpeakfit LorfourpeakY vs LorfourpeakX 
	 		AppendToGraph/W=Lorfourpeakfit fit_LorfourpeakY 
	 		Modifygraph rgb(fit_LorfourpeakY)=(0,0,0)
	 	endif
	 	fitcurveplot()
  	endif
  	
  	   	
   	if(stringmatch(Fitfunction,"Voigt_onepeak")==1)
   		duplicate/O $fitwaveX VoigtX
   		duplicate/O $fitwave VoigtY
   		make/O/N=5 Voigtfitcoeff
   		make/O fit_VoigtY
   		wave Voigtfitcoeff, fit_VoigtY
 		prompt w_0, "The fit function reads f=A+h/((x-p)^2+d^2)⊗gauss(x-p). The background A:" 
  		Prompt w_1, "Peak height h:"
  		Prompt w_2, "Peak position p:" 
  		Prompt w_3, "Peak width d:"
  		doprompt "", w_0, w_1, w_2, w_3
  		if(V_flag)
    		return -1  //user cancel
  		endif
  		Voigtfitcoeff={w_0, w_1, 5/w_3, w_2, 5}
  		pcsrA=pcsr(A,"") ; pcsrB=pcsr(B,"")
  		FuncFit/q onepeakVoigtfunction Voigtfitcoeff VoigtY[pcsrA,pcsrB]/X=VoigtX/D
  		duplicate/O W_sigma, onepeakVoigtdelta
 	 	printf "The peak1 position is %g±%g; the peak1 Lor width is %g; gauss width is %g; Voigt width is %g; peak1 area is %g\r", Voigtfitcoeff[3], onepeakVoigtdelta[3], Voigtfitcoeff[4]/Voigtfitcoeff[2],  sqrt(ln(2))/Voigtfitcoeff[2], Voigtfitcoeff[4]/Voigtfitcoeff[2]/2+sqrt((Voigtfitcoeff[4]/Voigtfitcoeff[2]/2)^2+(sqrt(ln(2))/Voigtfitcoeff[2])^2), Voigtfitcoeff[1]/Voigtfitcoeff[2]*sqrt(pi)
 	 	
 	 	dowindow/f Voigtfit
 	 	if(V_flag!=0)
    		removefromgraph/Z/w=Voigtfit $"#0", $"#1"
    		AppendToGraph/W=Voigtfit VoigtY vs VoigtX 
	 		AppendToGraph/w=Voigtfit fit_VoigtY 
	 		Modifygraph rgb(fit_VoigtY)=(0,0,0)
    	else
	 	 	Display /W=(309,48,723,580)/N=Voigtfit 
	 	 	AppendToGraph/w=Voigtfit VoigtY vs VoigtX 
	 	 	AppendToGraph/w=Voigtfit fit_VoigtY 
	 	 	Modifygraph rgb(fit_VoigtY)=(0,0,0)
	 	 endif
		 fitcurveplot()
   	endif
  	
  	if(stringmatch(Fitfunction,"Voigt_twopeak")==1)
   		duplicate/O $fitwaveX VoigttwopeakX
  		duplicate/O $fitwave VoigttwopeakY
  		make/O/N=9 Voigttwopeakfitcoeff
  		make/O fit_VoigttwopeakY
  		wave Voigttwopeakfitcoeff
   		 prompt w_0, "The fit function reads f=A+h1/((x-p1)^2+d1^2)⊗gauss(x-p1)+h2/((x-p2)^2+d2^2)⊗gauss(x-p2). The background A:" 
  		 Prompt w_1, "Peak1 height h1:"
		 Prompt w_2, "Peak1 position p1:" 
	    Prompt w_3, "Peak1 width d1:"
	    Prompt w_4, "Peak2 height h2:"
  	 	 Prompt w_5, "Peak2 position p2:" 
  		 Prompt w_6, "Peak2 width d2:"
  		doprompt "", w_0, w_1, w_2, w_3, w_4, w_5, w_6
  		if(V_flag)
   			return -1  //user cancel
  		endif
 		Voigttwopeakfitcoeff={w_0, w_1, 5/w_3, w_2, 5, w_4, 5/w_6, w_5, 5}
 		pcsrA=pcsr(A,"") ; pcsrB=pcsr(B,"")
  		FuncFit/q twopeakVoigtfunction Voigttwopeakfitcoeff VoigttwopeakY[pcsrA,pcsrB] /X=VoigttwopeakX /D
  		duplicate/O W_sigma, twopeakVoigtdelta
  		
  		printf "The peak1 position is %g±%g; the peak1 Lor width is %g; gauss width is %g; Voigt width is %g; peak1 area is %g\r", Voigttwopeakfitcoeff[3], twopeakVoigtdelta[3], Voigttwopeakfitcoeff[4]/Voigttwopeakfitcoeff[2],  sqrt(ln(2))/Voigttwopeakfitcoeff[2], Voigttwopeakfitcoeff[4]/Voigttwopeakfitcoeff[2]/2+sqrt((Voigttwopeakfitcoeff[4]/Voigttwopeakfitcoeff[2]/2)^2+(sqrt(ln(2))/Voigttwopeakfitcoeff[2])^2), Voigttwopeakfitcoeff[1]/Voigttwopeakfitcoeff[2]*sqrt(pi)
  		printf "The peak2 position is %g±%g; the peak1 Lor width is %g; gauss width is %g; Voigt width is %g; peak2 area is %g\r", Voigttwopeakfitcoeff[7], twopeakVoigtdelta[7], Voigttwopeakfitcoeff[8]/Voigttwopeakfitcoeff[6],  sqrt(ln(2))/Voigttwopeakfitcoeff[6], Voigttwopeakfitcoeff[8]/Voigttwopeakfitcoeff[6]/2+sqrt((Voigttwopeakfitcoeff[8]/Voigttwopeakfitcoeff[6]/2)^2+(sqrt(ln(2))/Voigttwopeakfitcoeff[6])^2), Voigttwopeakfitcoeff[5]/Voigttwopeakfitcoeff[6]*sqrt(pi)
  		
  		dowindow/f Voigttwopeakfit
  		if(V_flag!=0)
  			removefromgraph/Z/w=Voigttwopeakfit $"#0", $"#1"
    		AppendToGraph/W=Voigttwopeakfit VoigttwopeakY vs VoigttwopeakX 
	 		AppendToGraph/w=Voigttwopeakfit fit_VoigttwopeakY 
	 		Modifygraph rgb(fit_VoigttwopeakY)=(0,0,0)
	 	else
	 		Display /W=(309,48,723,580)/N=Voigttwopeakfit 
	 		AppendToGraph/w=Voigttwopeakfit VoigttwopeakY vs VoigttwopeakX
	 		AppendToGraph/w=Voigttwopeakfit fit_VoigttwopeakY 
	 		Modifygraph rgb(fit_VoigttwopeakY)=(0,0,0)
	 	endif
	 	fitcurveplot()
	endif
  	
  	if(stringmatch(Fitfunction,"gauss_twopeak")==1)
   		 duplicate/O $fitwaveX gausstwopeakX
  		 duplicate/O $fitwave gausstwopeakY
  		 make/O/N=7 gausstwopeakfitcoeff
  		 make/O fit_gausstwopeakY
  		 wave gausstwopeakfitcoeff 
  		 prompt w_0, "The fit function reads f=A+h1*exp(-((x-p1)/d1)^2)+h2*exp(-((x-p2)/d2)^2). The background A:" 
  		 Prompt w_1, "Peak1 height h1:"
  	 	 Prompt w_2, "Peak1 position p1:" 
  		 Prompt w_3, "Peak1 FWHM d1:"
  		 Prompt w_4, "Peak2 height h2:"
  	  	 Prompt w_5, "Peak2 position p2:" 
  		 Prompt w_6, "Peak2 FWHM d2:"
  		 doprompt "", w_0, w_1, w_2, w_3, w_4, w_5, w_6
  		 if(V_flag)
    		return -1  //user cancel
  		 endif
  		 pcsrA=pcsr(A,"") ; pcsrB=pcsr(B,"")
  		 FuncFit/q twopeakgaussfunction gausstwopeakfitcoeff gausstwopeakY[pcsrA,pcsrB] /X=gausstwopeakX /D
  		 duplicate/O W_sigma, twopeakgaussdelta
  		 printf "The peak1 position p1 is %g±%g; the peak1 FWHM d1 is %g±%g\r", gausstwopeakfitcoeff[2], twopeakgaussdelta[2], gausstwopeakfitcoeff[3], twopeakgaussdelta[3] 
  		 printf "The peak2 position p2 is %g±%g; the peak2 FWHM d2 is %g±%g\r", gausstwopeakfitcoeff[5], twopeakgaussdelta[5], gausstwopeakfitcoeff[6], twopeakgaussdelta[6]
  		 
  		 dowindow/f gausstwopeakfit
  		 if(V_flag!=0)	
  		 	removefromgraph/Z/w=gausstwopeakfit $"#0", $"#1"
    		AppendToGraph/W=gausstwopeakfit gausstwopeakY vs gausstwopeakX 
	 		AppendToGraph/w=gausstwopeakfit fit_gausstwopeakY 
	 		Modifygraph rgb(fit_gausstwopeakY)=(0,0,0)
	 	else
	 	 	Display /W=(309,48,723,580)/N=gausstwopeakfit 
	 	 	AppendToGraph gausstwopeakY vs gausstwopeakX 
	 	 	AppendToGraph fit_gausstwopeakY 
	 	 	Modifygraph rgb(fit_gausstwopeakY)=(0,0,0)
	 	 endif
	 	 fitcurveplot()
  	endif
End

Function fitcurveplot()
		PauseUpdate; Silent 1		// modifying window...
		ModifyGraph mode=0, lsize=2
		ModifyGraph/Z tick=2
	 	ModifyGraph/Z mirror=1
	 	ModifyGraph/Z font="Arial"
	 	ModifyGraph/Z fSize=16
	 	ModifyGraph/Z fStyle=1
	 	ModifyGraph/Z standoff=0
	 	ModifyGraph/Z axThick=2
	 	ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28,width=340.157,height=226.772
	 	Label/Z left "\\F'Arial'\\Z24\f00Intensity (arb. units)"
	 	Label bottom "\\F'Arial'\\Z24\\f00E (eV) / k (slice/Å\\S-1\\M\\F'Arial'\\Z24)"
End
/////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////// New 2D wave plot and view ///////////////////////////////////

Function ButtonProc_NewImage(ctrlName) : ButtonControl
	String ctrlName
	Execute "NewImagePanel()"
End

Window NewImagePanel() : Graph
	dowindow/f NewImagewindow
	if(V_flag==0)
	make/O EDCIntensity,MDCIntensity,EDCX,MDCX
	variable/g Scopeadd=1
	variable/g Scopesmooth=0, Scopeoffset=0
	variable/g plotx=0,ploty=0,xrange=0.01,yrange=0.01, ImageColorgammaval=1
	string/g NewImagename
	variable/g NewImagecolorcheck=1
	variable/g ImageColorgammaval=1
	string/g liveplotoptstr="raw"
	variable/g energydimension, momentumdimension, energyoff, momentumoff, energydelta, momentumdelta, energy1, momentum1
	Display/W=(400,100,1050,700) /N=NewImagewindow
	ControlBar 70
   PopupMenu plotcolor pos={340,10},bodyWidth=120,value="*COLORTABLEPOP*",proc=NewImagecolor,font="Times New Roman",fSize=20
   CheckBox check0 value=1,title="invert",pos={270,40},side=1,proc=ImageCheckProccolor,font="Times New Roman",fSize=20
   SetVariable setvarlive0 title="E",pos={80,10},size={100,20},proc=SetplotxProc,bodyWidth=55,value= plotx,limits={-inf,inf,0},font="Times New Roman",fSize=16
   SetVariable setvarlive1 title="k",pos={80,35},size={100,20},proc=SetplotyProc,bodyWidth=55,value= ploty,limits={-inf,inf,0},font="Times New Roman",fSize=16
   SetVariable setvar2 title="ΔE",pos={150,10},size={100,20},proc=SetxrangeProc,bodyWidth=40,value= _NUM:0.01,limits={-inf,inf,0},font="Times New Roman",fSize=16
   SetVariable setvar3 title="Δk",pos={150,35},size={100,20},proc=SetyrangeProc,bodyWidth=40,value= _NUM:0.01,limits={-inf,inf,0},font="Times New Roman",fSize=16
   SetVariable setvar4 title="γ",pos={340,40},size={55,20},proc=SetImageColorgamma,value=_Num:1,limits={0.1,inf,0.1},font="Times New Roman",fsize=16 
   Setvariable setvar5 title="Add",pos={490,12},size={80,20},proc=ScopeAddnum,value=Scopeadd,limits={1,inf,1},font="Times New Roman",fsize=16 
   SetVariable setvar8 title=" ",pos={5,35},size={100,20},value=NewImagename,font="Times New Roman",fsize=16
   Button button0 title="Load", pos={10,5},size={80,30},proc=ButtonProcPlotwave,font="Times New Roman",fSize=20
   Button button1 title="Scope", pos={400,10},size={80,30},proc=ButtonProcScope,font="Times New Roman",fSize=20
  	Button button2,title="AuEF",pos={532.00,45.00},size={50.00,20.00},proc=ButtonProcAuEffit,font="Times New Roman",fsize=14
   ModifyGraph swapXY=1
   AppendtoGraph/B=EDCaxisB/L=EDCaxisL EDCIntensity
   AppendtoGraph/B=MDCaxisB/L=MDCaxisL/VERT MDCIntensity
   ModifyGraph axisEnab(MDCaxisB)={0,0.7}
	ModifyGraph axisEnab(MDCaxisL)={0.7,1}
	ModifyGraph axisEnab(EDCaxisB)={0.70,1}
   ModifyGraph axisEnab(EDCaxisL)={0,0.7}
   ModifyGraph noLabel(MDCaxisB)=2,noLabel(EDCaxisL)=2
   	ModifyGraph/Z axThick=2
   ModifyGraph freePos(EDCaxisB)=0, freePos(EDCaxisL)={0,EDCaxisB}
   ModifyGraph freePos(MDCaxisB)={0,MDCaxisL}, freePos(MDCaxisL)=0
   ModifyGraph fStyle(MDCaxisL)=1,fSize(MDCaxisL)=16,font(MDCaxisL)="Arial"
   ModifyGraph fStyle(EDCaxisB)=1,fSize(EDCaxisB)=16,font(EDCaxisB)="Arial"
   Label EDCaxisB "\\F'Arial'\\Z24\f00 EDC Intensity"
   Label MDCaxisL "\\F'Arial'\\Z24\f00 MDC Intensity"
   ModifyGraph lblPosMode(MDCaxisL)=1, lblPosMode(EDCaxisB)=1
   ModifyGraph margin(left)=70,margin(bottom)=70,margin(right)=42,margin(top)=28
  
   SetVariable setvar6 title="Num",limits={1,inf,1},font="Arial",fSize=14,fstyle=1
	SetVariable setvar6 value= _NUM:1, pos={405,45}, size={70,20}, proc=ImagelistupdateProc
	PopupMenu popup0,pos={484.00,45.00},size={43.00,22.00},proc=PopMenuProc_liveplotoption
	PopupMenu popup0,font="Arial",fSize=20,fStyle=1
	PopupMenu popup0,mode=1,popvalue="raw",value= #"\"raw;norm;corr;nr+corr\""
	
	// generate a demo E-k cut and append live drag curve
	demo2Dgen()
	duplicate/o demo2D, curveplotwave
	energydimension=dimsize(curveplotwave,0); momentumdimension=dimsize(curveplotwave,1)
	energydelta=dimdelta(curveplotwave,0); momentumdelta=dimdelta(curveplotwave,1)
	energyoff=dimoffset(curveplotwave,0); momentumoff=dimoffset(curveplotwave,1)
	energy1=energyoff+energydelta*(energydimension-1)	
	momentum1=momentumoff+momentumdelta*(momentumdimension-1)	
	redimension/N=(energydimension) EDCIntensity
   	setscale/P x energyoff, energydelta, EDCIntensity
   	redimension/N=(momentumdimension) MDCIntensity
   	setscale/P x momentumoff, momentumdelta, MDCIntensity
	AppendImage curveplotwave
	ModifyGraph axisEnab(left)={0,0.7}
	ModifyGraph axisEnab(bottom)={0,0.7}
	SetAxis left energyoff, energy1
	SetAxis bottom momentumoff, momentum1
	ModifyGraph/Z tick=2
	ModifyGraph tickUnit(left)=1,tickUnit(bottom)=1
	ModifyGraph/Z mirror=1
	ModifyGraph/Z font="Arial"
	ModifyGraph/Z fSize=16
	ModifyGraph/Z fStyle=1
	ModifyGraph/Z standoff=0
	ModifyGraph zero(left)=4 
	ModifyGraph axThick=2
	Label/Z left "\\F'Arial'\\Z24\f02E-E\BF\M\F'Arial'\\Z24\f00 (eV)"
	Label/Z bottom "\\F'Arial'\\Z24\f00k\B//\M\F'Arial'\\Z24 (Å\S-1\M\F'Arial'\\Z24)"
   
   colorscale/C/N=text0/F=0/X=102.00/Y=-5.00 nticks=0
   make/o/n=2 LivecurveY_MDC, LivecurveX_MDC
	make/o/n=2 LivecurveY_EDC, LivecurveX_EDC
	LivecurveY_EDC={-inf,inf}; LivecurveX_EDC={0,0}
	LivecurveY_MDC={0,0}; LivecurveX_MDC={-inf,inf}
	AppendToGraph/VERT LivecurveY_EDC vs LivecurveX_EDC
	AppendToGraph/VERT LivecurveY_MDC vs LivecurveX_MDC
	ModifyGraph rgb(LivecurveY_EDC)=(65535,65535,0), rgb(LivecurveY_MDC)=(65535,65535,0)
	ModifyGraph lsize(LivecurveY_EDC)=2,lsize(LivecurveY_MDC)=2
	ModifyGraph live(LivecurveY_EDC)=1, live(LivecurveY_MDC)=1
	ModifyGraph quickdrag(LivecurveY_EDC)=1, quickdrag(LivecurveY_MDC)=1
	ModifyGraph lsize(EDCIntensity)=3, lsize(MDCIntensity)=3
   ModifyGraph lblPosMode(MDCaxisL)=1, lblPosMode(EDCaxisB)=1
   
   Doupdate;
   	twodimwavecurvetrack()
	twodimwavecurvelplot()
	NewImagecolorsetfunc()
	imageplotaxisupdate()
   killwaves demo2D
   endif
EndMacro

Function demo2Dgen()//// generate a demo E-k cut
	make/O/N=(601,601) demo2D
	setscale/I x -0.5, 0.1, "", demo2D
	setscale/I y -0.1, 0.5, "", demo2D
	//demo2D
	demo2D[][]=1/pi*(0.005+0.05*(x^2+(0.01*pi)^2))/((x-(4.5*(y-0.1)^2-0.4)-0.1*x)^2+(0.005+0.05*(x^2+(0.01*pi)^2))^2)
	demo2D[][]+=1/pi*(0.005+0.05*(x^2+(0.01*pi)^2))/((x-(4.5*(y-0.3)^2-0.4)-0.1*x)^2+(0.005+0.05*(x^2+(0.01*pi)^2))^2)
	demo2D*=1/(exp(x/0.005)+1)
	wavestats/Q demo2D
	variable V1=V_avg
	demo2D+=gnoise(V1/10)
End

Function ButtonProcPlotwave (ctrlName) : ButtonControl
	String ctrlName
	String loadwavename
	String/g NewImagename
	variable/g energydimension, momentumdimension, energyoff, momentumoff, energydelta, momentumdelta, energy1, momentum1
	wave EDCIntensity, MDCIntensity, curveplotwave
	string/g liveplotoptstr
	prompt loadwavename "Choose the 2D cuts to plot:" popup wavelist("!*curveplotwave",";","DIMS:2,MINCOLS:20")
	doprompt "", loadwavename
	NewImagename=loadwavename
	if(wavedims($loadwavename)==2)
			
		duplicate/o $loadwavename curveplotwave
		energydimension=dimsize(curveplotwave,0); momentumdimension=dimsize(curveplotwave,1)
		energydelta=dimdelta(curveplotwave,0); momentumdelta=dimdelta(curveplotwave,1)
		energyoff=dimoffset(curveplotwave,0); momentumoff=dimoffset(curveplotwave,1)
		energy1=energyoff+energydelta*(energydimension-1)	
		momentum1=momentumoff+momentumdelta*(momentumdimension-1)

		redimension/N=(energydimension) EDCIntensity
   		setscale/P x energyoff, energydelta, EDCIntensity
   		redimension/N=(momentumdimension) MDCIntensity
   		setscale/P x momentumoff, momentumdelta, MDCIntensity
		SetAxis left energyoff, energy1
		SetAxis bottom momentumoff, momentum1
		Label/Z left "\\F'Arial'\\Z24\f02E-E\BF\M\F'Arial'\\Z24\f00 (eV)"
		if(stringmatch(liveplotoptstr,"corr")==1)
			Label/Z bottom "\\F'Arial'\\Z24\f00k\B//\M\F'Arial'\\Z24 (Å\S-1\M\F'Arial'\\Z24)"
		else
			Label/Z bottom "\\F'Arial'\\Z24\f00slice angle (deg)"
		endif
		twodimwavecurvetrack()
		twodimwavecurvelplot()
		NewImagecolorsetfunc()
		Doupdate;
		imageplotaxisupdate()
	endif
End

Function ImagelistupdateProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave dataselwave, EDCIntensity, MDCIntensity, curveplotwave
	wave/T datalistwave
	String/g NewImagename, datatype
	variable/g energydimension, momentumdimension, energyoff, momentumoff, energydelta, momentumdelta, energy1, momentum1
	string/g liveplotoptstr
	
	variable uplimit=dimsize(dataselwave,0)
	if(uplimit == 0)
		Abort "Please first choose a path with file list and load data !"
	endif
	
	if(varNum >= uplimit)
		varNum = uplimit
		SetVariable setvar6 value= _Num:uplimit
		Print "This is the last one in the list."
	endif
	
	if(stringmatch(liveplotoptstr,"raw")==1)
		NewImagename=removeending(datalistwave[varNum-1],datatype)
		wave currentwave=$NewImagename
		if(waveexists(currentwave) != 1)
			Abort "Please first load the chosen data!"
		endif
	elseif(stringmatch(liveplotoptstr,"norm")==1)
		NewImagename=removeending(datalistwave[varNum-1],datatype)+"_nr"
		wave currentwave=$NewImagename
		if(waveexists(currentwave) != 1)
			Abort "Please first load and norm the data!"
		endif
	elseif(stringmatch(liveplotoptstr,"corr")==1)
		NewImagename=removeending(datalistwave[varNum-1],datatype)+"_corr"
		wave currentwave=$NewImagename
		if(waveexists(currentwave) != 1)
			Abort "Please first load and correct the data!"
		endif
	elseif(stringmatch(liveplotoptstr,"nr+corr")==1)
		NewImagename=removeending(datalistwave[varNum-1],datatype)+"_nr_corr"
		wave currentwave=$NewImagename
		if(waveexists(currentwave) != 1)
			Abort "Please first load and correct the data!"
		endif
	endif
	
		duplicate/o $NewImagename, curveplotwave
		energydimension=dimsize(curveplotwave,0); momentumdimension=dimsize(curveplotwave,1)
		energydelta=dimdelta(curveplotwave,0); momentumdelta=dimdelta(curveplotwave,1)
		energyoff=dimoffset(curveplotwave,0); momentumoff=dimoffset(curveplotwave,1)
		energy1=energyoff+energydelta*(energydimension-1)	
		momentum1=momentumoff+momentumdelta*(momentumdimension-1)
		
		redimension/N=(energydimension) EDCIntensity
   		setscale/P x energyoff, energydelta, EDCIntensity
   		redimension/N=(momentumdimension) MDCIntensity
   		setscale/P x momentumoff, momentumdelta, MDCIntensity
		SetAxis left energyoff, energy1
		SetAxis bottom momentumoff, momentum1

		Label/Z left "\\F'Arial'\\Z24\f02E-E\BF\M\F'Arial'\\Z24\f00 (eV)"
		if(stringmatch(liveplotoptstr,"corr")==1)
			Label/Z bottom "\\F'Arial'\\Z24\f00k\B//\M\\Z24 (\F'Times New Roman'Å\S-1\M\F'Arial'\\Z24)"
		elseif(stringmatch(liveplotoptstr,"nr+corr")==1)
			Label/Z bottom "\\F'Arial'\\Z24\f00k\B//\M\\Z24 (\F'Times New Roman'Å\S-1\M\F'Arial'\\Z24)"
		else
			Label/Z bottom "\\F'Arial'\\Z24\f00slice angle (deg)"
		endif
		twodimwavecurvetrack()
		twodimwavecurvelplot()
		NewImagecolorsetfunc()
		Doupdate;
		imageplotaxisupdate()
End

Function PopMenuProc_liveplotoption(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	string/g liveplotoptstr=popStr
End


Function twodimwavecurvetrack()
	wave EDCIntensity, MDCIntensity, curveplotwave
	variable/g plotx, xrange, energydimension, ploty, yrange, momentumdimension
	variable EDCmomentumtrackstart, EDCmomentumtrackend, MDCenergytrackstart, MDCenergytrackend
	EDCmomentumtrackstart= ScaleToIndex (curveplotwave,ploty,1)
   EDCmomentumtrackend= ScaleToIndex (curveplotwave,ploty+yrange,1)
   EDCIntensity[]=0
    variable i1 = EDCmomentumtrackstart
    variable j1 = -1
    do
    j1 += 1
    do
    EDCIntensity[j1] += curveplotwave[j1][i1]
    i1 +=1
    while (i1 < EDCmomentumtrackend)
    i1 = EDCmomentumtrackstart
    while (j1 < energydimension-1)
    
   MDCenergytrackstart= ScaleToIndex (curveplotwave,plotx,0)
   MDCenergytrackend= ScaleToIndex (curveplotwave,plotx+xrange,0)
   MDCIntensity[]=0
    variable i2 = MDCenergytrackstart
    variable j2 = -1
    do
    j2 += 1
    do
    MDCIntensity[j2] += curveplotwave[i2][j2]
    i2 +=1
    while (i2 < MDCenergytrackend)
    i2 = MDCenergytrackstart
    while (j2 < momentumdimension-1)
End
	
Function twodimwavecurvelplot()
	wave EDCIntensity, MDCIntensity, curveplotwave
	string/g currentwave
	variable/g plotx, ploty
	variable midx,midy,xdim,ydim
	xdim=dimsize(curveplotwave,0); ydim=dimsize(curveplotwave,1)
	midx=indextoscale(curveplotwave,xdim/2,0)
	midy=indextoscale(curveplotwave,ydim/2,1)
	plotx=midx; ploty=midy
	setvariable setvarlive0 value=plotx, win=NewImagewindow
	setvariable setvarlive1 value=ploty, win=NewImagewindow
	
	ModifyGraph/W=NewImagewindow offset(LivecurveY_EDC)={midy,0}
	ModifyGraph/W=NewImagewindow offset(LivecurveY_MDC)={0,midx}
   ModifyGraph tick(EDCaxisL)=2,tick(MDCaxisL)=2,tick(EDCaxisB)=2,tick(MDCaxisB)=2
   ModifyGraph fStyle(MDCaxisL)=1,fSize(MDCaxisL)=16,font(MDCaxisL)="Arial"
   ModifyGraph fStyle(EDCaxisB)=1,fSize(EDCaxisB)=16,font(EDCaxisB)="Arial"
   Doupdate;
   imageplotaxisupdate()
	setwindow NewImagewindow, hook(Imagehook)=NewImageHook
End

Function imageplotaxisupdate()
	wave EDCIntensity, MDCIntensity
	variable v1=wavemin(MDCIntensity)
	variable v2=wavemax(MDCIntensity)
	variable v3=wavemin(EDCIntensity)
	variable v4=wavemax(EDCIntensity)
	ModifyGraph freePos(MDCaxisB)={v1-(v2-v1)/20,MDCaxisL},freePos(MDCaxisL)=0
	SetAxis/W=NewImagewindow MDCaxisL v1-(v2-v1)/20, v2+(v2-v1)/20
	ModifyGraph freePos(EDCaxisL)={v3-(v4-v3)/20,EDCaxisB},freePos(EDCaxisB)=0
	SetAxis/W=NewImagewindow EDCaxisb v3-(v4-v3)/20, v4+(v4-v3)/20
End

Function NewImageHook(s)
	Struct WMWinHookstruct &s
	String offsetStr, offsetStr0, offsetStr1
	variable/g plotx, ploty, xrange, yrange
	variable hookresult=0
	wave curveplotwave, MDCIntensity,EDCIntensity

	switch(s.eventcode)
		case 8: // modified event
		if(s.eventMod == 8) // ctrl is down and liveupdate the Imagewindow
			offsetStr=StringByKey("offset(x)",TraceInfo("", "livecurveY_MDC", 0),"=")
			offsetStr0=StringfromList(1, offsetStr,",")[0,inf]
			offsetStr=StringByKey("offset(x)",TraceInfo("", "livecurveY_EDC", 0),"=")
			offsetStr1=StringfromList(0,offsetStr, ",")[1,inf]
				
			plotx=str2num(offsetStr0)
			SetVariable setvarlive0 value= plotx, win=NewImagewindow
			ploty=str2num(offsetStr1)
			SetVariable setvarlive1 value= ploty, win=NewImagewindow
			twodimwavecurvetrack()
			setAxis MDCaxisL wavemin(MDCIntensity), wavemax(MDCIntensity)
			setAxis EDCaxisB wavemin(EDCIntensity), wavemax(EDCIntensity)
		elseif(s.eventMod == 3) // shift is down and move the X Y to zero
			plotx=0; ploty=0
			SetVariable setvarlive0 value= plotx, win=NewImagewindow
			SetVariable setvarlive1 value= ploty, win=NewImagewindow
			ModifyGraph/w=NewImagewindow offset(LivecurveY_MDC)={0,plotx}
			ModifyGraph/w=NewImagewindow offset(LivecurveY_EDC)={ploty,0}
			twodimwavecurvetrack()
		endif
			imageplotaxisupdate()
			hookresult=1
		break
		
		case 11: // keyboard event
			switch(s.keycode-30)
				case -2:
					ploty-=yrange
					ModifyGraph/w=NewImagewindow offset(LivecurveY_EDC)={ploty,0}
				break
				case-1: 
					ploty+=yrange
					ModifyGraph/w=NewImagewindow offset(LivecurveY_EDC)={ploty,0}
				break
				case 0:
					plotx+=xrange
					ModifyGraph/w=NewImagewindow offset(LivecurveY_MDC)={0,plotx}
				break
				case 1:
					plotx-=xrange
					ModifyGraph/w=NewImagewindow offset(LivecurveY_MDC)={0,plotx}
				break
			endswitch
			setAxis MDCaxisL wavemin(MDCIntensity), wavemax(MDCIntensity)
			setAxis EDCaxisB wavemin(EDCIntensity), wavemax(EDCIntensity)
			twodimwavecurvetrack()
			imageplotaxisupdate()
			hookresult=1
		
		return hookresult
	endswitch
	
End

Function NewImagecolor(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	Colortab2wave $popStr
   NewImagecolorsetfunc()
End

Function ImageCheckProccolor(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	variable/g NewImagecolorcheck
	NewImagecolorcheck=checked
	NewImageColorsetfunc()
End

Function SetImageColorgamma(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g ImageColorgammaval
	ImageColorgammaval=varNum
	NewImageColorsetfunc()
End

Function NewImageColorsetfunc()
	wave NewImagecolortab, M_colors, curveplotwave
	variable/g ImageColorgammaval, NewImagecolorcheck
	variable size
	duplicate/O M_colors, NewImagecolortab
	size=dimsize(NewImagecolortab,0)
	NewImagecolortab[][]=M_colors[size*(p/size)^ImageColorgammaval][q]
	if(NewImagecolorcheck == 1)
      ModifyImage/Z curveplotwave ctab={*,*,NewImagecolortab,1}
   else
      ModifyImage/Z curveplotwave ctab={*,*,NewImagecolortab,0}
   endif
End

Function SetplotxProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
   variable/g plotx, curveplotcheck
   plotx=varNum
   twodimwavecurvetrack()
   ModifyGraph/w=NewImagewindow offset(LivecurveY_MDC)={0,plotx}
End

Function SetxrangeProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
   variable/g xrange
   xrange=varNum
   twodimwavecurvetrack()
End

Function SetplotyProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
   variable/g ploty, curveplotcheck
   ploty=varNum
   twodimwavecurvetrack()
   ModifyGraph/w=NewImagewindow offset(LivecurveY_EDC)={ploty,0}
End

Function SetyrangeProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
   variable/g yrange
   yrange=varNum
   twodimwavecurvetrack()
End

Function ButtonProcAuEffit(ctrlName) : ButtonControl
	String ctrlName
	wave curveplotwave
	variable Efi, Eff, i
	string auEFwave="polyAu001"
	string logtext
	string/g NewImagename
	prompt Efi "Enter the Fermi-Dirac fit Ei:"
	prompt Eff "Enter the Fermi Dirac fit Ef (> Ei):"
	prompt auEFwave "Enter the poly Au EF wave name:"
	doprompt "", Efi, Eff, auEFwave
	if(V_flag)
		return -1 //user cancel
	endif
	
	variable size1=dimsize(curveplotwave,0)
	variable size2=dimsize(curveplotwave,1)
	make/O/n=(size1) temp
	setscale/P x, dimoffset(curveplotwave,0), dimdelta(curveplotwave,0), temp
	make/O/n=(size2) $auEFwave
	wave auEF=$auEFwave
	make/O/n=5 FDfitcoeff
	
	for(i=0; i<size2; i+=1)
		temp[]=curveplotwave[p][i]
		FDfitcoeff={temp(Eff), temp(Efi)-temp(Eff),(Efi+Eff)/2, 0.01, 0}
		FuncFit/q FermiDiracfitfunction, FDfitcoeff, temp[x2pnt(temp,Efi), x2pnt(temp,Eff)]/D
		auEF[i]=FDfitcoeff[2]
	endfor
	
	Display $auEFwave
	ModifyGraph tick=2,mirror=1,fSize=20,axThick=2,standoff=0,font="Arial"
	Label left "\\F'Arial'\\Z24\\f02E\\BF\\M\\f00 (eV)"
	Label bottom "\\F'Arial'\\Z24slices"
	ModifyGraph mode=4,marker=19,msize=2,mrkThick=1,rgb=(2,39321,1)
	
	CurveFit/Q/L=(size2) /X=1 poly 8, $auEFwave /D 
	ModifyGraph lsize($"fit_"+auEFwave)=3
	killwaves temp, fit_temp
	
	logtext="generate a polyAu Fermi level wave from "+NewImagename+" to fit_"+auEFwave+"\r\r"
	Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
End

Function ButtonProcScope(ctrlName) : ButtonControl
	String ctrlName
	String scopetype, scopewave
	variable scopenum, i, j, curvenum, energydim, momentumdim, energyoff, momentumoff, energydelta, momentumdelta
	variable/g scopeadd
	string/g liveplotoptstr
	wave curveplotwave
	prompt scopetype "Please choose the scope type:" popup, "EDC;MDC"
	doprompt "", scopetype
	if(V_flag)
		return -1 //user cancel
	endif
	energydim=dimsize(curveplotwave,0);momentumdim=dimsize(curveplotwave,1)
	energyoff=dimoffset(curveplotwave,0);momentumoff=dimoffset(curveplotwave,1)
	energydelta=dimdelta(curveplotwave,0);momentumdelta=dimdelta(curveplotwave,1)
	dowindow/f NewScopewindow	
	if(V_flag==0)
		Display/W=(500,200,800,600) /N=NewScopewindow
		Controlbar/L 200
		make/O/T Scopelistwave
		make/O Scopelistselwave
		PopupMenu popup0 title="Color",value="*COLORPOP*",font="Times New Roman",fSize=16,popcolor=(65535,0,0)
		PopupMenu popup0 pos={10,10}, proc=PopMenuProc_Scopecolor
		PopupMenu popup1 pos={10,35}, bodyWidth=140,title="Colortab",value="*COLORTABLEPOP*",font="Times New Roman",fSize=16
		PopupMenu popup1 proc=PopMenuProc_Scopecolortab
		ListBox list0 pos={10,120},size={180,300}, mode=9, font="Times New Roman",fSize=16
		ListBox list0 listWave=Scopelistwave,selWave=Scopelistselwave
		SetVariable setvar0 title="lsize",pos={105,10},size={80,20},proc=SetVarProc_Scopelsize,limits={0,10,0.5},value= _NUM:2,font="Times New Roman",fSize=16
		SetVariable setvar1 title="Offset",pos={10,65},size={80,20},proc=Scopeoffsetnum,value=_NUM:0,limits={0,inf,0},font="Times New Roman",fsize=16 
		SetVariable setvar2 title="Smooth",pos={100,65},size={100,20},proc=ScopeSmoothnum,value=_Num:0,limits={0,inf,1},font="Times New Roman",fsize=16 
		Button button0 title="NewGraph",size={80,30},pos={55,90},proc=ButtonProc_NewScopeGraph,font="Times New Roman",fSize=16
		variable/g scopelsize=2, scopeoffset=0, scoper=65535, scopeg=0, scopeb=0
	else
		string displayscopelist=wavelist("Scope*",";","WIN:NewScopewindow")
		variable displayscopenum = itemsinlist(displayscopelist)-1
		for(i=0;i<displayscopenum;i+=1)
			RemoveFromGraph $"Scope"+num2str(i)
		endfor
	endif
	if(stringmatch(scopetype,"EDC") == 1)
		make/O/N=(energydim) ScopeEX
		ScopeEX[]=energyoff+p*energydelta
		if(scopeadd>momentumdim)
			scopeadd=momentumdim
		endif
		scopenum=floor(momentumdim/scopeadd)
		redimension/N=(scopenum+1) Scopelistwave, Scopelistselwave
		for(i=0;i<scopenum+1;i+=1)
			make/O/N=(energydim) currentscopewave
			Scopelistwave[i]="Scope"+num2str(i)
			currentscopewave=0
			for(j=0;j<scopeadd;j+=1)
				if(j+i*scopeadd<momentumdim)
					currentscopewave[]+=curveplotwave[p][j+i*scopeadd]	
				else
					currentscopewave[]+=0
				endif
			endfor
				currentscopewave/=scopeadd
				if(wavemax(currentscopewave)!=0)
					duplicate/O currentscopewave $"Scope"+num2str(i)
					AppendtoGraph/w=NewScopewindow $"Scope"+num2str(i) vs ScopeEX
				endif
		endfor
	endif
	
	if(stringmatch(scopetype,"MDC")==1)
		make/O/N=(momentumdim) ScopeMX
		ScopeMX[]=momentumoff+p*momentumdelta
		if(scopeadd>energydim)
			scopeadd=energydim
		endif
		scopenum=floor(energydim/scopeadd)
		redimension/N=(scopenum+1) Scopelistwave, Scopelistselwave
		for(i=0;i<scopenum+1;i+=1)
			make/O/N=(momentumdim) currentscopewave
			Scopelistwave[i]="Scope"+num2str(i)
			for(j=0;j<scopeadd;j+=1)
				if(j+i*scopeadd<energydim)
					currentscopewave[]+=curveplotwave[j+i*scopeadd][p]
				else
					currentscopewave[]+=0
				endif
			endfor
			currentscopewave/=scopeadd
			if(wavemax(currentscopewave)!=0)
				duplicate/O currentscopewave $"Scope"+num2str(i)
				AppendtoGraph/w=NewScopewindow $"Scope"+num2str(i) vs ScopeMX
			endif
		endfor
	endif
	
	ModifyGraph width=453.543,height=340.157
	ModifyGraph margin(left)=70,margin(bottom)=70,margin(right)=28,margin(top)=28
	ModifyGraph mirror=1,fStyle=1,fSize=16,font="Arial"
	ModifyGraph tick=2,lsize=2
	ModifyGraph axThick=2
	Showinfo/w=NewScopewindow
	if(stringmatch(scopetype,"EDC")==1)
		Label left "\\F'Arial'\\Z24\\f00 EDC Intensity (arb. units)"
		Label bottom "\\F'Arial'\\Z24\\f02 E-E\\BF\\M\\F'Arial'\\Z24 \\f00(eV)"
		ModifyGraph zero(bottom)=4, zeroThick(bottom)=2
	endif
	
	if(stringmatch(scopetype,"MDC")==1)
		Label left "\\F'Arial'\\Z24\\f00 MDC Intensity (arb. units)"
		if(stringmatch(liveplotoptstr,"*corr")==1)
			Label bottom "\\F'Arial'\\Z24\\f00k\\B//\\M\\F'Arial'\\Z24 (Å\\S-1\\M\\F'Arial'\\Z24)"
		else
			Label bottom "\\F'Arial'\\Z24\\f00 k (slice/angle)"
		endif
		ModifyGraph zero(bottom)=4, zeroThick(bottom)=2
	endif
	killwaves currentscopewave
End

Function ScopeAddnum(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
End

Function PopMenuProc_Scopecolor(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	wave/T Scopelistwave
	wave Scopelistselwave
	controlinfo/w=NewScopewindow popup0
	variable/g scoper=V_Red, scopeg=V_Green, scopeb=V_Blue 
	variable displayscopenum, i
	displayscopenum = dimsize(Scopelistwave,0)
	for(i=0; i<displayscopenum; i+=1)
		string scope=Scopelistwave[i]
		if(Scopelistselwave[i]!=0)
			ModifyGraph/Z/W=NewScopewindow hideTrace($scope)=2
		else
			ModifyGraph/Z/W=NewScopewindow hideTrace($scope)=0
			ModifyGraph/Z/W=NewScopewindow rgb($scope)=(scoper,scopeg,scopeb)
		endif
	endfor
End

Function PopMenuProc_Scopecolortab(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	wave/T Scopelistwave
	wave Scopelistselwave, M_colors
	colortab2wave $popStr
	duplicate/O M_colors Scopecolortab
	variable xsize=dimsize(Scopecolortab,0)
	variable scopenum=0, displayscopenum, i, j=0
	scopenum = dimsize(Scopelistwave,0)
	for(i=0; i<scopenum; i+=1)
		if(Scopelistselwave[i]==0)
			displayscopenum+=1
		endif
	endfor
	
	for(i=0; i<scopenum; i+=1)
		string scope=Scopelistwave[i]
		if(Scopelistselwave[i]!=0)
			ModifyGraph/Z/W=NewScopewindow hideTrace($scope)=2
		else
			ModifyGraph/Z/W=NewScopewindow hideTrace($scope)=0
			ModifyGraph/Z/W=NewScopeWindow rgb($scope)=(Scopecolortab[j*(xsize/displayscopenum)][0],Scopecolortab[j*(xsize/displayscopenum)][1],Scopecolortab[j*(xsize/displayscopenum)][2])
			j+=1
		endif
	endfor
End

Function SetVarProc_Scopelsize(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave/T Scopelistwave
	wave Scopelistselwave
	variable displayscopenum, i
	variable/g scopelsize=varNum
	displayscopenum = dimsize(Scopelistwave,0)
	for(i=0; i<displayscopenum; i+=1)
		string scope=Scopelistwave[i]
		if(Scopelistselwave[i]!=0)
			ModifyGraph/Z/W=NewScopewindow hideTrace($scope)=2
		else
			ModifyGraph/Z/W=NewScopewindow hideTrace($scope)=0
			ModifyGraph/Z/W=NewScopewindow lsize($scope)=scopelsize
		endif
	endfor
End

Function Scopeoffsetnum(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave/T Scopelistwave
	wave Scopelistselwave
	variable/g Scopeoffset=varNum
	variable scopenum=0,i, j=0
	scopenum = dimsize(Scopelistwave,0)
	for(i=0;i<scopenum;i+=1)
		string scope=Scopelistwave[i]
		if(Scopelistselwave[i]!=0)
			ModifyGraph/Z/W=NewScopewindow hideTrace($scope)=2
		else
			ModifyGraph/Z/W=NewScopewindow hideTrace($scope)=0
			ModifyGraph/Z/W=NewScopeWindow offset($Scope)={0,j*Scopeoffset}
			j+=1
		endif
	endfor
End

Function ScopeSmoothnum(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave/T Scopelistwave
	wave Scopelistselwave
	variable scopenum=0, i
	scopenum = dimsize(Scopelistwave,0)
	for(i=0;i<scopenum;i+=1)
		string scope=Scopelistwave[i]
		if(Scopelistselwave[i]!=0)
			ModifyGraph/Z/W=NewScopewindow hideTrace($scope)=2
		else
			ModifyGraph/Z/W=NewScopewindow hideTrace($scope)=0
			Smooth varNum, $Scope
		endif
	endfor	
End


Function ButtonProc_NewScopeGraph(ctrlName) : ButtonControl
	String ctrlName
	String scopelist=wavelist("Scope*",";","WIN:NewScopewindow")
	variable scopelistnum=itemsinlist(scopelist)-1
	string xwave, scopecolorcheck, EDCMDCcheck
	wave/T Scopelistwave
	wave Scopelistselwave, scopecolortab
	variable i, j=0, xsize=dimsize(scopecolortab,0)
	variable/g scopelsize, Scopeoffset
	variable/g scoper, scopeg, scopeb
	string/g NewImagename

	prompt scopecolorcheck "Whether use colortab?", popup, "No;Yes"
	prompt EDCMDCcheck "EDC or MDC plot?", popup, "EDC;MDC"
	doprompt "", scopecolorcheck, EDCMDCcheck
	if(V_flag)
		return -1 // user cancel
	endif
	
	if(stringmatch(EDCMDCcheck,"EDC")==1)
		xwave="ScopeEX"
	else
		xwave="ScopeMX"
	endif
	Display/W=(400,100,600,500)
	for(i=0; i<scopelistnum; i+=1)
		string ywave="Scope"+num2str(i)
		string newscopewave=NewImagename+ywave
		string newxwave=NewImagename+xwave
		duplicate/O $ywave, $newscopewave
		duplicate/O $xwave, $newxwave
		AppendtoGraph $newscopewave vs $newxwave
	endfor
	ModifyGraph width=453.543,height=340.157
	ModifyGraph margin(left)=70,margin(bottom)=70,margin(right)=28,margin(top)=28
	ModifyGraph mirror=1,fStyle=1,fSize=16,font="Arial"
	ModifyGraph tick=2,lsize=2
	ModifyGraph axThick=2
	Label left "\\F'Arial'\\Z24\\f00 EDC Intensity (arb. units)"
	if(stringmatch(EDCMDCcheck,"EDC")==1)
		Label bottom "\\F'Arial'\\Z24\\f02 E-E\\BF\\M\\F'Arial'\\Z24 \\f00(eV)"
	else
		Label bottom "\\F'Arial'\\Z24\\f00 k (slice/angle)"
	endif
	ModifyGraph zero(bottom)=4, zeroThick(bottom)=2
	
	variable scopenum = dimsize(Scopelistwave,0), displayscopenum
	for(i=0; i<scopenum; i+=1)
		if(Scopelistselwave[i]==0)
			displayscopenum+=1
		endif
	endfor
	for(i=0;i<scopenum;i+=1)
		string scope=Scopelistwave[i]
		if(Scopelistselwave[i]!=0)
			ModifyGraph/Z hideTrace($NewImagename+scope)=2
		else
			ModifyGraph/Z hideTrace($NewImagename+scope)=0
			ModifyGraph/Z lsize($NewImagename+scope)=scopelsize
			ModifyGraph/Z offset($NewImagename+scope)={0,Scopeoffset*j}
		if(stringmatch(scopecolorcheck,"No")==1)
			ModifyGraph/Z rgb($NewImagename+scope)=(scoper,scopeg,scopeb)
		else
			ModifyGraph/Z rgb($NewImagename+scope)=(Scopecolortab[j*(xsize/displayscopenum)][0],Scopecolortab[j*(xsize/displayscopenum)][1],Scopecolortab[j*(xsize/displayscopenum)][2])
		endif
		j+=1
		endif
	endfor	
End

////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////// New 3D map plot and view /////////////////////////////////

Function ButtonProc_NewMap (ctrlName) : ButtonControl
	String ctrlName
	Execute "NewMapPanel()"
End

Window NewMapPanel() : Graph
	dowindow/f NewMapwindow
	if(V_flag==0)
	variable/g mapcolorcheck=1
	variable/g Mapcolorgammaval=1
	variable/g threedimmapX, threedimmapY, threedimmapZ, threedimmapZstack=1
	variable/g deltaZ=0
	string/g cubicmapname
	String/g MapTool="Reorder"
	Display/W=(400,100,1050,800) /N=NewMapwindow
	ControlBar 70
   PopupMenu plotcolor pos={340,10},bodyWidth=120,value="*COLORTABLEPOP*",proc=NewMapcolor,font="Times New Roman",fSize=20
	CheckBox check0 value=1,title="invert",pos={270,40},size={60,20},side=1,proc=MapCheckProccolor,font="Times New Roman",fSize=20
	setvariable setvar0,title="γ",pos={335,40},size={60,30},value=_Num:1,limits={0.1,inf,0.1},proc=SetMapColorgamma,font="Times New Roman",fSize=20
	setvariable setvarmap1,title="X",pos={110,5},size={70,28},proc=ButtonProc3DMapX,value=threedimmapX,limits={-inf,inf,0},font="Times New Roman",fSize=16
	setvariable setvarmap2,title="Y",pos={110,38},size={70,28},proc=ButtonProc3DMapY,value=threedimmapY,limits={-inf,inf,0},font="Times New Roman",fSize=16
	setvariable setvarmap3,title="Z",pos={185,5},size={70,28},proc=ButtonProc3DMapZ,value=threedimmapZ,limits={-inf,inf,0},font="Times New Roman",fSize=16
	setvariable setvar4,title="Δn",pos={185,38},size={70,28},proc=ButtonProc3DMapZstack,value=threedimmapZstack,limits={-inf,inf,0},font="Times New Roman",fSize=16
	setvariable setvar5,title=" ",pos={5,40},size={100,20},value=cubicmapname,font="Times New Roman",fSize=16
	SetVariable setvar1,pos={560.00,40.00},size={56.00,22.00},proc=SetVarProc3DMapdeltaZ,title="∆Z"
	SetVariable setvar1,font="Times New Roman",fSize=16,fStyle=1
	SetVariable setvar1,limits={0,inf,0},value= _NUM:0

	Button button0,title="Load", pos={10,5},size={80,30},proc=ButtonProc3DMapload,font="Times New Roman",fSize=20
	Button button1,title="Execute",pos={405,35},size={80,30},proc=ButtonProc3DMapToolExecute,font="Times New Roman",fSize=20
	PopupMenu popup0 title="Map Tool",pos={400,10},value="Reorder;Bin;Truncate;Norm;XYzero;Rescale;Azimuth;AreaSpectra;kxkymap;kzmap;Export"
	PopupMenu popup0 font="Times New Roman",fSize=16,proc=PopMenuProc_MapTool
	Button button2, title="Graph", pos={550,5},size={80,30},proc=ButtonProc3DMapNewGraph,font="Times New Roman",fSize=20
	Button button3,pos={490.00,35.00},size={50.00,25.00},proc=ButtonProc3DMapHelp,title="Help",font="Times New Roman",fSize=16

	endif
	demo3Dgen()
	threeDmapload("demo3D")
	killwaves demo3D
	
EndMacro

Function demo3Dgen()
// image suitable for demonstating key features, function adapted from Image Tool ipf file by Jonathan Denlinger @ ALS, LBNL
	make/O/N=(81,61,41) demo3D
	
	SetScale/I x -25,25,"" demo3D
	SetScale/I y -25,25,"" demo3D
	SetScale/I z -15,15,"" demo3D
	demo3D=exp(-(((abs(x)-15-0.005*y^2-0.01*z^2)^2)/(10-0.01*y^2)))  //Left-Right arcs
	//demo3D=exp(-(((-x-15-0.005*y^2)^2)/(10-0.01*y^2)))  //Left arc
	demo3D+=0.1*erfc((x-15-0.005*abs(y)^1.75-0.01*z^2)/(2-0.002*y^2))  //Right arc step
	demo3D+=+exp(-(((abs(y)-15-0.2*x^2+0.1*z^2)^2)/(20-0.02*x^2)))   //Top-Bottom arcs
	demo3D+=0.1*(1+cos((pi/2)*sqrt(x^2+y^2+z^2)))*exp(-(x^2+y^2-0.5*z^2)/50) //Central circles
	SetScale/I x -15,15,"" demo3D
	SetScale/I z 20,50,"" demo3D

End

Function ButtonProc3DMapHelp(ctrlName) : ButtonControl
// brief help document for 3D Map window
	String ctrlName
	String logtext
	dowindow/f NewMapwindowHelp
	if(V_flag==0)
		NewNotebook/F=0/OPTS=4/ENCG=1/W=(300,100,1200,480)/N=NewMapwindowHelp
		logtext="Help for NewMapWindow \r\r"
		logtext+="drift blue lines: move the lines, no update of images and curve;\r"
		logtext+="ctrl+drift blue lines in X-Y image: move the lines and live update the X-Z, Y-Z images and intensity curve;\r"
		logtext+="ctrl+drift blue lines on Z-intensity curve: move the lines and live update the X-Y image;\r"
		logtext+="shift+drift blue lines in X-Y image: set X and Y to be zero and set the lines to that position;\r"
		logtext+="mouse wheel: increase/decrease the Z value by deltaZ, move the lines on Z-intensity curve and live update X-Y image;\r"
		logtext+="Arrow Keys: increase/decrease the X or Y value by deltaZ, move the lines on X-Y iamge and live update the images and curve;\r"
		logtext+="Pageup and Pagedown Keys: increase/decrease the Z value by deltaZ, move the lines on Z-intensity iamge and live update the images and curve;\r"
		logtext+="F7 and F9 Keys: increase/decrease the Z value by deltaZ, move the lines on Z-intensity iamge and live update the images and curve; for macOS system;\r"
		logtext+="Load Button: choose the three dimensional wave and load; the wave name would be shown in text box below;\r"
		logtext+="X, Y, Z variable: set the position of three lines, the 2D image and lines would update after the value set;\r"
		logtext+="delt n: set the image integration range (count by pixels);\r"
		logtext+="colortable menu, invert check and gamma variable: choose and modify the color table, update the colorscale bar;\r"
		logtext+="Map Tool option and Execute Button: choose different tools and execute corresponding functions;\r"
		logtext+="   Reorder: switch the two axises of the map;\r"
		logtext+="   Bin: bin the data along one axis by an integer number;\r"
		logtext+="   Truncate: cut out the redundant part of the data;\r"
		logtext+="   Norm: norm the data for each pixel in X-Y plane along Z axis by the area of Z-intensity curve at this pixel;\r"
		logtext+="   XYzero: set the current X-Y position to be (0, 0);\r"
		logtext+="   Rescale: rescale one axis of the map;\r"
		logtext+="   Azimuth: generate a new graph of  current X-Y image and perform in-plane rotation;\r"
		logtext+="   Export: export the current map to a new 3D wave;\r"
		logtext+="Graph Button: export the graph shown in NewMapwindow;\r"
		logtext+="deltaZ: set the increasement/decreasement of line movement;\r"

		Notebook NewMapwindowHelp selection={endoffile, endoffile},fsize=12, text=logtext 
	endif

End

Function ButtonProc3DMapload (ctrlName) : ButtonControl
	String ctrlName
	String threedimwave
	string/g cubicmapname
	prompt threedimwave "Please choose the 3D map:" popup, wavelist("!*threeDmap",";","DIMS:3")
	doprompt "", threedimwave
	if(V_flag)
		return -1 //user cancel
	endif
	cubicmapname=threedimwave
	threeDmapload(threedimwave)
End	

Function threeDmapload(threeDmapname)
	String threeDmapname
	string wavecheck
	duplicate/O $threeDmapname threeDmap
	variable/g threedimmapX, threedimmapY, threedimmapZ
	variable xdim,ydim,zdim,xoff,yoff,zoff,xdelta,ydelta,zdelta,i
	wave currentxwave, currentywave, currentzwave, zintensity
	xdim=dimsize(threeDmap,0);xdelta=dimdelta(threeDmap,0);xoff=dimoffset(threeDmap,0)
	ydim=dimsize(threeDmap,1);ydelta=dimdelta(threeDmap,1);yoff=dimoffset(threeDmap,1)
	zdim=dimsize(threeDmap,2);zdelta=dimdelta(threeDmap,2);zoff=dimoffset(threeDmap,2)
	for(i=0;i<3;i+=1)
	removefromgraph/Z LivecurveYY, LivecurveXX, LivecurveZY
		wavecheck=Stringbykey("ZWAVE",imageinfo("NewMapwindow","",0))
		if(stringmatch(wavecheck,"")!=1)
			RemoveImage $wavecheck
		endif
	endfor
	if(waveexists(zintensity)==1)
		removefromgraph/Z zintensity
	endif
	
	make/O/N=(xdim,zdim) currentxwave
	make/O/N=(zdim,ydim) currentywave
	make/O/N=(xdim,ydim) currentzwave 
	make/O/N=(zdim) zintensity
	setscale/p x xoff,xdelta, currentxwave; setscale/p y zoff,zdelta, currentxwave
	setscale/p x zoff,zdelta, currentywave; setscale/p y yoff,ydelta, currentywave
	setscale/p x xoff,xdelta, currentzwave; setscale/p y yoff,ydelta, currentzwave
	setscale/P x zoff,zdelta, zintensity

	currentxwave[][]=threeDmap[p][ydim/2][q]
	currentywave[][]=threeDmap[xdim/2][q][p]
	currentzwave[][]=threeDmap[p][q][zdim/2]
	zintensity[]=threeDmap[xdim/2][ydim/2][p]
	
	AppendImage/w=NewMapwindow/L=zLaxis/B=zBaxis currentzwave
	ModifyGraph axisEnab(zLaxis)={0,0.65}, axisEnab(zBaxis)={0,0.65}
	ModifyGraph freePos(zLaxis)=0,freePos(zBaxis)=0
	AppendImage/w=NewMapwindow/L=xLaxis/B=xBaxis currentxwave
	ModifyGraph axisEnab(xLaxis)={0.65,1}, axisEnab(xBaxis)={0,0.65}
	ModifyGraph freePos(xLaxis)=0,freePos(xBaxis)={zoff,xLaxis}
	AppendImage/w=NewMapwindow/L=yLaxis/B=yBaxis currentywave
	ModifyGraph axisEnab(yBaxis)={0.65,1}, axisEnab(yLaxis)={0,0.65}
	
	AppendtoGraph/w=NewMapwindow/L=zintenLaxis/B=zintenBaxis zintensity
	ModifyGraph axisEnab(zintenLaxis)={0.65,1}, axisEnab(zintenBaxis)={0.65,1}
	ModifyGraph noLabel(zintenLaxis)=2,freePos(zintenLaxis)={xoff+xdelta*xdim,zBaxis}
	ModifyGraph noLabel(zintenBaxis)=2,freePos(zintenBaxis)={zoff,xLaxis}
	ModifyGraph freePos(yBaxis)=0,freePos(yLaxis)={zoff,yBaxis}
	ModifyGraph noLabel(xBaxis)=2, noLabel(yLaxis)=2
	ModifyGraph lsize(zintensity)=2
	ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=42,margin(top)=28
	ModifyGraph mirror(xBaxis)=1,mirror(xLaxis)=1,mirror(yBaxis)=1,mirror(yLaxis)=1
	ModifyGraph fSize=16,axThick=2,standoff=0,font="Arial"
	ModifyGraph tick(zLaxis)=2,tick(zBaxis)=2,tick(xLaxis)=2
	ModifyGraph tick(xBaxis)=2,tick(yLaxis)=2,tick(yBaxis)=2
	ColorScale/C/N=text0/X=102.00/Y=-5.00/F=0 nticks=0
		
	make/o/n=2 LivecurveXY, LivecurveXX
	make/o/n=2 LivecurveYX, LivecurveYY
	make/o/n=2 LivecurveZX, LivecurveZY
	LivecurveYY={-inf,inf}; LivecurveYX={0,0}
	LivecurveXY={0,0}; LivecurveXX={-inf,inf}
	LivecurveZX={0,0}; LivecurveZY={-inf,inf}
	AppendToGraph/B=zBaxis/L=zLaxis LivecurveYY vs LivecurveYX
	AppendToGraph/VERT/B=zBaxis/L=zLaxis LivecurveXX vs LivecurveXY
	AppendToGraph/B=zintenBaxis/L=zintenLaxis LivecurveZY vs LivecurveZX
	ModifyGraph rgb(LivecurveYY)=(0,0,65535), rgb(LivecurveXX)=(0,0,65535), rgb(LivecurveZY)=(0,0,65535)
	ModifyGraph lsize(LivecurveYY)=2,lsize(LivecurveXX)=2, lsize(LivecurveZY)=2
	ModifyGraph live(LivecurveXX)=1, live(LivecurveXX)=1, live(LivecurveZY)=1
	ModifyGraph quickdrag(LivecurveYY)=1, quickdrag(LivecurveXX)=1, quickdrag(LivecurveZY)=1
	
	threedimmapX=xoff+xdelta*xdim/2
	threedimmapY=yoff+ydelta*ydim/2
	threedimmapZ=zoff+zdelta*zdim/2

	NewMapcolorsetfunc()
	livetwodimwaveplot()
End


Function NewMapcolor(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	ColorTab2wave $popStr
	NewMapcolorsetfunc()
End

Function MapCheckProccolor(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	variable/g mapcolorcheck
	mapcolorcheck=checked
	NewMapcolorsetfunc()
End

Function SetMapColorgamma(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g Mapcolorgammaval
	Mapcolorgammaval=varNum
	NewMapcolorsetfunc()
End

Function NewMapcolorsetfunc()
	wave NewMapcolortab
	wave M_colors
	variable/g mapcolorcheck,Mapcolorgammaval
	variable size
	duplicate/O M_colors NewMapcolortab
	size=dimsize(NewMapcolortab,0)
	NewMapcolortab[][]=M_colors[size*(p/size)^MapColorgammaval][q]
   if(mapcolorcheck == 1)
		ModifyImage/w=NewMapwindow/Z ''#0  ctab= {*,*,NewMapcolortab,1}
		ModifyImage/w=NewMapwindow/Z ''#1  ctab= {*,*,NewMapcolortab,1}
		ModifyImage/w=NewMapwindow/Z ''#2  ctab= {*,*,NewMapcolortab,1}
	else
   	ModifyImage/w=NewMapwindow/Z ''#0  ctab= {*,*,NewMapcolortab,0}
		ModifyImage/w=NewMapwindow/Z ''#1  ctab= {*,*,NewMapcolortab,0}
		ModifyImage/w=NewMapwindow/Z ''#2  ctab= {*,*,NewMapcolortab,0}
   endif
End

Function PopMenuProc_MapTool(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	String/g MapTool=popStr
End

Function ButtonProc3DMapToolExecute(ctrlName) : ButtonControl
	String ctrlName
	String/g MapTool
	if(Stringmatch(MapTool,"Reorder")==1)
		ButtonProc3DMapreorder() 
	elseif(Stringmatch(MapTool,"Bin")==1)
		ButtonProc3DMapBin() 
	elseif(Stringmatch(MapTool,"Truncate")==1)
		ButtonProc3DMapTruncate() 
	elseif(Stringmatch(MapTool,"Norm")==1)
		ButtonProc3DMapNorm()
	elseif(Stringmatch(MapTool,"Rescale")==1)
		ButtonProc3DMaprescale()
	elseif(Stringmatch(MapTool,"Export")==1)
		ButtonProc3DMapexport()
	elseif(Stringmatch(MapTool,"XYzero")==1)
		ButtonProc3DMapzeroset()
	elseif(Stringmatch(MapTool,"Azimuth")==1)
		ButtonProc3DMapAzimuth()	
	elseif(Stringmatch(MapTool,"AreaSpectra")==1)
		ButtonProc3DMapAreaspectra()	
	elseif(Stringmatch(MapTool,"kxkymap")==1)
		ButtonProc3DMapkxkymap()
	elseif(Stringmatch(MapTool,"kzmap")==1)
		ButtonProc3DMapkzmap()		
	endif
End

Function livetwodimwaveplot()
	variable/g threedimmapX, threedimmapY, threedimmapZ
	wave zintensity
	setwindow NewMapwindow, hook(maphook)=NewMapHook
	SetVariable setvarmap1 value= threedimmapX, win=NewMapwindow
	SetVariable setvarmap2 value= threedimmapY, win=NewMapwindow
	SetVariable setvarmap3 value= threedimmapZ, win=NewMapwindow	
	
	ModifyGraph/Z/w=NewMapWindow offset(LiveCurveZY)={threedimmapZ,0}
	ModifyGraph/Z/w=NewMapWindow offset(LivecurveYY)={threedimmapX,0}
	ModifyGraph/Z/w=NewMapWindow offset(LivecurveXX)={threedimmapY,0}
End

Function NewMapHook(s)
	struct WMWinHookstruct &s
	variable/g threedimmapX, threedimmapY, threedimmapZ, deltaZ
	string offsetStr, offsetStr0, offsetStr1, offsetStr2
	variable hookresult=0
	
	switch(s.eventCode)			
		case 8: //modified event
		if(s.eventMod == 8) // ctrl is down and liveupdate the MapWindow
		offsetStr=StringByKey("offset(x)",TraceInfo("", "livecurveYY", 0),"=")
		offsetStr0=StringfromList(0, offsetStr,",")[1,inf]
		offsetStr=StringByKey("offset(x)",TraceInfo("", "livecurveXX", 0),"=")
		offsetStr1=StringfromList(0,offsetStr, ",")[1,inf]
		offsetStr=StringByKey("offset(x)",TraceInfo("", "livecurveZY", 0),"=")
		offsetStr2=StringfromList(0,offsetStr, ",")[1,inf]

		threedimmapX=str2num(offsetStr0)
		SetVariable setvarmap1 value=threedimmapX, win=NewMapwindow
		threedimmapY=str2num(offsetStr1)
		SetVariable setvarmap2 value=threedimmapY, win=NewMapwindow
		threedimmapZ=str2num(offsetStr2)	
		SetVariable setvarmap3 value=threedimmapZ, win=NewMapwindow
		
		elseif(s.eventMod == 3) //  shift is down and move the X Y to zero
			threedimmapX=0
			SetVariable setvarmap1 value=threedimmapX, win=NewMapwindow
			threedimmapY=0
			SetVariable setvarmap2 value=threedimmapY, win=NewMapwindow
			ModifyGraph/Z/w=NewMapWindow offset(LiveCurveYY)={0,0}
			ModifyGraph/Z/w=NewMapWindow offset(LiveCurveXX)={0,0}
		endif
			hookresult=1		
		break
		
		case 11: //keyboard event
			switch(s.keycode-30)
				case -2: //leftarrow
					threedimmapX-=deltaZ
					ModifyGraph/Z/w=NewMapWindow offset(LiveCurveYY)={threedimmapX,0}
				break
				case -1:  //rightarrow
					threedimmapX+=deltaZ
					ModifyGraph/Z/w=NewMapWindow offset(LiveCurveYY)={threedimmapX,0}
				break
				case 0: //uparrow
					threedimmapY+=deltaZ
					ModifyGraph/Z/w=NewMapWindow offset(LiveCurveXX)={threedimmapY,0}
				break
				case 1: //downarrow
					threedimmapY-=deltaZ
					ModifyGraph/Z/w=NewMapWindow offset(LiveCurveXX)={threedimmapY,0}
				break
				//no pageup and pagedown key on macbook, change to use F7 and F9
				//case -19: //pageup
				//	threedimmapZ+=deltaZ
				//	ModifyGraph/Z/w=NewMapWindow offset(LiveCurveZY)={threedimmapZ,0}
				//break
				//case -18: //pagedown
				//	threedimmapZ-=deltaZ
				//	ModifyGraph/Z/w=NewMapWindow offset(LiveCurveZY)={threedimmapZ,0}
				//break
				
			endswitch
			switch(s.specialkeycode)	
				case 7: //F7
				threedimmapZ-=deltaZ
				ModifyGraph/Z/w=NewMapWindow offset(LiveCurveZY)={threedimmapZ,0}
				break
				case 9: //F9
				threedimmapZ+=deltaZ
				ModifyGraph/Z/w=NewMapWindow offset(LiveCurveZY)={threedimmapZ,0}
				break
			endswitch
			hookresult=1
		break
			
		case 22: //mouse wheel event
			if(s.wheelDy>0)
				threedimmapZ+=deltaZ
				ModifyGraph/Z/w=NewMapWindow offset(LiveCurveZY)={threedimmapZ,0}
			elseif(s.wheelDy<0)
				threedimmapZ-=deltaZ
				ModifyGraph/Z/w=NewMapWindow offset(LiveCurveZY)={threedimmapZ,0}
			endif
			SetVariable setvarmap3 value= threedimmapZ, win=NewMapwindow
			hookresult=1
		break
	endswitch
	twodimwaveliveupdate()
	return hookresult
End


Function ButtonProc3DMapX(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g threedimmapX, threedimmapY
	threedimmapX=varNum
	ModifyGraph/Z/w=NewMapWindow offset(LivecurveYY)={threedimmapX,0}
End

Function ButtonProc3DMapY(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g threedimmapX, threedimmapY
	threedimmapY=varNum
	ModifyGraph/Z/w=NewMapWindow offset(LivecurveXX)={threedimmapY,0}
End

Function ButtonProc3DMapZ(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g threedimmapZ
	threedimmapZ=varNum
	ModifyGraph/Z/w=NewMapWindow offset(LivecurveZY)={threedimmapZ,0}
End

Function SetVarProc3DMapdeltaZ(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g deltaZ=varNum
End


Function ButtonProc3DMapZstack(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g threedimmapZstack
	threedimmapZstack=varNum
	twodimwaveliveupdate()
End


Function twodimwaveliveupdate()
	wave threeDmap, currentxwave, currentywave, currentzwave,zintensity
	variable/g threedimmapX, threedimmapY, threedimmapZ, threedimmapZstack
	variable xindex, yindex, zindex,i
   xindex=scaletoindex(threeDmap,threedimmapX,0)
   yindex=scaletoindex(threeDmap,threedimmapY,1)
   zindex=scaletoindex(threeDmap,threedimmapZ,2)

	zintensity[]=threeDmap[xindex][yindex][p]
	variable a1=wavemax(zintensity), a2=wavemin(zintensity)
	SetAxis/W=NewMapwindow zintenLaxis a2-(a1-a2)/20, a1+(a1-a2)/20
	currentxwave=0
	currentywave=0
	currentzwave=0
	for(i=0;i<threedimmapZstack;i+=1)
		currentzwave[][]+=threeDmap[p][q][zindex+i]+threeDmap[p][q][zindex-i]
		currentxwave[][]+=threeDmap[p][yindex+i][q]+threeDmap[p][yindex-i][q]
		currentywave[][]+=threeDmap[xindex+i][q][p]+threeDmap[xindex-i][q][p]
	endfor
End

Function ButtonProc3DMapInterX(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g threedimmapInterX=varNum
End

Function ButtonProc3DMapInterY(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g threedimmapInterY=varNum
End

Function ButtonProc3DMapreorder() 
	wave threeDmap
	variable xdim,ydim,zdim,xoff,yoff,zoff,xdelta,ydelta,zdelta
	variable/g threedimmapX, threedimmapY, threedimmapZ
	string reordertype
	if(waveexists(threeDmap)==0)
		Abort "Please first load a 3D map!"
	endif
	prompt reordertype, "Choose the reorder type:" popup, "X<------>Y;X<------>Z;Y<------>Z"
	doprompt "", reordertype
	if(V_flag)
		return -1
	endif
	
	xdim=dimsize(threeDmap,0);xdelta=dimdelta(threeDmap,0);xoff=dimoffset(threeDmap,0)
	ydim=dimsize(threeDmap,1);ydelta=dimdelta(threeDmap,1);yoff=dimoffset(threeDmap,1)
	zdim=dimsize(threeDmap,2);zdelta=dimdelta(threeDmap,2);zoff=dimoffset(threeDmap,2)
	if(stringmatch(reordertype,"X<------>Y")==1)
		make/O/N=(ydim,xdim,zdim) threedimmapr
		multithread threedimmapr[][][]=threeDmap[q][p][r]
		setscale/P x, yoff, ydelta, threedimmapr
		setscale/P y, xoff, xdelta, threedimmapr
		setscale/P z, zoff, zdelta, threedimmapr
	endif
	if(stringmatch(reordertype,"X<------>Z")==1)
		make/O/N=(zdim,ydim,xdim) threedimmapr
		multithread threedimmapr[][][]=threeDmap[r][q][p]
		setscale/P x, zoff, zdelta, threedimmapr
		setscale/P y, yoff, ydelta, threedimmapr
		setscale/P z, xoff, xdelta, threedimmapr
	endif
	if(stringmatch(reordertype,"Y<------>Z")==1)
		make/O/N=(xdim,zdim,ydim) threedimmapr
		multithread threedimmapr[][][]=threeDmap[p][r][q]
		setscale/P x, xoff, xdelta, threedimmapr
		setscale/P y, zoff, zdelta, threedimmapr
		setscale/P z, yoff, ydelta, threedimmapr
	endif
	threeDmapload("threedimmapr")
	killwaves threedimmapr
	threedimmapX=xoff+xdelta*xdim/2
	threedimmapY=yoff+ydelta*ydim/2
	threedimmapZ=zoff+zdelta*zdim/2

End

Function ButtonProc3DMapBin() 
	wave threeDmap
	String bindim
	variable binnum
	variable xdim,xdelta,xoff,ydim,ydelta,yoff,zdim,zdelta,zoff,xdim2,ydim2,zdim2,i,j
	variable/g threedimmapX, threedimmapY, threedimmapZ
	prompt bindim "Please choose the bin direction for threeDmap:" popup, "X;Y;Z"
	prompt binnum "Please enter the bin number:"
	doprompt "", binnum, bindim
	if(V_flag)
		return -1
	endif
	if(binnum <= 1)
		Abort "Please enter a bin num larger than 1!"
	endif
	
	xdim=dimsize(threeDmap,0);xdelta=dimdelta(threeDmap,0);xoff=dimoffset(threeDmap,0)
	ydim=dimsize(threeDmap,1);ydelta=dimdelta(threeDmap,1);yoff=dimoffset(threeDmap,1)
	zdim=dimsize(threeDmap,2);zdelta=dimdelta(threeDmap,2);zoff=dimoffset(threeDmap,2)
	if(stringmatch(bindim,"Z")==1)
	zdim2=floor(zdim/binnum)
	make/o/N=(xdim,ydim,zdim2) threedimtemp
	for(i=0; i< zdim2-1; i+=1)
		for(j=0; j<binnum-1; j+=1)
			threedimtemp[][][i]+=threeDmap[p][q][binnum*i+j]
		endfor
	endfor
	threedimtemp/=binnum
	setscale/P x, xoff, xdelta, threedimtemp
	setscale/P y, yoff, ydelta, threedimtemp
	setscale/p z, zoff, zdelta*binnum, threedimtemp
	endif
	
	if(stringmatch(bindim,"X")==1)
	xdim2=floor(xdim/binnum)
	make/o/N=(xdim2,ydim,zdim) threedimtemp
	for(i=0; i< xdim2-1; i+=1)
		for(j=0; j<binnum-1; j+=1)
			threedimtemp[i][][]+=threeDmap[binnum*i+j][q][r]
		endfor
	endfor
	threedimtemp/=binnum
	setscale/P x, xoff, xdelta*binnum, threedimtemp
	setscale/P y, yoff, ydelta, threedimtemp
	setscale/p z, zoff, zdelta, threedimtemp
	endif
	
	if(stringmatch(bindim,"Y")==1)
	ydim2=floor(ydim/binnum)
	make/o/N=(xdim,ydim2,zdim) threedimtemp
	for(i=0; i< ydim2-1; i+=1)
		for(j=0; j<binnum-1; j+=1)
			threedimtemp[][i][]+=threeDmap[p][binnum*i+j][r]
		endfor
	endfor
	threedimtemp/=binnum
	setscale/P x, xoff, xdelta, threedimtemp
	setscale/P y, yoff, ydelta*binnum, threedimtemp
	setscale/p z, zoff, zdelta, threedimtemp
	endif
	
	//duplicate/O threedimtemp, threeDmap
	threeDmapload("threedimtemp")
	killwaves threedimtemp
	
	threedimmapX=xoff+xdelta*xdim/2
	threedimmapY=yoff+ydelta*ydim/2
	threedimmapZ=zoff+zdelta*zdim/2
	
End

Function ButtonProc3DMapTruncate() 
	wave threeDmap
	String tdim
	String/g cubicmapname
	variable tp1, tp2, xp1, xp2, yp1, yp2, zp1, zp2
	variable xdim,xdelta,xoff,ydim,ydelta,yoff,zdim,zdelta,zoff
	variable/g threedimmapX, threedimmapY, threedimmapZ
	prompt tdim, "Choose the truncate dimension:", popup, "X;Y;Z"
	prompt tp1, "Enter the starting point for new map:"
	prompt tp2, "Enter the ending point for new map:"
	doprompt "", tdim, tp1, tp2
	if(V_flag)
		return -1
	endif
	if(tp1>=tp2)
		Abort "Please set ending point larger than starting point!"
	endif
	
	xdim=dimsize(threeDmap,0);xdelta=dimdelta(threeDmap,0);xoff=dimoffset(threeDmap,0)
	ydim=dimsize(threeDmap,1);ydelta=dimdelta(threeDmap,1);yoff=dimoffset(threeDmap,1)
	zdim=dimsize(threeDmap,2);zdelta=dimdelta(threeDmap,2);zoff=dimoffset(threeDmap,2)
	if(stringmatch(tdim,"X")==1)
		xp1=ScaletoIndex(threeDmap, tp1, 0)
		xp2=ScaletoIndex(threeDmap, tp2, 0)
		make/O/N=(xp2-xp1+1, ydim, zdim) threedimmapt
		setscale/P x, tp1, xdelta, threedimmapt 
		setscale/P y, yoff, ydelta, threedimmapt
		setscale/p z, zoff, zdelta, threedimmapt
		multithread threedimmapt[][][]=threeDmap[p+xp1][q][r]
	endif
	
	if(stringmatch(tdim,"Y")==1)
		yp1=ScaletoIndex(threeDmap, tp1, 1)
		yp2=ScaletoIndex(threeDmap, tp2, 1)
		make/O/N=(xdim, yp2-yp1+1, zdim) threedimmapt
		setscale/P x, xoff, xdelta, threedimmapt
		setscale/P y, tp1, ydelta, threedimmapt
		setscale/p z, zoff, zdelta, threedimmapt
		multithread threedimmapt[][][]=threeDmap[p][q+yp1][r]
	endif
	
	if(stringmatch(tdim,"Z")==1)
		zp1=ScaletoIndex(threeDmap, tp1, 2)
		zp2=ScaletoIndex(threeDmap, tp2, 2)
		make/O/N=(xdim, ydim, zp2-zp1+1) threedimmapt
		setscale/P x, xoff, xdelta, threedimmapt
		setscale/P y, yoff, ydelta, threedimmapt
		setscale/p z, tp1, zdelta, threedimmapt
		multithread threedimmapt[][][]=threeDmap[p][q][r+zp1]
	endif
	string truncatemap=cubicmapname+"_tr"
	duplicate/O threedimmapt, $truncatemap
	threeDmapload(truncatemap)
	cubicmapname=truncatemap
	
	threedimmapX=xoff+xdelta*xdim/2
	threedimmapY=yoff+ydelta*ydim/2
	killwaves threedimmapt
	threedimmapZ=zoff+zdelta*zdim/2
	
End

Function ButtonProc3DMapNorm() 
	wave threeDmap
	String/g cubicmapname
	variable xdim,xdelta,xoff,ydim,ydelta,yoff,zdim,zdelta,zoff, i, j
	variable/g threedimmapX, threedimmapY, threedimmapZ
	xdim=dimsize(threeDmap,0);xdelta=dimdelta(threeDmap,0);xoff=dimoffset(threeDmap,0)
	ydim=dimsize(threeDmap,1);ydelta=dimdelta(threeDmap,1);yoff=dimoffset(threeDmap,1)
	zdim=dimsize(threeDmap,2);zdelta=dimdelta(threeDmap,2);zoff=dimoffset(threeDmap,2)

	String funccheck
	prompt funccheck "Do you want to execute the 3D Map normalization along EDC? Set the energy channel to z direction first!" popup, "No;Yes"
	doprompt "", funccheck
	if(stringmatch(funccheck,"No")==1)
		Abort "User cancel the normalization."
	endif
	if(V_flag)
		return -1 // user cancel
	endif
	
	string nrmap=cubicmapname+"_nr"
	duplicate/O threeDmap, $nrmap
	wave normmap=$nrmap
	make/O/N=(zdim) temp
	setscale/P x, zoff, zdelta, temp
	for(i=0; i<xdim; i+=1)
		for(j=0; j<ydim; j+=1)
			temp[]=threeDmap[i][j][p]
			normmap[i][j][]/=faverage(temp,zoff,zoff+zdelta*(zdim-1))
		endfor
	endfor
	killwaves temp
	threeDmapload(nrmap)
	cubicmapname=nrmap
	
	threedimmapX=xoff+xdelta*xdim/2
	threedimmapY=yoff+ydelta*ydim/2
	threedimmapZ=zoff+zdelta*zdim/2
End

Function ButtonProc3DMaprescale()
	String reorderdim
	String/g cubicmapname
	wave threeDmap
	variable/g threedimmapX, threedimmapY, threedimmapZ
	variable xdim,xdelta,xoff,ydim,ydelta,yoff,zdim,zdelta,zoff, rescaleoff, rescaledelta
	xdim=dimsize(threeDmap,0);xdelta=dimdelta(threeDmap,0);xoff=dimoffset(threeDmap,0)
	ydim=dimsize(threeDmap,1);ydelta=dimdelta(threeDmap,1);yoff=dimoffset(threeDmap,1)
	zdim=dimsize(threeDmap,2);zdelta=dimdelta(threeDmap,2);zoff=dimoffset(threeDmap,2)
	prompt reorderdim, "Choose the rescale dimension:", popup, "X;Y;Z"
	doprompt "", reorderdim
	if(V_flag)
		return -1
	endif
	
	if(stringmatch(reorderdim,"X")==1)
		rescaleoff=xoff
		rescaledelta=xdelta
	elseif(stringmatch(reorderdim,"Y")==1)
		rescaleoff=yoff
		rescaledelta=ydelta
	else
		rescaleoff=zoff
		rescaledelta=zdelta
	endif
	prompt rescaleoff, "Please enter the offset value for "+reorderdim+" direction:"
	prompt rescaledelta, "Please enter the delta value for "+reorderdim+" direction:"
	doprompt "", rescaleoff, rescaledelta
	if(V_flag)
		return -1
	endif
	string remap=cubicmapname+"_re"
	duplicate/O threeDmap, $remap
	wave remapwave=$remap
	if(stringmatch(reorderdim,"X")==1)
		setscale/P x, rescaleoff, rescaledelta, "", $remap
	elseif(stringmatch(reorderdim,"Y")==1)
		setscale/P y, rescaleoff, rescaledelta, "", $remap
	else
		setscale/P z, rescaleoff, rescaledelta, "", $remap
	endif
	threeDmapload(remap)
	cubicmapname=remap
	threedimmapX=xoff+xdelta*xdim/2
	threedimmapY=yoff+ydelta*ydim/2
	threedimmapZ=zoff+zdelta*zdim/2
	
End


Function ButtonProc3DMapzeroset()
	String zerodim
	String/g cubicmapname
	wave threeDmap
	variable/g threedimmapX, threedimmapY, threedimmapZ
	variable xdim,xdelta,xoff,ydim,ydelta,yoff,zdim,zdelta,zoff, rescaleoff, rescaledelta
	xdim=dimsize(threeDmap,0);xdelta=dimdelta(threeDmap,0);xoff=dimoffset(threeDmap,0)
	ydim=dimsize(threeDmap,1);ydelta=dimdelta(threeDmap,1);yoff=dimoffset(threeDmap,1)
	zdim=dimsize(threeDmap,2);zdelta=dimdelta(threeDmap,2);zoff=dimoffset(threeDmap,2)

	prompt zerodim "Select the zero mode:" popup "X;Y;Z;X and Y"
	doprompt "", zerodim
	if(V_flag)
		return -1
	endif
	
	string zeromap=cubicmapname+"_zero"
	duplicate/O threeDmap, $zeromap
	wave zeromapwave=$zeromap
	if(stringmatch(zerodim,"X")==1)
		setscale/P x, xoff-threedimmapX, xdelta, "", zeromapwave
	elseif(stringmatch(zerodim,"Y")==1)
		setscale/P y, yoff-threedimmapY, ydelta, "", zeromapwave
	elseif(stringmatch(zerodim,"Z")==1)
		setscale/P z, zoff-threedimmapZ, zdelta, "", zeromapwave
	else
	   setscale/P x, xoff-threedimmapX, xdelta, "", zeromapwave
	   setscale/P y, yoff-threedimmapY, ydelta, "", zeromapwave
	endif
	threedimmapX=0
	threedimmapY=0
	threeDmapload(zeromap)
	killwaves zeromapwave
	ModifyGraph/Z/w=NewMapWindow offset(LiveCurveYY)={0,0}
	ModifyGraph/Z/w=NewMapWindow offset(LiveCurveXX)={0,0}
	
End

Function ButtonProc3DMapAzimuth()
	wave NewMapcolortab
	variable/g mapcolorcheck
	duplicate/O currentzwave, temp
	variable xdelta=dimdelta(temp,0),  ydelta=dimdelta(temp,1)
	if(xdelta<ydelta)
		variable n=floor(ydelta/xdelta)
		variable offset=dimoffset(temp,1)
		Imageinterpolate/f={1,n}/dest=Azimuthtemp bilinear, temp
		setscale/p y offset, ydelta/n, "", Azimuthtemp
		offset=dimoffset(temp,0)
		setscale/p x offset, xdelta, "", Azimuthtemp
	else
		n=floor(xdelta/ydelta)
		offset=dimoffset(temp,0)
		Imageinterpolate/f={n,1}/dest=Azimuthtemp bilinear, temp
		setscale/p x offset, xdelta/n, "", Azimuthtemp
		offset=dimoffset(temp,1)
		setscale/p y offset, ydelta, "", Azimuthtemp
	endif
	duplicate/O Azimuthtemp, Azimuthwave
	killwaves temp	
	dowindow/f NewAzimuthGraph
	if(V_flag==0)
		variable/g Aziang=0
		Display/N=NewAzimuthGraph
		controlBar 50
		Slider Azislider,pos={10.00,1.00},size={270.00,52.00},proc=AzimuthGraphSliderProc,win=NewAzimuthGraph
		Slider Azislider,font="Times New Roman",fSize=10
		Slider Azislider,limits={-90.1,90.1,0.1},value= 0,side= 2,vert= 0,ticks= 6
		SetVariable setAzislidevar,pos={285.00,15.00},size={65.00,20.00},proc=SetAzisliderVarProc,win=NewAzimuthGraph
		SetVariable setAzislidevar,font="Times New Roman",fSize=16,title=" "
		SetVariable setAzislidevar,limits={-90.1,90.1,0.1},value= _NUM:0
		
		AppendImage/W=NewAzimuthGraph Azimuthwave
		
		ModifyGraph width=283,fsize=20
		ModifyGraph height={Plan,1,left,bottom}
		ModifyGraph tick=2,mirror=1,standoff=0
		ModifyGraph zero=4,zeroThick=2,axThick=2
		ModifyGraph font="Times New Roman"
		ModifyGraph margin(left)=42,margin(bottom)=42,margin(right)=28,margin(top)=28
	endif
	SetVariable setAzislidevar,value= _NUM:0
	Slider Azislider,value= 0
	if(mapcolorcheck==1)
		ModifyImage/W=NewAzimuthGraph/Z Azimuthwave ctab= {*,*,NewMapcolortab,1}
	else
		ModifyImage/W=NewAzimuthGraph/Z Azimuthwave ctab= {*,*,NewMapcolortab,0}
	endif
End

Function AzimuthGraphSliderProc(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
	wave Azimuthwave,  Azimuthtemp
	variable azi=sliderValue/180*pi
	variable/g Aziang=sliderValue
	variable ysize=dimsize(Azimuthtemp,1)
	SetVariable setAzislidevar,win=NewAzimuthGraph,value=Aziang
	if(event & 0x1)	// bit 0, value set
		duplicate/O  Azimuthtemp, Azimuthwave
		Azimuthwave[][]= Azimuthtemp(Indextoscale(Azimuthtemp,p,0)*cos(azi)+Indextoscale(Azimuthtemp,q,1)*sin(azi))(-Indextoscale(Azimuthtemp,p,0)*sin(azi)+Indextoscale(Azimuthtemp,q,1)*cos(azi))
	endif

	return 0
End

Function SetAzisliderVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g Aziang=varNum
	wave  Azimuthtemp
	
	Slider Azislider,win=NewAzimuthGraph,value=Aziang
	variable azi=Aziang/180*pi
	duplicate/O  Azimuthtemp, Azimuthwave
	Azimuthwave[][]= Azimuthtemp(Indextoscale(Azimuthwave,p,0)*cos(azi)+Indextoscale(Azimuthwave,q,1)*sin(azi))(-Indextoscale(Azimuthwave,p,0)*sin(azi)+Indextoscale(Azimuthwave,q,1)*cos(azi))
End

Function ButtonProc3DMapAreaspectra()	
	variable/g threedimmapX, threedimmapY
	wave threeDmap, currentzwave, zintensity
	variable zsize=dimsize(threeDmap,2)
	dowindow/f NewMapwindow
	ShowInfo
	cursor/A=1/C=(0,65535,0)/S=1/T=2/H=1/I A currentzwave threedimmapX, threedimmapY
	cursor/A=1/C=(0,65535,0)/S=1/T=2/H=1/I B currentzwave threedimmapX, threedimmapY
	
	variable x1=xcsr(A), x2=xcsr(B)
	variable y1=vcsr(A), y2=vcsr(B)
	
	duplicate/O zintensity, Areaspectra
	dowindow/f AreaSpectraGraph
	if(V_flag==0)
		Display/N=AreaSpectraGraph
		Appendtograph Areaspectra
		ModifyGraph lsize=2
		ModifyGraph tick=2,mirror=1,standoff=0
		ModifyGraph zero=4,zeroThick=2,axThick=2
		ModifyGraph font="Arial",fSize=16
		ModifyGraph margin(left)=56,margin(bottom)=42,margin(right)=28,margin(top)=28
		Label left "\\F'Arial'\\Z20AreaIntensity (a. u.)"
		ModifyGraph width=340,height=255
		controlbar 30
		Button button0,pos={1.00,1.00},size={78.00,28.00},proc=ButtonProc_Areaspectraupdate,title="Update",font="Times New Roman",fSize=16
		Button button1,pos={89.00,1.00},size={68.00,28.00},proc=ButtonProc_Areaspectraexport,title="Export",font="Times New Roman",fSize=16

		TextBox/C/N=text0/F=0/A=MC "\\F'Arial'\\Z20A X:"+num2str(x1)+" Y:"+num2str(y1)+"\rB X:"+num2str(x2)+" Y:"+num2str(y2)
	endif
End

Function ButtonProc_Areaspectraupdate(ctrlName) : ButtonControl
	String ctrlName
	wave Areaspectra, threeDmap
	variable i, j
	Areaspectra[]=0
	dowindow/f NewMapwindow
	if(V_flag==0)
		Abort "Please first show NewMapwindow!"
	endif
	variable p1=min(pcsr(A),pcsr(B)), p2=max(pcsr(A),pcsr(B))
	variable q1=min(qcsr(A),qcsr(B)), q2=max(qcsr(A),qcsr(B))
	for(i=p1; i<=p2; i+=1)
		for(j=q1; j<=q2; j+=1)
			AreaSpectra[]+=threeDmap[i][j][p]
		endfor
	endfor
	
	variable x1=xcsr(A), x2=xcsr(B)
	variable y1=vcsr(A), y2=vcsr(B)
	dowindow/f AreaSpectraGraph
	TextBox/C/N=text0/F=0/B=1/A=MC "\\F'Arial'\\Z20A X:"+num2str(x1)+" Y:"+num2str(y1)+"\rB X:"+num2str(x2)+" Y:"+num2str(y2)
End


Function ButtonProc_Areaspectraexport(ctrlName) : ButtonControl
	String ctrlName
	string/g cubicmapname
	
	duplicate/O Areaspectra, $"Areaspectra_"+cubicmapname
	string s1=stringbykey("TEXT",Annotationinfo ("", "text0",1),":",";")
	Display; Delayupdate
	Appendtograph $"Areaspectra_"+cubicmapname
	ModifyGraph lsize=2
	ModifyGraph tick=2,mirror=1,standoff=0
	ModifyGraph zero=4,zeroThick=2,axThick=2
	ModifyGraph font="Arial",fSize=16
	ModifyGraph margin(left)=56,margin(bottom)=42,margin(right)=28,margin(top)=28
	Label left "\\F'Arial'\\Z20AreaIntensity (a. u.)"
	ModifyGraph width=340,height=255
	TextBox/C/N=text0/F=0/B=1/A=MC s1
End


Function ButtonProc3DMapexport()
	String exportwavename
	wave threeDmap
	prompt exportwavename "Please enter the 3D export wave name:"
	doprompt "", exportwavename
	if(V_flag)
		return -1 //user cancel
	endif
	if(waveexists(threeDmap)!=1)
		Abort "Please first load a 3D map!"
	endif
	duplicate/O threeDmap, $exportwavename
End

Function ButtonProc3DMapkxkymap()	
	wave threeDmap
	String/g cubicmapname
	variable Ef, aziangle, i, j 
	prompt Ef "Please first set the energy axis to Z, enter the fermi energy (eV):"
	prompt aziangle "enter the azimuth angle:"
	doprompt "", Ef, aziangle
	if(V_flag)
		return -1 //user cancel
	endif
	
	variable thetaX1, thetaX2, thetaY1, thetaY2, thetamax, kmax, azi
	variable xdelta=dimdelta(threeDmap,0), ydelta=dimdelta(threeDmap,1), zdelta=dimdelta(threeDmap,2)
	variable xsize=dimsize(threeDmap,0), ysize=dimsize(threeDmap,1), zsize=dimsize(threeDmap,2)
	variable xoff=dimoffset(threeDmap,0), yoff=dimoffset(threeDmap,1), zoff=dimoffset(threeDmap,2)
	
	make/O/N=(xsize, ysize) currentwavetemp
	if(xdelta<ydelta)
		variable n=floor(ydelta/xdelta)
		make/O/N=(xsize, n*ysize, zsize) temp
		setscale/p x xoff, xdelta, "", temp
		setscale/p y yoff, ydelta/n, "", temp
		for(i=0; i<zsize; i+=1)
			currentwavetemp[][]=threeDmap[p][q][i]
			Imageinterpolate/f={1,n}/dest=temp1 bilinear, currentwavetemp  
			temp[][][i]=temp1[p][q]
		endfor
	else
		n=floor(xdelta/ydelta)
		make/O/N=(n*xsize,ysize, zsize) temp
		setscale/p x xoff, xdelta/n, "", temp
		setscale/p y yoff, ydelta, "", temp
		for(i=0; i<zsize; i+=1)
			currentwavetemp[][]=threeDmap[p][q][i]
			Imageinterpolate/f={n,1}/dest=temp1 bilinear, currentwavetemp 
			temp[][][i]=temp1[p][q]
		endfor
	endif
	
	setscale/p z zoff, zdelta, "", temp
	
	thetaX1=dimoffset(threeDmap,0); thetaY1=dimoffset(threeDmap,1)
	thetaX2=thetaX1+dimdelta(threeDmap,0)*(dimsize(threeDmap,0)-1)
	thetaY2=thetaY1+dimdelta(threeDmap,1)*(dimsize(threeDmap,1)-1)
	
	thetamax=max(abs(thetaX1),abs(thetaX2),abs(thetaY1),abs(thetaY2))
	kmax=ceil(0.51197*sqrt(Ef)*sin(thetamax/180*pi)*2)/2
	
	variable nsize=ceil(max(dimsize(temp,1), dimsize(temp,0))/100)
	make/O/N=(nsize*100+1,nsize*100+1, zsize) temp2
	setscale/I x -kmax, kmax, "", temp2
	setscale/I y -kmax, kmax, "", temp2
	setscale/p z zoff, zdelta, "", temp2
	
	for(i=0; i<dimsize(temp,0); i+=1)
		for(j=0; j<dimsize(temp,1); j+=1)
			//kx=0.51197*sqrt(Ef+IndextoScale(temp,r,2))*sin(thetaX)
			//ky=0.51197*sqrt(Ef+IndextoScale(temp,r,2))*cos(thetaX)*sin(thetaY)
		multithread temp2[ScaletoIndex(temp2,0.51197*sqrt(Ef )*sin(Indextoscale(temp,i,0)*pi/180),0)][ScaletoIndex(temp2,0.51197*sqrt(Ef )*cos(Indextoscale(temp,i,0)*pi/180)*sin(Indextoscale(temp,j,1)*pi/180),1)][]=temp[i][j][r]
		endfor
	endfor
	
	
	duplicate/O temp2, $cubicmapname+"_rot"
	wave newmapwave= $cubicmapname+"_rot"
	//map rotation
	azi=aziangle/180*pi
	multithread newmapwave[][][]=temp2(Indextoscale(newmapwave,p,0)*cos(-azi)-Indextoscale(newmapwave,q,1)*sin(-azi))(Indextoscale(newmapwave,p,0)*sin(-azi)+Indextoscale(newmapwave,q,1)*cos(-azi))[r]	
	threeDmapload(cubicmapname+"_rot")
	cubicmapname=cubicmapname+"_rot"

	killwaves temp, temp1, temp2, currentwavetemp
	print "convert to "+cubicmapname+" with Ef = "+num2str(Ef)+" eV, kx and ky scales in 1/Å\r "
End

Function ButtonProc3DMapkzmap()
	variable  h_bar=1.0545*10^-34,aa,cc,m=9.11*10^-31,eV=1.6*10^-19
	variable wfunc, V_0, internum, theta1, theta2, ang1, ang2, kzmin, kzmax, kpmin, kpmax, i, j, kp, kz
	wave threeDmap
	string/g cubicmapname
	string mapname
	
	internum=5
	prompt wfunc "Please set the energy along z, hv along y and angle along x. Rescale all axies. Enter the work function (eV):"
	prompt V_0 "Enter the inner potential (eV):"
	prompt internum "Enter the interpolate number:"
	prompt mapname "Enter the new map name:"
	doprompt "", wfunc,V_0, internum, mapname
	if(V_flag)
		return -1
	endif
	
	duplicate/O threeDmap, temp
	if(dimdelta(threeDmap,1)<0)
		temp[][][]=threeDmap[p][dimsize(threeDmap,1)-q][r]		
		setscale/P y, dimoffset(threeDmap,1)+dimdelta(threeDmap,1)*(dimsize(threeDmap,1)-1),-dimdelta(threeDmap,1),temp
	endif
	
	//interpolate the hv-theta map, only along the hv direction
	make/O/N=(dimsize(temp,0),dimsize(temp,1)) temp1
	make/O/N=(dimsize(temp,0),dimsize(temp,1)*internum,dimsize(temp,2)) temp2
	setscale/P x, dimoffset(temp,0),dimdelta(temp,0), temp2
	setscale/p y, dimoffset(temp,1),dimdelta(temp,1)/internum, temp2
	setscale/P z, dimoffset(temp,2),dimdelta(temp,2), temp2
	
	for(i=0; i<dimsize(temp,2); i+=1)
		temp1[][]=temp[p][q][i]
		Imageinterpolate/F={1, internum}/DEST=inter bilinear, temp1
		temp2[][][i]=inter[p][q]
	endfor
	duplicate/O temp2, temp

	variable Emin=dimoffset(temp,2)+dimoffset(temp,1)-wfunc
	variable Emax=dimoffset(temp,1)-wfunc+dimdelta(temp,1)*(dimsize(temp,1)-1)
	theta1=dimoffset(threeDmap,0)
	theta2=dimoffset(threeDmap,0)+dimdelta(threeDmap,0)*(dimsize(threeDmap,0)-1)
	ang1=max(abs(theta1),abs(theta2))
	ang2=min(abs(theta1),abs(theta2))
	//calculate the momentum range
	kzmin=(1/h_bar)*sqrt(2*m*(Emin*eV*cos(ang1/180*pi)^2+V_0*eV))*10^-10
	kzmax=(1/h_bar)*sqrt(2*m*(Emax*eV+V_0*eV) )*10^-10
	kpmin=sqrt(2*m*Emax*eV)/h_bar*sin(theta1/180*pi)*10^-10
	kpmax=sqrt(2*m*Emax*eV)/h_bar*sin(theta2/180*pi)*10^-10
			
	redimension/N=(-1, dimsize(temp2,1)/2 ,-1) temp
	setscale/I x, kpmin, kpmax, temp
	setscale/I y, kzmin, kzmax, temp
	setscale/I z, dimoffset(threeDmap,2), dimoffset(threeDmap,2)+dimdelta(threeDmap,2)*(dimsize(threeDmap,2)-1), temp
	temp[][][]=0
	
	//hv-theta map convert to kz-k// map
	//multithread temp[][][]=threeDmap[ScaletoIndex(threeDmap,sign(Indextoscale(temp,p,0))*atan(sqrt(Indextoscale(temp,p,0)^2/(Indextoscale(temp,q,1)^2-V_0*eV*2*m/(h_bar^2)*10^-20)))*180/pi,0)][ScaletoIndex(threeDmap,(Indextoscale(temp,p,0)^2+Indextoscale(temp,q,1)^2)*10^20*h_bar^2/(2*m*eV)+wfunc-V_0-Indextoscale(temp,r,2),1)][r]
	
	for(i=0; i<dimsize(temp2,0); i+=1)
		for(j=0; j<dimsize(temp2,1); j+=1)
			//kp=(1/h_bar)*sqrt(2*m*((Indextoscale(threeDmap,j,1)-wfunc+Indextoscale(threeDmap,r,2))*eV))*sin(Indextoscale(threeDmap,i,0)/180*pi)*10^-10
			//kz=(1/h_bar)*sqrt(2*m*((Indextoscale(threeDmap,j,1)-wfunc+Indextoscale(threeDmap,r,2))*eV*cos(Indextoscale(threeDmap,i,0)/180*pi)^2+V_0*eV))*10^-10
			multithread temp[ScaletoIndex(temp,(1/h_bar)*sqrt(2*m*((Indextoscale(temp2,j,1)-wfunc+Indextoscale(temp2,r,2))*eV))*sin(Indextoscale(temp2,i,0)/180*pi)*10^-10,0)][ScaletoIndex(temp,(1/h_bar)*sqrt(2*m*((Indextoscale(temp2,j,1)-wfunc+Indextoscale(temp2,r,2))*eV*cos(Indextoscale(temp2,i,0)/180*pi)^2+V_0*eV))*10^-10,1)][]=temp2[i][j][r]
		endfor
	endfor
	
	
	duplicate/O temp, $mapname
	killwaves temp, temp1, temp2, inter
	threeDmapload(mapname)
	cubicmapname=mapname
	
	print "convert to "+mapname+" with V0 = "+num2str(V_0)+" eV, kp and kz scales in 1/Å\r"
End

Function ButtonProc3DMapNewGraph(ctrlName) : ButtonControl
	String ctrlName
	String graphwave
	wave NewMapcolortab
	variable/g mapcolorcheck
	string/g cubicmapname
	prompt graphwave "Please choose the wave to plot new graph:" popup, "currentxwave;currentywave;currentzwave;zintensity"
	doprompt "", graphwave

	if(stringmatch(graphwave,"zintensity")==1)
		duplicate/O $graphwave, $cubicmapname+graphwave
		Display $cubicmapname+graphwave
		PauseUpdate; Silent 1		// modifying window...
		ModifyGraph/Z lsize=2
		ModifyGraph noLabel(left)=1
		exportgraphplot()
		Label/Z left "\\F'Arial'\\Z24\f00Intensity (arb. units)"
		Label/Z bottom "\\F'Arial'\\Z24\f02E-E\BF\M\F'Arial'\\Z24\f00 (eV)"
  	 	ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28,width=340.157,height=255.118 
   		TextBox/C/N=text0/B=1/F=0/A=MC "\\F'Arial'\\Z24zintensity"
	elseif(stringmatch(graphwave,"currentzwave")==1)
		Display;DelayUpdate
		duplicate/O $graphwave, $cubicmapname+graphwave
		AppendImage $cubicmapname+graphwave
		exportgraphplot()
		ModifyGraph zero=4
		Label/Z left "\\F'Arial'\\Z24\f00k\By\M\F'Arial'\\Z24"
		Label/Z bottom "\\F'Arial'\\Z24\f00k\Bx\M\F'Arial'\\Z24"
		ModifyGraph margin(left)=70,margin(bottom)=56,margin(right)=28,margin(top)=28,width=269.291,height=255.118
		if(mapcolorcheck==1)
			 PauseUpdate; Silent 1		// modifying window...
   			 ModifyImage/Z [0] ctab= {*,*,NewMapcolortab ,1}
		else
			 PauseUpdate; Silent 1		// modifying window...
   			 ModifyImage/Z [0] ctab= {*,*,NewMapcolortab ,0}
		endif
	elseif(stringmatch(graphwave,"currentxwave")==1)
		Display;DelayUpdate
		duplicate/O $graphwave, $cubicmapname+graphwave
		AppendImage $cubicmapname+graphwave
		exportgraphplot()
		ModifyGraph zero=4
		Label/Z left "\\F'Arial'\\Z24\f02E-E\BF\M\F'Arial'\\Z24\f00 (eV)"
		Label/Z bottom "\\F'Arial'\\Z24\f00k\Bx\M\F'Arial'\\Z24"
		ModifyGraph margin(left)=70,margin(bottom)=56,margin(right)=28,margin(top)=28,width=269.291,height=340.157
		if(mapcolorcheck==1)
			 PauseUpdate; Silent 1		// modifying window...
   			 ModifyImage/Z [0] ctab= {*,*,NewMapcolortab ,1}
		else
			 PauseUpdate; Silent 1		// modifying window...
   			 ModifyImage/Z [0] ctab= {*,*,NewMapcolortab ,0}
		endif	
	elseif(stringmatch(graphwave,"currentywave")==1)
		Display;DelayUpdate
		duplicate/O $graphwave, $cubicmapname+graphwave
		AppendImage $cubicmapname+graphwave
		ModifyGraph/Z swapXY=1
		exportgraphplot()
		ModifyGraph zero=4
		Label/Z left "\\F'Arial'\\Z24\f02E-E\BF\M\F'Arial'\\Z24\f00 (eV)"
		Label/Z bottom "\\F'Arial'\\Z24\f00k\By\M\F'Arial'\\Z24"
		ModifyGraph margin(left)=70,margin(bottom)=56,margin(right)=28,margin(top)=28,width=269.291,height=340.157
		if(mapcolorcheck==1)
			 PauseUpdate; Silent 1		// modifying window...
   			 ModifyImage/Z [0] ctab= {*,*,NewMapcolortab ,1}
		else
			 PauseUpdate; Silent 1		// modifying window...
   			 ModifyImage/Z [0] ctab= {*,*,NewMapcolortab ,0}
		endif	
	endif
End


Function exportgraphplot()
	ModifyGraph/Z tick=2
	ModifyGraph/Z mirror=1
	ModifyGraph/Z font="Arial"
	ModifyGraph/Z fSize=16, fStyle=1
	ModifyGraph/Z standoff=0
	ModifyGraph/Z axThick=2
End
////////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////Map Rotation/////////////////////////////////////////////

Function ButtonProc_FSrotate(ctrlName) : ButtonControl
	string ctrlName
	dowindow/f FSrotaPanel
	if(V_flag!=1)
		Execute "FSrotatPanel()"
	endif
End

Window FSrotatPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(1050,100,1400,375)
	ModifyPanel cbRGB=(65535,43690,0)
	SetDrawLayer UserBack
	SetDrawEnv linethick= 3
	DrawLine 5,115,350,115
	variable/g FSenergy=0, deltaE=0.01
	variable/g FSInterpX=1, FSInterpY=1
	variable/g FSrotategamma=1, FSinvertcheck=1
	variable/g Xanglestep=0, Yanglestep=0
	string/g FSmapname
	variable/g MaxK=2
	variable/g FSapicheck=0
	Button button1,pos={5.00,5.00},size={90.00,40.00},proc=Buttonproc_3DMapLoad,title="Map Load"
	Button button1,font="Times New Roman",fSize=20
	Button button2,pos={237.00,74.00},size={75.00,30.00},proc=Buttonproc_3DMapRescale,title="Rescale"
	Button button2,font="Times New Roman",fSize=20
	Button button3,pos={155.00,145.00},size={90.00,30.00},proc=Buttonproc_FSMapRotation,title="Rotation"
	Button button3,font="Times New Roman",fSize=20
	Button button4,pos={155.00,205.00},size={120.00,30.00},proc=Buttonproc_3DMapRotation,title="3D Rotation"
	Button button4,font="Times New Roman",fSize=20
	Button button5,pos={250.00,145.00},size={70.00,30.00},proc=ButtonProc_FSexport,title="Export"
	Button button5,font="Times New Roman",fSize=20
	Button button6,pos={155.00,237.00},size={78.00,27.00},proc=ButtonProc_FSrotat_lineprofile,title="LineProfile"
	Button button6,font="Times New Roman",fSize=14

	SetVariable setvar0,pos={100.00,15.00},size={90.00,22.00},proc=SetVarProc_FSenergy,title="E"
	SetVariable setvar0,font="Times New Roman",fSize=16
	SetVariable setvar0,limits={-inf,inf,0.01},value= FSenergy
	SetVariable setvar1,pos={195.00,15.00},size={100.00,22.00},proc=SetVarProc_deltaE,title="∆E(eV)"
	SetVariable setvar1,font="Times New Roman",fSize=16
	SetVariable setvar1,limits={-inf,inf,0.01},value= deltaE
	SetVariable setvar2,pos={117.00,45.00},size={90.00,22.00},proc=SetVarProc_FSInterpX,title="InterpX"
	SetVariable setvar2,font="Times New Roman",fSize=16
	SetVariable setvar2,limits={1,inf,1},value= FSInterpX
	SetVariable setvar3,pos={212.00,45.00},size={90.00,22.00},proc=SetVarProc_FSInterpY,title="InterpY"
	SetVariable setvar3,font="Times New Roman",fSize=16
	SetVariable setvar3,limits={1,inf,1},value= FSInterpY
	SetVariable setvar4,pos={117.00,69.00},size={110.00,22.00},proc=SetVarProc_Xanglestep,title="X anglestep"
	SetVariable setvar4,font="Times New Roman",fSize=16
	SetVariable setvar4,limits={0,inf,0},value= _NUM:0
	SetVariable setvar5,pos={117.00,89.00},size={110.00,22.00},proc=SetVarProc_Yanglestep,title="Y anglestep"
	SetVariable setvar5,font="Times New Roman",fSize=16
	SetVariable setvar5,limits={0,inf,0},value= _NUM:0
	SetVariable setvar6,pos={10.00,120.00},size={130.00,22.00},proc=SetVarProc_thetaangle,title="Theta(deg)"
	SetVariable setvar6,font="Times New Roman",fSize=16
	SetVariable setvar6,limits={-inf,inf,0},value= _NUM:0
	SetVariable setvar7,pos={10.00,145.00},size={130.00,22.00},proc=SetVarProc_phiangle,title="Phi(deg)"
	SetVariable setvar7,font="Times New Roman",fSize=16
	SetVariable setvar7,limits={-inf,inf,0},value= _NUM:0
	SetVariable setvar8,pos={10.00,170.00},size={130.00,22.00},proc=SetVarProc_rotationangle,title="rotation(deg)"
	SetVariable setvar8,font="Times New Roman",fSize=16
	SetVariable setvar8,limits={-inf,inf,0},value= _NUM:0
	SetVariable setvar9,pos={10.00,195.00},size={130.00,22.00},proc=SetVarProc_piangle,title="pi angle(deg)"
	SetVariable setvar9,font="Times New Roman",fSize=16
	SetVariable setvar9,limits={-inf,inf,0},value= _NUM:0
	SetVariable setvar10,pos={10.00,220.00},size={130.00,22.00},proc=SetVarProc_psiangle,title="psi angle(deg)"
	SetVariable setvar10,font="Times New Roman",fSize=16
	SetVariable setvar10,limits={-inf,inf,0},value= _NUM:0
	SetVariable setvar11,pos={150.00,120.00},size={110.00,22.00},proc=SetVarProc_meshsize,title="Mesh size"
	SetVariable setvar11,font="Times New Roman",fSize=16
	SetVariable setvar11,limits={1,inf,1},value= _NUM:1
	SetVariable setvar12,pos={240.00,180.00},size={50.00,22.00},proc=SetVarProc_FSrotategamma,title="γ"
	SetVariable setvar12,font="Times New Roman",fSize=16
	SetVariable setvar12,limits={0.1,inf,0.1},value= _NUM:1
	setvariable setvar13 pos={5,45},size={100,20},font="Times New Roman",fSize=16,value=FSmapname,title=" "
	PopupMenu popup0,pos={145.00,180.00},size={90.00,21.00},bodyWidth=90,proc=PopMenuProc_FSrotatemapcolor
	PopupMenu popup0,font="Times New Roman",fSize=16
	PopupMenu popup0,mode=1,value= #"\"*COLORTABLEPOP*\""
	CheckBox check0,pos={290.00,180.00},size={50.00,19.00},proc=CheckProc_FSinvertcheck,title="Invert"
	CheckBox check0,font="Times New Roman",fSize=16,value= 1,side= 1
	
	SetVariable setvar14,pos={260.00,120.00},size={85.00,22.00},title="MaxK"
	SetVariable setvar14,font="Times New Roman",fSize=16
	SetVariable setvar14,limits={1,4,1},value= _NUM:2,proc=SetVarProc_FSMaxK
	CheckBox check1,pos={10.00,250.00},size={46.00,19.00},proc=CheckProc_FSrotapicheck,title="a=π?"
	CheckBox check1,font="Times New Roman",fSize=16,value= 0,side= 1
	
	Button button0,pos={68.00,246.00},size={55.00,25.00},title="BZplot",font="Times New Roman",fSize=14,proc=Buttonproc_3DMapBZplot

EndMacro

Function Buttonproc_3DMapLoad(ctrlName) : ButtonControl
	String ctrlName
	string threedimmapname
	string/g FSmapname
	prompt threedimmapname "Choose the 3D map to rotate:" popup, wavelist("*",";","DIMS:3")
	doprompt "", threedimmapname
	if(V_flag)
		return -1 //user cancel
	endif 
	duplicate/O $threedimmapname cubicmap
	FSmapname=threedimmapname
	variable/g Xanglestep=dimdelta(cubicmap,0)
	variable/g Yanglestep=dimdelta(cubicmap,1)
	SetVariable setvar4 value= Xanglestep,win=FSrotatPanel
	SetVariable setvar5 value= Yanglestep,win=FSrotatPanel
	ShowFS()
End

Function SetVarProc_FSenergy(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g FSenergy=varNum
	wave FSmap
	if(waveexists(FSmap)==1)
		ShowFS()
	endif
End

Function SetVarProc_deltaE(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g deltaE=varNum
	wave FSmap
	if(waveexists(FSmap)==1)
		ShowFS()
	endif
End

Function SetVarProc_FSInterpX(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g FSInterpX=varNum
	wave FSmap
	if(waveexists(FSmap)==1)
		InterpFSmap()
	endif
End

Function SetVarProc_FSInterpY(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g FSInterpY=varNum
	wave FSmap
	if(waveexists(FSmap)==1)
		InterpFSmap()
	endif
End

Function ShowFS()
	wave cubicmap
	variable xdim,xoff,xdelta,ydim,yoff,ydelta,zdim,zoff,zdelta,zstart,zend,j
	variable/g FSenergy, deltaE
	xdim=dimsize(cubicmap,0);xdelta=dimdelta(cubicmap,0);xoff=dimoffset(cubicmap,0)
	ydim=dimsize(cubicmap,1);ydelta=dimdelta(cubicmap,1);yoff=dimoffset(cubicmap,1)
	zdim=dimsize(cubicmap,2);zdelta=dimdelta(cubicmap,2);zoff=dimoffset(cubicmap,2)
	zstart=ScaletoIndex(cubicmap,FSenergy-(deltaE/2),2)
	zend=ScaletoIndex(cubicmap,FSenergy+(deltaE/2),2)
	if(zstart>zend)
		zstart=ScaletoIndex(cubicmap,FSenergy+(deltaE/2),2)
		zend=ScaletoIndex(cubicmap,FSenergy-(deltaE/2),2)
	endif
	make/O/N=(xdim,ydim) FSmap
	FSmap[][]=0
	setscale/P x xoff,xdelta, FSmap
	setscale/p y yoff,ydelta, FSmap
	
	for(j=zstart;j<=zend;j+=1)
		if(j==zdim)
			break
		endif
		FSmap[][]+=cubicmap[p][q][j]
	endfor
	dowindow/f FSMapwindow
	if(V_flag==0)
		Display/W=(400,200,800,600)/N=FSMapwindow
		duplicate/O FSmap ShowFSmap 
		AppendImage/W=FSMapwindow ShowFSmap
		ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28,width=368.504,height=368.504
		ModifyGraph mirror=1,fStyle=1,fSize=16,font="Arial"
		ModifyGraph axThick=2
		ModifyImage ShowFSmap ctab= {*,*,Grays,1}
		ModifyGraph height={Plan,1,left,bottom}
	else
		string wavecheck=Stringbykey("ZWAVE",imageinfo("FSMapwindow","",0))
		if(stringmatch(wavecheck,"")!=1)
			RemoveImage $wavecheck
		endif
		duplicate/O FSmap ShowFSmap 
		AppendImage/W=FSMapwindow ShowFSmap
		ModifyGraph mirror=1,fStyle=1,fSize=16,font="Arial"
		ModifyGraph axThick=2
		ModifyImage ShowFSmap ctab= {*,*,Grays,1}
	endif
End

Function InterpFSmap()
	wave FSmap,M_InterpolatedImage,ShowFSmap, cubicmap
	variable/g FSInterpX,FSInterpY
	if(waveexists(FSmap)==1)
		ImageInterpolate/F={FSInterpX,FSInterpY}/DEST=ShowFSmap bilinear, FSmap
	endif
End

Function SetVarProc_Xanglestep(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g Xanglestep=varNum
End

Function SetVarProc_Yanglestep(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g Yanglestep=varNum
End

Function Buttonproc_3DMapRescale(ctrlName) : ButtonControl
	String ctrlName
	variable/g Xanglestep, Yanglestep, FSInterpX, FSInterpY
	wave FSmap, ShowFSmap
	setscale/P x 0, Xanglestep/FSInterpX, ShowFSmap
	setscale/P y 0, Yanglestep/FSInterpY, ShowFSmap
End

Function SetVarProc_phiangle(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g phiangle=varNum
End

Function SetVarProc_thetaangle(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g thetaangle=varNum
End

Function SetVarProc_rotationangle(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g rotationangle=varNum
End

Function SetVarProc_piangle(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g piangle=varNum
End

Function SetVarProc_psiangle(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g psiangle=varNum
End

Function SetVarProc_meshsize(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g meshsize=varNum
End

Function SetVarProc_FSMaxK(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g MaxK=varNum
End


Function CheckProc_FSrotapicheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	variable/g FSapicheck=checked
End


// The FS map rotation function comes from ScientaProcedure.ipf by Takeshi Kondo.
Function Buttonproc_FSMapRotation (ctrlName) : ButtonControl
	String ctrlName
	variable sizeX, sizeY, dX, dY, firstX, firstY, midY
	variable/g thetaangle, phiangle, rotationangle, piangle, psiangle, meshsize, MaxK, FSapicheck
	variable Psi, Phi, Theta, rotation, i, j
	variable termX1,termX2,termX3,termY1,termY2,termY3,termZ1,termZ2,termZ3
	wave ShowFSmap

	//Adjust the size of output map
	make/o/n=(meshsize*100+1,meshsize*100+1) temp
	temp[][]=0
	setscale/I x, -MaxK, MaxK, "" temp
	setscale/I y, -MaxK, MaxK, "" temp
	
	//Map angle read
	sizeX=dimsize(ShowFSmap,0)
	sizeY=dimsize(ShowFSmap,1)
	dX=dimdelta(ShowFSmap,0)
	dY=dimdelta(ShowFSmap,1)
	firstX=dimoffset(ShowFSmap,1)
	firstY=dimoffset(ShowFSmap,1)
	midY= firstY+dY*(sizeY-1)/2
	duplicate/o ShowFSmap temp1

	// Unit change to kx and ky
	make/o/n=(sizeY) Ywave,Zwave,x2wave,y2wave,temp2
	setscale/I x, -midY, midY, "" Ywave,Zwave
	Ywave[] = sin(pnt2x(Ywave,p)*pi/180) / sin(piangle*pi/180)
	Zwave[] = cos(pnt2x(Zwave,p)*pi/180) / sin(piangle*pi/180)
	Psi = psiangle*(pi/180)
	Phi = -phiangle*(pi/180)
	for (i=0 ; i< sizeX; i+=1)
	temp2[] = temp1[i][p]
   Theta= (DimOffset(ShowFSmap,0)+dx*i+thetaangle) *(pi/180)
   
   termX1=cos(Psi)*cos(Theta)-cos(Phi)*sin(Theta)*sin(Psi)
	termX2=cos(Psi)*sin(Theta)+cos(Phi)*cos(Theta)*sin(Psi)
	termX3=sin(Psi)*sin(Phi)
	
   termY1=-sin(Psi)*cos(Theta)-cos(Phi)*sin(Theta)*cos(Psi)
	termY2=-sin(Psi)*sin(Theta)+cos(Phi)*cos(Theta)*cos(Psi)
	termY3=cos(Psi)*sin(Phi)	
	
	termZ1=sin(Phi)*sin(Theta)
	termZ2=-sin(Phi)*cos(Theta)
	termZ3=cos(Phi)

	x2wave[] = termX2*Zwave[p]+termX3*Ywave[p]
	y2wave[] = termZ2*Zwave[p]+termZ3*Ywave[p]
		for (j=0 ; j<sizeY ; j+=1) 
			temp[x2pnt(temp,x2wave[j])][x2pnt(temp,y2wave[j])] = temp2[j]
		endfor
	endfor
	duplicate/O temp FSrotatemap
	
	//Map rotation
	if(rotationangle != 0)
		rotation = rotationangle*pi/180
		FSrotatemap[][]=temp(pnt2x(FSrotatemap,p)*cos(-rotation)-pnt2x(FSrotatemap,q)*sin(-rotation))(pnt2x(FSrotatemap,p)*sin(-rotation)+pnt2x(FSrotatemap,q)*cos(-rotation))
	endif
	killwaves temp, temp1, temp2,Ywave,Zwave,x2wave,y2wave
	
	dowindow/f FSrotateMapping

	if (V_flag != 1)
  		display/W=(279,112,683,496); 
  		dowindow/c FSrotateMapping
  		AppendImage FSrotateMap 
  		ModifyGraph margin(left)=75,margin(bottom)=75,margin(right)=42,margin(top)=28,width=283.465,height={Aspect,1}
		ModifyGraph mirror=1,fStyle=1,fSize=16,font="Arial"
		ModifyGraph standoff=0, tick=2, zero=4,zeroThick=2
		ModifyGraph axThick=2
		ModifyImage/Z FSrotateMap ctab={*,*,Grays,1}

		ColorScale/C/N=text0/F=0/A=MC/X=55.00/Y=0.00 nticks=0
		ModifyGraph width=0
	endif
	if(FSapicheck==1)
		Label bottom "\\F'Arial'\\Z24\\f00 k\\Bx\\M\\F'Times New Roman'\\Z24 (Å\\S-1\\M\\F'Arial'\\Z24)"
		Label left "\\F'Arial'\\Z24\\f00 k\\By\\M\\F'Times New Roman'\\Z24 (Å\\S-1\\M\\F'Arial'\\Z24)"
	else
		Label bottom "\\F'Arial'\\Z24\\f00 k\\Bx\\M\\F'Arial'\\Z24 (π/a)"
		Label left "\\F'Arial'\\Z24\\f00 k\\By\\M\\F'Arial'\\Z24 (π/a)"
	endif
End

Function ButtonProc_FSexport(ctrlName) : ButtonControl
	String ctrlName
	wave FSrotateMap, FSrotatemapcolortab, FSBZwave
	string/g FSmapname
	string logtext
	variable/g FSenergy, FSinvertcheck, FSapicheck, piangle
	String newFSname, newFSBZname
	if(waveexists(FSrotateMap)==1)
		newFSname=FSmapname+"_"+num2str(-FSenergy*1000)+"meV"
		duplicate/O FSrotateMap, $newFSname
		
		Display;Delayupdate 
  		AppendImage $newFSname 
  		ModifyGraph margin(left)=75,margin(bottom)=75,margin(right)=28,margin(top)=28,width=340.157,height={Aspect,1}
		ModifyGraph mirror=1,fStyle=1,fSize=16,font="Arial"
		ModifyGraph standoff=0, tick=2, zero=4,zeroThick=2
		ModifyGraph axThick=2
		if(waveexists(FSrotatemapcolortab)==1)
			if(FSinvertcheck==1)
				ModifyImage/Z $newFSname ctab={*,*,FSrotatemapcolortab,1}
			else
				ModifyImage/Z $newFSname ctab={*,*,FSrotatemapcolortab,0}
			endif
		else
			ModifyImage/Z $newFSname ctab={*,*,Grays,1}
		endif
	if(FSapicheck==1)
		Label bottom "\\F'Arial'\\Z24\\f00 k\\Bx\\M\\F'Times New Roman'\\Z24 (Å\\S-1\\M\\F'Arial'\\Z24)"
		Label left "\\F'Arial'\\Z24\\f00 k\\By\\M\\F'Times New Roman'\\Z24 (Å\\S-1\\M\\F'Arial'\\Z24)"
	else
		Label bottom "\\F'Arial'\\Z24\\f00 k\\Bx\\M\\F'Arial'\\Z24 (π/a)"
		Label left "\\F'Arial'\\Z24\\f00 k\\By\\M\\F'Arial'\\Z24 (π/a)"
	endif
	
	logtext="Rotate the FS of "+FSmapname+" to wave "+newFSname+", with piangle = "+num2str(piangle)+"\r"
	if(waveexists(FSBZwave))
		newFSBZname=FSmapname+"_BZ"
		duplicate/O FSBZwave, $newFSBZname
		AppendToGraph $newFSBZname[][1] vs $newFSBZname[][0]
		ModifyGraph mode=4,marker=8,msize=2,mrkThick=1,lsize=2
		
		logtext+="export "+newFSBZname+" together with the "+newFSname+"\r"	
	endif
	
	Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
	else
		Abort "Please first rotate the Fermi surface !"
	endif
End

Function Buttonproc_3DMapBZplot(ctrlName) : ButtonControl
	String ctrlName
	string BZwavestr
	
	dowindow/f FSrotateMapping
	if (V_flag != 1)
		Abort "Please first rotate the Fermi surface !"
	endif
	prompt BZwavestr "Please load the Brillouin zone wave (name contains \"BZ\"):" popup, wavelist("*BZ*", ";", "DIMS:2")
	doprompt "", BZwavestr
	if(V_flag)
		return -1 // use cancel
	endif
	
	duplicate/O $BZwavestr, FSBZwave
	AppendToGraph FSBZwave[][1] vs FSBZwave[][0]
   ModifyGraph mode=4,marker=8,msize=2,mrkThick=1,lsize=2
	
end


Function Buttonproc_3DMapRotation (ctrlName) : ButtonControl 
	String ctrlName
	variable sizeX, sizeY, sizeZ, dX, dY, dZ, firstX, firstY, firstZ, midY, zoff, deltaz
	variable/g thetaangle, phiangle, rotationangle, piangle, psiangle, meshsize, FSInterpX, FSInterpY, Xanglestep, Yanglestep
	variable/g MaxK
	variable Psi, Phi, Theta, rotation, i, j, k
	variable termX1,termX2,termX3,termY1,termY2,termY3,termZ1,termZ2,termZ3
	string logtext
	string/g FSmapname
	wave cubicmap
	String funccheck, FSnewname="newFSrot"
	prompt funccheck "Do you want to execute the 3D Map rotation? This would be time-consuming!" popup, "No;Yes"
	prompt FSnewname "Enter the name for 3D FSrotation Map:"
	doprompt "", funccheck, FSnewname
	if(stringmatch(funccheck,"No")==1)
		Abort "User cancel the procedure."
	endif
	if(V_flag)
		return -1
	endif
	zoff=dimoffset(cubicmap,2)
	deltaz=dimdelta(cubicmap,2)
	ImageInterpolate/F={FSInterpX,FSInterpY}/DEST=cubicmapint bilinear, cubicmap
	setscale/P z zoff, deltaz, "" cubicmapint
	setscale/P x 0, Xanglestep/FSInterpX, "" cubicmapint
	setscale/P y 0, Yanglestep/FSInterpY, "" cubicmapint
	//Adjust the size of output map
	make/o/n=(meshsize*100+1,meshsize*100+1) temp
	temp[][]=0
	setscale/I x, -MaxK, MaxK, "" temp
	setscale/I y, -MaxK, MaxK, "" temp
	
	//Map angle read
	sizeX=dimsize(cubicmapint,0)
	sizeY=dimsize(cubicmapint,1)
	sizeZ=dimsize(cubicmapint,2)
	dX=dimdelta(cubicmapint,0)
	dY=dimdelta(cubicmapint,1)
	dZ=dimdelta(cubicmapint,2)
	firstX=dimoffset(cubicmapint,0)
	firstY=dimoffset(cubicmapint,1)
	firstZ=dimoffset(cubicmapint,2)
	midY= firstY+dY*(sizeY-1)/2
	//duplicate/o cubicmapint temp1
	
	make/o/n=(meshsize*100,meshsize*100,sizeZ) cubicmap_rot
	setscale/I x, -MaxK, MaxK, "" cubicmap_rot
	setscale/I y, -MaxK, MaxK, "" cubicmap_rot
	setscale/P z, firstZ, dZ, "" cubicmap_rot
	// Unit change to kx and ky
	make/o/n=(sizeY) Ywave,Zwave,x2wave,y2wave,temp2
	setscale/I x, -midY, midY, "" Ywave,Zwave
	Ywave[] = sin(pnt2x(Ywave,p)*pi/180) / sin(piangle*pi/180)
	Zwave[] = cos(pnt2x(Zwave,p)*pi/180) / sin(piangle*pi/180)
	Psi = psiangle*(pi/180)
	Phi = -phiangle*(pi/180)

	//Rotation progress panel
	NewPanel/N=threedimRotationprogress/w=(285,111,739,193)
   ValDisplay energydim, pos={18,32}, size={342,18}, limits={0,sizeZ-1,0},barmisc={0,0}
   ValDisplay energydim, value=_NUM:0, highcolor=(0,65535,0), mode=3
   Button Stop, pos={375,32},size={50,20},title="Stop"
   DoUpdate/W=threedimRotationprogress/E=1
  
	for(k=0; k<sizeZ; k+=1)
	for (i=0 ; i< sizeX; i+=1)
	temp2[] = cubicmapint[i][p][k]
 	Theta= (DimOffset(cubicmapint,0)+dx*i+thetaangle) *(pi/180)
 	 
   termX1=cos(Psi)*cos(Theta)-cos(Phi)*sin(Theta)*sin(Psi)
	termX2=cos(Psi)*sin(Theta)+cos(Phi)*cos(Theta)*sin(Psi)
	termX3=sin(Psi)*sin(Phi)
	
   termY1=-sin(Psi)*cos(Theta)-cos(Phi)*sin(Theta)*cos(Psi)
	termY2=-sin(Psi)*sin(Theta)+cos(Phi)*cos(Theta)*cos(Psi)
	termY3=cos(Psi)*sin(Phi)	
	
	termZ1=sin(Phi)*sin(Theta)
	termZ2=-sin(Phi)*cos(Theta)
	termZ3=cos(Phi)
	x2wave[] = termX2*Zwave[p]+termX3*Ywave[p]
	y2wave[] = termZ2*Zwave[p]+termZ3*Ywave[p]
		for (j=0 ; j<sizeY ; j+=1) 
			temp[x2pnt(temp,x2wave[j])][x2pnt(temp,y2wave[j])] = temp2[j]
		endfor
	endfor
	multithread cubicmap_rot[][][k]=temp[p][q]
		if(rotationangle != 0)
		rotation = rotationangle*pi/180
		multithread cubicmap_rot[][][k]=temp(Indextoscale(cubicmap_rot,p,0)*cos(rotation)+Indextoscale(temp,q,1)*sin(rotation))(-Indextoscale(temp,p,0)*sin(rotation)+Indextoscale(temp,q,1)*cos(rotation))(indextoscale(temp,k,2))
	endif
	 ValDisplay energydim, value=_NUM:k,win=threedimRotationprogress
	 doupdate/W=threedimRotationprogress
		if(V_flag == 2)  //User stop the output progress
			k = sizeZ+1
			print "User stop the Map rotation progress!"
		endif
	endfor

	killwindow threedimRotationprogress	
	killwaves temp, temp2,Ywave,Zwave,x2wave,y2wave
	duplicate/O cubicmap_rot, $FSnewname
	logtext="Rotate the 3D map "+FSmapname+" to wave "+FSnewname+", with piangle = "+num2str(piangle)+"\r"
	Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
End

Function ButtonProc_FSrotat_lineprofile(ctrlName) : ButtonControl
	String ctrlName
	wave FSrotatemap
	variable/g FSlp_k1, FSlp_kint, FSlp_dk
	variable/g meshsize, MaxK, FSenergy
	string/g FSmapname, FSlp_kopt
	string kopt
	variable k1, dk, kint, knum
	variable i, j
	
	prompt kopt "Please choose the momentum direction:", popup "kx;ky"
	prompt k1 "Please enter the initial momentum:"
	prompt dk "Please enter the MDC integral width:"
	prompt kint "Please enter the MDC interval:"
	prompt knum "Please enter the MDC num:"
	doprompt "", kopt, k1, dk, kint, knum
	
	if(V_flag)
		return -1
	endif
	
	FSlp_k1=k1; FSlp_kint=kint;FSlp_dk=dk
	FSlp_kopt=kopt
	make/O/N=(meshsize*100+1) FSlptemp
	setscale/I x, -MaxK, MaxK, "", FSlptemp
	
	for(i=0; i<knum; i+=1)
		FSlptemp[]=0
		for(j=ScaletoIndex(FSrotatemap,k1+kint*i,1);j<=ScaletoIndex(FSrotatemap,k1+kint*i+dk,1);j+=1)
			if(stringmatch(kopt, "kx"))
				FSlptemp[]+=FSrotatemap[p][j]
			else
				FSlptemp[]+=FSrotatemap[j][p]
			endif
		endfor
		duplicate/O FSlptemp, $"FSlp"+num2str(i+1)
	endfor
	
	dowindow/f FSlineprofile
	if(V_flag!=1)
		display/W=(279,112,683,496); 
		ControlBar 50
		SetVariable setvar0,pos={8.00,6.00},size={120.00,25.00},proc=SetVarProc_FSlineprofileoffset,title="Offset"
		SetVariable setvar0,font="Times New Roman",fSize=20,value= _NUM:0,limits={0,inf,0}
		Button button0,pos={285.00,5.00},size={110.00,30.00},proc=ButtonProc_FSlineprofileMDCfit,title="MDCpeakfit"
		Button button0,font="Times New Roman",fSize=20
		SetVariable setvar1,pos={130.00,5.00},size={60.00,25.00},title="k1"
		SetVariable setvar1,font="Times New Roman",fSize=20,limits={0,inf,0},value=FSlp_k1
		SetVariable setvar2,pos={200.00,5.00},size={80.00,25.00},title="kint"
		SetVariable setvar2,font="Times New Roman",fSize=20,limits={-inf,inf,0}, value=FSlp_kint

  		dowindow/c FSlineprofile
  		ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28,width=340.157,height=255.118
	else
		SetVariable setvar0,value= _NUM:0
		string traceplotlist=wavelist("*",";","WIN:FSlineprofile")
		variable plotnum=itemsinlist(traceplotlist)
		for(j=0; j<plotnum; j+=1)
			Removefromgraph/W=FSlineprofile $StringFromList(j, traceplotlist)   
		endfor
	endif
	
	for(i=0; i<knum; i+=1)
		Appendtograph/W=FSlineprofile $"FSlp"+num2str(i+1)
	endfor
	
	FSlineprofileplot( )
	print "Show line profile of "+FSmapname+" FS at "+num2str(FSenergy)+" eV at "+kopt+" = "+num2str(k1)+" Å, integral within "+num2str(dk)+" Å, interval of "+num2str(kint)+" Å;"
End

Function FSlineprofileplot( )
	variable i, num
	string/g FSlp_kopt
	
	ModifyGraph/Z lsize=2
	ModifyGraph tick=2,mirror=1,fSize=20,axThick=2,standoff(bottom)=0,font="Arial",zero(bottom)=4,zeroThick(bottom)=2
	Label left "\\F'Arial'\\Z24MDC Intensity";DelayUpdate
	if(stringmatch(FSlp_kopt, "kx"))
		Label bottom "\\F'Arial'\\Z24\\f02k\\Bx\\M\\Z24\\f00 (Å\\S-1\\M\\Z24)"
	else
		Label bottom "\\F'Arial'\\Z24\\f02k\\By\\M\\Z24\\f00 (Å\\S-1\\M\\Z24)"
	endif
	Showinfo
End

Function SetVarProc_FSlineprofileoffset(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	string plotlist=wavelist("*",";", "WIN:FSlineprofile")
	variable num=itemsinlist(plotlist)
	variable i
	for(i=0; i<num; i+=1)
		string curstr=stringfromlist(i, plotlist)
		ModifyGraph/Z offset($curstr)={0, i*varNum}
	endfor
End

Function ButtonProc_FSlineprofileMDCfit(ctrlName) : ButtonControl //two-peak Voigt function fit for MDC
	String ctrlName
	string plotlist=wavelist("*",";", "WIN:FSlineprofile")
	string/g FSlp_kopt
	variable/g FSlp_k1, FSlp_kint, FSlp_dk
	variable num=itemsinlist(plotlist)
	variable w_0, w_1, w_2, w_3, w_4, w_5, w_6, w_7, w_8
	variable peaklevel, i
	
	dowindow/f FSlineprofile
	if(V_flag==0)
		Abort "Please show FS line profiles first!"
	endif
	if (stringmatch(CsrWave(a,""),"") || stringmatch(CsrWave(b,""),"") ||stringmatch(Csrwave(a),Csrwave(b))==0)
       Abort "Set A and B cursors on the same trace!!"
  	endif
	
	make/O/T/N=1 fitcwave1="K0>0"
	make/O/N=9 FSlp_Voigttwopeakfitcoeff
	make/O/N=(2*num) FSlp_Voigttwopeaksigma, FSlp_Voigttwopeakpos
	make/O/N=(2*num) FSlp_kpos
	FSlp_kpos[]=FSlp_k1+floor(p/2)*FSlp_kint
	//findpeak
	duplicate/O $stringfromlist(0,plotlist), temp
	peaklevel=(wavemax(temp,xcsr(A),xcsr(B))*2+wavemin(temp,xcsr(A),xcsr(B))*3)/5
	
	findpeak/Q/B=3/M=(peaklevel)/R=(xcsr(A),xcsr(B)) temp
	w_0=wavemin(temp,xcsr(A),xcsr(B))
	if(V_flag==0)
		w_1=V_PeakVal-w_0
		w_2=V_PeakLoc
		w_3=V_PeakWidth
	else
		w_1=0
		w_2=0
		w_3=0
	endif
	findpeak/Q/B=3/M=(peaklevel)/R=(w_2+w_3/2,xcsr(B)) temp
	if(V_flag==0)
		w_4=V_PeakVal-w_0
		w_5=V_PeakLoc
		w_6=V_PeakWidth
	else
		w_4=0
		w_5=0
		w_6=0
	endif	
	
	prompt w_0, "This is two peak Voigt function fit procedure for MDC profile. The fit function reads f=A+h1/((x-p1)^2+d1^2)⊗gauss(x-p1)+h2/((x-p2)^2+d2^2)⊗gauss(x-p2). The background A:" 
  	Prompt w_1, "Peak1 height h1:"
  	Prompt w_2, "Peak1 position p1(1/Å):" 
  	Prompt w_3, "Peak1 width d1(1/Å):"
  	Prompt w_4, "Peak2 height h2:"
  	Prompt w_5, "Peak2 position p2(1/Å):" 
  	Prompt w_6, "Peak2 width d2(1/Å):"
  	doprompt "", w_0, w_1, w_2, w_3, w_4, w_5, w_6
  	if(V_flag)
   		return -1  //user cancel
  	endif
  		
  	FSlp_Voigttwopeakfitcoeff={w_0, w_1, 5/w_3, w_2, 5, w_4, 5/w_6, w_5, 5} //the fifth and nineth parameter defines the ratio between Loretizian and gaussian function, use 5 for initial value	
	for(i=0; i<num; i+=1)
		duplicate/O $stringfromlist(i,plotlist), temp
		FuncFit/q twopeakVoigtfunction FSlp_Voigttwopeakfitcoeff temp[pcsr(A),pcsr(B)]/D/C=fitcwave1
		wave W_sigma
		FSlp_Voigttwopeakpos[2*i]=FSlp_Voigttwopeakfitcoeff[3]
		FSlp_Voigttwopeakpos[2*i+1]=FSlp_Voigttwopeakfitcoeff[7]
		FSlp_Voigttwopeaksigma[2*i]=W_Sigma[3]
		FSlp_Voigttwopeaksigma[2*i+1]=W_Sigma[7]
	endfor
	
	Display; Delayupdate
	AppendtoGraph FSlp_Voigttwopeakpos vs FSlp_kpos
	ErrorBars FSlp_Voigttwopeakpos XY,const=FSlp_dk/2,wave=(FSlp_Voigttwopeaksigma,FSlp_Voigttwopeaksigma)
	
	ModifyGraph mode=3,marker=8,msize=3,mrkThick=1
	ModifyGraph tick=2,mirror=1,fSize=20,axThick=2,standoff=0,font="Arial"
	ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28,width=255.118,height={Plan,1,left,bottom}
	if(stringmatch(FSlp_kopt, "kx"))
		Label bottom "\\F'Arial'\\Z20\\f02k\\By\\M\\Z20\\f00 (Å\\S-1\\M\\Z24)"
		Label left "\\F'Arial'\\Z20\\f02k\\Bx\\M\\Z20\\f00 (Å\\S-1\\M\\Z24)"
	else
		Label bottom "\\F'Arial'\\Z20\\f02k\\Bx\\M\\Z20\\f00 (Å\\S-1\\M\\Z24)"
		Label left "\\F'Arial'\\Z20\\f02k\\By\\M\\Z20\\f00 (Å\\S-1\\M\\Z24)"
	endif
	
	variable FSarea=0
	for(i=0; i<num; i+=1)
		FSarea+=abs(FSlp_Voigttwopeakpos[2*i+1]-FSlp_Voigttwopeakpos[2*i])*FSlp_kint
	endfor
	printf "The area enclosed by the FS is %g Å^2\r", FSarea
End


Function PopMenuProc_FSrotatemapcolor(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	String/g FSrotatemapcolor=popStr	
	colortab2wave $FSrotatemapcolor
	FSrotatemapcolorsetfunc()
End

Function SetVarProc_FSrotategamma (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g FSrotategamma=varNum
	FSrotatemapcolorsetfunc()
End


Function CheckProc_FSinvertcheck(ctrlName,checked) : CheckBoxControl 
	String ctrlName
	Variable checked
	variable/g FSinvertcheck=checked
	FSrotatemapcolorsetfunc()
End

Function FSrotatemapcolorsetfunc()
	String/g FSrotatemapcolor
	variable/g FSrotategamma, FSinvertcheck
	variable size
	wave M_colors, FSrotatemap, FSrotatemapcolortab
	duplicate/O M_colors FSrotatemapcolortab
	size=dimsize(FSrotatemapcolortab,0)
	FSrotatemapcolortab[][]=M_colors[size*(p/size)^(FSrotategamma)][q]

	if(FSinvertcheck == 1)
      ModifyImage/Z FSrotatemap ctab={*,*,FSrotatemapcolortab,1}
   else
      ModifyImage/Z FSrotatemap ctab={*,*,FSrotatemapcolortab,0}
   endif
End
////////////////////////////////////////////////////////////////////////////////////////////
		

//////////////////////////////////////Pi angle calculator//////////////////////////////////
//This Pi angle calculate function comes from ScientaProcedure.ipf by Takeshi Kondo.
Function ButtonProc_PiAngleCal (ctrlName) : ButtonControl
	String ctrlName
	variable/g a_ang, c_ang, hvi, hvf, V_0, hv_step, WW
  	variable KcZero, KcPi, KcsqrtPi, Kc2Pi, Kc2sqrtPi
 	variable aa, cc, aa_ang, cc_ang, VV_0
 	variable h_bar=1.0545*10^-34, m=9.11*10^-31, eV=1.6*10^-19
 	variable start_E,end_E, E_step, workfunc, angle,kcAtZero,kcAtPi,kcAtsqrtPi,kcAt2Pi,start_Ek,waveNum,Windex
   variable AngAtPi, AngAtHalfPi, AngAtsqrt2Pi,AngAt2sqrt2Pi, AngAt2Pi
   	string plotcheck
   		start_E = hvi; end_E = hvf
  	 	aa_ang = a_ang; cc_ang = c_ang; E_step=hv_step
   		VV_0 = V_0; workfunc=WW	
  	Prompt start_E,"starting hv (eV)"
 	Prompt end_E, "ending hv (eV)"
 	Prompt E_step, "Energy step (eV)"
  	Prompt aa_ang, "a lattice constant (ang)"
  	Prompt cc_ang, "c lattice constant (ang)"
  	Prompt VV_0, "Inner potential (eV)"
  	prompt workfunc, "Work function (eV)"
  	prompt plotcheck, "Plot Graph?", popup, "No;Yes"
  	DoPrompt "E vs Kz", start_E, end_E, E_step, aa_ang, cc_ang, VV_0, workfunc, plotcheck  // VV_0 = EE_0 + WW 
  	if (V_flag != 0) 
		return -1; // User cancelled. 
  	endif 
  	hvi=start_E ; hvf=end_E; WW=workfunc
  	a_ang=aa_ang  ; c_ang=cc_ang ; hv_step=E_step
  	V_0=VV_0
  	aa = aa_ang*10^-10
  	cc = cc_ang*10^-10
  	waveNum=(end_E-start_E)/E_step+1
  	make/O/N=(waveNum) Energy_eV, Piangle_deg, HalfPiangle_deg, kz_AtZero_pi, kz_AtPi_pi, kz_AtSqrtPi_pi, kz_At2Pi_pi, kz_At2SqrtPi_pi
	
	make/O/T/N=(7) infowave
	infowave={"starting hv = "+num2str(start_E)+" eV", "ending hv = "+num2str(end_E)+" eV", "Energy step = "+num2str(E_step)+" eV", "a lattice constant = "+num2str(aa_ang)+" Å", "c lattice constant = "+num2str(c_ang)+" Å", "Inner potential = "+num2str(VV_0)+" eV", "Work function = "+num2str(workfunc)+" eV" }
	
	do
 		start_Ek=start_E-workfunc
 		//I modify the calculation parameter, now we can set the work function value.
 		AngAtHalfPi=asin(h_bar*(pi/(2*aa))/(2*m*start_Ek*eV)^0.5)
 		AngAtPi=asin(h_bar*(pi/(aa))/(2*m*start_Ek*eV)^0.5)
		AngAtsqrt2Pi=asin(h_bar*(sqrt(2)*pi/(aa))/(2*m*start_Ek*eV)^0.5)
 		AngAt2Pi=asin(h_bar*(2*pi/(aa))/(2*m*start_Ek*eV)^0.5)
 		AngAt2sqrt2Pi=asin(h_bar*(2*sqrt(2)*pi/(aa))/(2*m*start_Ek*eV)^0.5)
 
 		KcZero=(1/h_bar)*(2*m*((start_Ek)*eV*cos(0)^2+(VV_0)*eV))^0.5
 		KcPi=(1/h_bar)*(2*m*((start_Ek)*eV*cos(AngAtPi)^2+(VV_0)*eV))^0.5
 		KcsqrtPi=(1/h_bar)*(2*m*((start_Ek)*eV*cos(AngAtsqrt2Pi)^2+(VV_0)*eV))^0.5
		Kc2Pi=(1/h_bar)*(2*m*((start_Ek)*eV*cos(AngAt2Pi)^2+(VV_0)*eV))^0.5
 		Kc2sqrtPi=(1/h_bar)*(2*m*((start_Ek)*eV*cos(AngAt2sqrt2Pi)^2+(VV_0)*eV))^0.5
 
 		Energy_eV [Windex]=start_E
 		HalfPiangle_deg[Windex]=AngAtHalfPi*180/pi
		Piangle_deg[Windex]=AngAtPi*180/pi
 		kz_AtZero_pi[Windex]=KcZero/(pi/cc)
 		kz_AtPi_pi[Windex]=KcPi/(pi/cc)
 		kz_AtSqrtPi_pi[Windex]=KcsqrtPi/(pi/cc)
		kz_At2Pi_pi[Windex]=Kc2Pi/(pi/cc)
 		kz_At2SqrtPi_pi[Windex]=Kc2sqrtPi/(pi/cc)

 		Windex+=1
 		//start_E+=1
 		start_E+=E_step
	while (start_E<=end_E)
	
	dowindow/f EvsKz
	if (V_flag!=1)
		Edit/W=(130,160,1050,730) Energy_eV, HalfPiangle_deg, Piangle_deg, kz_AtZero_pi, kz_AtPi_pi, kz_AtSqrtPi_pi, kz_At2Pi_pi, kz_At2SqrtPi_pi, infowave
  		dowindow/c EvsKz
 		
 		ModifyTable alignment=0
 		ModifyTable width(infowave)=180
	endif
	if(stringmatch(plotcheck,"Yes")==1)
		dowindow/f piangleKzGraph
		if(V_flag!=1)
			display/W=(279,112,683,496); 
  			dowindow/c piangleKzGraph
			Appendtograph/W=piangleKzGraph Piangle_deg vs Energy_eV
			Appendtograph/W=piangleKzGraph/R kz_AtZero_pi vs Energy_eV
			ModifyGraph/Z tick=2
			ModifyGraph/Z mirror(bottom)=1
			ModifyGraph/Z font="Arial"
			ModifyGraph/Z fSize=16, fStyle=1, standoff=0
			ModifyGraph/Z axThick=2
			ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=56,margin(top)=28,width=340.157,height=255.118
			ModifyGraph mode(Piangle_deg)=3,marker(Piangle_deg)=8,msize(Piangle_deg)=3,mrkThick(Piangle_deg)=2,rgb(Piangle_deg)=(65535,0,0)
			ModifyGraph mode(kz_AtZero_pi)=3,marker(kz_AtZero_pi)=5,msize(kz_AtZero_pi)=3,mrkThick(kz_AtZero_pi)=2,rgb(kz_AtZero_pi)=(0,0,65535)
			Label left "\\K(65535,0,0)\\F'Arial'\\Z24 Pi angle (°)"
			Label bottom "\\F'Arial'\\Z24\\f00 hν (eV)"
			Label right "\\K(0,0,65535)\\F'Arial'\\Z24 k\\Bz\\M\\F'Arial'\\Z24 (π/c)"
		endif
	endif
	//printf "a_lattice: %g Å; c_lattice: %g Å; Inner_potential: %g eV\r",aa_ang,cc_ang,VV_0
End 
///////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////Image Axis Correction///////////////////////////////
//This Image Axis Correct function comes from ScientaProcedure.ipf by Takeshi Kondo.
Function ButtonProc_ImAxisCorr(ctrlName) : Buttoncontrol
	String ctrlName
	dowindow/f ImageAxisCorrPanel
	if(V_flag!=1)
		Execute "ImageAxisCorrPanel()"
	endif
End

Window ImageAxisCorrPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel/W=(1250,520,1550,700)
	ModifyPanel cbRGB=(0,48830,0)
	variable/g ImAxis_onesliceangle=0
	variable/g ImAxis_piangle=0
	variable/g ImAxis_axisoff=0
	variable/g ImageAxis_colorgammaval=1
	variable/g ImageAxis_colorcheck=1
	variable/g lasercoref=0
	variable/g Axiscorrapicheck=0
	string/g ImAxiswave
	Button button0,pos={10.00,5.00},size={80.00,30.00},proc=ButtonProc_Getimagewave,title="Get",font="Times New Roman",fSize=20
	Button button1,pos={170,90},size={80.00,30.00},proc=ButtonProc_ImAxisCorrFunc,title="Correct",font="Times New Roman",fSize=20
	Button button2,pos={10,115},size={80.00,30.00},proc=ButtonProc_corrwaveoutput,title="Output",font="Times New Roman",fSize=20
	Button button3,pos={170,120},size={120.00,30.00},proc=ButtonProc_ImAxisCorrFunclaser,title="laserCorrect",font="Times New Roman",fSize=20
	SetVariable setvar0 title="Imagename",size={180,20},pos={100,5},font="Times New Roman",fSize=16,value=ImAxiswave
	SetVariable setvar1 title="one slice(deg)",pos={10,40},size={140,20},limits={-inf,inf,0},font="Times New Roman",fSize=16,value=ImAxis_onesliceangle
	SetVariable setvar2 title="pi angle(deg)",pos={10,65},size={140,20},limits={-inf,inf,0},font="Times New Roman",fSize=16,value=ImAxis_piangle
	SetVariable setvar3 title="Axis off",pos={10,90},size={140,20},limits={-inf,inf,0},font="Times New Roman",fSize=16,value=ImAxis_axisoff
	SetVariable setvar4 title="γ",pos={150,65},size={60,22},value=_Num:1,limits={0.1,inf,0.1},font="Times New Roman",fsize=16,proc=SetImageAxis_colorgamma
	PopupMenu popup0 value="*COLORTABLEPOP*",pos={220,40},bodyWidth=120,font="Times New Roman",fSize=16,proc=ImageAxis_color
	CheckBox check0 value=1,title="invert",pos={210,65},size={60,22},proc=ImageAxis_colorCheckProc,font="Times New Roman",fSize=20,side=1
	CheckBox check1,pos={98.00,122.00},size={39.00,19.00},proc=CheckProc_Axiscorrapicheck,title="a=π"
	CheckBox check1,font="Times New Roman",fSize=16,value= 0,side= 1
	Button button4,pos={9.00,145.00},size={80.00,30.00},proc=ButtonProc_CutslistAxisCorr,title="Cutslistcorr"
	Button button4,font="Times New Roman",fSize=14

EndMacro

Function ButtonProc_Getimagewave (ctrlName) : ButtonControl
	String ctrlName
	String ImAxis_ImageName
	String/g ImAxiswave
	prompt ImAxis_ImageName "Please choose the 2D wave to correct:" popup, wavelist("!*color*",";","DIMS:2,MINCOLS:50")
	doprompt "", ImAxis_ImageName
	if(V_flag)
		return -1//user cancel
	endif
	
	duplicate/o $ImAxis_ImageName, ImAxis_corr
	ImAxiswave=ImAxis_ImageName
	variable slice=dimdelta(ImAxis_corr,1)
	SetVariable setvar0 value=ImAxiswave
	variable/g ImAxis_onesliceangle=slice
End

Proc ButtonProc_ImAxisCorrFunc (ctrlName) : ButtonControl
	String ctrlName
	variable/g ImAxis_onesliceangle, ImAxis_piangle, ImAxis_axisoff, Axiscorrapicheck
	variable rrr, Theta_off, Theta_min, Theta_max, k_min, k_max, kpoints
	silent 1; pauseupdate
	duplicate/O ImAxis_corr, temp
	duplicate/O ImAxis_corr, temp1
	kpoints=dimsize(ImAxis_corr,1)
	rrr=1/sin(ImAxis_piangle/180*pi)
	Theta_off=asin(ImAxis_axisoff/rrr)
	Theta_min=-Theta_off
	k_min=rrr*sin(Theta_min)
	Theta_max=Theta_min+(kpoints-1)*(ImAxis_onesliceangle/180*pi)
	k_max=rrr*sin(Theta_max)
	setscale/I y, Theta_min, Theta_max, "" temp
	setscale/I y, k_min, k_max, "" temp1
	temp1()() = temp(x)(asin(y/rrr))
	duplicate/o temp1 ImAxis_corrMap
	dowindow/f ImAxisPanel
	killwaves temp, temp1
	
	if (V_flag==1)
 		ImageAxiscorr_colorsetfunc()
	endif
	if (V_flag!=1)
  		display/W=(280,110,680,500); 
  		dowindow/c ImAxisPanel
  		AppendImage ImAxis_corrMap 
  		ModifyGraph swapXY=1, standoff=0
  		ModifyGraph zero=4,zeroThick=2,mirror=1, tick=2
		ModifyGraph margin(left)=70,margin(bottom)=70,margin(right)=42,margin(top)=28,width=255.118,height=340.157
		ModifyGraph fStyle=1,tickUnit=1,font="Arial"
		ModifyGraph fSize(bottom)=16,fSize(left)=16
		ModifyGraph axThick=2
		Label/Z left "\\F'Arial'\\Z24\f02E-E\BF\M\F'Arial'\\Z24\f00 (eV)"
		ColorScale/C/N=text0/F=0/A=MC/X=58.00/Y=5.00 nticks=0
	endif
	if(Axiscorrapicheck==1)
		Label bottom "\\F'Arial'\\Z24\\f00 k\\Bx\\M\\F'Times New Roman'\\Z24 (Å\\S-1\\M\\F'Arial'\\Z24)"
	else
		Label/Z bottom "\\F'Arial'\\Z24\f00k (π/a)"
	endif		
end

Function ButtonProc_ImAxisCorrFunclaser (ctrlName) : ButtonControl
	string ctrlName
	wave ImAxis_corr
	variable/g ImAxis_onesliceangle, ImAxis_axisoff, lasercoref
	variable Epoints, Estep, EF, ImAxis_laserpiangle
	variable h_bar=1.0545*10^-34, m=9.11*10^-31, eV=1.6*10^-19
	variable rrr, Theta_off, Theta_min, Theta_max, k_min, k_max, kpoints, i, j 
	EF=lasercoref
	prompt EF "Please enter the value of fermi level (eV):"
	doprompt "" EF
	if(V_flag)
		return -1
	endif
	lasercoref=EF
	
	ImAxis_laserpiangle=asin(h_bar*10^10/(2*m*EF*eV*100)^0.5)*180/pi
	silent 1; pauseupdate
	duplicate/O ImAxis_corr, temp2
	kpoints=dimsize(ImAxis_corr,1)
	Epoints=dimsize(ImAxis_corr,0)
	rrr=1/sin(ImAxis_laserpiangle/180*pi)
	Theta_off=asin(ImAxis_axisoff*10/rrr)
	Theta_min=-Theta_off
	k_min=rrr*sin(Theta_min)
	Theta_max=Theta_min+(kpoints-1)*(ImAxis_onesliceangle/180*pi)
	k_max=rrr*sin(Theta_max)
	temp2[][]=0
	setscale/I y, k_min, k_max, "" temp2
	
	for(i=0; i<Epoints; i+=1)
		duplicate/O/RMD=[i][0,kpoints-1] ImAxis_corr, temp
		duplicate/O/RMD=[i][0,kpoints-1] ImAxis_corr, temp1
		variable piangle=sqrt(EF/(Indextoscale(ImAxis_corr,i,0)+EF))*ImAxis_laserpiangle
		rrr=1/sin(piangle/180*pi)
		k_min=rrr*sin(Theta_min)
		k_max=rrr*sin(Theta_max)
		setscale/I y, Theta_min, Theta_max, "" temp
		setscale/I y, k_min, k_max, "" temp1
		temp1[x2pnt(temp,asin(y/rrr))] = temp[q]
		for(j=0; j<kpoints; j+=1)
		variable currentk=indextoscale(temp1,j,1)
			temp2[i][scaletoindex(temp2,currentk,1)]=temp1[j]
		endfor
	endfor
	setscale/I y, k_min/10, k_max/10, "" temp2
	duplicate/o temp2 ImAxis_corrMap
	dowindow/f ImAxisPanel
	
	if (V_flag==1)
 		ImageAxiscorr_colorsetfunc()
	endif
	if (V_flag!=1)
  		display/W=(280,110,680,500); 
  		dowindow/c ImAxisPanel
  		AppendImage ImAxis_corrMap 
  		ModifyGraph swapXY=1, standoff=0
  		ModifyGraph zero=4,zeroThick=2,mirror=1, tick=2
		ModifyGraph margin(left)=70,margin(bottom)=70,margin(right)=42,margin(top)=28,width=255.118,height=340.157
		ModifyGraph fStyle=1,tickUnit=1,font="Arial"
		ModifyGraph fSize(bottom)=16,fSize(left)=16
		ModifyGraph axThick=2
		ColorScale/C/N=text0/F=0/A=MC/X=58.00/Y=5.00 nticks=0
		Label/Z left "\\F'Arial'\\Z24\f02E-E\BF\M\F'Arial'\\Z24\f00 (eV)"
		Label bottom "\\F'Arial'\\Z24\\f00k (Å\\S-1\\M\\F'Arial'\\Z24)"
	endif
End

Function CheckProc_Axiscorrapicheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	variable/g Axiscorrapicheck=checked

End

Function ImageAxis_color(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	Colortab2wave $popStr
   ImageAxiscorr_colorsetfunc()
End

Function ImageAxis_colorCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	variable/g ImageAxis_colorcheck
	ImageAxis_colorcheck=checked
	ImageAxiscorr_colorsetfunc()
End

Function SetImageAxis_colorgamma(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g ImageAxis_colorgammaval
	ImageAxis_colorgammaval=varNum
	ImageAxiscorr_colorsetfunc()
End

Function ImageAxiscorr_colorsetfunc()
	wave NewImageAxiscolortab, M_colors, ImAxis_corrMap
	variable/g ImageAxis_colorgammaval, ImageAxis_colorcheck
	variable size
	duplicate/O M_colors, NewImageAxiscolortab
	size=dimsize(NewImageAxiscolortab,0)
	NewImageAxiscolortab[][]=M_colors[size*(p/size)^ImageAxis_colorgammaval][q]
	if(ImageAxis_colorcheck == 1)
      ModifyImage/Z ImAxis_corrMap ctab={*,*,NewImageAxiscolortab,1}
   else
      ModifyImage/Z ImAxis_corrMap ctab={*,*,NewImageAxiscolortab,0}
   endif
End

Function ButtonProc_corrwaveoutput (ctrlName) : ButtonControl
	String ctrlName
	String outputwave, logtext
	String/g ImAxiswave
	wave ImAxis_corrMap, NewImageAxiscolortab
	variable/g ImageAxis_colorcheck, Axiscorrapicheck, ImAxis_piangle
	if(waveexists(ImAxis_corrMap)!=1)
		Abort "Please correct the 2D wave first!"
	endif
	outputwave= ImAxiswave+"_corr"
	duplicate/O ImAxis_corrMap $outputwave
	Display;DelayUpdate
	AppendImage $outputwave
  	ModifyGraph swapXY=1
  	ModifyGraph zero=4,zeroThick=2,mirror=1, tick=2
  	ModifyGraph axThick=2
	ModifyGraph margin(left)=70,margin(bottom)=70,margin(right)=28,margin(top)=28,width=255.118,height=340.157
	ModifyGraph fStyle=1,tickUnit=1,font="Arial"
	ModifyGraph fSize(bottom)=16,fSize(left)=16
	Label/Z left "\\F'Arial'\\Z24\f02E-E\BF\M\F'Arial'\\Z24\f00 (eV)"
	if(Axiscorrapicheck==1)
		Label bottom "\\F'Arial'\\Z24\\f00 k\\Bx\\M\\F'Times New Roman'\\Z24 (Å\\S-1\\M\\F'Arial'\\Z24)"
	else
		Label/Z bottom "\\F'Arial'\\Z24\f00k (π/a)"
	endif
	if(ImageAxis_colorcheck == 1)
      ModifyImage/Z $outputwave ctab={*,*,NewImageAxiscolortab,1}
   else
      ModifyImage/Z $outputwave ctab={*,*,NewImageAxiscolortab,0}
   endif
   
   logtext="correct the momentum of "+ImAxiswave+" to "+outputwave+" with piangle = "+num2str(ImAxis_piangle)+" \r"
	Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
	//ModifyImage $outputwave ctab={*,*,Grays,1}

End


Function ButtonProc_CutslistAxisCorr(ctrlName) : ButtonControl
	String ctrlName
	make/O/T/N=0 cutcorrlistwave
	make/O/N=0 pianglelistwave
	NewPanel /W=(538,182,800,650)/N=cutlistwaveedit
	Button button0,pos={145.00,425.00},size={60.00,30.00},title="End"
	Button button0,font="Times New Roman",fSize=16,fStyle=1,proc=ButtonProc_cutlistwavebutton1
	Button button1,pos={15.00,425.00},size={60.00,30.00},proc=ButtonProc_culistadd1,title="Add"
	Button button1,font="Times New Roman",fSize=16
	Button button2,pos={80.00,425.00},size={60.00,30.00},proc=ButtonProc_culistremove1,title="Remove"
	Button button2,font="Times New Roman",fSize=16
	Button button3,pos={220.00,430.00},size={30.00,20.00},title="All"
	Button button3,font="Times New Roman",proc=ButtonProc_cutlistall1
	PopupMenu popup0,pos={15.00,395.00},size={42.00,21.00},font="Times New Roman"
	PopupMenu popup0,fSize=16,mode=1,value=wavelist("!*colors*", ";", "DIMS:2")
	SetVariable setvar0,pos={164.00,398.00},size={90.00,19.00},title="filstr"
	SetVariable setvar0,font="Times New Roman",fSize=14,limits={-inf,inf,0},value= _STR:"", proc=SetVarProc_cutlistpianglefilter
	Edit/W=(14,25,273,374)/HOST=#  cutcorrlistwave, pianglelistwave 
	ModifyTable format(Point)=1
	ModifyTable statsArea=85
	RenameWindow #,T0
	SetActiveSubwindow ##
	pauseforuser cutlistwaveedit
End

Function ButtonProc_culistadd1(ctrlName) : ButtonControl
	String ctrlName
	controlinfo/W=cutlistwaveedit popup0
	string currentstr=S_value
	variable size=dimsize(cutcorrlistwave,0)
	make/O/T/N=(size+1) cutcorrlistwave
	make/O/N=(size+1) pianglelistwave
	cutcorrlistwave[size+1]=currentstr
End

Function ButtonProc_culistremove1(ctrlName) : ButtonControl
	String ctrlName
	variable startnum, denum
	prompt startnum, "Enter the num of points start to delete:"
	prompt denum, "Enter the num of points to delete:"
	doprompt "", startnum, denum
	if(V_flag)
		return -1
	endif
	Deletepoints startnum, denum, cutcorrlistwave
	Deletepoints startnum, denum, pianglelistwave
End

Function ButtonProc_cutlistall1(ctrlName) : ButtonControl
	String ctrlName
	string liststr=pianglecutlistfilter()
	variable num=itemsinlist(liststr)
	make/O/T/N=(num) cutcorrlistwave
	make/O/N=(num) pianglelistwave
	variable i
	for(i=0; i<num; i+=1)
		cutcorrlistwave[i]=stringfromlist(i,liststr)
	endfor
End

Function SetVarProc_cutlistpianglefilter(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	string/g pianglefilstr=varStr
	popupmenu popup0 value=pianglecutlistfilter()
End

Function/S pianglecutlistfilter()
	string/g pianglefilstr
	string list=wavelist("*"+pianglefilstr+"*", ";", "DIMS:2")
	return list
End

Function ButtonProc_cutlistwavebutton1(ctrlName) : ButtonControl
	String ctrlName
	wave/T cutcorrlistwave
	variable size=dimsize(cutcorrlistwave,0)
	variable i
	killwindow cutlistwaveedit
	cutlistgocorr()
End

Function cutlistgocorr()
	wave/T cutcorrlistwave
	wave pianglelistwave
	variable i, j, size, currentpiangle, thetaoffset
	variable Theta_min, Theta_max, kpoints, rrr, onesliceangle, k_min, k_max
	string logtext
	size=dimsize(pianglelistwave,0)
	prompt thetaoffset "Please enter the thetaoffset for cutlist corr:"
	doprompt "", thetaoffset
	if(V_flag)
		return -1
	endif
	
	for(i=0; i<size; i+=1)
		wave currentwave=$cutcorrlistwave[i]
		currentpiangle=pianglelistwave[i]
		onesliceangle=dimdelta(currentwave,1)
		
		duplicate/O currentwave, temp, temp1
		kpoints=dimsize(temp,1)
		rrr=1/sin(currentpiangle/180*pi)
		Theta_min=(dimoffset(currentwave,1)-thetaoffset)/180*pi
		Theta_max=Theta_min+((kpoints-1)*onesliceangle)/180*pi
		k_min=rrr*sin(Theta_min)
		k_max=rrr*sin(Theta_max)
		setscale/I y, Theta_min, Theta_max, "" temp
		setscale/I y, k_min, k_max, "" temp1
		temp1[][]=temp[p][ScaletoIndex(temp,asin(Indextoscale(temp1, q, 1)/rrr),1)]
		duplicate/o temp1 $cutcorrlistwave[i]+"_corr"
		cutlistgocorrplot(cutcorrlistwave[i]+"_corr")
		
		logtext="correct the momentum of "+cutcorrlistwave[i]+" to "+cutcorrlistwave[i]+"_corr with piangle = "+num2str(pianglelistwave[i])+" \r"
	   Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
	endfor
	
	killwaves temp, temp1
End

Function cutlistgocorrplot(str)
	string str
	wave  NewImageAxiscolortab
	variable/g ImageAxis_colorcheck, Axiscorrapicheck
	Display;DelayUpdate
	AppendImage $str
  	ModifyGraph swapXY=1
  	ModifyGraph zero=4,zeroThick=2,mirror=1, tick=2
  	ModifyGraph axThick=2
	ModifyGraph margin(left)=70,margin(bottom)=70,margin(right)=28,margin(top)=28,width=255.118,height=340.157
	ModifyGraph fStyle=1,tickUnit=1,font="Arial"
	ModifyGraph fSize(bottom)=16,fSize(left)=16
	Label/Z left "\\F'Arial'\\Z24\f02E-E\BF\M\F'Arial'\\Z24\f00 (eV)"
	if(Axiscorrapicheck==1)
		Label bottom "\\F'Arial'\\Z24\\f00 k\\Bx\\M\\F'Times New Roman'\\Z24 (Å\\S-1\\M\\F'Arial'\\Z24)"
	else
		Label/Z bottom "\\F'Arial'\\Z24\f00k (π/a)"
	endif
	if(ImageAxis_colorcheck == 1)
      ModifyImage/Z $str ctab={*,*,NewImageAxiscolortab,1}
   else
      ModifyImage/Z $str ctab={*,*,NewImageAxiscolortab,0}
   endif
	
End
///////////////////////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////kz Map rotation panel////////////////////////////////////////////////////////
/////////////////////This kz map correct function comes from ScientaProcedure.ipf by Takeshi Kondo.//////////////////////////////////
Function ButtonProc_kzMaprotation (ctrlName) : ButtonControl
	String ctrlName
	dowindow/f kzMappanel
	if (V_flag!=1)
 		Execute "kzmappanel()"
	endif
End

Window kzmappanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(1253,407,1600,700)
	ModifyPanel cbRGB=(0,65535,65535)
	SetDrawLayer UserBack
	SetDrawEnv linethick= 3
	DrawLine 5,120,345,120
	variable/g kzInterpX=1, kzInterpY=1
	variable/g kzFSenergy=0, kzdeltaE=0.01
	string/g kzmapname
	variable/g kzanglestep=0, kzhvstep=0
	variable/g hvkzr=65535
	variable/g hvkzg=0
	variable/g hvkzb=0

	Button button0,pos={5.00,5.00},size={90.00,40.00},proc=Buttonproc_kzmapload,title="Map Load"
	Button button0,font="Times New Roman",fSize=20
	SetVariable setvar0,pos={102.00,10.00},size={90.00,22.00},proc=SetVarProc_kzFSenergy,title="E"
	SetVariable setvar0,font="Times New Roman",fSize=16
	SetVariable setvar0,limits={-inf,inf,0.01},value= kzFSenergy
	SetVariable setvar1,pos={197.00,10.00},size={100.00,22.00},proc=SetVarProc_kzdeltaE,title="∆E(eV)"
	SetVariable setvar1,font="Times New Roman",fSize=16
	SetVariable setvar1,limits={-inf,inf,0.01},value= kzdeltaE
	SetVariable setvar2,pos={120.00,40.00},size={90.00,22.00},proc=SetVarProc_kzInterpX,title="InterpX"
	SetVariable setvar2,font="Times New Roman",fSize=16
	SetVariable setvar2,limits={1,inf,1},value= kzInterpX
	SetVariable setvar3,pos={230.00,40.00},size={90.00,22.00},proc=SetVarProc_kzInterpY,title="InterpY"
	SetVariable setvar3,font="Times New Roman",fSize=16
	SetVariable setvar3,limits={1,inf,1},value= kzInterpY
	Button button1,pos={155.00,150.00},size={80.00,30.00},proc=Buttonproc_KzmapCorr,title="kz rot"
	Button button1,font="Times New Roman",fSize=20
	Button button2,pos={236.00,74.00},size={75.00,30.00},proc=ButtonProc_3DkzMapRescale,title="Rescale"
	Button button2,font="Times New Roman",fSize=20
	Button button4,pos={155.00,220.00},size={80.00,25.00},proc=Buttonproc_3DKzmapCorr,title="3D kz rot"
	Button button4,font="Times New Roman",fSize=16
	SetVariable setvar4,pos={116.00,67.00},size={110.00,22.00},proc=SetVarProc_kzanglestep,title="X anglestep"
	SetVariable setvar4,font="Times New Roman",fSize=16
	SetVariable setvar4,limits={0,inf,0},value= _NUM:0
	SetVariable setvar5,pos={116.00,91.00},size={110.00,22.00},proc=SetVarProc_kzhvstep,title="Y hν step"
	SetVariable setvar5,font="Times New Roman",fSize=16
	SetVariable setvar5,limits={0,inf,0},value= _NUM:0
	SetVariable setvar6,pos={5.00,125.00},size={130.00,22.00},proc=SetVarProc_kzhv,title="hv (eV)"
	SetVariable setvar6,font="Times New Roman",fSize=16
	SetVariable setvar6,limits={0,inf,0},value= _NUM:0
	SetVariable setvar7,pos={5.00,150.00},size={130.00,22.00},proc=SetVarProc_thetaoffset,title="Theta offset"
	SetVariable setvar7,font="Times New Roman",fSize=16
	SetVariable setvar7,limits={-inf,inf,0},value= _NUM:0
	SetVariable setvar8,pos={5.00,175.00},size={130.00,22.00},proc=SetVarProc_innerpotential,title="V0 (eV)"
	SetVariable setvar8,font="Times New Roman",fSize=16
	SetVariable setvar8,limits={0,inf,0},value= _NUM:0
	SetVariable setvar9,pos={5.00,200.00},size={130.00,22.00},proc=SetVarProc_latticea,title="a (Å)"
	SetVariable setvar9,font="Times New Roman",fSize=16
	SetVariable setvar9,limits={0,inf,0},value= _NUM:0
	SetVariable setvar10,pos={5.00,225.00},size={130.00,22.00},proc=SetVarProc_latticec,title="c (Å)"
	SetVariable setvar10,font="Times New Roman",fSize=16
	SetVariable setvar10,limits={0,inf,0},value= _NUM:0
	SetVariable setvar11,pos={140.00,125.00},size={100.00,22.00},proc=SetVarProc_workfunc,title="workfunc"
	SetVariable setvar11,font="Times New Roman",fSize=16
	SetVariable setvar11,limits={0,inf,0},value= _NUM:0
	SetVariable setvar12,pos={240.00,190.00},size={50.00,22.00},proc=SetVarProc_kzmapgamma,title="γ"
	SetVariable setvar12,font="Times New Roman",fSize=16
	SetVariable setvar12,limits={0.1,inf,0.1},value= _NUM:1
	SetVariable setvar13,pos={5.00,45.00},size={100.00,22.00},title=" "
	SetVariable setvar13,font="Times New Roman",fSize=16
	SetVariable setvar13,limits={-inf,inf,0},value= kzmapname
	PopupMenu popup0,pos={145.00,190.00},size={90.00,21.00},bodyWidth=90,proc=PopMenuProc_kzmapcolor
	PopupMenu popup0,font="Times New Roman",fSize=16
	PopupMenu popup0,mode=1,value= #"\"*COLORTABLEPOP*\""
	CheckBox check0,pos={290.00,190.00},size={50.00,19.00},proc=CheckProc_kzinvertcheck,title="Invert"
	CheckBox check0,font="Times New Roman",fSize=16,value= 1,side= 1
	CheckBox check1,pos={10.00,80.00},size={51.00,19.00},proc=CheckProc_kznorm,title="Norm"
	CheckBox check1,font="Times New Roman",fSize=16,value= 0,side= 1
	Button button5,pos={250.00,150.00},size={75.00,30.00},proc=ButtonProc_kzmapexport,title="Export"
	Button button5,font="Times New Roman",fSize=20
	Button button6,pos={20.00,255.00},size={70.00,30.00},proc=ButtonProc_kzhvkzconvert,title="hv-kz"
	Button button6,font="Times New Roman",fSize=20
	PopupMenu popup1,pos={100.00,258.00},size={50.00,21.00},proc=PopMenuProc_hvkzcolor
	PopupMenu popup1,mode=1,popColor= (65535,0,0),value= #"\"*COLORPOP*\""
EndMacro

Function ButtonProc_kzmapload(ctrlName) : ButtonControl
	String ctrlName
	string threedimmapname
	string/g kzmapname
	prompt threedimmapname "Choose the 3D map to perform kz correction (please first reorder x to in-plane angle, y to photon energy):" popup, wavelist("!*threeDmap*",";","DIMS:3")
	doprompt "", threedimmapname
	if(V_flag)
		return -1 //user cancel
	endif 
	wave kzwave=$threedimmapname
	variable hv=dimdelta(kzwave,1)
	variable hvsize=dimsize(kzwave,1)
	variable hvoffset=dimoffset(kzwave,1)
	if(hv > 0)
		duplicate/O kzwave kzcubicmap
	else
		duplicate/O kzwave kzcubicmap
		multithread kzcubicmap[][][]=kzwave[p][hvsize-1-q][r]
		setscale/P y,  hvoffset+hv*(hvsize-1), -hv, kzcubicmap
	endif
	kzmapname=threedimmapname
	variable/g kzanglestep=dimdelta(kzcubicmap,0)
	variable/g kzhvstep=dimdelta(kzcubicmap,1)
	SetVariable setvar4 value= kzanglestep, win=kzmappanel
	SetVariable setvar5 value= kzhvstep, win=kzmappanel
	Showkzrawmap()
End

Function SetVarProc_kzFSenergy(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g kzFSenergy=varNum
	wave kzrawmap
	if(waveexists(kzrawmap))
		showkzrawmap()
	endif
End

Function SetVarProc_kzdeltaE(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g kzdeltaE=varNum
	wave kzrawmap
	if(waveexists(kzrawmap))
		showkzrawmap()
	endif
End

Function SetVarProc_kzInterpX(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g kzInterpX=varNum
	Interpkzmap()
End

Function SetVarProc_kzInterpY(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g kzInterpY=varNum
	Interpkzmap()
End

Function SetVarProc_kzanglestep(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g kzanglestep=varNum
End

Function SetVarProc_kzhvstep(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g kzhvstep=varNum
End

Function SetVarProc_workfunc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g WW=varNum
End

Function CheckProc_kznorm(ctrlName, checked) : CheckBoxControl
	String ctrlName
	variable checked
	variable/g kznormcheck=checked
End

Function Showkzrawmap()
	wave kzcubicmap
	variable xdim,xoff,xdelta,ydim,yoff,ydelta,zdim,zoff,zdelta,zstart,zend,j
	variable/g kzFSenergy, kzdeltaE
	xdim=dimsize(kzcubicmap,0);xdelta=dimdelta(kzcubicmap,0);xoff=dimoffset(kzcubicmap,0)
	ydim=dimsize(kzcubicmap,1);ydelta=dimdelta(kzcubicmap,1);yoff=dimoffset(kzcubicmap,1)
	zdim=dimsize(kzcubicmap,2);zdelta=dimdelta(kzcubicmap,2);zoff=dimoffset(kzcubicmap,2)
	zstart=ScaletoIndex(kzcubicmap,kzFSenergy-(kzdeltaE/2),2)
	zend=ScaletoIndex(kzcubicmap,kzFSenergy+(kzdeltaE/2),2)
	if(zstart>zend)
		zstart=ScaletoIndex(kzcubicmap,kzFSenergy+(kzdeltaE/2),2)
		zend=ScaletoIndex(kzcubicmap,kzFSenergy-(kzdeltaE/2),2)
	endif
	make/O/N=(xdim,ydim) kzrawmap
	kzrawmap[][]=0
	setscale/P x xoff,xdelta, kzrawmap
	setscale/p y yoff,ydelta, kzrawmap
	
	for(j=zstart;j<=zend;j+=1)
		if(j==zdim)
			break
		endif
		kzrawmap[][]+=kzcubicmap[p][q][j]
	endfor
	dowindow/f kzMapwindow
	if(V_flag==0)
		Display/W=(400,200,800,600)/N=kzMapwindow
		duplicate/O kzrawmap Showkzmap 
		AppendImage/W=kzMapwindow Showkzmap
		ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28,width=368.504,height=368.504
		ModifyGraph mirror=1,fStyle=1,fSize=16,font="Arial"
		ModifyGraph axThick=2, tick=2
		ModifyImage Showkzmap ctab= {*,*,Grays,1}
	else
		string wavecheck=Stringbykey("ZWAVE",imageinfo("kzMapwindow","",0))
		if(stringmatch(wavecheck,"")!=1)
			RemoveImage $wavecheck
		endif
		duplicate/O kzrawmap Showkzmap 
		AppendImage/W=kzMapwindow Showkzmap
		ModifyGraph mirror=1,fStyle=1,fSize=16,font="Arial"
		ModifyGraph axThick=2, tick=2
		ModifyImage Showkzmap ctab= {*,*,Grays,1}
	endif
End

Function Interpkzmap()
	wave kzrawmap,M_InterpolatedImage,Showkzmap, kzcubicmap
	variable/g kzInterpX,kzInterpY
	variable zoff, dz
	zoff=dimoffset(kzcubicmap,2)
	dz=dimdelta(kzcubicmap,2)
	if(waveexists(kzrawmap)==1)
		ImageInterpolate/F={kzInterpX,kzInterpY}/DEST=Showkzmap bilinear, kzrawmap
	endif
End

Function SetVarProc_kzhv(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g photonenergy = varNum
End

Function ButtonProc_3DkzMapRescale(ctrlName) : ButtonControl
	String ctrlName
	variable/g kzanglestep, kzhvstep, kzInterpX, kzInterpY, photonenergy, kznormcheck
	variable xsize, ysize, i
	wave kzrawmap, Showkzmap
	setscale/P x 0, kzanglestep/kzInterpX, Showkzmap
	setscale/P y photonenergy, kzhvstep/kzInterpY, Showkzmap
	xsize=dimsize(Showkzmap,0); ysize=dimsize(Showkzmap,1)
	
	//Norm of the kz raw map along the MCP angle// 
	if(kznormcheck==1)
	make/O/N=(xsize) temp1
	for (i=0; i<ysize; i+=1)
		temp1[]=Showkzmap[p][i]
		Showkzmap[][i]/=mean(temp1,0,xsize-1)
	endfor
	endif
	killwaves temp1
End

Function SetVarProc_thetaoffset (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g thetaoffset = varNum
End

Function SetVarProc_innerpotential (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g V_0 = varNum
End

Function SetVarProc_latticea (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g latticea = varNum
End

Function SetVarProc_latticec (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g latticec = varNum
End

Proc Buttonproc_KzmapCorr (ctrlName) : ButtonControl
	string ctrlName
	variable h_bar=1.0545*10^-34,aa,cc,m=9.11*10^-31,eV=1.6*10^-19
	variable/g kzanglestep, kzInterpX, kzInterpY, photonenergy, kzhvstep, thetaoffset, latticea, latticec, V_0, WW
	variable ki, kf, kzi, kzf, Tipi, Tfpi, Ei, Ef, EieV, EfeV, HalfMCP, kpoints, Epoints, V_0eV
	silent 1 ; pauseupdate

	duplicate/o Showkzmap, kzSourceMap, kzMap, ThetaMap, EkMap
	Epoints=dimsize(Showkzmap,1)
	kpoints=dimsize(Showkzmap,0)
	HalfMCP=abs( (kpoints-1)*kzanglestep/kzInterpX/2 )
	SetScale/I x -HalfMCP+thetaoffset,HalfMCP+thetaoffset,"", kzSourceMap
	SetScale/I y (photonenergy-WW),(photonenergy+Epoints*kzhvstep/kzInterpY-WW),"", kzSourceMap
	Tipi=-(HalfMCP-thetaoffset)*pi/180
	Tfpi=(HalfMCP+thetaoffset)*pi/180
	EieV=(photonenergy-WW)*eV
	EfeV=(photonenergy+Epoints*kzhvstep/kzInterpY-WW)*eV
	V_0eV=V_0*eV
	ki=sqrt(2*m*EfeV)/h_bar*sin(Tipi)
	kf=sqrt(2*m*EfeV)/h_bar*sin(Tfpi)
	kzi=(1/h_bar)*sqrt( 2*m*(EieV*cos(Tipi)^2+V_0eV) )
	kzf=(1/h_bar)*sqrt( 2*m*(EfeV+V_0eV) )
	SetScale/I x ki,kf,"", kzMap, ThetaMap, EkMap
	SetScale/I y kzi,kzf,"", kzMap, ThetaMap, EkMap
	ThetaMap()()=asin( x / sqrt( x^2 +y^2 - 2*m*V_0eV/(h_bar^2) ) )
	EkMap()()=( (h_bar*y)^2/(2*m) - V_0eV ) / cos( ThetaMap(x)(y) )^2 /eV
	kzMap[][]= kzSourceMap(ThetaMap[p][q]/pi*180)(EkMap[p][q])
	aa=latticea*10^-10
	cc=latticec*10^-10
	SetScale/I x ki/(pi/aa),kf/(pi/aa),"", kzMap
	SetScale/I y kzi/(pi/cc),kzf/(pi/cc),"", kzMap
	SetScale/I y photonenergy,photonenergy+Epoints*kzhvstep/kzInterpY,"", kzSourceMap
	kzmapmodify() 
	
	dowindow/f kzSourceMapPanel
	if (V_flag!=1)
		Display /W=(245,122,635,514)
		dowindow/c kzSourceMapPanel
		AppendImage kzSourceMap
		ModifyImage kzSourceMap ctab= {*,*,Grays,1}
		ModifyGraph mirror=1
		ModifyGraph nticks=10, tick=2 
		ModifyGraph minor=1
		ModifyGraph/Z font="Arial", fSize=16
		ModifyGraph axThick=2 
		ModifyGraph standoff=0
		ModifyGraph zero(bottom)=4,zeroThick(bottom)=2
		Label left "\\F'Arial'\\Z24\f00Photon energy (eV)"
		Label bottom "\\F'Arial'\\Z24\f00MCP angle (deg)"
		ModifyGraph margin(left)=70,margin(bottom)=56,margin(right)=28,margin(top)=28,width=255.118,height=340.157
	endif

	dowindow/f kzMapgraph
	if (V_flag!=1)
		Display /W=(245,122,635,514)
		dowindow/c kzMapgraph
		AppendImage kzMap
		ModifyImage kzMap ctab= {*,*,Grays,1}
		ModifyGraph mirror=1
		ModifyGraph nticks=10, tick=2 
		ModifyGraph minor=1
		ModifyGraph/Z font="Arial", fSize=16
		ModifyGraph axThick=2
		ModifyGraph standoff=0
		ModifyGraph zero(bottom)=4,zeroThick(bottom)=2
		Label bottom "\\F'Arial'\\Z24\f00k\B//\M\F'Arial'\\Z24 (π/a)"
		Label left "\\F'Arial'\\Z24\f00k\Bz\M\F'Arial'\\Z24 (π/c)"
		ModifyGraph margin(left)=70,margin(bottom)=56,margin(right)=42,margin(top)=28,width=255.118,height=340.157
		ColorScale/C/N=text0/F=0/A=MC/X=58.00/Y=5.00 nticks=0
	endif
		killwaves thetamap, Ekmap
end

Function kzmapmodify() 
	String ctrlName
	variable kzdimension, kparadimension, kzmin, kzmax, kz1, kz2, kparamin, kparamax, kpara1, kpara2
	variable/g kzanglestep, kzInterpX, kzInterpY, photonenergy, kzhvstep, thetaoffset, latticea, latticec, V_0, WW
	variable ee = 1.6*10^(-19)
	variable em = 9.109*10^(-31)
	variable hbar = 6.626*10^(-34)/(2*pi)
	variable angstron = 10^(-10)
	// these variables are physical constants
	wave kzMap
	if(waveexists(kzMap)!=1)
		Abort "Please first do kz map rotate!"
	endif
	
	kzdimension=dimsize (kzMap,1)
	kparadimension=dimsize (kzMap,0)
	kzmin = IndextoScale (kzMap,0,1)
	kzmax = IndextoScale (kzMap,kzdimension-1,1)
	kparamin = IndextoScale (kzMap,0,0)
	kparamax = IndextoScale (kzMap,kparadimension-1,0)
	variable Ef=photonenergy+(kzdimension-1)/kzInterpY*kzhvstep

	duplicate/O kzMap kzMapmod
	kpara1=sqrt((photonenergy-ww)/(Ef-WW))*kparamin
	kpara2=sqrt((photonenergy-ww)/(Ef-WW))*kparamax
	kz1=sqrt(2*em/(hbar^2)*ee*(Ef+V_0)-(kparamin*pi/(latticea*angstron))^2)*latticec*angstron/pi
	kz2=sqrt(2*em/(hbar^2)*ee*(Ef+V_0)-(kparamax*pi/(latticea*angstron))^2)*latticec*angstron/pi
	variable kparaindex1=ScaletoIndex(kzMap,kpara1,0)
	variable kparaindex2=ScaletoIndex(kzMap,kpara2,0)
	
	variable i1, j1, i2, j2, i3, j3
	variable currentkz,currentkpara,currentkzlim, currentkzlim2
	
for ( i1=0; i1<=kparaindex1; i1+=1 )
for ( j1=0; j1<kzdimension-1; j1+=1 )
	currentkz=IndextoScale(kzMapmod,j1,1)
	currentkpara=IndextoScale(kzMapmod,i1,0)
	currentkzlim=kz1+(kz1-kzmin)/(kparamin-kpara1)*(currentkpara-kparamin)
	if (currentkz < currentkzlim)
		kzMapmod[i1][j1]=0
	endif	
endfor
endfor

for ( i2=kparadimension-1; i2>=ScaletoIndex(kzMapmod,kpara2,1) ; i2-=1 )
for ( j2=0; j2<kzdimension-1; j2+=1 )
	currentkz=IndextoScale(kzMapmod,j2,1)
	currentkpara=IndextoScale(kzMapmod,i2,0)
	currentkzlim=kz2+(kz2-kzmin)/(kparamax-kpara2)*(currentkpara-kparamax)
	if (currentkz < currentkzlim)
		kzMapmod[i2][j2]=0
	endif	
endfor
endfor

for ( i3=0; i3<kparadimension-1; i3+=1 )
for ( j3=0; j3<kzdimension-1; j3+=1 )
	currentkz=IndextoScale(kzMapmod,j3,1)
	currentkpara=IndextoScale(kzMapmod,i3,0)
	if (2*em/(hbar^2)*ee*(photonenergy+V_0-WW)-(currentkpara*pi/(latticea*angstron))^2 >0)
		currentkzlim=sqrt(2*em/(hbar^2)*ee*(photonenergy+V_0-WW)-(currentkpara*pi/(latticea*angstron))^2)*latticec*angstron/pi
	else
		currentkzlim=0
	endif
	currentkzlim2=sqrt(2*em/(hbar^2)*ee*(Ef+V_0-WW)-(currentkpara*pi/(latticea*angstron))^2)*latticec*angstron/pi
	if (currentkz < currentkzlim || currentkz > currentkzlim2)
		kzMapmod[i3][j3]=0
	endif	
endfor
endfor
duplicate/O kzMapmod, kzMap
killwaves kzMapmod

End

Function PopMenuProc_kzmapcolor(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	String/g kzmapcolor=popStr	
	colortab2wave $kzmapcolor
	kzmapcolorsetfunc()
End

Function SetVarProc_kzmapgamma (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g kzmapgamma=varNum
	kzmapcolorsetfunc()
End

Function CheckProc_kzinvertcheck(ctrlName,checked) : CheckBoxControl 
	String ctrlName
	Variable checked
	variable/g kzinvertcheck=checked
	kzmapcolorsetfunc()
End

Function kzmapcolorsetfunc()
	String/g kzmapcolor
	variable/g kzmapgamma, kzinvertcheck
	variable size
	wave M_colors, kzMap, kzmapcolortab, kzMapmod
	duplicate/O M_colors kzmapcolortab
	size=dimsize(kzmapcolortab,0)
	kzmapcolortab[][]=M_colors[size*(p/size)^(kzmapgamma)][q]

	if(kzinvertcheck == 1)
		ModifyImage/w=kzSourceMapPanel/Z kzSourceMap ctab={*,*,kzmapcolortab,1}
		ModifyImage/w=kzMapgraph/Z kzMap ctab={*,*,kzmapcolortab,1}
		if(waveexists(kzMapmod)==1)
			ModifyImage/w=kzMapmodifygraph/Z kzMapmod ctab={*,*,kzmapcolortab,1}
		endif
   else
		ModifyImage/w=kzSourceMapPanel/Z kzSourceMap ctab={*,*,kzmapcolortab,0}
		ModifyImage/w=kzMapgraph/Z kzMap ctab={*,*,kzmapcolortab,0}
      if(waveexists(kzMapmod)==1)
      		ModifyImage/w=kzMapmodifygraph/Z kzMapmod ctab={*,*,kzmapcolortab,0}
      	endif
   endif
End


Function Buttonproc_3DKzmapCorr (ctrlName) : ButtonControl
	string ctrlName
	variable h_bar=1.0545*10^-34,aa,cc,m=9.11*10^-31,eV=1.6*10^-19
	variable/g kzanglestep, kzInterpX, kzInterpY, photonenergy, kzhvstep, thetaoffset, latticea, latticec, V_0, WW
	variable/g kznormcheck
	variable ki, kf, kzi, kzf, Tipi, Tfpi, Ei, Ef, EieV, EfeV, HalfMCP, kpoints, Epoints, Ebpoints, Eboff, Ebdelta, V_0eV, i, j
	wave kzcubicmap
	string/g kzmapname
	string logtext
	String funccheck, kznewname="newkzrot"
	prompt funccheck "Do you want to execute the 3D Map rotation? This would be time-consuming!" popup, "No;Yes"
	prompt kznewname "Enter the name for 3D kz Map:"
	doprompt "", funccheck, kznewname
	if(stringmatch(funccheck,"No")==1)
		Abort "User cancel the procedure."
	endif
	if(V_flag)
		return -1
	endif

	ImageInterpolate/F={kzInterpX,kzInterpY}/DEST=kzcubicmapint bilinear, kzcubicmap
	Epoints=dimsize(kzcubicmapint,1)
	kpoints=dimsize(kzcubicmapint,0)
	Ebpoints=dimsize(kzcubicmapint,2)	
	Eboff=dimoffset(kzcubicmap,2); Ebdelta=dimdelta(kzcubicmap,2)
	duplicate/O kzcubicmapint, kzrotcubicmap
	make/O/N=(kpoints,Epoints) kzSourceMap1, ThetaMap1, EkMap1
	HalfMCP=abs((kpoints-1)*kzanglestep/kzInterpX/2 )
	SetScale/I x -HalfMCP+thetaoffset,HalfMCP+thetaoffset,"", kzSourceMap1
	SetScale/I y (photonenergy-WW),(photonenergy+Epoints*kzhvstep/kzInterpY-WW),"", kzSourceMap1
	Tipi=-(HalfMCP-thetaoffset)*pi/180
	Tfpi=(HalfMCP+thetaoffset)*pi/180
	EieV=(photonenergy-WW)*eV
	EfeV=(photonenergy+Epoints*kzhvstep/kzInterpY-WW)*eV
	V_0eV=V_0*eV
	ki=sqrt(2*m*EfeV)/h_bar*sin(Tipi)
	kf=sqrt(2*m*EfeV)/h_bar*sin(Tfpi)
	kzi=(1/h_bar)*sqrt( 2*m*(EieV*cos(Tipi)^2+V_0eV) )
	kzf=(1/h_bar)*sqrt( 2*m*(EfeV+V_0eV) )
	
	//kz rotation progress panel
	NewPanel/N=kzRotationprogress/w=(285,111,739,193)
   ValDisplay energydim, pos={18,32}, size={342,18}, limits={0,Ebpoints-1,0},barmisc={0,0}
   ValDisplay energydim, value=_NUM:0, highcolor=(0,65535,0), mode=3
   Button Stop, pos={375,32},size={50,20},title="Stop"
   DoUpdate/W=kzRotationprogress/E=1
	
	for(i=0; i< Ebpoints; i+=1)
		make/O/N=(kpoints,Epoints) temp2
		temp2[][]=kzcubicmapint[p][q][i]
		if(kznormcheck==1)
			make/O/N=(kpoints) temp1
			for(j=0; j<Epoints; j+=1)
				temp1[]=temp2[p][j]
				temp2[][j]/=mean(temp1,0,kpoints-1)
			endfor
		endif
		kzSourceMap1[][]=temp2[p][q]
		ThetaMap1[][]=temp2[p][q]
		EkMap1[][]=temp2[p][q]
		SetScale/I x ki,kf,"",  ThetaMap1, EkMap1
		SetScale/I y kzi,kzf,"", ThetaMap1, EkMap1
		
		ThetaMap1[][]=asin( IndextoScale(ThetaMap1,p,0) / sqrt((IndextoScale(ThetaMap1,p,0))^2 +(IndextoScale(ThetaMap1,q,1))^2 - 2*m*V_0eV/(h_bar^2) ) )
		EkMap1[][]=( (h_bar*IndextoScale(EkMap1,q,1))^2/(2*m) - V_0eV ) / cos( ThetaMap1(x)(y) )^2 /eV
		kzrotcubicmap[][][i]= kzSourceMap1(ThetaMap1[p][q]/pi*180)(EkMap1[p][q])
		
		ValDisplay energydim, value=_NUM:i,win=kzRotationprogress
	 	doupdate/W=kzRotationprogress
		if(V_flag == 2)  //User stop the output progress
			i = Ebpoints
			print "User stop the Map rotation progress!"
		endif
	endfor
	
	aa=latticea*10^-10
	cc=latticec*10^-10
	SetScale/I x ki/(pi/aa),kf/(pi/aa),"", kzrotcubicmap
	SetScale/I y kzi/(pi/cc),kzf/(pi/cc),"", kzrotcubicmap
	setScale/P z Eboff, Ebdelta, "", kzrotcubicmap
	//SetScale/I y photonenergy,photonenergy+Epoints*kzhvstep/kzInterpY,"", kzSourceMap
	kzrotcubicmapcorr()
	duplicate/O kzrotcubicmap, $kznewname
	killwaves kzSourceMap1, ThetaMap1, Ekmap1, kzcubicmapint, temp1, temp2, kzrotcubicmap
	killwindow kzRotationprogress

	
	logtext="Rotate the 3D kz map "+kzmapname+" to wave "+kznewname+", with a = "+num2str(latticea)+" Å, c = "+num2str(latticec)+" Å, V0 = "+num2str(V_0)+" eV\r"
	Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
End

Function kzrotcubicmapcorr()
	variable kzdimension, kparadimension, kzmin, kzmax, kz1, kz2, kparamin, kparamax, kpara1, kpara2
	variable/g kzanglestep, kzInterpX, kzInterpY, photonenergy, kzhvstep, thetaoffset, latticea, latticec, V_0, WW
	variable ee = 1.6*10^(-19)
	variable em = 9.109*10^(-31)
	variable hbar = 6.626*10^(-34)/(2*pi)
	variable angstron = 10^(-10)
	// these variables are physical constants
	wave kzrotcubicmap
	
	kzdimension=dimsize (kzrotcubicmap,1)
	kparadimension=dimsize (kzrotcubicmap,0)
	kzmin = IndextoScale (kzrotcubicmap,0,1)
	kzmax = IndextoScale (kzrotcubicmap,kzdimension-1,1)
	kparamin = IndextoScale (kzrotcubicmap,0,0)
	kparamax = IndextoScale (kzrotcubicmap,kparadimension-1,0)
	variable Ef=photonenergy+kzdimension/kzInterpY*kzhvstep
	duplicate/O kzrotcubicmap temp
	kpara1=sqrt((photonenergy-ww)/(Ef-WW))*kparamin
	kpara2=sqrt((photonenergy-ww)/(Ef-WW))*kparamax
	kz1=sqrt(2*em/(hbar^2)*ee*(Ef+V_0)-(kparamin*pi/(latticea*angstron))^2)*latticec*angstron/pi
	kz2=sqrt(2*em/(hbar^2)*ee*(Ef+V_0)-(kparamax*pi/(latticea*angstron))^2)*latticec*angstron/pi
	variable kparaindex1=ScaletoIndex(kzrotcubicmap,kpara1,0)
	variable kparaindex2=ScaletoIndex(kzrotcubicmap,kpara2,0)
	
	variable i1, j1, i2, j2, i3, j3
	variable currentkz,currentkpara,currentkzlim, currentkzlim2
	for ( i1=0; i1<=kparaindex1; i1+=1 )
		for ( j1=0; j1<kzdimension-1; j1+=1 )
			currentkz=IndextoScale(temp,j1,1)
			currentkpara=IndextoScale(temp,i1,0)
			currentkzlim=kz1+(kz1-kzmin)/(kparamin-kpara1)*(currentkpara-kparamin)
		if (currentkz < currentkzlim)
			temp[i1][j1][]=0
		endif	
		endfor
	endfor

for ( i2=kparadimension-1; i2>=ScaletoIndex(temp,kpara2,1) ; i2-=1 )
for ( j2=0; j2<kzdimension-1; j2+=1 )
	currentkz=IndextoScale(temp,j2,1)
	currentkpara=IndextoScale(temp,i2,0)
	currentkzlim=kz2+(kz2-kzmin)/(kparamax-kpara2)*(currentkpara-kparamax)
	if (currentkz < currentkzlim)
		temp[i2][j2][]=0
	endif	
endfor
endfor

for ( i3=0; i3<kparadimension-1; i3+=1 )
for ( j3=0; j3<kzdimension-1; j3+=1 )
	currentkz=IndextoScale(temp,j3,1)
	currentkpara=IndextoScale(temp,i3,0)
	if (2*em/(hbar^2)*ee*(photonenergy+V_0-WW)-(currentkpara*pi/(latticea*angstron))^2 >0)
		currentkzlim=sqrt(2*em/(hbar^2)*ee*(photonenergy+V_0-WW)-(currentkpara*pi/(latticea*angstron))^2)*latticec*angstron/pi
	else
		currentkzlim=0
	endif
	currentkzlim2=sqrt(2*em/(hbar^2)*ee*(Ef+V_0-WW)-(currentkpara*pi/(latticea*angstron))^2)*latticec*angstron/pi
	if (currentkz < currentkzlim || currentkz > currentkzlim2)
		temp[i3][j3][]=0
	endif	
endfor
endfor
duplicate/O temp, kzrotcubicmap
killwaves temp
End


Function ButtonProc_kzmapexport(ctrlName) : ButtonControl
	String ctrlName
	wave kzMapmod, kzmapcolortab
	string/g  kzmapname
	string logtext
	variable/g kzFSenergy, kzinvertcheck, latticea, latticec, V_0
	string newkzmapname
	if(waveexists(kzMap)!=1)
		Abort "Please first rotate kz map!"
	endif
	newkzmapname=kzmapname+"_"+num2str(-kzFSenergy*1000)+"meV"
	duplicate/O kzMap, $newkzmapname
	
	Display; Delayupdate
	AppendImage $newkzmapname
	ModifyGraph mirror=1
	ModifyGraph nticks=10, tick=2,minor=1
	ModifyGraph/Z font="Arial",fSize=16, standoff=0
	ModifyGraph axThick=2
	ModifyGraph zero(bottom)=4,zeroThick(bottom)=1
	Label bottom "\\F'Arial'\\Z24\f00k\B//\M\F'Arial'\\Z24 (π/a)"
	Label left "\\F'Arial'\\Z24\f00k\Bz\M\F'Arial'\\Z24 (π/c)"
	ModifyGraph margin(left)=70,margin(bottom)=56,margin(right)=28,margin(top)=28,width=255.118,height=340.157
	if(waveexists(kzmapcolortab)!=1)
		ModifyImage/Z $newkzmapname ctab={*,*,Grays,1}
	else
		if(kzinvertcheck==1)
			ModifyImage/Z $newkzmapname ctab={*,*,kzmapcolortab,1}
		else
			ModifyImage/Z $newkzmapname ctab={*,*,kzmapcolortab,0}
		endif
	endif
	
	logtext="Rotate the kz map "+kzmapname+" to wave "+newkzmapname+", with a = "+num2str(latticea)+" Å, c = "+num2str(latticec)+" Å, V0 = "+num2str(V_0)+" eV\r"
	Notebook exp_logbook selection={endoffile, endoffile},fsize=12, text=logtext
End

Function ButtonProc_kzhvkzconvert(ctrlName) : ButtonControl
	String ctrlName
	wave kzMapmod
	variable size, kparaoff, kparadelta, photonenergy
	variable h_bar=1.0545*10^-34,aa,cc,m=9.11*10^-31,eV=1.6*10^-19
	variable/g latticea, latticec, V_0, WW
	variable/g hvkzr, hvkzg, hvkzb
	dowindow/f kzMapgraph
	if (V_flag!=1)
		Abort "Please first rotate the kzmap!"
	endif
	prompt photonenergy "Please enter the photon energy (eV):"
	doprompt "", photonenergy
	if(V_flag)
		return -1 //user cancel
	endif
	size=dimsize(kzMap,0)
	kparaoff=dimoffset(kzMap,0)
	kparadelta=dimdelta(kzMap,0)
	
	make/O/N=(size) $"kpara"+num2str(photonenergy)+"eV", $"kz"+num2str(photonenergy)+"eV"
	wave hvkpara=$"kpara"+num2str(photonenergy)+"eV"
	wave hvkz=$"kz"+num2str(photonenergy)+"eV"
	hvkpara[]=kparaoff+p*kparadelta
	aa=latticea*10^-10
	cc=latticec*10^-10
	hvkz[]=sqrt(2*m/(h_bar^2)*(photonenergy-WW+V_0)*eV-(pi/aa*hvkpara[p])^2)
	hvkz/=pi/cc
	AppendtoGraph/W=kzMapgraph hvkz vs hvkpara
	ModifyGraph/Z lsize($"kz"+num2str(photonenergy)+"eV")=2
	ModifyGraph/Z rgb($"kz"+num2str(photonenergy)+"eV")=(hvkzr,hvkzg,hvkzb)
	SetDrawEnv textrgb= (hvkzr,hvkzg,hvkzb),fsize= 24,xcoord= bottom,ycoord= left;DelayUpdate
	DrawText 0, wavemax(hvkz), num2str(photonenergy)+"eV"
End

Function PopMenuProc_hvkzcolor(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	controlinfo popup1
	variable/g hvkzr= V_red 
	variable/g hvkzg=V_green
	variable/g hvkzb=V_blue
End

/////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////Symmetry Tool Panel//////////////////////////////////
Function ButtonProc_Symmetry(ctrlName) : ButtonControl
	String ctrlName
	dowindow/f Symmpanel
	if (V_flag!=1)
 		Execute "Symmpanel()"
	endif
End

Window Symmpanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(1266,138,1581,501)
	SetDrawLayer UserBack
	SetDrawEnv linethick= 2
	DrawLine -11,145,320,145
	make/O/T/N=0 symmtracelistwave
	make/O/N=0 symmtraceselwave
	String/g symmwavestr
	String/g symmdirection="X"
	variable/g Symmcenter=0, traceSymmcenter=0, symmimageplotcheck=1, symmfoldnum=2
	TitleBox title0,pos={5.00,5.00},size={159.00,28.00},title="2D Image Symmetry"
	TitleBox title0,labelBack=(65535,65535,65535),font="Times New Roman",fSize=18
	TitleBox title0,frame=5
	TitleBox title1,pos={5.00,155.00},size={165.00,30.00},title="1D Trace Symmetry"
	TitleBox title1,labelBack=(65535,65535,65535),font="Times New Roman",fSize=20
	TitleBox title1,frame=5
	Button button0,pos={10.00,35.00},size={50.00,30.00},proc=ButtonProc_GetSymmImage,title="Get"
	Button button0,font="Times New Roman",fSize=18
	SetVariable setvar0,pos={65.00,35.00},size={90.00,24.00},title=" ",fSize=16
	SetVariable setvar0,value= symmwavestr
	PopupMenu popup0,pos={170.00,35.00},size={130.00,21.00},proc=PopMenuProc_symmdirection,title="Symm Direction"
	PopupMenu popup0,font="Times New Roman",fSize=16
	PopupMenu popup0,mode=2,popvalue="X",value= #"\"X;Y\""
	SetVariable setvar1,pos={168.00,60.00},size={132.00,22.00},bodyWidth=45,title="Symm Center"
	SetVariable setvar1,font="Times New Roman",fSize=16
	SetVariable setvar1,limits={-inf,inf,0},value= Symmcenter
	SetVariable setvar2,pos={8.00,225.00},size={132.00,22.00},bodyWidth=45,title="Symm Center"
	SetVariable setvar2,font="Times New Roman",fSize=16
	SetVariable setvar2,limits={-inf,inf,0},value= traceSymmcenter
	Button button1,pos={10.00,70.00},size={90.00,30.00},proc=ButtonProc_2DImageSymmetry,title="Symmetry"
	Button button1,font="Times New Roman",fSize=18
	Button button2,pos={5.00,190.00},size={60.00,30.00},proc=ButtonProc_1Dtracelistget,title="Get"
	Button button2,font="Times New Roman",fSize=16
	ListBox list0,pos={175.00,155.00},size={135.00,200.00},font="Times New Roman"
	ListBox list0,fSize=16,listWave=root:symmtracelistwave
	ListBox list0,selWave=root:symmtraceselwave,mode= 9
	Button button3,pos={70.00,190.00},size={90.00,30.00},proc=ButtonProc_1Dtracesymmetry,title="Symmetry"
	Button button3,font="Times New Roman",fSize=18
	SetVariable setvar3,pos={5.00,250.00},size={90.00,22.00},proc=SetVarProc_symmtracesmooth,title="Smooth"
	SetVariable setvar3,font="Times New Roman",fSize=16
	SetVariable setvar3,limits={0,inf,1},value= _NUM:0
	SetVariable setvar4,pos={5.00,275.00},size={80.00,22.00},proc=SetVarProc_symmtraceoffset,title="Offset"
	SetVariable setvar4,font="Times New Roman",fSize=16
	SetVariable setvar4,limits={0,inf,0},value= _NUM:0
	PopupMenu popup1,pos={106.00,85.00},size={120.00,21.00},bodyWidth=120,proc=PopMenuProc_symmimagecolor
	PopupMenu popup1,font="Times New Roman",fSize=16
	PopupMenu popup1,mode=1,value= #"\"*COLORTABLEPOP*\""
	CheckBox check0,pos={230.00,85.00},size={50.00,19.00},proc=CheckProc_symmimageplotcheck,title="Invert"
	CheckBox check0,font="Times New Roman",fSize=16,value= 1,side= 1
	Button button4,pos={9.00,110.00},size={160.00,25.00},proc=ButtonProc_multifoldsymmetry,title="Multi-fold Symmetry"
	Button button4,font="Times New Roman",fSize=18
	PopupMenu popup2,pos={190.00,110.00},size={61.00,21.00},bodyWidth=30,proc=PopMenuProc_foldnum,title="Fold"
	PopupMenu popup2,font="Times New Roman",fSize=16
	PopupMenu popup2,mode=1,popvalue="2",value= #"\"2;3;4;6;8\""
	SetVariable setvar5 title="lsize",pos={100,250},size={70,20},value= _NUM:2,limits={0,10,0.5},font="Times New Roman",fSize=16,proc=SetVarProc_Symmtracelsize
	PopupMenu popup3 title="Color",pos={85,275},value="*COLORPOP*",popColor=(65535,0,0),font="Times New Roman",fSize=16,proc=PopMenuProc_Symmtracecolor
EndMacro

Function PopMenuProc_symmdirection(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	String/g symmdirection=popStr
End

Function ButtonProc_GetSymmImage(ctrlName) : ButtonControl
	String ctrlName
	String SymmImagename
	prompt SymmImagename "Choose the 2D Image wave to symmetry:" popup, wavelist("!*color*",";","DIMS:2,MINCOLS:100")
	doprompt "", SymmImagename
	duplicate/O $SymmImagename rawSymmwave
	String/g symmwavestr=SymmImagename
End

Function ButtonProc_2DImageSymmetry(ctrlName) : ButtonControl
	String ctrlName
	wave rawSymmwave
	variable/g Symmcenter 
	String/g symmdirection
	variable xsize, xoff, xdelta, ysize, yoff, ydelta, symmxoff, symmyoff
	xsize=dimsize(rawSymmwave,0); ysize=dimsize(rawSymmwave,1)
	xoff=dimoffset(rawSymmwave,0); yoff=dimoffset(rawSymmwave,1)
	xdelta=dimdelta(rawSymmwave,0); ydelta=dimdelta(rawSymmwave,1)
	if(stringmatch(symmdirection,"X")==1)
		if(Symmcenter<xoff || Symmcenter>xoff+(xsize-1)*xdelta)
			Abort "Please set Symmetry center in the x range!"
		endif
		
		variable xpnt=ScaletoIndex(rawSymmwave, Symmcenter, 0)
		if(xpnt>=xsize-xpnt-1)
			make/O/N=(2*xpnt+1,ysize) Symmwave
			Symmwave=0
			symmxoff=xoff
			setscale/P x, symmxoff, xdelta, "", Symmwave
			setscale/P y, yoff, ydelta, "", Symmwave
			Symmwave[0,xsize-1][]=rawSymmwave[p][q]
			Symmwave[2*xpnt-xsize+1,2*xpnt][]+=rawSymmwave[2*xpnt-p][q]
			//Symmwave[2*xpnt-xsize+1,xsize-1][]/=2
		else
			make/O/N=(2*(xsize-1-xpnt)+1,ysize) Symmwave
			Symmwave=0
			symmxoff=2*Symmcenter-IndextoScale(rawSymmwave, xsize-1, 0)
			setscale/P x, symmxoff, xdelta, "", Symmwave
			setscale/P y, yoff, ydelta, "", Symmwave
			Symmwave[0,xsize-1][]=rawSymmwave[xsize-1-p][q]
			Symmwave[xsize-1-2*xpnt,2*(xsize-1-xpnt)][]+=rawSymmwave[p-(-2*xpnt+xsize-1)][q]
			//Symmwave[xsize-1-2*xpnt,xsize-1][]/=2
		endif
	endif
	
	if(stringmatch(symmdirection,"Y")==1)
		if(Symmcenter<yoff || Symmcenter>yoff+(ysize-1)*ydelta)
			Abort "Please set Symmetry center in the y range!"
		endif
		
		variable ypnt=ScaletoIndex(rawSymmwave, Symmcenter, 1)
		if(ypnt>=ysize-ypnt-1)
			make/O/N=(xsize,2*ypnt+1) Symmwave
			Symmwave=0
			symmyoff=yoff
			setscale/P x, xoff, xdelta, "", Symmwave
			setscale/P y, Symmyoff, ydelta, "", Symmwave
			Symmwave[][0,ysize-1]=rawSymmwave[p][q]
			Symmwave[][2*ypnt-ysize+1,2*ypnt]+=rawSymmwave[p][2*ypnt-q]
			//Symmwave[][2*ypnt-ysize+1,ysize-1]/=2
		else
			make/O/N=(xsize,2*(ysize-1-ypnt)+1) Symmwave
			Symmwave=0
			symmyoff=2*Symmcenter-IndextoScale(rawSymmwave, ysize-1, 1)
			setscale/P x, xoff, xdelta, "", Symmwave
			setscale/P y, Symmyoff, ydelta, "", Symmwave
			Symmwave[][0,ysize-1]=rawSymmwave[p][ysize-1-q]
			Symmwave[][ysize-1-2*ypnt,2*(ysize-1-ypnt)]+=rawSymmwave[p][q-(-2*ypnt+ysize-1)]
			//Symmwave[][ysize-1-2*ypnt,ysize-1]/=2
		endif
	endif
	
	dowindow/f SymmetryImageplotwindow	
	if (V_flag!=1)
		Display /W=(245,122,635,514);
		dowindow/c SymmetryImageplotwindow
		AppendImage Symmwave
		ModifyGraph mirror=1
		ModifyGraph minor=1, TICK=2
		ModifyGraph/Z font="Arial",fSize=16
		ModifyGraph standoff=0
		ModifyGraph axThick=2
		ModifyImage Symmwave ctab= {*,*,Grays,1}
		ModifyGraph margin(left)=70,margin(bottom)=56,margin(right)=28,margin(top)=28
	endif	
End

Function PopMenuProc_symmimagecolor(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	wave M_colors
	colortab2wave $popStr
	duplicate/O M_colors symmimagecolortab
	Symmimagecolorsetfunc() 
End

Function CheckProc_symmimageplotcheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	variable/g symmimageplotcheck=checked
	Symmimagecolorsetfunc()
End

Function Symmimagecolorsetfunc()
	wave Symmimagecolortab, Symmwave, multifoldwave
	variable/g symmimageplotcheck
	if(waveexists(Symmwave)==1)
	dowindow/f SymmetryImageplotwindow
	if(V_flag==0)
		Print "Show the symmetrized image first!"
	else
		ModifyImage Symmwave ctab={*,*,symmimagecolortab,symmimageplotcheck}
	endif
	endif
	
	if(waveexists(multifoldwave)==1)
	dowindow/f multifoldSymmetryplot
	if(V_flag==0)
		Print "Show the multi-symmetrized image first!"
	else
		ModifyImage multifoldwave ctab={*,*,symmimagecolortab,symmimageplotcheck}
	endif
	endif
End

Function ButtonProc_1Dtracelistget(ctrlName) : ButtonControl
	String ctrlName
	String tracelistname
	variable tracelistnum, i
	wave/T symmtracelistwave 
	wave symmtraceselwave
	tracelistname=tracenamelist("",";",1)
	if(stringmatch(tracelistname,"")==1)
		Abort "No traces in the top graph!"
	endif
	tracelistnum=itemsinlist(tracelistname)
	redimension/N=(tracelistnum) symmtracelistwave
	redimension/N=(tracelistnum) symmtraceselwave
	make/O/T/N=(tracelistnum) symmtracexlistwave
	for(i=0; i<tracelistnum; i+=1)
		symmtracelistwave[i]=stringfromlist(i, tracelistname)
		symmtracexlistwave[i]=XWaveName("",stringfromlist(i, tracelistname))
	endfor
End

Function ButtonProc_1Dtracesymmetry(ctrlName) : ButtonControl
	String ctrlName
	wave/T symmtracelistwave, symmtracexlistwave
	wave symmtraceselwave
	String namexwave, nameywave, symmyname, symmxname
	variable/g traceSymmcenter
	variable tracelistnum, tracesymmpnt, i, j, size
	tracelistnum=numpnts(symmtracelistwave)
	dowindow/f Symmtraceplot	
	if(V_flag==0)
		Display/W=(500,200,1000,600) /N=Symmtraceplot
	else
		string traceplotlist=tracenamelist("Symmtraceplot",";",1)
		variable plotnum=itemsinlist(traceplotlist)
		for(j=0; j<plotnum; j+=1)
			Removefromgraph/W=Symmtraceplot $StringFromList(j, traceplotlist)   
		endfor
	endif
	
	for(i=0; i<tracelistnum; i+=1)
		if(symmtraceselwave[i]!=0)
			namexwave=symmtracexlistwave[i]
			nameywave=symmtracelistwave[i]
			wave xwave=$namexwave, ywave=$nameywave
			if(traceSymmcenter>=wavemax(xwave)|| traceSymmcenter<=wavemin(xwave))
				Abort "Please set symmetry center within the x range of traces!"
			endif
			symmxname=namexwave+"symm"
			symmyname=nameywave+"symm"
			tracesymmpnt=floor((traceSymmcenter-xwave[0])/(xwave[1]-xwave[0]))
			size=numpnts($namexwave)
			if(tracesymmpnt>=size-tracesymmpnt-1)
				make/O/N=(2*tracesymmpnt+1) $symmxname, $symmyname
				wave symmxwave=$symmxname, symmywave=$symmyname
				symmxwave=0; symmywave=0
				symmxwave[]=xwave[0]+p*(xwave[1]-xwave[0])
				symmywave[0,size-1]=ywave[p]
				symmywave[2*tracesymmpnt-size+1, 2*tracesymmpnt]+=ywave[2*tracesymmpnt-p]
				//symmywave[2*tracesymmpnt-size+1,size-1]/=2
			else
				make/O/N=(2*(size-1-tracesymmpnt)+1) $symmxname, $symmyname
				wave symmxwave=$symmxname, symmywave=$symmyname
				symmxwave=0; symmywave=0
				symmxwave[]=xwave[size-1]+(p-2*(size-1-tracesymmpnt))*(xwave[1]-xwave[0])
				symmywave[0,size-1]=ywave[size-1-p]
				symmywave[size-1-2*tracesymmpnt, 2*(size-tracesymmpnt-1)]+=ywave[p-(size-1-2*tracesymmpnt)]
				//symmywave[size-1-2*tracesymmpnt,size-1]/=2
			endif
			AppendtoGraph/W=Symmtraceplot symmywave vs symmxwave
		endif
	endfor
	ModifyGraph tick=2,mirror=1,fSize=16,standoff=0,fStyle=1,lsize=2,axThick=2,font="Arial"
	ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28
End

Function SetVarProc_symmtracesmooth(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g symmtracesmooth=varNum
	Symmtracesmoothfunc()
End

Function Symmtracesmoothfunc()
	dowindow/f Symmtraceplot
	if(V_flag==0)
		Abort "Please show symmetry trace window first!"
	endif
	string displaylist=tracenamelist("",";",1)
	variable plotnum=itemsinlist(displaylist), j
	variable/g symmtracesmooth
	for(j=0; j<plotnum; j+=1)
		Smooth symmtracesmooth, $stringfromlist(j, displaylist) 
	endfor
End

Function SetVarProc_symmtraceoffset(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g symmtraceoffset=varNum
	Symmtraceoffsetfunc()
End

Function Symmtraceoffsetfunc()
 	dowindow/f Symmtraceplot
	if(V_flag==0)
		Abort "Please show symmetry trace window first!"
	endif
	string displaylist=tracenamelist("",";",1)
	variable plotnum=itemsinlist(displaylist), j
	variable/g symmtraceoffset
	for(j=0; j<plotnum; j+=1)
		ModifyGraph offset($stringfromlist(j, displaylist))={0,symmtraceoffset*j}
	endfor
End

Function SetVarProc_Symmtracelsize(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	dowindow/f Symmtraceplot
	if(V_flag==0)
		Abort "Please show symmetry trace window first!"
	endif
	ModifyGraph/W=Symmtraceplot/Z lsize=varNum
End

Function PopMenuProc_Symmtracecolor(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	dowindow/f Symmtraceplot
	if(V_flag==0)
		Abort "Please show symmetry trace window first!"
	endif
	controlinfo/w=Symmpanel popup3
	ModifyGraph/Z/W=Symmtraceplot/Z rgb=(V_Red, V_Green, V_Blue)
End

Function PopMenuProc_foldnum(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable/g symmfoldnum=str2num(popStr)
End

Function ButtonProc_multifoldsymmetry(ctrlName) : ButtonControl
	String ctrlName
	wave rawSymmwave
	variable/g symmfoldnum, i
	duplicate/O rawSymmwave multifoldwave
	multifoldwave=0
	variable rotation=2*pi/symmfoldnum
	for(i=0; i<symmfoldnum; i+=1)
		multifoldwave[][]+=rawSymmwave(pnt2x(rawSymmwave,p)*cos(-i*rotation)-pnt2x(rawSymmwave,q)*sin(-i*rotation))(pnt2x(rawSymmwave,p)*sin(-i*rotation)+pnt2x(rawSymmwave,q)*cos(-i*rotation))
	endfor
	
	dowindow/f multifoldSymmetryplot
	if (V_flag!=1)
		Display /W=(245,122,635,514);
		dowindow/c multifoldSymmetryplot
		AppendImage multifoldwave
		ModifyGraph mirror=1
		ModifyGraph minor=1, TICK=2
		ModifyGraph/Z font="Arial",fSize=16
		ModifyGraph standoff=0, zero=4
		ModifyGraph axThick=2
		ModifyImage multifoldwave ctab= {*,*,Grays,1}
		ModifyGraph margin(left)=70,margin(bottom)=56,margin(right)=28,margin(top)=28
		Label bottom "\\F'Arial'\\Z24\\f00 k\\Bx\\M\\F'Arial'\\Z24 (π/a)"
		Label left "\\F'Arial'\\Z24\\f00 k\\By\\M\\F'Arial'\\Z24 (π/a)"
	endif	
End

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////DrawPanel///////////////////////////////////////////////////////////
Function ButtonProc_DrawPanel(ctrlName) : ButtonControl
	String ctrlName
	dowindow/f DrawPanelmacro
	if(V_flag!=1)
		Execute "DrawPanelmacro()"
	endif
End

Window DrawPanelmacro() : Panel
	PauseUpdate; Silent 1		// building window...
	variable/g DrawInterpX=1, DrawInterpY=1
	string/g DrawMapName=""
	variable/g DrawImagegamma=1, DrawImageinvertcheck=1, DrawImagekoff=0
	NewPanel /W=(1300,100,1580,300)
	ModifyPanel cbRGB=(57568,65535,49087)
	Button button0,pos={9.00,11.00},size={50.00,30.00},proc=ButtonProc_Drawline,title="Draw"
	Button button0,font="Times New Roman",fSize=16,fStyle=1
	Button button1,pos={69.00,11.00},size={50.00,30.00},proc=ButtonProc_Eraseline,title="Erase"
	Button button1,font="Times New Roman",fSize=16,fStyle=1
	SetVariable setvar0,pos={148.00,12.00},size={90.00,22.00},title="InterpX"
	SetVariable setvar0,font="Times New Roman",fSize=16
	SetVariable setvar0,limits={0,inf,1},value= DrawInterpX
	SetVariable setvar1,pos={148.00,42.00},size={90.00,22.00},title="InterpY"
	SetVariable setvar1,font="Times New Roman",fSize=16
	SetVariable setvar1,limits={0,inf,1},value= DrawInterpY
	Button button2,pos={6.00,64.00},size={90.00,30.00},proc=ButtonProc_Showdrawcut,title="Show Cut"
	Button button2,font="Times New Roman",fSize=16,fStyle=1
	SetVariable setvar2,pos={106.00,68.00},size={170.00,22.00},title="MapName"
	SetVariable setvar2,font="Times New Roman",fSize=16
	SetVariable setvar2,limits={0,0,0},value= DrawMapName
	PopupMenu popup0,pos={10.00,110.00},size={120.00,21.00},bodyWidth=120,proc=PopMenuProc_DrawImagecolor
	PopupMenu popup0,font="Times New Roman",fSize=16
	PopupMenu popup0,mode=1,value= #"\"*COLORTABLEPOP*\""
	CheckBox check0,pos={140.00,110.00},size={50.00,19.00},proc=CheckProc_DrawImageinvertcheck,title="Invert"
	CheckBox check0,font="Times New Roman",fSize=16,value= 1,side= 1
	SetVariable setvar3,pos={201.00,110.00},size={60.00,22.00},proc=SetVarProc_DrawImage,title="γ"
	SetVariable setvar3,font="Times New Roman",fSize=16
	SetVariable setvar3,limits={0.1,inf,0.1},value= DrawImagegamma
	SetVariable setvar4,pos={100.00,140.00},size={90.00,22.00},proc=SetVarProc_DrawImagekoffset,title="k offset"
	SetVariable setvar4,font="Times New Roman",fSize=16
	SetVariable setvar4,limits={-inf,inf,0},value= DrawImagekoff
	Button button3,pos={10.00,140.00},size={80.00,30.00},proc=ButtonProc_DrawImageNewGraph,title="NewGraph"
	Button button3,font="Times New Roman",fSize=16,fStyle=1
EndMacro

Function ButtonProc_Drawline(ctrlName) : ButtonControl
	String ctrlName
	dowindow/f NewMapwindow
	if(V_flag!=1)
		Abort "Please show NewMapwindow first!"
	endif
	Graphwavedraw/w=NewMapwindow/O/L=zLaxis/B=zBaxis DrawY, DrawX
End

Function ButtonProc_Eraseline(ctrlName) : ButtonControl
	String ctrlName
	string waveAll, Item
	variable Itemtotal,i 
	dowindow/f NewMapwindow
	if(V_flag!=1)
		Abort "Please show NewMapwindow first!"
	endif
	   waveAll = TraceNameList("NewMapwindow",";",1)
      Itemtotal = ItemsInList(waveAll, ";")
	for (i=0 ; i<Itemtotal; i+=1)
		Item = StringFromList(i, waveAll)
		if (stringmatch(Item,"DrawY"))
			removefromgraph/w=NewMapwindow DrawY
		endif
	endfor
End


Function ButtonProc_Showdrawcut(ctrlName) : ButtonControl
	String ctrlName
	variable kdistance, dx, dy, num, cutdim, cutwavedim, i
	variable xoff, xdelta, xdim, yoff, ydelta, ydim, zoff, zdelta, zdim
	variable/g DrawInterpX, DrawInterpY
	string/g cubicmapname, DrawMapName
	string waveAll
	wave threeDmap, DrawY, DrawX
	
	waveAll = TraceNameList("NewMapwindow",";",1)
   if (stringmatch(waveAll,"*DrawY*")!=1)
   		Abort "Draw line first on NewMapwindow first!"
   endif
   DrawMapName=cubicmapname
   xoff=dimoffset(threeDmap,0); xdelta=dimdelta(threeDmap,0); xdim=dimsize(threeDmap,0)
   yoff=dimoffset(threeDmap,1); ydelta=dimdelta(threeDmap,1); ydim=dimsize(threeDmap,1)
   zoff=dimoffset(threeDmap,2); zdelta=dimdelta(threeDmap,2); zdim=dimsize(threeDmap,2)
   ImageInterpolate/F={DrawInterpX,DrawInterpY}/DEST=DrawMapInterp bilinear, threeDmap
   setscale/P x, xoff, xdelta/DrawInterpX,"", DrawMapInterp
   setscale/P y, yoff, ydelta/DrawInterpY,"", DrawMapInterp
   setscale/P z, zoff, zdelta,"", DrawMapInterp
   
   num=numpnts(DrawX); kdistance=0; cutwavedim=0
   for(i=0; i<num-1; i+=1)
   kdistance += sqrt( (DrawX[i+1]-DrawX[i])^2+(DrawY[i+1]-DrawY[i])^2 )
	dx=abs(ScaletoIndex(DrawMapInterp,DrawX[i+1],0)-ScaletoIndex(DrawMapInterp,DrawX[i],0))
	dy=abs(ScaletoIndex(DrawMapInterp,DrawY[i+1],1)-ScaletoIndex(DrawMapInterp,DrawY[i],1))
	if(dx>=dy)
		cutdim=dx
		make/O/N=(zdim,cutdim) temp
		if(DrawX[i]<=DrawX[i+1])	
			temp[][]=DrawMapInterp[q+ScaletoIndex(DrawMapInterp,DrawX[i],0)][(DrawY[i+1]-DrawY[i])/(DrawX[i+1]-DrawX[i])*q+ScaletoIndex(DrawMapInterp,DrawY[i],1)][p]
		else
			temp[][]=DrawMapInterp[-q+ScaletoIndex(DrawMapInterp,DrawX[i],0)][(DrawY[i+1]-DrawY[i])/(DrawX[i+1]-DrawX[i])*(-q)+ScaletoIndex(DrawMapInterp,DrawY[i],1)][p]
		endif	
	else
		cutdim=dy
		make/O/N=(zdim,cutdim) temp
		if(DrawY[i]<=DrawY[i+1])
			temp[][]=DrawMapInterp[(DrawX[i+1]-DrawX[i])/(DrawY[i+1]-DrawY[i])*q+ScaletoIndex(DrawMapInterp,DrawX[i],0)][q+ScaletoIndex(DrawMapInterp,DrawY[i],1)][p]
		else
			temp[][]=DrawMapInterp[(DrawX[i+1]-DrawX[i])/(DrawY[i+1]-DrawY[i])*(-q)+ScaletoIndex(DrawMapInterp,DrawX[i],0)][-q+ScaletoIndex(DrawMapInterp,DrawY[i],1)][p]
		endif
	endif
	cutwavedim+=cutdim
	duplicate/O temp $"temp"+num2str(i)
	endfor

	make/O/N=(zdim,cutwavedim) DrawImage
	SetScale/I y 0,kdistance,"", DrawImage
	SetScale/P x zoff, zdelta, "", DrawImage
	cutwavedim=0
	for(i=0; i<num-1; i+=1)
		wave cutwave=$"temp"+num2str(i)
		DrawImage[][cutwavedim,cutwavedim+dimsize(cutwave,1)-1]=cutwave[p][q-cutwavedim]
		cutwavedim+=dimsize(cutwave,1)
		killwaves cutwave
	endfor
	killwaves temp, DrawMapInterp
	DrawImageplot()
End

Function DrawImageplot()
	wave DrawImage
	dowindow/f DrawImageGraph
	if(V_flag!=1)
		display/W=(279,112,683,496); 
  		dowindow/c DrawImageGraph
		AppendImage DrawImage
	endif
	
	ModifyGraph swapXY=1
	ModifyGraph margin(left)=70,margin(bottom)=70,margin(right)=28,margin(top)=28,height=340.157
	ModifyGraph fSize=16,font="Arial"
	ModifyGraph zero=4,standoff=0,tick=2,mirror=1
	ModifyGraph axThick=2
	Label left "\\F'Arial'\\Z24\\f02E-E\\BF\\M\\F'Arial'\\Z24\\f00 (eV)"
	Label bottom "\\F'Arial'\\Z24 k\\B//\\M\\F'Times New Roman'\\Z24 (Å\\S-1\\M\\F'Arial'\\Z24)"
	DrawImagecolorsetfunc()
End

Function PopMenuProc_DrawImagecolor(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	String/g DrawImagecolor=popStr	
	colortab2wave $DrawImagecolor
	DrawImagecolorsetfunc()
End

Function SetVarProc_DrawImage (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g DrawImagegamma=varNum
	DrawImagecolorsetfunc()
End


Function CheckProc_DrawImageinvertcheck(ctrlName,checked) : CheckBoxControl 
	String ctrlName
	Variable checked
	variable/g DrawImageinvertcheck=checked
	DrawImagecolorsetfunc()
End

Function DrawImagecolorsetfunc()
	String/g DrawImagecolor
	variable/g DrawImagegamma, DrawImageinvertcheck
	variable size
	wave M_colors, DrawImage, DrawImagecolortab
	duplicate/O M_colors DrawImagecolortab
	size=dimsize(DrawImagecolortab,0)
	DrawImagecolortab[][]=M_colors[size*(p/size)^(DrawImagegamma)][q]

	if(DrawImageinvertcheck == 1)
      ModifyImage/Z DrawImage ctab={*,*,DrawImagecolortab,1}
   else
      ModifyImage/Z DrawImage ctab={*,*,DrawImagecolortab,0}
   endif
End

Function ButtonProc_DrawImageNewGraph(ctrlName) : ButtonControl
	String ctrlName
	String newimagename
	wave DrawImage, DrawImagecolortab
	variable/g DrawImageinvertcheck
	prompt newimagename, "Please enter the new image name:"
	doprompt "", newimagename
	if(V_flag)
		return -1 //user cancel
	endif
	
	duplicate/O DrawImage $newimagename
	Display; Delayupdate
	AppendImage $newimagename
	ModifyGraph swapXY=1
	ModifyGraph margin(left)=70,margin(bottom)=70,margin(right)=28,margin(top)=28,height=340.157
	ModifyGraph fSize=16,font="Arial"
	ModifyGraph zero(left)=4,standoff=0,tick=2,mirror=1
	ModifyGraph axThick=2
	Label left "\\F'Arial'\\Z24\\f02E-E\\BF\\M\\F'Arial'\\Z24\\f00 (eV)"
	Label bottom "\\F'Arial'\\Z24 k\\B//\\M\\F'Times New Roman'\\Z24 (Å\\S-1\\M\\F'Arial'\\Z24)"
	if(DrawImageinvertcheck == 1)
      ModifyImage/Z $newimagename ctab={*,*,DrawImagecolortab,1}
   else
      ModifyImage/Z $newimagename ctab={*,*,DrawImagecolortab,0}
   endif
End

Function SetVarProc_DrawImagekoffset(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	wave DrawImage
	variable/g DrawImagekoff=varNum
	if(waveexists(DrawImage)==1)
		variable kdelta=dimdelta(DrawImage,1)
		setscale/P y 0-DrawImagekoff, kdelta, "", DrawImage
	endif
End

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////AnalysisPanel/////////////////////////////////////////////////
Function ButtonProc_AnalysisPanel(ctrlName) : ButtonControl
	String ctrlName
	dowindow/f AnalysisPanel
	if(V_flag!=1)
		Execute "AnalysisPanel()"
	endif
End

Window AnalysisPanel() : Panel
	variable/g analysistrackpoint=0, analysiswidth=0.01
	variable/g analysisinterval=0, analysisoffset=0
	variable/g analylistcheck=0
	string/g analysiswavename="", analysisfunc="LorOne"
	string/g analysistracktype="EDC"
	String/g analysisdispersionfunc="2"
	String/g analysisfitbg="None"
	String/g cutliststr=""
	make/O/T/N=0 cutlistwave

	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(1163,167,1418,519)
	SetDrawLayer UserBack
	SetDrawEnv linethick= 3
	DrawLine 0,96,255,96
	Button button0,pos={10.00,9.00},size={60.00,25.00},proc=ButtonProc_Analysisupdate,title="Update"
	Button button0,font="Times New Roman",fSize=16
	SetVariable setvar0,pos={84.00,10.00},size={160.00,22.00},title="cutname"
	SetVariable setvar0,font="Times New Roman",fSize=16
	SetVariable setvar0,limits={-inf,inf,0},value= analysiswavename
	SetVariable setvar1,pos={10.00,44.00},size={70.00,22.00},proc=SetVarProc_AnalysisEk,title="E/k"
	SetVariable setvar1,font="Times New Roman",fSize=16
	SetVariable setvar1,limits={-inf,inf,0},value= _NUM:0
	SetVariable setvar2,pos={90.00,43.00},size={101.00,22.00},proc=SetVarProc_Analysis_deltaEk,title="∆E/∆k"
	SetVariable setvar2,font="Times New Roman",fSize=16
	SetVariable setvar2,limits={0,inf,0.01},value= _NUM:0.01
	SetVariable setvar3,pos={10.00,70.00},size={95.00,22.00},proc=SetVarProc_Analysisinterval,title="Interval"
	SetVariable setvar3,font="Times New Roman",fSize=16
	SetVariable setvar3,limits={-inf,inf,0},value= _NUM:0
	SetVariable setvar4,pos={112.00,70.00},size={81.00,22.00},proc=SetVarProc_Analysistracknum,title="Num"
	SetVariable setvar4,font="Times New Roman",fSize=16
	SetVariable setvar4,limits={1,inf,1},value= _NUM:1
	PopupMenu popup0,pos={201.00,56.00},size={46.00,21.00},proc=PopMenuProc_Analysistracktype
	PopupMenu popup0,font="Times New Roman",fSize=16
	PopupMenu popup0,mode=1,popvalue="EDC",value= #"\"EDC;MDC\""
	Button button1,pos={7.00,153.00},size={70.00,30.00},proc=ButtonProc_Analysiscurvetrack,title="Track"
	Button button1,font="Times New Roman",fSize=16,fStyle=1
	PopupMenu popup1,pos={81.00,158.00},size={84.00,21.00},proc=PopMenuProc_analysisplotcolor,title="color"
	PopupMenu popup1,font="Times New Roman",fSize=16
	PopupMenu popup1,mode=1,popColor= (65535,0,0),value= #"\"*COLORPOP*\""
	SetVariable setvar5,pos={170.00,156.00},size={80.00,22.00},proc=SetVarProc_analysisplotlsize,title="size"
	SetVariable setvar5,font="Times New Roman",fSize=16
	SetVariable setvar5,limits={1,10,0.5},value= _NUM:1
	SetVariable setvar6,pos={172.00,181.00},size={78.00,22.00},proc=SetVarProc_analysisplotoffset,title="Offset"
	SetVariable setvar6,font="Times New Roman",fSize=16
	SetVariable setvar6,limits={-inf,inf,0},value= _NUM:0
	SetVariable setvar7,pos={81.00,180.00},size={88.00,22.00},proc=SetVarProc_analysisplotsmooth,title="Smooth"
	SetVariable setvar7,font="Times New Roman",fSize=16
	SetVariable setvar7,limits={0,inf,1},value= _NUM:0
	PopupMenu popup2,pos={77.00,221.00},size={97.00,21.00},proc=PopMenuProc_analysisfuncset,title="Func"
	PopupMenu popup2,font="Times New Roman",fSize=14
	PopupMenu popup2,mode=1,popvalue="LorOne",value= #"\"LorOne;LorTwo;LorFour;VoigtOne;VoigtTwo;GaussTwo;FermiDirac\""
	Button button2,pos={8.00,217.00},size={64.00,29.00},proc=ButtonProc_analysisfuncfit,title="Funcfit"
	Button button2,font="Times New Roman",fSize=16
	Button button3,pos={6.00,275.00},size={73.00,30.00},proc=ButtonProc_analysisdispersion,title="Dispersion"
	Button button3,font="Times New Roman",fSize=16
	PopupMenu popup3,pos={83.00,281.00},size={58.00,21.00},proc=PopMenuProc_analysisdisperfunc,title="peak"
	PopupMenu popup3,font="Times New Roman",fSize=14
	PopupMenu popup3,mode=2,popvalue="2",value= #"\"1;2;4\""
	Button button4,pos={183.00,218.00},size={66.00,25.00},proc=ButtonProc_analysisfitpeaksplit,title="Peaksplit"
	Button button4,font="Times New Roman",fSize=16
	Button button5,pos={8.00,308.00},size={91.00,30.00},proc=ButtonProc_analysisDividefermi,title="FermiDivide"
	Button button5,font="Times New Roman",fSize=16
	PopupMenu popup4,pos={78.00,250.00},size={129.00,21.00},proc=PopMenuProc_analysisfitbg,title="background"
	PopupMenu popup4,font="Times New Roman",fSize=16
	PopupMenu popup4,mode=1,popvalue="None",value= #"\"None;Linear;Cubic;exp1;exp2\""
	Button button6,pos={7.00,183.00},size={70.00,25.00},proc=ButtonProc_AnalysisOutput,title="Output"
	Button button6,font="Times New Roman",fSize=16
	Button button7,pos={150.00,277.00},size={60.00,25.00},proc=ButtonProc_MDCDispexport,title="Export"
	Button button7,font="Times New Roman",fSize=16
	Button button8 title="CutLists",font="Times New Roman",fSize=16
	Button button8 proc=ButtonProc_analysiscutlist, pos={10,110}, size={65,30}
	CheckBox check0,pos={83.00,113.00},size={62.00,19.00},title="listtrack"
	CheckBox check0,font="Times New Roman",fSize=16,value= 0,proc=CheckProc_analysislistcheck
	PopupMenu popup5 value=cutliststr,font="Times New Roman",fSize=16, pos={150,110} 

EndMacro

Function ButtonProc_Analysisupdate(ctrlName) : ButtonControl
	String ctrlName
	Analysisupdate()
End

Function Analysisupdate()
	wave curveplotwave
	string/g analysiswavename, NewImagename
	if(waveexists(curveplotwave)==1)
		duplicate/O curveplotwave Analysiswave
		analysiswavename=NewImagename
	else
		Abort "Please show cut in NewImagewindow first!"
	endif
End

Function SetVarProc_AnalysisEk(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g analysistrackpoint =varNum
End

Function SetVarProc_Analysis_deltaEk(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g analysiswidth=varNum
End

Function SetVarProc_Analysisinterval(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g analysisinterval=varNum
End

Function SetVarProc_Analysistracknum(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g analysistracknum=varNum
End

Function PopMenuProc_Analysistracktype(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	string/g analysistracktype=popStr
End

Function ButtonProc_analysiscutlist(ctrlName) : ButtonControl
	String ctrlName
	String cutliststr=wavelist("!*colors*", ";", "DIMS:2")
	
	NewPanel /W=(538,182,800,650)/N=cutlistwaveedit
	Button button0,pos={145.00,425.00},size={60.00,30.00},title="End"
	Button button0,font="Times New Roman",fSize=16,fStyle=1,proc=ButtonProc_cutlistwavebutton
	Button button1,pos={15.00,425.00},size={60.00,30.00},proc=ButtonProc_culistadd,title="Add"
	Button button1,font="Times New Roman",fSize=16
	Button button2,pos={80.00,425.00},size={60.00,30.00},proc=ButtonProc_culistremove,title="Remove"
	Button button2,font="Times New Roman",fSize=16
	Button button3,pos={205.00,430.00},size={30.00,20.00},proc=ButtonProc_cutlistall,title="All"
	Button button3,font="Times New Roman"
	PopupMenu popup0,pos={15.00,395.00},size={42.00,21.00},font="Times New Roman"
	PopupMenu popup0,fSize=16,mode=1,value=wavelist("!*colors*", ";", "DIMS:2")
	SetVariable setvar0,pos={147.00,398.00},title="filterstr",size={90.00,20.00},proc=SetVarProc_cutlistfilterstr
	SetVariable setvar0,font="Times New Roman",fSize=14,limits={-inf,inf,0},value=_STR:""
	Edit/W=(14,25,273,374)/HOST=#  cutlistwave
	ModifyTable format(Point)=1
	ModifyTable statsArea=85
	RenameWindow #,T0
	SetActiveSubwindow ##
	pauseforuser cutlistwaveedit
End


Function ButtonProc_culistadd(ctrlName) : ButtonControl
	String ctrlName
	controlinfo/W=cutlistwaveedit popup0
	string currentstr=S_value
	variable size=dimsize(cutlistwave,0)
	make/O/T/N=(size+1) cutlistwave
	cutlistwave[size+1]=currentstr
End

Function ButtonProc_culistremove(ctrlName) : ButtonControl
	String ctrlName
	variable startnum, denum
	prompt startnum, "Enter the num of points start to delete:"
	prompt denum, "Enter the num of points to delete:"
	doprompt "", startnum, denum
	if(V_flag)
		return -1
	endif
	Deletepoints startnum, denum, cutlistwave
End

Function ButtonProc_cutlistwavebutton(ctrlName) : ButtonControl
	String ctrlName
	String/g cutliststr
	wave/T cutlistwave
	variable size=dimsize(cutlistwave,0)
	variable i
	cutliststr=""
	killwindow cutlistwaveedit
	for(i=0; i<size; i+=1)
		cutliststr+=cutlistwave[i]+";"
	endfor
End

Function SetVarProc_cutlistfilterstr(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	string/g filstr=varStr
	PopupMenu popup0,value=cutlistfilter()
End

Function/S cutlistfilter()
	string/g filstr
	string fillist = wavelist("*"+filstr+"*", ";", "DIMS:2")
	return fillist
End


Function ButtonProc_cutlistall(ctrlName) : ButtonControl
	String ctrlName
	string liststr=cutlistfilter()
	variable num=itemsinlist(liststr)
	make/O/T/N=(num) cutlistwave
	variable i
	for(i=0; i<num; i+=1)
		cutlistwave[i]=stringfromlist(i,liststr)
	endfor
End



Function CheckProc_analysislistcheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	variable/g analylistcheck=checked
End


Function ButtonProc_Analysiscurvetrack(ctrlName) : ButtonControl
	String ctrlName
	wave Analysiswave
	wave/T cutlistwave
	variable/g analysistrackpoint, analysiswidth,  analysisinterval, analysistracknum, analylistcheck
	string/g analysistracktype
	variable xwavesize, xwavestart, xwavedelta, xstart, xend
	variable i, j, startindex, endindex

	if(analylistcheck==0)
		if(stringmatch(analysistracktype,"EDC")==1)
		xwavesize=dimsize(analysiswave,0)
		xwavestart=dimoffset(analysiswave,0)
		xwavedelta=dimdelta(analysiswave,0)
		else
		xwavesize=dimsize(analysiswave,1)
		xwavestart=dimoffset(analysiswave,1)
		xwavedelta=dimdelta(analysiswave,1)
		endif
		for(i=1; i<=analysistracknum; i+=1)
			make/N=(xwavesize)/O $"analyxwave"+num2str(i), $"analyywave"+num2str(i)
			wave xwave=$"analyxwave"+num2str(i)
			wave ywave=$"analyywave"+num2str(i)
			xwave[]=xwavestart+p*xwavedelta
			ywave[]=0
			xstart=analysistrackpoint+(i-1)*analysisinterval
			xend=xstart+analysiswidth
		if(stringmatch(analysistracktype,"EDC")==1)
			startindex=ScaletoIndex(analysiswave,xstart,1)
			endindex=ScaletoIndex(analysiswave,xend,1)
			if(startindex>endindex)
				startindex=ScaletoIndex(analysiswave,xend,1)
				endindex=ScaletoIndex(analysiswave,xstart,1)
			endif
			for(j=startindex; j<=endindex; j+=1)
				ywave[]+=analysiswave[p][j]
			endfor
		else
			startindex=ScaletoIndex(analysiswave,xstart,0)
			endindex=ScaletoIndex(analysiswave,xend,0)
			if(startindex>endindex)
				startindex=ScaletoIndex(analysiswave,xend,0)
				endindex=ScaletoIndex(analysiswave,xstart,0)
			endif
			for(j=startindex; j<=endindex; j+=1)
				ywave[]+=analysiswave[j][p]
			endfor
		endif
		endfor
	
	else
		for(i=1; i<=dimsize(cutlistwave,0); i+=1)
	
		wave currentwave=$cutlistwave[i-1]		
		if(waveexists(currentwave)==0)
			printf "The wave %s doesn't exists!\r"	, cutlistwave[i-1] 
		else
			if(stringmatch(analysistracktype,"EDC")==1)
				xwavesize=dimsize(currentwave,0)
				xwavestart=dimoffset(currentwave,0)
				xwavedelta=dimdelta(currentwave,0)
			else
				xwavesize=dimsize(currentwave,1)
				xwavestart=dimoffset(currentwave,1)
				xwavedelta=dimdelta(currentwave,1)
			endif
			make/N=(xwavesize)/O $"analyxwave"+num2str(i), $"analyywave"+num2str(i)
			wave xwave=$"analyxwave"+num2str(i)
			wave ywave=$"analyywave"+num2str(i)
			xwave[]=xwavestart+p*xwavedelta
			ywave[]=0
			xstart=analysistrackpoint+(i-1)*analysisinterval
			xend=xstart+analysiswidth
			if(stringmatch(analysistracktype,"EDC")==1)
			startindex=ScaletoIndex(currentwave,xstart,1)
			endindex=ScaletoIndex(currentwave,xend,1)
			if(startindex>endindex)
				startindex=ScaletoIndex(currentwave,xend,1)
				endindex=ScaletoIndex(currentwave,xstart,1)
			endif
			for(j=startindex; j<=endindex; j+=1)
				ywave[]+=currentwave[p][j]
			endfor
			else
			startindex=ScaletoIndex(currentwave,xstart,0)
			endindex=ScaletoIndex(currentwave,xend,0)
			if(startindex>endindex)
				startindex=ScaletoIndex(currentwave,xend,0)
				endindex=ScaletoIndex(currentwave,xstart,0)
			endif
			for(j=startindex; j<=endindex; j+=1)
				ywave[]+=currentwave[j][p]
			endfor
		endif
		endif
		endfor
	endif 
	analysiswaveplot()
End

Function analysiswaveplot()
	String analysisxwavelist, analysisywavelist
	wave/T cutlistwave
	variable/g analysistracknum, analylistcheck
	string/g analysistracktype
	variable i, numstack
	analysisxwavelist=wavelist("analyxwave*",";","DIMS:1")
	analysisywavelist=wavelist("analyywave*",";","DIMS:1")
	dowindow/f analysiswaveplotwin
	if(V_flag==0)
		Display/W=(500,200,800,600)/N=analysiswaveplotwin
		Showinfo/W=analysiswaveplotwin
	else
		string displaylist=wavelist("analyywave*",";","WIN:analysiswaveplotwin")
		variable displaynum=itemsinlist(displaylist)
		for(i=0; i<displaynum; i+=1)
			removefromgraph/W=analysiswaveplotwin/Z $stringfromlist(i, displaylist)
		endfor
	endif
	if(analylistcheck==0)
		numstack=analysistracknum
	else
		numstack=dimsize(cutlistwave,0)
	endif
	
	for(i=0; i<numstack; i+=1)
		wave xwave=$stringfromlist(i,analysisxwavelist)
		wave ywave=$stringfromlist(i,analysisywavelist)
		appendtograph/W=analysiswaveplotwin ywave vs xwave
	endfor
		ModifyGraph/Z tick=2
		ModifyGraph/Z mirror=1
		ModifyGraph/Z font="Arial"
		ModifyGraph/Z fSize=16
		ModifyGraph/Z fStyle=1
		ModifyGraph/Z standoff=0
		ModifyGraph/Z axThick=2
		ModifyGraph/Z zero(bottom)=4
		Label/Z left "\\F'Arial'\\Z24\f00Intensity (arb. units)"
		if(stringmatch(analysistracktype,"EDC")==1)
			Label/Z bottom "\\F'Arial'\\Z24\f02E-E\BF\M\F'Arial'\\Z24\f00 (eV)"
		else
			Label/Z bottom "\\F'Arial'\\Z24\f00k\B//\M\F'Times New Roman'\\Z24 (Å\S-1\M\F'Arial'\\Z24)"
		endif
  	ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28,width=453.543,height=340.157
End

Function SetVarProc_analysisplotlsize(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	ModifyGraph/W=analysiswaveplotwin/Z lsize=varNum
End

Function PopMenuProc_analysisplotcolor(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	controlinfo/w=Analysispanel popup1
	ModifyGraph/Z/W=analysiswaveplotwin/Z rgb=(V_Red, V_Green, V_Blue)
End

Function SetVarProc_analysisplotoffset(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable i
	variable/g analysisoffset=varNum
	string displaylist=wavelist("analyywave*",";","WIN:analysiswaveplotwin")
	variable displaynum=itemsinlist(displaylist)
	for(i=0; i<displaynum; i+=1)
		ModifyGraph/W=analysiswaveplotwin/Z offset($stringfromlist(i, displaylist))={0,i*analysisoffset}
	endfor
End

Function SetVarProc_analysisplotsmooth(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable i
	string displaylist=wavelist("analyywave*",";","WIN:analysiswaveplotwin")
	variable displaynum=itemsinlist(displaylist)
	for(i=0; i<displaynum; i+=1)
		Smooth varNum, $stringfromlist(i,displaylist)
	endfor
End

Function PopMenuProc_analysisfuncset(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	string/g analysisfunc=popStr
End

Function PopMenuProc_analysisfitbg(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	String/g analysisfitbg=popStr
End

Function ButtonProc_analysisfuncfit(ctrlName) : ButtonControl
	String ctrlName
	string/g analysisfunc, analysistracktype, analysisfitbg
	variable w_0, w_1, w_2, w_3, w_4, w_5, w_6, w_7, w_8, w_9, w_10, w_11, w_12
	variable pcsrA, pcsrB
	variable peaklevel
	make/O/T fitcwave1={"K0 > 0"}
	dowindow/f analysiswaveplotwin
	if(V_flag==0)
		Abort "Please show analysis traces first!"
	endif
	if (stringmatch(CsrWave(a,""),"") || stringmatch(CsrWave(b,""),"") ||stringmatch(Csrwave(a),Csrwave(b))==0)
       Abort "Set A and B cursors on the same trace!!"
  	endif
  	wave ywave=$Csrwave(A)
	wave xwave=$csrxwave(A)
	string fitwavename="fit_"+Csrwave(A)
	pcsrA=pcsr(A,"")
	pcsrB=pcsr(B,"")
	
	if(stringmatch(analysisfunc,"FermiDirac")==1)
		if(stringmatch(analysistracktype,"EDC")!=1)
			Abort "Please perform FermiDirac fit to EDC!"
		endif
		make/O/N=5 FDfitcoeff
		prompt w_0, "The fit function reads f=A+(B+C(x-Ef))/(exp(-(x-Ef)/kBT)+1). The background A:" 
		Prompt w_1, "Height of curve B:"
		Prompt w_2, "Fermi energy Ef(eV):"
		Prompt w_3, " kBT (meV):"
		prompt w_4, "the linear correct C:"
  		doprompt "", w_0, w_1, w_2, w_3, w_4
  		if(V_flag)
  			return -1  //user cancel
 	 	endif
 	 	FDfitcoeff={w_0, w_1, w_2, w_3/1000, w_4}
 	 	if(stringmatch(analysisfitbg,"None")==1)
 	 		FuncFit/q FermiDiracfitfunction FDfitcoeff ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 	elseif(stringmatch(analysisfitbg,"Linear")==1)
 	 		make/O/N=1 linearbgcoeff
 	 		linearbgcoeff={1}
 	 		FuncFit/q {{FermiDiracfitfunction, FDfitcoeff},{linear_bg, linearbgcoeff}} ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 	elseif(stringmatch(analysisfitbg,"Cubic")==1)
 	 		make/O/N=3 cubicbgcoeff
 	 		cubicbgcoeff={1,1,1}
 	 		FuncFit/q {{FermiDiracfitfunction, FDfitcoeff},{cubic_bg, cubicbgcoeff}} ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 	elseif(stringmatch(analysisfitbg,"exp1")==1)
 	 		make/O/N=2 exp1bgcoeff
 	 		exp1bgcoeff={1,1}
 	 		FuncFit/q {{FermiDiracfitfunction, FDfitcoeff},{exp1_bg, exp1bgcoeff}} ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 	elseif(stringmatch(analysisfitbg,"exp2")==1)
 	 		make/O/N=4 exp2bgcoeff
 	 		exp2bgcoeff={1,1,1,1}
 	 		FuncFit/q {{FermiDiracfitfunction, FDfitcoeff},{exp2_bg, exp2bgcoeff}} ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 	endif
 	 	wave W_sigma
 	 	duplicate/O W_sigma FermiDiracdelta
  		printf "The fermi level is %g±%g eV;\rThe kBT is %g±%g meV;\rThe linear correct is %g±%g\r", FDfitcoeff[2],FermiDiracdelta[2],FDfitcoeff[3]*1000,FermiDiracdelta[3]*1000,FDfitcoeff[4],W_sigma[4]
	endif
	
	if(stringmatch(analysisfunc,"LorOne")==1)
		make/O/N=4 Lorfitcoeff
		duplicate/O ywave, temp
		setscale/P x, xwave[0], xwave[1]-xwave[0], temp
		peaklevel=(wavemax(temp,xwave(pcsrA),xwave(pcsrB))*2+wavemin(temp,xwave(pcsrA),xwave(pcsrB))*3)/5
		findpeak/Q/B=3/M=(peaklevel)/R=(xwave[pcsrA],xwave[pcsrB]) temp
		w_0=wavemin(temp,xwave(pcsrA),xwave(pcsrB))
		if(V_flag==0)
			w_1=V_PeakVal
			w_2=V_PeakLoc
			w_3=V_PeakWidth
		else
			w_1=0
			w_2=0
			w_3=0
		endif
		prompt w_0, "The fit function reads f=A+h1/((x-p1)^2+d1^2). The background A:" 
  		Prompt w_1, "Peak1 height h1:"
  		Prompt w_2, "Peak1 position p1(1/Å):" 
  		Prompt w_3, "Peak1 width d1(1/Å):"
  		doprompt "", w_0, w_1, w_2, w_3
  		if(V_flag)
   			return -1  //user cancel
  		endif
  	
  		if(stringmatch(analysisfitbg,"None")==1)
  			Lorfitcoeff={w_0, w_1*w_3^2, w_2, w_3}
  			FuncFit/q onepeaklorfunction Lorfitcoeff ywave[pcsrA,pcsrB] /X=xwave /D/C=fitcwave1
  		elseif(stringmatch(analysisfitbg,"Linear")==1)
  			Lorfitcoeff={w_0, w_1*w_3^2, w_2, w_3, 1}
 	 		FuncFit/q onepeaklorfunction_slope Lorfitcoeff ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 		make/O/N=100 linbg
 	 		setscale/I x, xwave[xcsr(A)], xwave[xcsr(B)], linbg
 	 		linbg=Lorfitcoeff[0]+Lorfitcoeff[4]*x
 	 		duplicate/O linbg, bgcurve
 	 	elseif(stringmatch(analysisfitbg,"Cubic")==1)
 	 		Lorfitcoeff={w_0, w_1*w_3^2, w_2, w_3, 1,1,1}
 	 		FuncFit/q onepeaklorfunction_cubic Lorfitcoeff ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 		make/O/N=100 cubicbg
 	 		setscale/I x, xwave[xcsr(A)], xwave[xcsr(B)], cubicbg
 	 		cubicbg=Lorfitcoeff[0]+Lorfitcoeff[4]*x+Lorfitcoeff[5]*x^2+Lorfitcoeff[6]*x^3
 	 		duplicate/O cubicbg, bgcurve
 	 	elseif(stringmatch(analysisfitbg,"exp1")==1)
 	 		make/O/N=2 exp1bgcoeff
 	 		exp1bgcoeff={1,1}
 	 		FuncFit/q {{onepeaklorfunction, Lorfitcoeff},{exp1_bg, exp1bgcoeff}} ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 		make/O/N=100 exp1bg
 	 		setscale/I x, xwave[xcsr(A)], xwave[xcsr(B)], exp1bg
 	 		exp1bg=exp1bgcoeff[0]*e^(x/exp1bgcoeff[1])*x
 	 		duplicate/O exp1bg, bgcurve
 	 	elseif(stringmatch(analysisfitbg,"exp2")==1)
 	 		make/O/N=4 exp2bgcoeff
 	 		exp2bgcoeff={1,1,1,1}
 	 		FuncFit/q {{onepeaklorfunction, Lorfitcoeff},{exp2_bg, exp2bgcoeff}} ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
  		endif
  		wave W_sigma
  		duplicate/O W_sigma, Lordelta
  		printf "The peak position is %g±%g; the peak width is %g±%g\r", Lorfitcoeff[2], Lordelta[2], Lorfitcoeff[3], Lordelta[3]
	endif
	
	if(stringmatch(analysisfunc,"LorTwo")==1)
		make/O/N=7 Lortwopeakfitcoeff
		duplicate/O ywave, temp
		setscale/P x, xwave[0], xwave[1]-xwave[0], temp
		peaklevel=(wavemax(temp,xwave(pcsrA),xwave(pcsrB))*2+wavemin(temp,xwave(pcsrA),xwave(pcsrB))*3)/5
		findpeak/Q/B=3/M=(peaklevel)/R=(xwave[pcsrA],xwave[pcsrB]) temp
		w_0=wavemin(temp,xwave(pcsrA),xwave(pcsrB))
		if(V_flag==0)
			w_1=V_PeakVal
			w_2=V_PeakLoc
			w_3=V_PeakWidth
		else
			w_1=0
			w_2=0
			w_3=0
		endif
		findpeak/Q/B=3/M=(peaklevel)/R=(w_2+w_3/2,xwave[pcsrB]) temp
		if(V_flag==0)
			w_4=V_PeakVal
			w_5=V_PeakLoc
			w_6=V_PeakWidth
		else
			w_4=0
			w_5=0
			w_6=0
		endif			
		prompt w_0, "The fit function reads f=A+h1/((x-p1)^2+d1^2)+h2/((x-p2)^2+d2^2). The background A:" 
  		Prompt w_1, "Peak1 height h1:"
  		Prompt w_2, "Peak1 position p1(1/Å):" 
  		Prompt w_3, "Peak1 width d1(1/Å):"
  		Prompt w_4, "Peak2 height h2:"
  		Prompt w_5, "Peak2 position p2(1/Å):" 
  		Prompt w_6, "Peak2 width d2(1/Å):"
  		doprompt "", w_0, w_1, w_2, w_3, w_4, w_5, w_6
  		if(V_flag)
   			return -1  //user cancel
  		endif
  	
  		
  		if(stringmatch(analysisfitbg,"None")==1)
  			Lortwopeakfitcoeff={w_0, w_1*w_3^2, w_2, w_3, w_4*w_6^2, w_5, w_6}
  			FuncFit/q twopeaklorfunction Lortwopeakfitcoeff ywave[pcsrA,pcsrB] /X=xwave /D/C=fitcwave1
  		elseif(stringmatch(analysisfitbg,"Linear")==1)
  			Lortwopeakfitcoeff={w_0, w_1*w_3^2, w_2, w_3, w_4*w_6^2, w_5, w_6, 1}
 	 		FuncFit/q twopeaklorfunction_slope Lortwopeakfitcoeff ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 		make/O/N=100 linbg
 	 		setscale/I x, xwave[xcsr(A)], xwave[xcsr(B)], linbg
 	 		linbg=Lortwopeakfitcoeff[0]+Lortwopeakfitcoeff[7]*x
 	 		duplicate/O linbg, bgcurve
 	 	elseif(stringmatch(analysisfitbg,"Cubic")==1)
 	 		Lortwopeakfitcoeff={w_0, w_1*w_3^2, w_2, w_3, w_4*w_6^2, w_5, w_6, 1, 1, 1}
 	 		FuncFit/q twopeaklorfunction_cubic Lortwopeakfitcoeff ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 		make/O/N=100 cubicbg
 	 		setscale/I x, xwave[xcsr(A)], xwave[xcsr(B)], cubicbg
 	 		cubicbg= Lortwopeakfitcoeff[0]+ Lortwopeakfitcoeff[7]*x+ Lortwopeakfitcoeff[8]*x^2+ Lortwopeakfitcoeff[9]*x^3
 	 		duplicate/O cubicbg, bgcurve
 	 	elseif(stringmatch(analysisfitbg,"exp1")==1)
 	 		make/O/N=2 exp1bgcoeff
 	 		exp1bgcoeff={1,1}
 	 		FuncFit/q {{twopeaklorfunction, Lortwopeakfitcoeff},{exp1_bg, exp1bgcoeff}} ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 		make/O/N=100 exp1bg
 	 		setscale/I x, xwave[xcsr(A)], xwave[xcsr(B)], exp1bg
 	 		exp1bg=exp1bgcoeff[0]*e^(x/exp1bgcoeff[1])*x
 	 		duplicate/O exp1bg, bgcurve
 	 	elseif(stringmatch(analysisfitbg,"exp2")==1)
 	 		make/O/N=4 exp2bgcoeff
 	 		exp2bgcoeff={1,1,1,1}
 	 		FuncFit/q {{twopeaklorfunction, Lortwopeakfitcoeff},{exp2_bg, exp2bgcoeff}} ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
  		endif
  		wave W_sigma
  		duplicate/O W_sigma, Lortwopeakdelta
  		printf "The peak1 position p1 is %g±%g ; the peak1 width d1 is %g±%g \r", Lortwopeakfitcoeff[2], Lortwopeakdelta[2], Lortwopeakfitcoeff[3], Lortwopeakdelta[3]
  		printf "The peak2 position p2 is %g±%g ; the peak2 width d2 is %g±%g \r", Lortwopeakfitcoeff[5], Lortwopeakdelta[5], Lortwopeakfitcoeff[6], Lortwopeakdelta[6]
	endif
	
	if(stringmatch(analysisfunc,"LorFour")==1)
		make/O/N=13 Lorfourpeakfitcoeff
		duplicate/O ywave, temp
		setscale/P x, xwave[0], xwave[1]-xwave[0], temp
		peaklevel=(wavemax(temp,xwave(pcsrA),xwave(pcsrB))*2+wavemin(temp,xwave(pcsrA),xwave(pcsrB))*3)/5
  		findpeak/Q/B=3/M=(peaklevel)/R=(xwave[pcsrA],xwave[pcsrB]) temp
		w_0=wavemin(temp,xwave(pcsrA),xwave(pcsrB))
		if(V_flag==0)
			w_1=V_PeakVal
			w_2=V_PeakLoc
			w_3=V_PeakWidth
		else
			w_1=0
			w_2=0
			w_3=0
		endif
	
		findpeak/Q/B=3/M=(peaklevel)/R=(w_2+w_3/2,xwave[pcsrB]) temp
		if(V_flag==0)
			w_4=V_PeakVal
			w_5=V_PeakLoc
			w_6=V_PeakWidth
		else
			w_4=0
			w_5=0
			w_6=0
		endif
	
		findpeak/Q/B=3/M=(peaklevel)/R=(w_5+w_6/2,xwave[pcsrB]) temp
		if(V_flag==0)
			w_7=V_PeakVal
			w_8=V_PeakLoc
			w_9=V_PeakWidth
		else
			w_7=0
			w_8=0
			w_9=0
		endif
  		
		findpeak/Q/B=3/M=(peaklevel)/R=(w_8+w_9/2,xwave[pcsrB]) temp
		if(V_flag==0)
			w_10=V_PeakVal
			w_11=V_PeakLoc
			w_12=V_PeakWidth
		else
			w_10=0
			w_11=0
			w_12=0
		endif	
			
		prompt w_0, "The fit function reads f=A+h1/((x-p1)^2+d1^2)+h2/((x-p2)^2+d2^2)+h3/((x-p3)^2+d3^2)+h4/((x-p4)^2+d4^2). The background A:" 
  		Prompt w_1, "Peak1 height h1:"
  		Prompt w_2, "Peak1 position p1:" 
  		Prompt w_3, "Peak1 width d1:"
 		Prompt w_4, "Peak2 height h2:"
 		Prompt w_5, "Peak2 position p2:" 
 		Prompt w_6, "Peak2 width d2:"
  		doprompt "", w_0, w_1, w_2, w_3, w_4, w_5, w_6
 		Prompt w_7, "Peak3 height h3:"
  		Prompt w_8, "Peak3 position p3:" 
  		Prompt w_9, "Peak3 width d3:"
  		Prompt w_10, "Peak4 height h4:"
  		Prompt w_11, "Peak4 position p4:" 
 		Prompt w_12, "Peak4 width d4:"
  		doprompt "", w_7, w_8, w_9, w_10, w_11, w_12 
  		if(V_flag)
    		return -1  //user cancel
  		endif
 
  		if(stringmatch(analysisfitbg,"None")==1)
  		 	Lorfourpeakfitcoeff={w_0, w_1*w_3^2, w_2, w_3, w_4*w_6^2, w_5, w_6, w_7*w_9^2, w_8, w_9, w_10*w_12^2, w_11, w_12}
  			FuncFit/q fourpeaklorfunction Lorfourpeakfitcoeff ywave[pcsrA,pcsrB] /X=xwave /D/C=fitcwave1
  		elseif(stringmatch(analysisfitbg,"Linear")==1)
  			Lorfourpeakfitcoeff={w_0, w_1*w_3^2, w_2, w_3, w_4*w_6^2, w_5, w_6, w_7*w_9^2, w_8, w_9, w_10*w_12^2, w_11, w_12, 1}
 	 		FuncFit/q fourpeaklorfunction_slope Lorfourpeakfitcoeff ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 		make/O/N=100 linbg
 	 		setscale/I x, xwave[xcsr(A)], xwave[xcsr(B)], linbg
 	 		linbg=Lorfourpeakfitcoeff[0]+Lorfourpeakfitcoeff[13]*x
 	 		duplicate/O linbg, bgcurve
 	 		
  		elseif(stringmatch(analysisfitbg,"Cubic")==1)
 	 		Lorfourpeakfitcoeff={w_0, w_1*w_3^2, w_2, w_3, w_4*w_6^2, w_5, w_6, w_7*w_9^2, w_8, w_9, w_10*w_12^2, w_11, w_12, 1, 1, 1}
 	 		FuncFit/q fourpeaklorfunction_cubic Lorfourpeakfitcoeff ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 		make/O/N=100 cubicbg
 	 		setscale/I x, xwave[xcsr(A)], xwave[xcsr(B)], cubicbg
 	 		cubicbg=Lorfourpeakfitcoeff[0]+Lorfourpeakfitcoeff[13]*x+Lorfourpeakfitcoeff[14]*x^2+Lorfourpeakfitcoeff[15]*x^3
 	 		duplicate/O cubicbg, bgcurve
 	 	elseif(stringmatch(analysisfitbg,"exp1")==1)
 	 		make/O/N=2 exp1bgcoeff
 	 		exp1bgcoeff={1,1}
 	 		FuncFit/q {{fourpeaklorfunction, Lorfourpeakfitcoeff},{exp1_bg, exp1bgcoeff}} ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 	elseif(stringmatch(analysisfitbg,"exp2")==1)
 	 		make/O/N=4 exp2bgcoeff
 	 		exp2bgcoeff={1,1,1,1}
 	 		FuncFit/q {{fourpeaklorfunction, Lorfourpeakfitcoeff},{exp2_bg, exp2bgcoeff}} ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
  		endif
  		wave W_sigma
  		duplicate/O W_sigma, Lorfourpeakdelta
  		printf "The peak1 position p1 is %g±%g ; the peak1 width d1 is %g±%g \r", Lorfourpeakfitcoeff[2], Lorfourpeakdelta[2], Lorfourpeakfitcoeff[3], Lorfourpeakdelta[3]
  		printf "The peak2 position p2 is %g±%g ; the peak2 width d2 is %g±%g \r", Lorfourpeakfitcoeff[5], Lorfourpeakdelta[5], Lorfourpeakfitcoeff[6], Lorfourpeakdelta[6]
 		printf "The peak3 position p3 is %g±%g ; the peak3 width d3 is %g±%g \r", Lorfourpeakfitcoeff[8], Lorfourpeakdelta[8], Lorfourpeakfitcoeff[9], Lorfourpeakdelta[9]
 		printf "The peak4 position p4 is %g±%g ; the peak4 width d4 is %g±%g \r", Lorfourpeakfitcoeff[11], Lorfourpeakdelta[11], Lorfourpeakfitcoeff[12], Lorfourpeakdelta[12]
	endif
	
	if(stringmatch(analysisfunc,"VoigtOne")==1)
		make/O/N=5 Voigtfitcoeff
		duplicate/O ywave, temp
		setscale/P x, xwave[0], xwave[1]-xwave[0], temp
		peaklevel=(wavemax(temp,xwave(pcsrA),xwave(pcsrB))*2+wavemin(temp,xwave(pcsrA),xwave(pcsrB))*3)/5
		findpeak/Q/B=3/M=(peaklevel)/R=(xwave[pcsrA],xwave[pcsrB]) temp
		w_0=wavemin(temp,xwave(pcsrA),xwave(pcsrB))
		if(V_flag==0)
			w_1=V_PeakVal
			w_2=V_PeakLoc
			w_3=V_PeakWidth
		else
			w_1=0
			w_2=0
			w_3=0
		endif
		prompt w_0, "The fit function reads f=A+h1/((x-p1)^2+d1^2)⊗gauss(x-p1). The background A:" 
  		Prompt w_1, "Peak1 height h1:"
  		Prompt w_2, "Peak1 position p1(1/Å):" 
  		Prompt w_3, "Peak1 width d1(1/Å):"
  		doprompt "", w_0, w_1, w_2, w_3
  		if(V_flag)
   			return -1  //user cancel
  		endif
  		Voigtfitcoeff={w_0, w_1, 5/w_3, w_2, 5} //the parameter w_4 defines the ratio between Loretizian and gaussian function, use 5 for initial value
  		
  		if(stringmatch(analysisfitbg,"None")==1)
  			Voigtfitcoeff={w_0, w_1, 5/w_3, w_2, 5}
  			FuncFit/q onepeakVoigtfunction Voigtfitcoeff ywave[pcsrA,pcsrB] /X=xwave /D/C=fitcwave1
  		elseif(stringmatch(analysisfitbg,"Linear")==1)
  			Voigtfitcoeff={w_0, w_1, 5/w_3, w_2, 5, 1}
 	 		FuncFit/q onepeakVoigtfunction_slope Voigtfitcoeff ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 		make/O/N=100 linbg
 	 		setscale/I x, xwave[xcsr(A)], xwave[xcsr(B)], linbg
 	 		linbg=Voigtfitcoeff[0]+Voigtfitcoeff[5]*x
 	 		duplicate/O linbg, bgcurve
 	 		
 	 	elseif(stringmatch(analysisfitbg,"Cubic")==1)
 	 		Voigtfitcoeff={w_0, w_1, 5/w_3, w_2, 5, 1, 1, 1}
 	 		FuncFit/q onepeakVoigtfunction_cubic Voigtfitcoeff ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 		make/O/N=100 cubicbg
 	 		setscale/I x, xwave[xcsr(A)], xwave[xcsr(B)], cubicbg
 	 		cubicbg=Voigtfitcoeff[0]+Voigtfitcoeff[5]*x+Voigtfitcoeff[6]*x^2+Voigtfitcoeff[7]*x^3
 	 		duplicate/O cubicbg, bgcurve
 	 	elseif(stringmatch(analysisfitbg,"exp1")==1)
 	 		make/O/N=2 exp1bgcoeff
 	 		exp1bgcoeff={1,1}
 	 		FuncFit/q {{onepeakVoigtfunction, Voigtfitcoeff},{exp1_bg, exp1bgcoeff}} ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 	elseif(stringmatch(analysisfitbg,"exp2")==1)
 	 		make/O/N=4 exp2bgcoeff
 	 		exp2bgcoeff={1,1,1,1}
 	 		FuncFit/q {{onepeakVoigtfunction, Voigtfitcoeff},{exp2_bg, exp2bgcoeff}} ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
  		endif
  		
  		wave W_sigma
  		duplicate/O W_sigma, Voigtdelta
  		printf "The peak position is %g±%g; the peak Lor width is %g; gauss width is %g; Voigt width is %g; peak area is %g\r", Voigtfitcoeff[3], Voigtdelta[3], Voigtfitcoeff[4]/Voigtfitcoeff[2],  sqrt(ln(2))/Voigtfitcoeff[2], Voigtfitcoeff[4]/Voigtfitcoeff[2]/2+sqrt((Voigtfitcoeff[4]/Voigtfitcoeff[2]/2)^2+(sqrt(ln(2))/Voigtfitcoeff[2])^2),Voigtfitcoeff[1]/Voigtfitcoeff[2]*sqrt(pi)
  	
  	endif
	
	
	if(stringmatch(analysisfunc,"VoigtTwo")==1)
		make/O/N=9 Voigttwopeakfitcoeff
		duplicate/O ywave, temp
		setscale/P x, xwave[0], xwave[1]-xwave[0], temp
		peaklevel=(wavemax(temp,xwave(pcsrA),xwave(pcsrB))*2+wavemin(temp,xwave(pcsrA),xwave(pcsrB))*3)/5
		findpeak/Q/B=3/M=(peaklevel)/R=(xwave[pcsrA],xwave[pcsrB]) temp
		w_0=wavemin(temp,xwave(pcsrA),xwave(pcsrB))
		if(V_flag==0)
			w_1=V_PeakVal
			w_2=V_PeakLoc
			w_3=V_PeakWidth
		else
			w_1=0
			w_2=0
			w_3=0
		endif
		findpeak/Q/B=3/M=(peaklevel)/R=(w_2+w_3/2,xwave[pcsrB]) temp
		if(V_flag==0)
			w_4=V_PeakVal
			w_5=V_PeakLoc
			w_6=V_PeakWidth
		else
			w_4=0
			w_5=0
			w_6=0
		endif			
		prompt w_0, "The fit function reads f=A+h1/((x-p1)^2+d1^2)⊗gauss(x-p1)+h2/((x-p2)^2+d2^2)⊗gauss(x-p2). The background A:" 
  		Prompt w_1, "Peak1 height h1:"
  		Prompt w_2, "Peak1 position p1(1/Å):" 
  		Prompt w_3, "Peak1 width d1(1/Å):"
  		Prompt w_4, "Peak2 height h2:"
  		Prompt w_5, "Peak2 position p2(1/Å):" 
  		Prompt w_6, "Peak2 width d2(1/Å):"
  		doprompt "", w_0, w_1, w_2, w_3, w_4, w_5, w_6
  		if(V_flag)
   			return -1  //user cancel
  		endif
  		
  		Voigttwopeakfitcoeff={w_0, w_1, 5/w_3, w_2, 5, w_4, 5/w_6, w_5, 5} //the fifth and nineth parameter defines the ratio between Loretizian and gaussian function, use 5 for initial value
  		if(stringmatch(analysisfitbg,"None")==1)
  			FuncFit/q twopeakVoigtfunction Voigttwopeakfitcoeff ywave[pcsrA,pcsrB] /X=xwave /D/C=fitcwave1
  		elseif(stringmatch(analysisfitbg,"Linear")==1)
  			Voigttwopeakfitcoeff={w_0, w_1, 5/w_3, w_2, 5, w_4, 5/w_6, w_5, 5, 1}
 	 		FuncFit/q twopeakVoigtfunction_slope Voigttwopeakfitcoeff ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 		make/O/N=100 linbg
 	 		setscale/I x, xwave[xcsr(A)], xwave[xcsr(B)], linbg
 	 		linbg=Voigttwopeakfitcoeff[0]+Voigttwopeakfitcoeff[9]*x
 	 		duplicate/O linbg, bgcurve
 	 	elseif(stringmatch(analysisfitbg,"Cubic")==1)
 	 		Voigttwopeakfitcoeff={w_0, w_1, 5/w_3, w_2, 5, w_4, 5/w_6, w_5, 5, 1, 1, 1}
 	 		FuncFit/q twopeakVoigtfunction_cubic Voigttwopeakfitcoeff ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 		make/O/N=100 cubicbg
 	 		setscale/I x, xwave[xcsr(A)], xwave[xcsr(B)], cubicbg
 	 		cubicbg=Voigttwopeakfitcoeff[0]+Voigttwopeakfitcoeff[9]*x+Voigttwopeakfitcoeff[10]*x^2+Voigttwopeakfitcoeff[11]*x^3
 	 		duplicate/O cubicbg, bgcurve
 	 	elseif(stringmatch(analysisfitbg,"exp1")==1)
 	 		make/O/N=2 exp1bgcoeff
 	 		exp1bgcoeff={1,1}
 	 		FuncFit/q {{twopeakVoigtfunction, Voigttwopeakfitcoeff},{exp1_bg, exp1bgcoeff}} ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 	elseif(stringmatch(analysisfitbg,"exp2")==1)
 	 		make/O/N=4 exp2bgcoeff
 	 		exp2bgcoeff={1,1,1,1}
 	 		FuncFit/q {{twopeakVoigtfunction, Voigttwopeakfitcoeff},{exp2_bg, exp2bgcoeff}} ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
  		endif
  		wave W_sigma
  		duplicate/O W_sigma, Voigttwopeakdelta
  		printf "The peak1 position is %g±%g; the peak1 Lor width is %g; gauss width is %g; Voigt width is %g; peak1 area is %g\r", Voigttwopeakfitcoeff[3], Voigttwopeakdelta[3], Voigttwopeakfitcoeff[4]/Voigttwopeakfitcoeff[2],  sqrt(ln(2))/Voigttwopeakfitcoeff[2], Voigttwopeakfitcoeff[4]/Voigttwopeakfitcoeff[2]/2+sqrt((Voigttwopeakfitcoeff[4]/Voigttwopeakfitcoeff[2]/2)^2+(sqrt(ln(2))/Voigttwopeakfitcoeff[2])^2), Voigttwopeakfitcoeff[1]/Voigttwopeakfitcoeff[2]*sqrt(pi)
  		printf "The peak2 position is %g±%g; the peak1 Lor width is %g; gauss width is %g; Voigt width is %g; peak2 area is %g\r", Voigttwopeakfitcoeff[7], Voigttwopeakdelta[7], Voigttwopeakfitcoeff[8]/Voigttwopeakfitcoeff[6],  sqrt(ln(2))/Voigttwopeakfitcoeff[6], Voigttwopeakfitcoeff[8]/Voigttwopeakfitcoeff[6]/2+sqrt((Voigttwopeakfitcoeff[8]/Voigttwopeakfitcoeff[6]/2)^2+(sqrt(ln(2))/Voigttwopeakfitcoeff[6])^2), Voigttwopeakfitcoeff[5]/Voigttwopeakfitcoeff[6]*sqrt(pi)
  		
	endif

	
	if(stringmatch(analysisfunc,"GaussTwo")==1)
		make/O/N=7 gausstwopeakfitcoeff
		prompt w_0, "The fit function reads f=A+h1*exp(-((x-p1)/d1)^2)+h2*exp(-((x-p2)/d2)^2). The background A:" 
  		Prompt w_1, "Peak1 height h1:"
 		Prompt w_2, "Peak1 position p1:" 
  		Prompt w_3, "Peak1 FWHM d1:"
  		Prompt w_4, "Peak2 height h2:"
  		Prompt w_5, "Peak2 position p2:" 
  		Prompt w_6, "Peak2 FWHM d2:"
  		doprompt "", w_0, w_1, w_2, w_3, w_4, w_5, w_6
  		if(V_flag)
    		return -1  //user cancel
  		endif
  		gausstwopeakfitcoeff={w_0, w_1*exp(w_3^2), w_2, w_3, w_4*exp(w_6^2), w_5, w_6}
  		if(stringmatch(analysisfitbg,"None")==1)
  			FuncFit/q twopeakgaussfunction gausstwopeakfitcoeff ywave[pcsrA,pcsrB] /X=xwave /D/C=fitcwave1
  		elseif(stringmatch(analysisfitbg,"Linear")==1)
  			make/O/N=1 linearbgcoeff
 	 		linearbgcoeff={1}
 	 		FuncFit/q {{twopeakgaussfunction, gausstwopeakfitcoeff},{linear_bg, linearbgcoeff}} ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
  		elseif(stringmatch(analysisfitbg,"Cubic")==1)
 	 		make/O/N=3 cubicbgcoeff
 	 		cubicbgcoeff={1,1,1}
 	 		FuncFit/q {{twopeakgaussfunction, gausstwopeakfitcoeff},{cubic_bg, cubicbgcoeff}} ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 		make/O/N=100 cubicbg
 	 		setscale/I x, xwave[xcsr(A)], xwave[xcsr(B)], cubicbg
 	 		cubicbg=cubicbgcoeff[0]*x+cubicbgcoeff[1]*x*x+cubicbgcoeff[2]*x*x*x
 	 		duplicate/O cubicbg, bgcurve
 	 	elseif(stringmatch(analysisfitbg,"exp1")==1)
 	 		make/O/N=2 exp1bgcoeff
 	 		exp1bgcoeff={1,1}
 	 		FuncFit/q {{twopeakgaussfunction, gausstwopeakfitcoeff},{exp1_bg, exp1bgcoeff}} ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
 	 	elseif(stringmatch(analysisfitbg,"exp2")==1)
 	 		make/O/N=4 exp2bgcoeff
 	 		exp2bgcoeff={1,1,1,1}
 	 		FuncFit/q {{twopeakgaussfunction, gausstwopeakfitcoeff},{exp2_bg, exp2bgcoeff}} ywave[pcsrA,pcsrB] /X=xwave/D/C=fitcwave1
  		endif
  		wave W_sigma
 		duplicate/O W_sigma, gausstwopeakdelta
  		printf "The peak1 position p1 is %g±%g ; the peak1 FWHM d1 is %g±%g \r", gausstwopeakfitcoeff[2], gausstwopeakdelta[2], gausstwopeakfitcoeff[3], gausstwopeakdelta[3]
  		printf "The peak2 position p2 is %g±%g ; the peak2 FWHM d2 is %g±%g \r", gausstwopeakfitcoeff[5], gausstwopeakdelta[5], gausstwopeakfitcoeff[6], gausstwopeakdelta[6]
	endif
	killwaves temp
	
	wave fitwave=$fitwavename
	removefromgraph/W=analysiswaveplotwin $fitwavename
	Display/N=$fitwavename  ywave vs xwave
	dowindow/f $fitwavename
	AppendtoGraph fitwave
	if(stringmatch(analysisfitbg,"None")!=1)
	if(waveexists(bgcurve)==1)
		AppendtoGraph bgcurve
		ModifyGraph lstyle(bgcurve)=3, rgb(bgcurve)=(0,0,0)
	endif
	endif
   PauseUpdate; Silent 1		// modifying window...
	ModifyGraph rgb($fitwavename)=(0,0,0)
	ModifyGraph mode=0, lsize=2
	ModifyGraph/Z tick=2
	ModifyGraph/Z mirror=1
	ModifyGraph/Z font="Arial"
	ModifyGraph/Z fSize=16
	ModifyGraph/Z fStyle=1
	ModifyGraph/Z standoff=0
	ModifyGraph noLabel(left)=1
	ModifyGraph axThick=2
	ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28,width=340.157,height=226.772
	Label/Z left "\\F'Arial'\\Z24\f00Intensity (arb. units)"
	if(stringmatch(analysistracktype,"EDC")==1)
		Label/Z bottom "\\F'Arial'\\Z24\f02E-E\BF\M\F'Arial'\\Z24\f00 (eV)"
	else
		Label/Z bottom "\\F'Arial'\\Z24\f00k\B//\M\F'Times New Roman'\\Z24 (Å\S-1\M\F'Arial'\\Z24)"
	endif
End

Function PopMenuProc_analysisdisperfunc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	String/g analysisdispersionfunc=popStr
End

Function ButtonProc_analysisdispersion(ctrlName) : ButtonControl
	String ctrlName
	variable i, pcsrA, pcsrB
	variable peaklevel
	variable w_0, w_1, w_2, w_3, w_4, w_5, w_6, w_7, w_8, w_9, w_10, w_11, w_12, w_13, w_14, w_15
	variable/g analysistrackpoint, analysisinterval, analysisoffset
	string/g analysisdispersionfunc, analysistracktype
	
	string displaylist=wavelist("analyywave*",";","WIN:analysiswaveplotwin")
	variable displaynum=itemsinlist(displaylist)
	if(displaynum<5)
		Abort "Please show more than 5 curves!"	
	endif
	if (stringmatch(CsrWave(a,""),"") || stringmatch(CsrWave(b,""),""))
       Abort "Set A and B cursors on the analysiswave plot window!!"
  	endif
  	if(stringmatch(analysistracktype,"MDC")!=1)
  		Abort "Please show MDC"
  	endif
	wave ywave=$Csrwave(A)
	wave xwave=$csrxwave(A)
	string fitwavename="fit_"+Csrwave(A)
	pcsrA=pcsr(A,"")
	pcsrB=pcsr(B,"")  
  
  	if(stringmatch(analysisdispersionfunc,"2")==1)
  	make/O/N=(2*displaynum) MDCDispE, MDCDispk
  	make/O/N=7 MDCDispFitcoeff
  	duplicate/O ywave, temp
	setscale/P x, xwave[0], xwave[1]-xwave[0], temp
	peaklevel=(wavemax(temp,xwave(pcsrA),xwave(pcsrB))*2+wavemin(temp,xwave(pcsrA),xwave(pcsrB))*3)/5
	findpeak/Q/B=3/M=(peaklevel)/R=(xwave[pcsrA],xwave[pcsrB]) temp
	w_0=wavemin(temp,xwave(pcsrA),xwave(pcsrB))
	if(V_flag==0)
		w_1=V_PeakVal
		w_2=V_PeakLoc
		w_3=V_PeakWidth
	else
		w_1=0
		w_2=0
		w_3=0
	endif
	findpeak/Q/B=3/M=(peaklevel)/R=(w_2+w_3/2,xwave[pcsrB]) temp
	if(V_flag==0)
		w_4=V_PeakVal
		w_5=V_PeakLoc
		w_6=V_PeakWidth
	else
		w_4=0
		w_5=0
		w_6=0
	endif
  	
  	prompt w_0, "The fit function reads f=A+h1/((x-p1)^2+d1^2)+h2/((x-p2)^2+d2^2). The background A:" 
  	Prompt w_1, "Peak1 height h1:"
  	Prompt w_2, "Peak1 position p1(1/Å):" 
  	Prompt w_3, "Peak1 width d1(1/Å):"
  	Prompt w_4, "Peak2 height h2:"
  	Prompt w_5, "Peak2 position p2(1/Å):" 
  	Prompt w_6, "Peak2 width d2(1/Å):"
  	doprompt "", w_0, w_1, w_2, w_3, w_4, w_5, w_6
  	if(V_flag)
   		return -1  //user cancel
  	endif
  	
  	MDCDispFitcoeff={w_0, w_1*w_3^2, w_2, w_3, w_4*w_6^2, w_5, w_6}
  	
  	elseif(stringmatch(analysisdispersionfunc,"1")==1)
  	make/O/N=(displaynum) MDCDispE, MDCDispk
   make/O/N=4 MDCDispFitcoeff
   duplicate/O ywave, temp
	setscale/P x, xwave[0], xwave[1]-xwave[0], temp
	peaklevel=(wavemax(temp,xwave(pcsrA),xwave(pcsrB))*2+wavemin(temp,xwave(pcsrA),xwave(pcsrB))*3)/5
   	findpeak/Q/B=3/M=(peaklevel)/R=(xwave[pcsrA],xwave[pcsrB]) temp
	w_0=wavemin(temp,xwave(pcsrA),xwave(pcsrB))
	if(V_flag==0)
		w_1=V_PeakVal
		w_2=V_PeakLoc
		w_3=V_PeakWidth
	else
		w_1=0
		w_2=0
		w_3=0
	endif
	
  	prompt w_0, "The fit function reads f=A+h1/((x-p1)^2+d1^2). The background A:" 
  	Prompt w_1, "Peak1 height h1:"
  	Prompt w_2, "Peak1 position p1(1/Å):" 
  	Prompt w_3, "Peak1 width d1(1/Å):"
  	doprompt "", w_0, w_1, w_2, w_3
  	if(V_flag)
   		return -1  //user cancel
  	endif
  	MDCDispFitcoeff={w_0, w_1*w_3^2, w_2, w_3}
  		
  	elseif(stringmatch(analysisdispersionfunc,"4")==1)
  	make/O/N=(4*displaynum) MDCDispE, MDCDispk
  	make/O/N=13 MDCDispFitcoeff
  	duplicate/O ywave, temp
	setscale/P x, xwave[0], xwave[1]-xwave[0], temp
	peaklevel=(wavemax(temp,xwave(pcsrA),xwave(pcsrB))*2+wavemin(temp,xwave(pcsrA),xwave(pcsrB))*3)/5
  	findpeak/Q/B=3/M=(peaklevel)/R=(xwave[pcsrA],xwave[pcsrB]) temp
	w_0=wavemin(temp,xwave(pcsrA),xwave(pcsrB))
	if(V_flag==0)
		w_1=V_PeakVal
		w_2=V_PeakLoc
		w_3=V_PeakWidth
	else
		w_1=0
		w_2=0
		w_3=0
	endif
	
	findpeak/Q/B=3/M=(peaklevel)/R=(w_2+w_3/2,xwave[pcsrB]) temp
	if(V_flag==0)
		w_4=V_PeakVal
		w_5=V_PeakLoc
		w_6=V_PeakWidth
	else
		w_4=0
		w_5=0
		w_6=0
	endif
	
	findpeak/Q/B=3/M=(peaklevel)/R=(w_5+w_6/2,xwave[pcsrB]) temp
	if(V_flag==0)
		w_7=V_PeakVal
		w_8=V_PeakLoc
		w_9=V_PeakWidth
	else
		w_7=0
		w_8=0
		w_9=0
	endif
  		
	findpeak/Q/B=3/M=(peaklevel)/R=(w_8+w_9/2,xwave[pcsrB]) temp
	if(V_flag==0)
		w_10=V_PeakVal
		w_11=V_PeakLoc
		w_12=V_PeakWidth
	else
		w_10=0
		w_11=0
		w_12=0
	endif
	
  	prompt w_0, "The fit function reads f=A+h1/((x-p1)^2+d1^2)+h2/((x-p2)^2+d2^2)+h3/((x-p3)^2+d3^2)+h4/((x-p4)^2+d4^2). The background A:" 
  	Prompt w_1, "Peak1 height h1:"
  	Prompt w_2, "Peak1 position p1(1/Å):" 
  	Prompt w_3, "Peak1 width d1(1/Å):"
  	Prompt w_4, "Peak2 height h2:"
  	Prompt w_5, "Peak2 position p2(1/Å):" 
  	Prompt w_6, "Peak2 width d2(1/Å):"
  	doprompt "", w_0, w_1, w_2, w_3, w_4, w_5, w_6
  	 if(V_flag)
   		return -1  //user cancel
  	endif
  	Prompt w_7, "Peak2 height h3:"
  	Prompt w_8, "Peak2 position p3(1/Å):" 
  	Prompt w_9, "Peak2 width d3(1/Å):"
  	Prompt w_10, "Peak2 height h4:"
  	Prompt w_11, "Peak2 position p4(1/Å):" 
  	Prompt w_12, "Peak2 width d4(1/Å):"
  	doprompt "", w_7, w_8, w_9, w_10, w_11, w_12
  	if(V_flag)
   		return -1  //user cancel
  	endif
  	MDCDispFitcoeff={w_0, w_1*w_3^2, w_2, w_3, w_4*w_6^2, w_5, w_6,w_7*w_9^2, w_8, w_9,w_10*w_12^2, w_11, w_12}
  	endif
  	
  	
 	pcsrA=pcsr(A,"") ; pcsrB=pcsr(B,"")
 	for(i=0; i<displaynum; i+=1)
 		string ywavenamestr=stringfromlist(i,displaylist)
 		string xwavenamestr=xwavename("",stringfromlist(i,displaylist))
 		if(stringmatch(analysisdispersionfunc,"2")==1)
 			FuncFit/q twopeaklorfunction MDCDispFitcoeff $ywavenamestr[pcsrA,pcsrB] /X=$xwavenamestr /D
  			MDCDispk[2*i]=MDCDispFitcoeff[2]
  			MDCDispk[2*i+1]=MDCDispFitcoeff[5]
  			MDCDispE[2*i,2*i+1]=analysistrackpoint+i*analysisinterval
  		elseif(stringmatch(analysisdispersionfunc,"1")==1)
  			FuncFit/q onepeaklorfunction MDCDispFitcoeff $ywavenamestr[pcsrA,pcsrB] /X=$xwavenamestr /D
  			MDCDispk[i]=MDCDispFitcoeff[2]
  			MDCDispE[i]=analysistrackpoint+i*analysisinterval
  		elseif(stringmatch(analysisdispersionfunc,"4")==1)
  			FuncFit/q fourpeaklorfunction MDCDispFitcoeff $ywavenamestr[pcsrA,pcsrB] /X=$xwavenamestr /D
  			MDCDispk[4*i]=MDCDispFitcoeff[2]
  			MDCDispk[4*i+1]=MDCDispFitcoeff[5]
  			MDCDispk[4*i+2]=MDCDispFitcoeff[8]
  			MDCDispk[4*i+3]=MDCDispFitcoeff[11]
  			MDCDispE[4*i,4*i+3]=analysistrackpoint+i*analysisinterval
  		endif
  		Modifygraph/W=analysiswaveplotwin/Z rgb($"fit_"+ywavenamestr)=(0,0,0), lsize($"fit_"+ywavenamestr)=2
  		Modifygraph/W=analysiswaveplotwin/Z lstyle($"fit_"+ywavenamestr)=3, offset($"fit_"+ywavenamestr)={0,i*analysisoffset}
 	endfor
 	killwaves temp
 	wave W_sigma
 	
 	if(stringmatch(analysisdispersionfunc,"2")==1)
 		string fitcheck
 		prompt fitcheck "Fit the band dispersion:" popup "No;parabolic;Dirac"
 		doprompt "", fitcheck 
 		if(V_flag)
   			return -1  //user cancel
  		endif
 	if(stringmatch(fitcheck,"parabolic")==1)
  		CurveFit/q poly 3, MDCDispE /X=MDCDispk /D
  		duplicate/O W_sigma, paradispdelta
  		printf "The effective mass is %g me\r", 3.815/K2
  		MDCDispplot()
  		MDCDispfitplot()
  	elseif(stringmatch(fitcheck,"Dirac")==1)
  		make/O/N=3 DiracDispfitcoeff
  		prompt w_13, "The energy of Dirac point(eV):"
  		prompt w_14, "The band velocity(eV*Å):"
  		prompt w_15, "The momentum of Dirac point(1/Å):"
  		doprompt "", w_13, w_14, w_15
  		if(V_flag)
  		  return -1  //user cancel
  		endif
  		DiracDispfitcoeff={w_13, w_14, w_15}
  		make/O/N=3 Diracdispdelta
  		duplicate/O W_sigma, Diracdispdelta
  		FuncFit/q DiracDispersionfitfunction DiracDispfitcoeff MDCDispE /X=MDCDispk /D 
  		printf "Dirac point locates at %g±%g 1/Å, %g±%g eV; The band velocity is %g±%g eV*Å\r", DiracDispfitcoeff[2], Diracdispdelta[2], DiracDispfitcoeff[0], Diracdispdelta[0], DiracDispfitcoeff[1], Diracdispdelta[1]
  		MDCDispplot()
  		MDCDispfitplot()
  	else
  		MDCDispplot()
  	endif
  	endif
End

Function MDCDispplot()
	wave MDCDispE, MDCDispk
	Display/W=(309,48,723,580)//N=MDCDispfitplot
	PauseUpdate; Silent 1		// building window...
	AppendtoGraph MDCDispE vs MDCDispk
	Modifygraph rgb(MDCDispE)=(0,0,0), mode(MDCDispE)=3, marker(MDCDispE)=8, msize(MDCDispE)=4, mrkThick(MDCDispE)=1.5
	 ModifyGraph/Z tick=2
	 ModifyGraph/Z mirror=1
	 ModifyGraph/Z font="Arial"
	 ModifyGraph/Z fSize=16
	 ModifyGraph/Z fStyle=1
	 ModifyGraph/Z standoff=0
	 ModifyGraph/Z axThick=2
	 ModifyGraph margin(left)=70,margin(bottom)=70,margin(right)=28,margin(top)=28,width=340.157,height=226.772
	 Label/Z left "\\F'Arial'\\Z24\f01E-E\BF\M\F'Arial'\\Z24\f00(eV)"
	 Label/Z bottom "\\F'Arial'\\Z24\f00k\F'Times New Roman'\\Z24 (Å\S-1\M\F'Arial'\\Z24)"
End

Function MDCDispfitplot()
	wave fit_MDCDispE
	AppendtoGraph fit_MDCDispE
	Modifygraph rgb(fit_MDCDispE)=(65535,0,0), lsize(fit_MDCDispE)=2
End

Function ButtonProc_MDCDispexport(ctrlName) : ButtonControl
	String ctrlName
	String exportwavename
	String/g analysiswavename
	wave MDCDispE, MDCDispk
	if(waveexists(MDCDispE)==0 || waveexists(MDCDispk)==0)
		Abort "Please first fit the dispersion!"
	endif
	
	exportwavename=analysiswavename
	prompt exportwavename "Enter the name for dispersion:"
	doprompt "", exportwavename
	if(V_flag)
		return -1
	endif
	duplicate/O MDCDispE, $exportwavename+"_DispE"
	duplicate/O MDCDispk, $exportwavename+"_Dispk"
	
	Display/W=(309,48,723,580)//N=MDCDispfitplot
	PauseUpdate; Silent 1	
	AppendtoGraph $exportwavename+"_DispE" vs $exportwavename+"_Dispk"
	Modifygraph rgb($exportwavename+"_DispE")=(0,0,0), mode($exportwavename+"_DispE")=3
	Modifygraph marker($exportwavename+"_DispE")=8, msize($exportwavename+"_DispE")=4, mrkThick($exportwavename+"_DispE")=1.5
	ModifyGraph/Z tick=2
 	ModifyGraph/Z mirror=1
	ModifyGraph/Z font="Arial"
	ModifyGraph/Z fSize=16
	ModifyGraph/Z fStyle=1
	ModifyGraph/Z standoff=0
	ModifyGraph/Z axThick=2
	ModifyGraph margin(left)=70,margin(bottom)=70,margin(right)=28,margin(top)=28,width=340.157,height=226.772
	Label/Z left "\\F'Arial'\\Z24\f01E-E\BF\M\F'Arial'\\Z24\f00(eV)"
	Label/Z bottom "\\F'Arial'\\Z24\f00k\F'Times New Roman'\\Z24 (Å\S-1\M\F'Arial'\\Z24)"
	if(waveexists(fit_MDCDispE)==1)
		duplicate/O fit_MDCDispE, $"fit_"+exportwavename+"_DispE"
		AppendtoGraph $"fit_"+exportwavename+"_DispE"
		Modifygraph rgb($"fit_"+exportwavename+"_DispE")=(65535,0,0), lsize($"fit_"+exportwavename+"_DispE")=2
	endif
	
End


Function ButtonProc_analysisfitpeaksplit(ctrlName) : ButtonControl
	String ctrlName
	string/g analysisfunc
	wave Lortwopeakfitcoeff, Lorfourpeakfitcoeff, gausstwopeakfitcoeff
	if(stringmatch(analysisfunc,"LorTwo")==1)
		if(waveexists(Lortwopeakfitcoeff)!=1)
			Abort "Please perform Lor two-peak fit first!"
		endif
		make/O/N=100, fitLorTwopeak1, fitLorTwopeak2
		setscale/I x, Lortwopeakfitcoeff[2]-2*Lortwopeakfitcoeff[3], Lortwopeakfitcoeff[2]+2*Lortwopeakfitcoeff[3], fitLorTwopeak1
		setscale/I x, Lortwopeakfitcoeff[5]-2*Lortwopeakfitcoeff[6], Lortwopeakfitcoeff[5]+2*Lortwopeakfitcoeff[6], fitLorTwopeak2
		fitLorTwopeak1[]=Lortwopeakfitcoeff[1]/((x-Lortwopeakfitcoeff[2])^2+Lortwopeakfitcoeff[3]^2)
		fitLorTwopeak2[]=Lortwopeakfitcoeff[4]/((x-Lortwopeakfitcoeff[5])^2+Lortwopeakfitcoeff[6]^2)
		AppendtoGraph fitLorTwopeak1, fitLorTwopeak2
		ModifyGraph mode(fitLorTwopeak1)=7,mode(fitLorTwopeak2)=7
		ModifyGraph hbFill(fitLorTwopeak1)=5,hbFill(fitLorTwopeak2)=5,rgb(fitLorTwopeak1)=(0,0,65535), rgb(fitLorTwopeak2)=(0,0,65535)
		ModifyGraph usePlusRGB(fitLorTwopeak1)=1,plusRGB(fitLorTwopeak1)=(0,0,65535),usePlusRGB(fitLorTwopeak2)=1,plusRGB(fitLorTwopeak2)=(0,0,65535)
		ModifyGraph offset(fitLorTwopeak1)={0,-Lortwopeakfitcoeff[1]/Lortwopeakfitcoeff[3]^2/10}, offset(fitLorTwopeak2)={0,-Lortwopeakfitcoeff[4]/Lortwopeakfitcoeff[6]^2/10}
	elseif(stringmatch(analysisfunc,"LorFour")==1)
		if(waveexists(Lorfourpeakfitcoeff)!=1)
			Abort "Please perform Lor four-peak fit first!"
		endif
		make/O/N=100, fitLorFourpeak1, fitLorFourpeak2, fitLorFourpeak3, fitLorFourpeak4
		setscale/I x, LorFourpeakfitcoeff[2]-2*LorFourpeakfitcoeff[3], LorFourpeakfitcoeff[2]+2*LorFourpeakfitcoeff[3], fitLorFourpeak1
		setscale/I x, LorFourpeakfitcoeff[5]-2*LorFourpeakfitcoeff[6], LorFourpeakfitcoeff[5]+2*LorFourpeakfitcoeff[6], fitLorFourpeak2
		setscale/I x, LorFourpeakfitcoeff[8]-2*LorFourpeakfitcoeff[9], LorFourpeakfitcoeff[8]+2*LorFourpeakfitcoeff[9], fitLorFourpeak3
		setscale/I x, LorFourpeakfitcoeff[11]-2*LorFourpeakfitcoeff[12], LorFourpeakfitcoeff[11]+2*LorFourpeakfitcoeff[12], fitLorFourpeak4
		fitLorFourpeak1[]=Lorfourpeakfitcoeff[1]/((x-Lorfourpeakfitcoeff[2])^2+Lorfourpeakfitcoeff[3]^2)
		fitLorFourpeak2[]=Lorfourpeakfitcoeff[4]/((x-Lorfourpeakfitcoeff[5])^2+Lorfourpeakfitcoeff[6]^2)
		fitLorFourpeak3[]=Lorfourpeakfitcoeff[7]/((x-Lorfourpeakfitcoeff[8])^2+Lorfourpeakfitcoeff[9]^2)
		fitLorFourpeak4[]=Lorfourpeakfitcoeff[10]/((x-Lorfourpeakfitcoeff[11])^2+Lorfourpeakfitcoeff[12]^2)
		AppendtoGraph fitLorFourpeak1, fitLorFourpeak2, fitLorFourpeak3, fitLorFourpeak4
		ModifyGraph mode(fitLorFourpeak1)=7, mode(fitLorFourpeak2)=7, mode(fitLorFourpeak3)=7, mode(fitLorFourpeak4)=7
		ModifyGraph hbFill(fitLorFourpeak1)=5,hbFill(fitLorFourpeak2)=5,hbFill(fitLorFourpeak3)=5,hbFill(fitLorFourpeak4)=5,rgb(fitLorFourpeak1)=(0,0,65535), rgb(fitLorFourpeak2)=(0,0,65535),rgb(fitLorFourpeak3)=(0,0,65535),rgb(fitLorFourpeak4)=(0,0,65535)
		ModifyGraph usePlusRGB(fitLorFourpeak1)=1,plusRGB(fitLorFourpeak1)=(0,0,65535),usePlusRGB(fitLorFourpeak2)=1,plusRGB(fitLorFourpeak2)=(0,0,65535)	
		ModifyGraph usePlusRGB(fitLorFourpeak3)=1,plusRGB(fitLorFourpeak3)=(0,0,65535),usePlusRGB(fitLorFourpeak4)=1,plusRGB(fitLorFourpeak4)=(0,0,65535)	
		ModifyGraph offset(fitLorFourpeak1)={0,-Lorfourpeakfitcoeff[1]/Lorfourpeakfitcoeff[3]^2/10}, offset(fitLorFourpeak2)={0,-Lorfourpeakfitcoeff[4]/Lorfourpeakfitcoeff[6]^2/10}
		ModifyGraph offset(fitLorFourpeak3)={0,-Lorfourpeakfitcoeff[7]/Lorfourpeakfitcoeff[9]^2/10}, offset(fitLorFourpeak4)={0,-Lorfourpeakfitcoeff[10]/Lorfourpeakfitcoeff[12]^2/10}
	elseif(stringmatch(analysisfunc,"GaussTwo")==1)
		if(waveexists(gausstwopeakfitcoeff)!=1)
			Abort "Please perform gauss two-peak fit first!"
		endif
		make/O/N=100, fitgaussTwopeak1, fitgaussTwopeak2
		setscale/I x, gausstwopeakfitcoeff[2]-2*gausstwopeakfitcoeff[3], gausstwopeakfitcoeff[2]+2*gausstwopeakfitcoeff[3], fitgaussTwopeak1
		setscale/I x, gausstwopeakfitcoeff[5]-2*gausstwopeakfitcoeff[6], gausstwopeakfitcoeff[5]+2*gausstwopeakfitcoeff[6], fitgaussTwopeak2
		fitgaussTwopeak1[]=gausstwopeakfitcoeff[1]*exp(-((x-gausstwopeakfitcoeff[2])/gausstwopeakfitcoeff[3])^2)
		fitgaussTwopeak2[]=gausstwopeakfitcoeff[4]*exp(-((x-gausstwopeakfitcoeff[5])/gausstwopeakfitcoeff[6])^2)
		AppendtoGraph fitgaussTwopeak1, fitgaussTwopeak2
		ModifyGraph mode(fitgaussTwopeak1)=5,mode(fitgaussTwopeak2)=5
		ModifyGraph hbFill(fitgaussTwopeak1)=3,hbFill(fitgaussTwopeak2)=3,rgb(fitgaussTwopeak1)=(0,0,65535), rgb(fitgaussTwopeak2)=(0,0,65535)
		ModifyGraph usePlusRGB(fitgaussTwopeak1)=1,plusRGB(fitgaussTwopeak1)=(0,0,65535),usePlusRGB(fitgaussTwopeak2)=1,plusRGB(fitgaussTwopeak2)=(0,0,65535)
		ModifyGraph offset(fitgaussTwopeak1)={0,-gausstwopeakfitcoeff[1]*exp(-gausstwopeakfitcoeff[3]^2)/10}, offset(fitgaussTwopeak2)={0,-gausstwopeakfitcoeff[4]*exp(-gausstwopeakfitcoeff[6]^2)/10}
	else
		Abort "Please choose a function with more than one peak"
	endif
End


Function ButtonProc_analysisDividefermi(ctrlName) : ButtonControl
	String ctrlName
	string/g analysistracktype
	variable fermiwidth, i
	if(stringmatch(analysistracktype,"EDC")!=1)
		Abort "Track EDC in analysispanel first!"
	endif
	prompt fermiwidth "Please enter the kBT of the fitting result(meV):" 
	doprompt "", fermiwidth
	if(V_flag)
		return -1
	endif
	string displaylist=wavelist("analyywave*",";","WIN:analysiswaveplotwin")
	string xwavelist=wavelist("analyxwave*",";","WIN:analysiswaveplotwin")
	variable displaynum=itemsinlist(displaylist)
	for(i=0; i<displaynum; i+=1)
		duplicate/O $stringfromlist(i, xwavelist), temp
		duplicate/O $stringfromlist(i, displaylist), $stringfromlist(i, displaylist)+"_fermidiv"
		wave ywave=$stringfromlist(i, displaylist)+"_fermidiv"
		temp=1/(exp(temp/fermiwidth*1000)+1)
		ywave/=temp
		removefromgraph/W=analysiswaveplotwin/Z $stringfromlist(i, displaylist)
		AppendtoGraph/W=analysiswaveplotwin ywave vs $stringfromlist(i, xwavelist)
	endfor
	killwaves temp
End

Function ButtonProc_AnalysisOutput(ctrlName) : ButtonControl
	String ctrlName
	string outputtype
	string/g analysiswavename
	string/g analysistracktype
	variable/g analysisoffset, analylistcheck
	wave/T cutlistwave
	
	dowindow/f analysiswaveplotwin
	if(V_flag == 0)
		Abort "Please track and show scopes in the analysis wave plot window!"
	endif
	if(stringmatch(analysistracktype,"EDC") == 1)
		outputtype="EDC"
	else
		outputtype="MDC"
	endif
	
	string displaylist=wavelist("analyywave*",";","WIN:analysiswaveplotwin")
	string xwavelist=wavelist("analyxwave*",";","WIN:analysiswaveplotwin")
	variable displaynum=itemsinlist(displaylist)
	string fitwavelist=wavelist("fit_*",";","WIN:analysiswaveplotwin")
	variable fitnum=itemsinlist(fitwavelist)
	variable i,j
	Display;
	for(i=0; i<displaynum; i+=1)
	if(analylistcheck==1)
		duplicate/O $stringfromlist(i, xwavelist), $cutlistwave[i]+outputtype+"X"+num2str(i+1)
		duplicate/O $stringfromlist(i, displaylist), $cutlistwave[i]+outputtype+"Y"+num2str(i+1)
		AppendtoGraph $cutlistwave[i]+outputtype+"Y"+num2str(i+1) vs $cutlistwave[i]+outputtype+"X"+num2str(i+1)
		ModifyGraph/Z offset($cutlistwave[i]+outputtype+"Y"+num2str(i+1))={0,i*analysisoffset}
		ModifyGraph/Z rgb($cutlistwave[i]+outputtype+"Y"+num2str(i+1))=(65535,0,0)
	else
		duplicate/O $stringfromlist(i, xwavelist), $analysiswavename+outputtype+"X"+num2str(i+1)
		duplicate/O $stringfromlist(i, displaylist), $analysiswavename+outputtype+"Y"+num2str(i+1)
		AppendtoGraph $analysiswavename+outputtype+"Y"+num2str(i+1) vs $analysiswavename+outputtype+"X"+num2str(i+1)
		ModifyGraph/Z offset($analysiswavename+outputtype+"Y"+num2str(i+1))={0,i*analysisoffset}
		ModifyGraph/Z rgb($analysiswavename+outputtype+"Y"+num2str(i+1))=(65535,0,0)
	endif
	endfor
	if(fitnum >=1)
	for(j=0; j<fitnum; j+=1)
		string temp=removeending(stringfromlist(j,fitwavelist))
		string strnum=replacestring(temp, stringfromlist(j,fitwavelist), "")
		variable k=str2num(strnum)
		if(analylistcheck==0)
			duplicate/O $stringfromlist(j,fitwavelist), $"fit_"+analysiswavename+outputtype+"Y"+num2str(k)
			AppendtoGraph $"fit_"+analysiswavename+outputtype+"Y"+num2str(k)
			ModifyGraph/Z offset($"fit_"+analysiswavename+outputtype+"Y"+num2str(k))={0,(k-1)*analysisoffset}
			ModifyGraph/Z rgb($"fit_"+analysiswavename+outputtype+"Y"+num2str(k))=(0,0,0)
			ModifyGraph/Z lstyle($"fit_"+analysiswavename+outputtype+"Y"+num2str(k))=3
		else
			duplicate/O $stringfromlist(j,fitwavelist), $"fit_"+cutlistwave[k-1]+outputtype+"Y"
			AppendtoGraph $"fit_"+cutlistwave[k-1]+outputtype+"Y"
			ModifyGraph/Z offset($"fit_"+cutlistwave[k-1]+outputtype+"Y")={0,(k-1)*analysisoffset}
			ModifyGraph/Z rgb($"fit_"+cutlistwave[k-1]+outputtype+"Y")=(0,0,0)
			ModifyGraph/Z lstyle($"fit_"+cutlistwave[k-1]+outputtype+"Y")=3
		endif
	endfor
	endif
	ModifyGraph/Z tick=2
	ModifyGraph/Z mirror=1
   ModifyGraph/Z font="Arial"
	ModifyGraph/Z fSize=16, fStyle=1
   ModifyGraph/Z standoff=0, axThick=2
	ModifyGraph/Z noLabel(left)=1, zero(bottom)=4
	ModifyGraph/Z lsize=2
	ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28,width=340.157,height=226.772
	Label/Z left "\\F'Arial'\\Z24\f00Intensity (arb. units.)"
	
	if(stringmatch(outputtype,"EDC")==1)
		Label/Z bottom"\\F'Arial'\\Z24\f02E-E\BF\M\F'Arial'\\Z24\f00(eV)"
	else
		Label/Z bottom "\\F'Arial'\\Z24\f00k\B//\M\F'Times New Roman'\Z24 (Å\S-1\M\F'Arial'\\Z24)"
	endif

End


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////// fit functions ///////////////////////////////////////////////////
Function linear_bg (w,x) :fitfunc
	wave w
	variable x
	return  w[0]*x
End

Function cubic_bg (w,x) :fitfunc
	wave w
	variable x
	return w[0]*x+w[1]*x^2+w[2]*x^3
End

Function exp1_bg (w,x) :fitfunc
	wave w
	variable x
	return w[0]*exp(x/w[1])
End

Function exp2_bg (w,x) :fitfunc
	wave w
	variable x
	return w[0]*exp(x/w[1])+w[2]*exp(x/w[3])
End

Function onepeaklorfunction(w,x) :FitFunc
	wave w
	variable x
	return   W[0]+W[1]/((x-W[2])^2+W[3]^2)
End

Function onepeaklorfunction_slope(w,x) :FitFunc
	wave w
	variable x
	return   W[0]+W[1]/((x-W[2])^2+W[3]^2)+w[4]*x
End


Function onepeaklorfunction_cubic(w,x) :FitFunc
	wave w
	variable x
	return   W[0]+W[1]/((x-W[2])^2+W[3]^2)+w[4]*x+w[5]*x^2+w[6]*x^3
End

Function twopeaklorfunction(w,x) :FitFunc
   wave w
   variable x
   return   w[0]+w[1]/((x-w[2])^2+w[3]^2)+w[4]/((x-w[5])^2+w[6]^2)
End

Function twopeaklorfunction_slope(w,x) :FitFunc
   wave w
   variable x
   return   w[0]+w[1]/((x-w[2])^2+w[3]^2)+w[4]/((x-w[5])^2+w[6]^2)+w[7]*x
End

Function twopeaklorfunction_cubic(w,x) :FitFunc
   wave w
   variable x
   return   w[0]+w[1]/((x-w[2])^2+w[3]^2)+w[4]/((x-w[5])^2+w[6]^2)+w[7]*x+w[8]*x^2+w[9]*x^3
End

Function FermiDiracfitfunction(w,x) :FitFunc
   wave w
   variable x
   return w[0]+(w[1]+w[4]*(x-w[2]))/(exp((x-w[2])/w[3])+1)
End

Function DiracDispersionfitfunction(w,x) :FitFunc
   wave w
   variable x
   return w[0]+w[1]*abs(x-w[2])
End

Function fourpeaklorfunction(w,x) :FitFunc
   wave w
   variable x
   return  w[0]+w[1]/((x-w[2])^2+w[3]^2)+w[4]/((x-w[5])^2+w[6]^2)+w[7]/((x-w[8])^2+w[9]^2)+w[10]/((x-w[11])^2+w[12]^2)
End

Function fourpeaklorfunction_slope(w,x) :FitFunc
   wave w
   variable x
   return  w[0]+w[1]/((x-w[2])^2+w[3]^2)+w[4]/((x-w[5])^2+w[6]^2)+w[7]/((x-w[8])^2+w[9]^2)+w[10]/((x-w[11])^2+w[12]^2)+w[13]*x
End

Function fourpeaklorfunction_cubic(w,x) :FitFunc
   wave w
   variable x
   return  w[0]+w[1]/((x-w[2])^2+w[3]^2)+w[4]/((x-w[5])^2+w[6]^2)+w[7]/((x-w[8])^2+w[9]^2)+w[10]/((x-w[11])^2+w[12]^2)+w[13]*x+w[14]*x^2+w[15]*x^3
End

Function twopeakgaussfunction(w,x) :FitFunc
   wave w
   variable x
   return w[0]+w[1]*exp(-((x-w[2])/w[3])^2)+w[4]*exp(-((x-w[5])/w[6])^2)
End

Function onepeakvoigtfunction(w,x) : FitFunc
	wave w
	variable x
	//CurveFitDialog/ w[0] = Y0
	//CurveFitDialog/ w[1] = Amp
	//CurveFitDialog/ w[2] = width
	//CurveFitDialog/ w[3] = x0
	//CurveFitDialog/ w[4] = shape
	
	return w[0]+w[1]*VoigtFunc(w[2]*(x-w[3]),w[4])
End

Function onepeakvoigtfunction_slope(w,x) : FitFunc
	wave w
	variable x
	return w[0]+w[1]*VoigtFunc(w[2]*(x-w[3]),w[4])+w[5]*x
End

Function onepeakvoigtfunction_cubic(w,x) : FitFunc
	wave w
	variable x
	return w[0]+w[1]*VoigtFunc(w[2]*(x-w[3]),w[4])+w[5]*x+w[6]*x^2+w[7]*x^3
End

Function twopeakvoigtfunction(w,x) : FitFunc
	wave w
	variable x
	//CurveFitDialog/ w[0] = Y0
	//CurveFitDialog/ w[1] = Amp1
	//CurveFitDialog/ w[2] = width1
	//CurveFitDialog/ w[3] = x1
	//CurveFitDialog/ w[4] = shape1
	//CurveFitDialog/ w[5] = Amp2
	//CurveFitDialog/ w[6] = width2
	//CurveFitDialog/ w[7] = x2
	//CurveFitDialog/ w[8] = shape2
	return w[0]+w[1]*VoigtFunc(w[2]*(x-w[3]),w[4])+w[5]*VoigtFunc(w[6]*(X-W[7]),W[8])
End

Function twopeakvoigtfunction_slope(w,x) : FitFunc
	wave w
	variable x
	return w[0]+w[1]*VoigtFunc(w[2]*(x-w[3]),w[4])+w[5]*VoigtFunc(w[6]*(X-w[7]),w[8])+w[9]*x
End

Function twopeakvoigtfunction_cubic(w,x) : FitFunc
	wave w
	variable x
	return w[0]+w[1]*VoigtFunc(w[2]*(x-w[3]),w[4])+w[5]*VoigtFunc(w[6]*(X-w[7]),w[8])+w[9]*x+w[10]*x^2+w[11]*x^3
End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////Self Energy Panel///////////////////////////////////////////////////////////////
Function ButtonProc_SelfEnergyPanel(ctrlName) : ButtonControl
	String ctrlName
	dowindow/f NewSelfEnergy
	if(V_flag==0)
		Execute "NewSelfEnergy()"		
	endif
End

Window NewSelfEnergy() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(1446,239,1698,521) as "NewSelfEnergy"
	ModifyPanel cbRGB=(56797,56797,56797)
	variable/g selfenergygamma=1
	variable/g selfenergyinvertcheck=1
	String/g selfenergycutname=""
	variable/g selfMDCE=0
	variable/g selfMDCdeltaE=0.01
	variable/g selfMDCnum=1
	variable/g selfMDCInter=0
	variable/g selfkf=0
	variable/g selfvf=0
	Button button0,pos={8.00,2.00},size={59.00,32.00},proc=ButtonProc_selfenergyload,title="Load"
	Button button0,font="Times New Roman",fSize=16,fStyle=1
	PopupMenu popup0,pos={100.00,8.00},size={146.00,21.00},bodyWidth=146,proc=PopMenuProc_selfenergycolor
	PopupMenu popup0,font="Times New Roman",fSize=16
	PopupMenu popup0,mode=1,value= #"\"*COLORTABLEPOP*\""
	SetVariable setvar0,pos={121.00,32.00},size={61.00,22.00},proc=SetVarProc_selfenergygamma,title="γ"
	SetVariable setvar0,font="Times New Roman",fSize=16
	SetVariable setvar0,limits={0.1,inf,0.1},value= _NUM:1
	CheckBox check0,pos={188.00,36.00},size={50.00,19.00},proc=CheckProc_selfenergyinvertcheck,title="Invert"
	CheckBox check0,font="Times New Roman",fSize=16,value= 1,side= 1
	SetVariable setvar1,pos={4.00,34.00},size={106.00,22.00},title="cutname"
	SetVariable setvar1,font="Times New Roman",fSize=16
	SetVariable setvar1,limits={-inf,inf,0},value= selfenergycutname
	SetVariable setvar2,pos={9.00,70.00},size={65.00,22.00},proc=SetVarProc_selfMDCE,title="E"
	SetVariable setvar2,font="Times New Roman",fSize=16
	SetVariable setvar2,limits={-inf,inf,0},value= _NUM:0
	SetVariable setvar3,pos={92.00,70.00},size={85.00,22.00},proc=SetVarProc_selfMDCdeltaE,title="ΔE"
	SetVariable setvar3,font="Times New Roman",fSize=16
	SetVariable setvar3,limits={0.005,inf,0.01},value= _NUM:0.01
	SetVariable setvar4,pos={9.00,97.00},size={84.00,22.00},proc=SetVarProc_selfMDCInter,title="Interval"
	SetVariable setvar4,font="Times New Roman",fSize=16
	SetVariable setvar4,limits={0,inf,0},value= _NUM:0
	SetVariable setvar5,pos={100.00,96.00},size={78.00,22.00},proc=SetVarProc_selfMDCnum,title="Num"
	SetVariable setvar5,font="Times New Roman",fSize=16
	SetVariable setvar5,limits={1,inf,1},value= _NUM:1
	Button button1,pos={185.00,76.00},size={62.00,38.00},proc=ButtonProc_selfMDCtrack,title="Track"
	Button button1,font="Times New Roman",fSize=20
	Button button2,pos={7.00,130.00},size={68.00,33.00},proc=ButtonProc_selfMDCLorfit,title="LorFit"
	Button button2,font="Times New Roman",fSize=20
	SetVariable setvar6,pos={100.00,175.00},size={70.00,25.00},proc=SetVarProc_selfkf,title="k\\BF"
	SetVariable setvar6,font="Times New Roman",fSize=16
	SetVariable setvar6,limits={-inf,inf,0},value= _NUM:0
	SetVariable setvar7,pos={174.00,175.00},size={70.00,25.00},proc=SetVarProc_selfvf,title="v\\BF"
	SetVariable setvar7,font="Times New Roman",fSize=16
	SetVariable setvar7,limits={-inf,inf,0},value= _NUM:0
	Button button3,pos={10.00,173.00},size={77.00,30.00},proc=ButtonProc_baredispersion,title="BareDisp"
	Button button3,font="Times New Roman",fSize=16
	Button button4,pos={100.00,130.00},size={65.00,35.00},proc=ButtonProc_Getselfenergy,title="GetΣ"
	Button button4,font="Times New Roman",fSize=20
EndMacro

Function ButtonProc_selfenergyload(ctrlName) : ButtonControl
	String ctrlName
	String selfenergywavename
	prompt selfenergywavename, "Choose the momentum corrected cut:" popup, wavelist("!*color*",";","DIMS:2,MINCOLS:100")
	doprompt "", selfenergywavename
	if(V_flag)
		return -1
	endif
	String/g selfenergycutname=selfenergywavename
	duplicate/O $selfenergywavename, selfenergycut
	dowindow/f Selfenergygraph
	if(V_flag==0)
		Display/W=(400,200,800,600)/N=Selfenergygraph
		AppendImage/W=Selfenergygraph selfenergycut
		ModifyGraph swapXY=1, tick=2, standoff=0
		ModifyGraph axThick=2
		ModifyGraph zero=4
		ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28,width=255.118,height=340.157
		ModifyGraph mirror=1,fStyle=1,fSize=16,font="Arial"
		Label bottom "\\F'Arial'\\Z24\\f00 k\\B//\\M\\F'Times New Roman'\\Z24(Å\\S-1\\M\\F'Arial'\\Z24)"
		Label left "\\F'Arial'\\Z24\\f02E-E\\BF\\M\\F'Arial'\\Z24\\f00 (eV)"
	endif
	selfenergycolorsetfunc()
End

Function PopMenuProc_selfenergycolor(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	String/g selfenergycolor=popStr	
	colortab2wave $selfenergycolor
	selfenergycolorsetfunc()
End

Function SetVarProc_selfenergygamma (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g selfenergygamma=varNum
	selfenergycolorsetfunc()
End

Function CheckProc_selfenergyinvertcheck(ctrlName,checked) : CheckBoxControl 
	String ctrlName
	Variable checked
	variable/g selfenergyinvertcheck=checked
	selfenergycolorsetfunc()
End

Function selfenergycolorsetfunc()
	String/g selfenergycolor
	variable/g selfenergygamma, selfenergyinvertcheck
	variable size
	wave M_colors, selfenergycut, selfenergycolortab
	duplicate/O M_colors selfenergycolortab
	size=dimsize(selfenergycolortab,0)
	selfenergycolortab[][]=M_colors[size*(p/size)^(selfenergygamma)][q]
	if(selfenergyinvertcheck == 1)
      ModifyImage/Z selfenergycut ctab={*,*,selfenergycolortab,1}
   else
      ModifyImage/Z selfenergycut ctab={*,*,selfenergycolortab,0}
   endif
End

Function SetVarProc_selfMDCE(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g selfMDCE=varNum
End

Function SetVarProc_selfMDCdeltaE(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g selfMDCdeltaE=varNum
End

Function SetVarProc_selfMDCInterval(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g selfMDCInter=varNum
End

Function SetVarProc_selfMDCInter(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g selfMDCInter=varNum
End

Function SetVarProc_selfMDCnum(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g selfMDCnum=varNum
End

Function ButtonProc_selfMDCtrack(ctrlName) : ButtonControl
	String ctrlName
	variable/g selfMDCE, selfMDCdeltaE, selfMDCInter, selfMDCnum
	wave selfenergycut
	if(selfMDCInter<= selfMDCdeltaE && selfMDCnum>1)
		Abort "Please set interval larger than ΔE!"
	endif
	
	variable ksize=dimsize(selfenergycut,1), Esize=dimsize(selfenergycut,0)
	variable deltak=dimdelta(selfenergycut,1), deltaE=dimdelta(selfenergycut,0)
	variable koff=dimoffset(selfenergycut,1), Eoff=dimoffset(selfenergycut,0)
	variable i, j, Eindex1, Eindex2
	if(selfMDCE+(selfMDCnum-1)*selfMDCInter >= Eoff+deltaE*(Esize-1) || selfMDCE <= Eoff)
		Abort "MDC track energy is out of range!"
	endif
	make/O/N=(selfMDCnum) selfMDCEnergy
	selfMDCEnergy[]=selfMDCE+p*selfMDCInter
	make/o/N=(ksize) selfMDCX
	selfMDCX[]=koff+p*deltak
	for(i=1; i<=selfMDCnum; i+=1)
		string tracename="selfMDC"+num2str(i)
		make/O/N=(ksize) $tracename
		wave currentwave=$tracename
		Eindex1=ScaletoIndex(selfenergycut,selfMDCE+(i-1)*selfMDCInter-(selfMDCdeltaE/2),0)
		Eindex2=ScaletoIndex(selfenergycut,selfMDCE+(i-1)*selfMDCInter+(selfMDCdeltaE/2),0)
		for(j=Eindex1; j<=Eindex2; j+=1)
			currentwave[]+=selfenergycut[j][p]
		endfor
	endfor
	selfenergyMDCplot()	
End

Function selfenergyMDCplot()
	String selfMDCwavelist
	variable/g selfMDCnum
	wave selfMDCX
	variable i, offset
	selfMDCwavelist=wavelist("selfMDC*",";","DIMS:1,MINROWS:51")
	dowindow/f selfMDCplotwin
	if(V_flag==0)
		Display/W=(500,200,800,600)/N=selfMDCplotwin
		Showinfo/W=selfMDCplotwin
	else
		string displaylist=wavelist("selfMDC*",";","WIN:selfMDCplotwin")
		variable displaynum=itemsinlist(displaylist)
		for(i=0; i<displaynum; i+=1)
			removefromgraph/Z/W=selfMDCplotwin/Z $stringfromlist(i, displaylist)
		endfor
	endif
	
	for(i=1; i<=selfMDCnum; i+=1)
		wave ywave=$stringfromlist(i,selfMDCwavelist)
		if(i==1)
			offset=0
		else
			offset+=wavemax(ywave)*0.5
		endif
		appendtograph/W=selfMDCplotwin ywave vs selfMDCX
		modifygraph offset($stringfromlist(i,selfMDCwavelist))={0,offset}
	endfor
		ModifyGraph/Z tick=2, mirror=1, lsize=2
		ModifyGraph/Z font="Arial"
		ModifyGraph/Z fSize=16, fStyle=1, standoff=0
		ModifyGraph/Z axThick=2
		ModifyGraph/Z zero(bottom)=4
		Label/Z left "\\F'Arial'\\Z24\f00Intensity (arb. units)"
		Label/Z bottom "\\F'Arial'\\Z24\f00k\B//\M\F'Times New Roman'\\Z24 (Å\S-1\M\F'Arial'\\Z24)"
  		ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28,width=340.157,height=255.118
End


Function ButtonProc_selfMDCLorfit(ctrlName) : ButtonControl
	String ctrlName
	variable w_0, w_1, w_2, w_3
	variable pcsrA, pcsrB, i, offset
	wave selfMDCX
	dowindow/f selfMDCplotwin
	if(V_flag==0)
		Abort "Please show MDCs first!"
	endif
	if (stringmatch(CsrWave(a,""),"") || stringmatch(CsrWave(b,""),""))
       Abort "Set A and B cursors on the MDC!!"
  	endif
  	pcsrA=pcsr(A,"")
	pcsrB=pcsr(B,"")
  	make/O/N=4 selfLorfitcoeff
	prompt w_0, "The fit function reads f=A+h/((x-p)^2+d^2). The background A:" 
 	Prompt w_1, "Peak height h:"
  	Prompt w_2, "Peak position p:" 
  	Prompt w_3, "Peak width d:"
  	doprompt "", w_0, w_1, w_2, w_3
  	if(V_flag)
    	return -1  //user cancel
  	endif
  	
  	selfLorfitcoeff={w_0, w_1*w_3^2, w_2, w_3}
  	string displaylist=wavelist("selfMDC*",";","WIN:selfMDCplotwin")
	variable displaynum=itemsinlist(displaylist)
	make/O/N=(displaynum-1) selfmomentum, selfLorwidth
	for(i=1; i<displaynum; i+=1)
		FuncFit/q onepeaklorfunction selfLorfitcoeff $stringfromlist(i,displaylist)[pcsrA,pcsrB] /X=selfMDCX /D
		selfLorwidth[i-1]=selfLorfitcoeff[3]
		selfmomentum[i-1]=selfLorfitcoeff[2]
		if(i==1)
			offset=0
		else
			offset+=wavemax($stringfromlist(i,displaylist))
		endif
		ModifyGraph/Z offset($"fit_"+stringfromlist(i,displaylist))={0,offset}
		ModifyGraph/Z rgb($"fit_"+stringfromlist(i,displaylist))=(0,0,0)
		ModifyGraph/Z lsize($"fit_"+stringfromlist(i,displaylist))=2
		ModifyGraph/Z lstyle($"fit_"+stringfromlist(i,displaylist))=3
	endfor
	
	wave selfMDCEnergy
	dowindow/f Selfenergygraph
	string plotlist=wavelist("*",";","WIN:Selfenergygraph")
	if(stringmatch(plotlist,"*selfMDCEnergy*")==0)
		AppendtoGraph/VERT/w=Selfenergygraph selfMDCEnergy vs selfmomentum
		ModifyGraph/Z mode=3,marker=8,msize=3,mrkThick=2
	endif
End

Function SetVarProc_selfkf(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g selfkf=varNum
End

Function SetVarProc_selfvf(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable/g selfvf=varNum
End

Function ButtonProc_baredispersion(ctrlName) : ButtonControl
	String ctrlName
	variable/g selfkf, selfvf
	variable k1, k2
	wave selfmomentum, selfMDCEnergy
	if(waveexists(selfmomentum)==0)
		Abort "Please perform Lor fit to MDCs first!"
	endif
	
	make/O/N=101 baredispk, baredispE
	if(selfvf>0)
		k1=selfkf-1.4*(selfkf-wavemin(selfmomentum))
		k2=selfkf+0.2*(selfkf-k1)
		baredispk[]=k1+p*(k2-k1)/100
	else
		k2=selfkf-1.4*(selfkf-wavemax(selfmomentum))
		k1=selfkf+0.2*(selfkf-k2)
		baredispk[]=k1+p*(k2-k1)/100
	endif
	baredispE=selfvf*(baredispk-selfkf)
	dowindow/f Selfenergygraph
	string plotlist=wavelist("*",";","WIN:Selfenergygraph")
	if(stringmatch(plotlist,"*baredispE*")==0)
		AppendtoGraph/VERT/w=Selfenergygraph baredispE vs baredispk
		ModifyGraph/Z lstyle(baredispE)=3,lsize(baredispE)=2,rgb(baredispE)=(0,0,0)
	endif
End

Function ButtonProc_Getselfenergy(ctrlName) : ButtonControl
	String ctrlName
	wave selfmomentum, selfMDCEnergy, selfLorwidth
	variable/g selfkf, selfvf
	if(waveexists(selfmomentum)==0 || waveexists(selfLorwidth)==0)
		Abort "Please do the Lor fit to MDCs first!"
	endif
	duplicate/O selfMDCEnergy, ReSigma
	duplicate/O selfLorwidth, ImSigma
	ReSigma[]=selfMDCEnergy-(selfmomentum[p]-selfkf)*selfvf*1000
	ImSigma=-abs(selfvf)*selfLorwidth*1000
	
	Display; Delayupdate
	AppendtoGraph ReSigma vs selfMDCEnergy
	AppendtoGraph ImSigma vs selfMDCEnergy
	ModifyGraph/Z tick=2, mirror=1, lsize=2
	ModifyGraph/Z font="Arial"
	ModifyGraph/Z fSize=16, fStyle=1, standoff=0
	ModifyGraph/Z axThick=2
	Label/Z left "\\F'Arial'\\Z24\f00Σ (meV)"
	Label bottom "\\F'Arial'\\Z24\\f02 E-E\\BF\\M \\F'Arial'\\Z24\\f00(eV)"
  	ModifyGraph margin(left)=56,margin(bottom)=56,margin(right)=28,margin(top)=28,width=340.157,height=255.118
	ModifyGraph rgb(ImSigma)=(0,0,65535)
	Legend/C/N=text0/J/F=0/B=1/A=MC "\\F'Arial'\\Z24\\s(ReSigma) ReSigma\r\\s(ImSigma) ImSigma"
End



/////////////////////////////////////////////new functions added in newpanel///////////////////////////////////////////////////////////////
Function PopMenuProc_newFuncs(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	if(stringmatch(popStr,"minigr")==1)
		minigr()
	elseif(stringmatch(popStr,"FSjoint")==1)
		FSjoint()
	elseif(stringmatch(popStr,"curvature")==1)
		execute "curv_ini()"
	elseif(stringmatch(popStr,"simulation")==1)
		newsimpanel()
	elseif(stringmatch(popStr,"realspacemap")==1)
		makerealspacemap()
	endif
End



Function minigr() // mini gradient to emphasize the band dispersion
	String minigrwavestr
	prompt minigrwavestr "Please choose the wave to perform mini gradient:", popup, wavelist("*", ";","DIMS:2")
	doprompt "", minigrwavestr
	if(V_flag)
		return -1
	endif
	
	wave rawwave=$minigrwavestr
	variable kexi=dimdelta(rawwave,0)/dimdelta(rawwave,1)
	Differentiate/DIM=0 rawwave/D=$minigrwavestr+"dh"
	Differentiate/DIM=1 rawwave/D=$minigrwavestr+"dv"
	
	duplicate/O rawwave, $minigrwavestr+"gr"
	duplicate/O rawwave, $minigrwavestr+"minigr"
	wave grwave=$minigrwavestr+"gr"
	wave dhwave=$minigrwavestr+"dh"
	wave dvwave=$minigrwavestr+"dv"
	wave minigrwave=$minigrwavestr+"minigr"
	grwave[][]=sqrt((2+4/(1+kexi^2))*dhwave[p][q]^2+(2+4/(1+kexi^2))*dvwave[p][q]^2)
	variable i, j
	for(i=0; i<dimsize(rawwave,0);i+=1)
		for(j=0; j<dimsize(rawwave,1);j+=1)
			if(grwave[i][j]==0)
			//grwave[i][j]=0.01
			endif
		endfor
	endfor
	
	minigrwave=rawwave/grwave
	Display;Delayupdate
	AppendImage $minigrwavestr+"minigr"
	ModifyGraph/Z tick=2
	ModifyGraph/Z mirror=1
	ModifyGraph/Z font="Arial"
	ModifyGraph/Z fSize=16
	ModifyGraph/Z fStyle=1
	ModifyGraph/Z standoff=0
	ModifyGraph swapXY=1 
	ModifyGraph zero(left)=4
	ModifyGraph axThick=2
	Label/Z left "\\F'Arial'\\Z24\f02E-E\BF\M\F'Arial'\\Z24\f00 (eV)"
	Label/Z bottom "\\F'Arial'\\Z24\f00k\B//\M\F'Arial'\\Z24 (Å\S-1\M\F'Arial'\\Z24)"
   ModifyGraph margin(left)=70,margin(bottom)=56,margin(right)=28,margin(top)=28,width=269.291,height=340.157
   ModifyImage/Z $minigrwavestr+"minigr" ctab={0,1,Grays,1}
End


Function FSjoint() //function joint two FS maps together smoothly
	variable i, j, map1avg, map2avg, x1, x2, y1, y2, d1, d2
	String map1str, map2str, newmapstr
	prompt map1str, "Please choose the FSmap1:",  popup wavelist("*", ";", "DIMS:2")
	prompt map2str, "Please choose the FSmap2:",  popup wavelist("*", ";", "DIMS:2")
	prompt newmapstr, "Please enter the new map name:"
	doprompt "", map1str, map2str, newmapstr
	if(V_flag)
		return -1
	endif
	if(stringmatch(map1str, map2str)==1)
		Abort "Please choose two different FS map!"
	endif
	duplicate/O $map1str, FS1
	duplicate/O $map2str, FS2, $newmapstr
	variable map1size1=dimsize(FS1,0)
	variable map1size2=dimsize(FS1,1)
	variable map2size1=dimsize(FS2,0)
	variable map2size2=dimsize(FS2,1)
	if(map1size1!=map2size1 || map2size2!=map2size2)
		Abort "Please choose two FS maps with same size!"
	endif
	
	wavestats/q FS1
	map1avg=V_avg
	FS1/=map1avg
	wavestats/q FS2
	map2avg=V_avg
	FS2/=map2avg
	
	Imagethreshold/T=(0.0001) FS1 // convert the FS map to a binary mapduplicate
	wave M_ImageThresh
	duplicate/O M_ImageThresh, FS1thr
	Imagethreshold/T=(0.0001) FS2 
	duplicate/O M_ImageThresh, FS2thr
	FindContour/DSTX=FS1X/DSTY=FS1Y FS1thr, 255
	FindContour/DSTX=FS2X/DSTY=FS2Y FS2thr, 255 // detect the boundary of FS map
	duplicate/O FS1X, D1wave
	duplicate/O FS2X, D2wave
	
	wave newFSmap=$newmapstr
	for(i=0; i<map1size1; i+=1)
		for(j=0; j<map1size2; j+=1)
			if(FS1[i][j]==0 || FS2[i][j]==0)
				newFSmap[i][j]=FS1[i][j]+FS2[i][j]
			elseif(FS1[i][j]!=0 && FS2[i][j]!=0)
				x1=indextoscale(FS1,i,0)
				y1=indextoscale(FS1,j,1)
				x2=indextoscale(FS2,i,0)
				y2=indextoscale(FS2,j,1)
				D1wave[]=sqrt((x1-FS1X[p])^2+(y1-FS1Y[p])^2)
				D2wave[]=sqrt((x2-FS2X[p])^2+(y2-FS2Y[p])^2)
				d1=wavemin(D1wave)
				d2=wavemin(D2wave)
				newFSmap[i][j]=d1/(d1+d2)*FS1[i][j]+d2/(d1+d2)*FS2[i][j]
				
			endif
		endfor
	endfor
	
	killwaves D1wave, D2wave, FS1thr, FS1X, FS1Y, FS2thr, FS2X, FS2Y, M_ImageThresh
	Display;DelayUpdate
	AppendImage newFSmap
	FSmapjointplot()
End

Function FSmapjointplot()
	ModifyImage/Z [0] ctab= {*,*,Terrain256,1}
	ModifyGraph/Z tick=2
	ModifyGraph/Z mirror=1
	ModifyGraph/Z font="Arial"
	ModifyGraph/Z fSize=16
	ModifyGraph/Z fStyle=1
	ModifyGraph/Z standoff=0
	ModifyGraph zero=4
	ModifyGraph axThick=2
	Label/Z left "\\F'Arial'\\Z24\f00k\By\M\F'Arial'\\Z24 (Å\S-1\M\F'Arial'\\Z24)"
	Label/Z bottom "\\F'Arial'\\Z24\f00k\Bx\M\F'Arial'\\Z24 (Å\S-1\M\F'Arial'\\Z24)"
   ModifyGraph margin(left)=70,margin(bottom)=56,margin(right)=28,margin(top)=28,width=269.291,height={Plan,1,left,bottom}
End