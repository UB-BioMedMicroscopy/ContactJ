
/*
Advanced Optical Microscopy Unit
Scientific and Technological Centers (CCiTUB). Clinic Medicine Campus
UNIVERSITY OF BARCELONA
C/ Casanova 143
Barcelona 08036 
Tel: 34 934037159

------------------------------------------------
Gemma Martin (gemmamartin@ub.edu) , Maria Calvo (mariacalvo@ub.edu)
------------------------------------------------

Name of Macro: ContactJ.ijm


Date: 31 December 2021

Objective: Analyse contacts between fluorescently labelled lipid droplets and mitochondria from cultured cells in confocal microscopy images. 

Input: .tif format of Confocal microscopy images (nbits, 1 section) of labelled cells, 3 fluorescent channels (lipid droplet labelling, mitochondria labelling and DNA DAPI labelling)

Output: The following parameters are quantified from each cell (in um and um2)and stored in a Data Base results table, registering the file name and number of cell detected: 
		- The total length of the contact sites, the mean length of each contact and the number of contacts detected per cell (a contact is defined as a continuous contact line) between mitochondria and lipid droplets.
	    - Cell Area, number of LDs and Mitochondria, LDs and Mitochondria Total Area, Mean LD Area per cell, Standard deviation of the LD mean Area, Mean LD Perimeter, Total Mitochondria and LD Perimeter,
	      Mitochondria Intensity Parameters.

ImageJ Version: 1.7

Requirements: 
- Colocalization Plugin (Pierre Bourdoncle, Institut Jacques Monod, Service Imagerie, Paris) https://imagej.nih.gov/ij/plugins/colocalization.html. 
- Advanced Weka Segmentation PMID 28369169, doi:10.1093/bioinformatics/btx180

*/

//Close previous images and results

if(isOpen("Results")){
    IJ.deleteRows(0, nResults);
}
run("ROI Manager...");
roiManager("reset"); //to delete previous ROIs
IJ.deleteRows(0, nResults);



//get directory with the images to analyze

dir = getDirectory("Choose images folder. Atention: required 8-bit images with 3 channels.");
list=getFileList(dir);

//create the results folder 

dirRes=dir+"Results"+File.separator;
File.makeDirectory(dirRes);
run("ROI Manager...");



//set measurement options
run("Set Measurements...", "area mean min shape integrated display redirect=None decimal=5");

run("Options...", "iterations=1 count=1 do=Nothing");

////////////////////////////////////// UI CONTACT J ////////////////////////////////////////////////////////////

  title1 = "LD";
  title2 = "Mitochondria";
  comp1=0.2; 
  comp2=0.2;
  ratio=50;
  extension = newArray(".tif", ".lif", ".czi");
  threshold1 = newArray("Default dark", "Huang dark", "Intermodes dark", "IsoData dark", "Li dark", "MaxEntropy dark", "Mean dark", "MinError dark", "Minimum dark", "Moments dark", "Otsu dark", "Percentile dark", "RenyiEntropy dark", "Shanbhag dark", "Triangle dark", "Yen dark");
  threshold2 = newArray("Default dark", "Huang dark", "Intermodes dark", "IsoData dark", "Li dark", "MaxEntropy dark", "Mean dark", "MinError dark", "Minimum dark", "Moments dark", "Otsu dark", "Percentile dark", "RenyiEntropy dark", "Shanbhag dark", "Triangle dark", "Yen dark");

  
  Dialog.create("ContactJ");

  Dialog.addChoice("Images extension:", extension);

  
  Dialog.addMessage("\n Organelle 1\n ");
  Dialog.addString("Name organelle 1:", title1);
  Dialog.addNumber("Compensation organlle 1:", comp1);
  Dialog.addChoice("Threshold organelle 1:", threshold1);

  Dialog.addMessage("\n Organelle 2\n ");
  Dialog.addString("Name organelle 2:", title2);
  Dialog.addNumber("Compensation organlle 2:", comp2);
  Dialog.addChoice("Threshold organelle 2:", threshold2);
 
  Dialog.addMessage("\n");
  Dialog.addNumber("Ratio colocalization (0-100):", ratio);

  Dialog.addCheckbox("Check ROIs", true);

  Dialog.addMessage("\n");

  Dialog.addHelp("https://github.com/UB-BioMedMicroscopy/ContactJ/tree/1.0")
  
  Dialog.show();
  
  title1 = Dialog.getString();
  title2 = Dialog.getString();
  comp1 = Dialog.getNumber();
  comp2 = Dialog.getNumber();
  ratio = Dialog.getNumber();
  extension = Dialog.getChoice();
  threshold1 = Dialog.getChoice();
  threshold2 = Dialog.getChoice();
  check = Dialog.getCheckbox();

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//create the results .txt file 
path = dirRes+"Results.txt";

File.append( "Image \t # Cells \t Area Cell \t Area Mito (um2) \t Mean Grey Value \t Std dev. Grey Value \t RawIntDen \t Median \t # LD \t Mean Area LD (um2) \t Std dev. Area LD (um2) \t Mean Circ. LD \t Mean Perim. LD (um) \t Std dev. Perim LD (um) \t Perim. total LD (um) \t # Contact \t Mean Length contact (um) \t Std dev. Length contact (um) \t  Total length contact (um)", path);


//loop to open each image to analyze inside the folder selected by the user
for(i=0;i<list.length;i++){

	//open images only if met with the extension selected
	if(endsWith(list[i],extension)){

		run("Bio-Formats Importer", "open=[" + dir + list[i] + "] autoscale color_mode=Composite open_all_series rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		numseries=nImages;		
		run("Close All");

		//close all images and open one image each time
		
		for (m=1; m<=numseries; m++) {

			run("Bio-Formats Importer", "open=[" + dir + list[i] + "] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+m);

			setBatchMode(true);
			
			//get title of image			
			title=getTitle();
			t=title;

			ImageID=getImageID();
			run("Duplicate...", "duplicate");

			//split channels and rename each channel. 
			run("Split Channels");

	        for (j=1; j<=nImages; j++) {

	        	selectImage(j);
	        	title=getTitle();
	        	
		        if (matches(title,".*C1.*")==1){   //Change the condition .*C1*. if the green channel is different
		  			mito=getImageID();
					run("Red");
					rename("Mito");
					run("Subtract Background...", "rolling=30"); 	 		
		   	 		getPixelSize(unit, pixelWidth, pixelHeight);
				}		

				if (matches(title,".*C2.*")==1){  //Change the condition .*C2*. if the blue channel is different	        	
		        	ld=getImageID();
		        	rename("LD");
		        	run("Green");
		        	run("Subtract Background...", "rolling=30");       
				}	
				
		        if (matches(title,".*C3.*")==1){   //Change the condition .*C3*. if the red channel is different
					dapi=getImageID();
		        	rename("Dapi");
		        	run("Blue");
				}
	        }

			// ************************* Cells Count ***************************************

			selectImage(dapi);
			run("Duplicate...", "title=DAPI");

			//setBatchMode(true);
			
			//Segment nuclei
			run("Mean...", "radius=7");
			setAutoThreshold("Huang dark");
			setOption("BlackBackground", true);
			run("Convert to Mask");
			run("Fill Holes");
			run("Duplicate...", "title=NucleiMaskUnsegmented");
			run("Distance Map");
			run("Find Maxima...", "prominence=5 output=[Segmented Particles]");
			imageCalculator("Min create", "DAPI","NucleiMaskUnsegmented Segmented");
			run("Analyze Particles...", "size=2000-Infinity pixel show=Masks");
			run("Invert LUT");
			rename("Nuclei");

			//Calculate addition 0.2LD+ 0.2Mitochondria
			selectImage(ld);
			run("Duplicate...", " ");
			rename("LipidDroplet");
			run("Multiply...", "value="+comp1);

			selectImage(mito);
			run("Duplicate...", " ");
			rename("Mitochondria");
			run("Multiply...", "value="+comp2);
			
			imageCalculator("Add create", "LipidDroplet","Mitochondria");
			rename("CellMask");
	
			//Addition: Binary Nuclei and Cell Mask; Cell Territories Segmented Particles
			imageCalculator("Max create", "Nuclei","CellMask");
			run("Find Maxima...", "prominence=100 output=[Segmented Particles]");
			run("Analyze Particles...", "size=1000-Infinity pixel show=Masks add");
		
			// Cells Limits thresholded from the original 3 channels addition 
			selectImage(ImageID);
			run("RGB Color");
			run("8-bit");
			run("Median...", "radius=2");
			setAutoThreshold("Huang dark");
			setOption("BlackBackground", true);
			run("Convert to Mask");
			rename("4channels");
		
			//Segmented Cells:  Cell Territories MIN Cell limits thresholded
			imageCalculator("Min create", "Result of Nuclei Segmented","4channels");
			run("Analyze Particles...", "size=7000-Infinity pixel show=Masks clear add");

			//setBatchMode(false);
			
			//select original image and ask user to check cells ROIs 
			selectImage(ImageID);		
			roiManager("Show All");

			if (check==1) {

				waitForUser("Check Cells ROIs. Delete the excluded ones for measurement. ClicK OK when finished");

			}

			roiManager("Show All");
			roiManager("Show None");
			
			//get the number of cells selected by the user
			numcells=roiManager("count");

			if(numcells>0){
				//setBatchMode(true);
				//measure cell area of each cell
				IJ.deleteRows(0, nResults);
				roiManager("measure");
				AreaCell =newArray(numcells);
				for(k=0;k<numcells;k++){
					AreaCell[k]=getResult("Area",k);
				}
	
				//ROIs of the cells are saved as a .zip
				roiManager("save", dirRes+"_ROI_Cells_"+t +".zip");
	
				//print the number of cells
				print("Number of selected cells in "+t+" image:" + numcells);
	
				IJ.deleteRows(0, nResults);
	
				
				//close unnecessary images
	
	
	
				selectWindow("Mask of Result of Result of Nuclei Segmented");
				close();
				selectWindow("DAPI");
				close();
	
					
				// *************************  Lipid Droplet segmentation  (WEKA)  *******************************
				setBatchMode("exit and display");
				
				selectImage(ld);
	
				run("Duplicate...", " ");
	
				run("Advanced Weka Segmentation");
				wait(3000);
				
				nameweka=getInfo("window.title");
				
				call("trainableSegmentation.Weka_Segmentation.loadClassifier", dir+"model\\classifierLD.model");
				wait(5000);
				call("trainableSegmentation.Weka_Segmentation.loadData", dir+"model\\dataLD.arff");
				wait(5000);
				call("trainableSegmentation.Weka_Segmentation.trainClassifier");
				wait(10000);
				call("trainableSegmentation.Weka_Segmentation.getResult");
				wait(3000);
				
				selectWindow("Classified image");
	
				setBatchMode(true);			
	
				//get the classified image from WEKA results
				run("8-bit");
				setThreshold(0, 135);
				setOption("BlackBackground", false);
				run("Convert to Mask");
	
		
				//set mearurements 
				run("Set Measurements...", "area mean min perimeter shape integrated display redirect=None decimal=5");
	
				//initialize the results arrays for LD results
				CircLDCell =newArray(numcells);
				AreaLDCell =newArray(numcells);
				PerimLDCell =newArray(numcells);
				CircdvLDCell =newArray(numcells);
				AreadvLDCell =newArray(numcells);
				PerimdvLDCell =newArray(numcells);
				numLDs =newArray(numcells);
	
				//measure LD characteristics for each cell
				
				for(k=0;k<numcells;k++){
	
					roiManager("select", k);
	
					run("Analyze Particles...", "size=5-Infinity pixel display exclude clear");
					numLD=nResults;
	
					//Save results in arrays 
									
					CircLD =newArray(numLD);
					AreaLD =newArray(numLD);
					PerimLD =newArray(numLD);
	
					for (j=0;j<numLD;j++){
	
						CircLD[j]=getResult("Circ.",j);
						AreaLD[j]=getResult("Area",j);
						PerimLD[j]=getResult("Perim.", j);		
					}
					
					Array.getStatistics(AreaLD, min, max, meanareaLD, stddesvLD);
					Array.getStatistics(CircLD, min, max, meancircLD, stddesvcircLD);
					Array.getStatistics(PerimLD, min, max, meanperimLD, stddesvperimLD);
	
					CircLDCell[k] =meancircLD;
					AreaLDCell[k] = meanareaLD;
					PerimLDCell[k] =meanperimLD;
					CircdvLDCell[k] =stddesvcircLD;
					AreadvLDCell[k] =stddesvLD;
					PerimdvLDCell[k] =stddesvperimLD;
					numLDs[k] =numLD;	
				}
	
				//reset RoiManager and results window
				roiManager("Deselect");				
				IJ.deleteRows(0, nResults);
						
				// *************************  Mitochondria segmentation    *******************************
						
				selectImage(mito);
				
				run("Duplicate...", " ");
	
				//initialize the results arrays for mitochondria results
				
				AreaMitoCell =newArray(numcells);
				MeangreyMitoCell =newArray(numcells);
				stddesvMitoCell =newArray(numcells);
				RawIntDenMitoCell =newArray(numcells);
				medianMitoCell =newArray(numcells);
				
				//Measure mitochondria characteristics in each cell
	
				run("Set Measurements...", "area limit mean standard modal min perimeter shape integrated median limit display redirect=None decimal=5");
				setAutoThreshold(threshold2);
	
				roiManager("Show All");
				roiManager("Measure");
				
				for(k=0;k<numcells;k++){
	
					//Save results in arrays				
					AreaMitoCell[k]=getResult("Area",k);
					MeangreyMitoCell[k]=getResult("Mean",k);
					stddesvMitoCell[k]=getResult("StdDev",k);
					RawIntDenMitoCell[k]=getResult("RawIntDen",k);
					medianMitoCell[k]=getResult("Median",k);
				}
	
				//Reset results window
				IJ.deleteRows(0, nResults);
	
				//close unnecessary images
				close();
				print(nameweka);
				selectWindow(nameweka);
				close();
				//close();
	
				
				//********************************************************************************************************************
				// ******************************** Colocalization Mitochondria Lipid Droplets ***************************************
				//********************************************************************************************************************
	
				run("Set Measurements...", "area limit mean standard modal min perimeter shape integrated median display redirect=None decimal=5");
	
				//get values of autothreshold for green channel (Yen dark)
				selectImage(ld);
				setAutoThreshold(threshold1);
				getThreshold(thresholdld,thresholdld2);
	
				//get values of autothreshold for red channel (Otsu dark)		
				selectImage(mito);
				setAutoThreshold(threshold2);
				getThreshold(thresholdmito,thresholdmito2);
				
				//colocalization using previous autothresholds
			
				coloc_contactj(ld, mito, thresholdld,thresholdld2,thresholdmito,thresholdmito2,ratio);
				
				//using the colocalized image of colocalization highlighter and combining it with skeletonize, the colocalized perimeter is obtained. 
				
				selectWindow("Colocalized_Points");
	
				//************************************** Skeletonize **********************************************************
	
				//selection of LD masks to obtain Segmented particles of LD
				selectWindow("Classified image");
				roiManager("Show All");
				roiManager("Show None");
	
				run("Analyze Particles...", "size=5-Infinity pixel show=Masks");
				run("Find Maxima...", "prominence=100 light output=[Segmented Particles]");
	
				//Min image calculator between LD segmented particles and colocalization mask
				imageCalculator("Min create", "Colocalized_Points","Mask of Classified image Segmented");
	
				//Skeletonization of the obtained mask
				run("Skeletonize");
	
				//*************************************************************************************************************
	
				//initialize the results arrays for LD-mitochondria contacts
				colocpixels =newArray(numcells);
				colocmicron =newArray(numcells);
				colocstdmicron=newArray(numcells);
				numcontact =newArray(numcells);
	
				//Contact perimeter and contact counts (a contact is defined as a continuous contact line) between mitochondria and lipid droplets are quantified from each cell and stored in arrays.
	
				for(k=0;k<numcells;k++){
	
					roiManager("select", k);
	
					run("Analyze Particles...", "size=0-Infinity display exclude clear");
	
					numcontacts=nResults;
					numcontact[k]=numcontacts;
	
					Areacontact =newArray(numcontacts);
	
					for(n=0;n<numcontacts;n++){
						Areacontact[n]=getResult("Area",n);					
					}
	
					Array.getStatistics(Areacontact, min, max, meanareacontact, stddesvcontact);
					
					colocpixels[k]=meanareacontact;
					colocmicron[k]=colocpixels[k]*pixelWidth;
					colocstdmicron[k]=stddesvcontact*pixelWidth;
				}
	
				roiManager("reset"); //to delete previous ROIs
	
				run("Create Selection");
				roiManager("Add");	
	
				// Save LD-mitochondria contact ROIs
				roiManager("save", dirRes+"_ROI_contact_"+t +".zip");
	
				//Reset results window
				IJ.deleteRows(0, nResults);
	
				//****************************************************************************************
				// ********************************  measurements ****************************************
	
				//all values saved in arrays are saved in a results table 
				
				for(k=0;k<numcells;k++){				
					File.append( t + "\t" + k+1 + "\t" + AreaCell[k] + "\t" + AreaMitoCell[k] + "\t" + MeangreyMitoCell[k] + "\t" + stddesvMitoCell[k] + "\t" + RawIntDenMitoCell[k] + "\t" + medianMitoCell[k] + "\t" + numLDs[k] + "\t" + AreaLDCell[k] + "\t" + AreadvLDCell[k] + "\t" + CircLDCell[k] + "\t" + PerimLDCell[k] + "\t" + PerimdvLDCell[k] + "\t" + PerimLDCell[k]*numLDs[k] + "\t" +  numcontact[k] + "\t" + colocmicron[k] + "\t" + colocstdmicron[k] + "\t" + colocmicron[k]*numcontact[k], path);		
				}
				
			}

			setBatchMode("exit and display");
			
			//close all
			closeImagesWindows();
		}		
	
	}

}

waitForUser("Macro has finished");


// closeall function

function closeImagesWindows(){
	run("Close All");
	if(isOpen("Results")){
		IJ.deleteRows(0, nResults);
	}
	if(isOpen("ROI Manager")){
		roiManager("reset");
	}
	if(isOpen("Threshold")){
		selectWindow("Threshold");
		run("Close");
	}
	if(isOpen("Summary")){
		selectWindow("Summary");
		run("Close");
	}
	if(isOpen("B&C")){
		selectWindow("B&C");
		run("Close");
	}

}



/// *********************** Colocalization function **************************************

function coloc_contactj(green, red, lr,ur,lg,ug,A){
	Stack.getDimensions(width, height, channels, slices, frames);
	if(frames>1){
		selectWindow("Red");
		run("Stack to Hyperstack...","channels=1 slices="+frames+" frames=1 display=Grayscale");
		run("Hyperstack to Stack");
		selectWindow("Green");
		run("Stack to Hyperstack...","channels=1 slices="+frames+" frames=1 display=Grayscale");
		run("Hyperstack to Stack");
		Stack.getDimensions(width, height, channels, slices, frames);
	}
	pixg=newArray(slices*width*height);
	pixr=newArray(slices*width*height);
	selectImage(green);
	f=1;
	for (i=0;i<slices;i++) {
		setSlice(i+1);
		for (x=0;x<width;x++) {
			for (y=0;y<height;y++) {
				pixg[f-1]=getPixel(x,y);
				showProgress(f/(width*height*slices)/3);
				f=f+1;
			}
		}
			
	}
	selectImage(red);
	f=1;			
	for (i=0;i<slices;i++) {
		setSlice(i+1);
		for (x=0;x<width;x++) {
			for (y=0;y<height;y++) {
				pixr[f-1]=getPixel(x,y);
				showProgress((f/(width*height*slices)/3)+1/3);
				f=f+1;
			}
		}
	}
	newImage("Colocalized_Points","32-bit black",width,height,slices);	
	f=1;
	for (i=0;i<slices;i++) {
		setSlice(i+1);
		for (x=0;x<width;x++) {
			for (y=0;y<height;y++) {
				if (pixg[f-1]>lg && pixr[f-1]>lr && pixg[f-1]/pixr[f-1]*100>A && pixr[f-1]/pixg[f-1]*100>A) {
					setPixel(x,y,1);
				}
				else {
					setPixel(x,y,0);
					}
				showProgress((f/(width*height*slices)/3)+2/3);
				f=f+1;
			}
		}	
	}

	run("8-bit");
	setAutoThreshold("Default dark");
	run("Convert to Mask");
}



