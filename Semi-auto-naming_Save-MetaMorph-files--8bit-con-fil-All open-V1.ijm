/*
 * Macro template to process multiple open images
 */

#@ File(label = "Output directory", style = "directory") output
input = getDirectory("Input directory");
//
CellDir="G:\\Data\\Machine learning data\\3D-to-2D Converted Data Stacks\\Cell\\";
NucDir="G:\\Data\\Machine learning data\\3D-to-2D Converted Data Stacks\\Nucleus\\";
ECMDir="G:\\Data\\Machine learning data\\3D-to-2D Converted Data Stacks\\ECM\\";
Dialog.create("Naming the Stack");
Dialog.addString("Cell", "HFF");
Dialog.addString("Experiment", "Mig");
Dialog.addString("CH1", "LA");
Dialog.addString("CH2", "ECM");
Dialog.addString("CH3", "DNA");
Dialog.addString("Dimension", "3D");
Dialog.show();
  Cell = Dialog.getString();
  Exp = Dialog.getString();;
  CH1 = Dialog.getString();;;
  CH2 = Dialog.getString();;;;
  CH3 = Dialog.getString();;;;;

processOpenImages();

/*
 * Processes all open images. If an image matches the provided title
 * pattern, processImage() is executed.
 */
function processOpenImages() {

	n = nImages;
	setBatchMode(true);
	for (i=1; i<=n; i++) {
		selectImage(i);
		imageTitle = getTitle();
		imageId = getImageID();
		//if (matches(imageTitle, "(.*)"+pattern+"(.*)"))
			processImage(imageTitle, imageId, output);
	}
	setBatchMode(false);
}

/*
 * Processes the currently active image. Use imageId parameter
 * to re-select the input image during processing.
 */
function processImage(imageTitle, imageId, output) {
	Date=substring(imageTitle,0,6);
	Substage1=indexOf(imageTitle, "Stage");Substage2=Substage1+7;
	Substage3=substring(imageTitle,Substage1,Substage2);
	Stage=replace(Substage3,"Stage","Pos");
	BaseName=Date+"_"+Cell+"_"+Exp+"_"+CH1+"_"+CH2+"_"+CH3+"_"+Stage;
	DirName1=Date+"_"+Cell+"_"+Exp+"_"+Stage;
	//rename(imageTitle,BaseName);
	//targetD2= output+File.separator+DirName1+File.separator;
//File.makeDirectory(targetD2);
	
	
			print("Processing: " + imageTitle);
	pathToOutputFile = output+DirName1+File.separator;
File.makeDirectory(pathToOutputFile);
	saveAs("Tiff",pathToOutputFile+BaseName);
	selectWindow(BaseName+".tif"); BaseName2=replace(BaseName, ".tif","");
run("Z Project...", "projection=[Max Intensity] all");selectWindow("MAX_"+BaseName+".tif");
Stack.setChannel(1); run("Enhance Contrast", "saturated=0.1");
Stack.setChannel(2); run("Enhance Contrast", "saturated=0.2");
Stack.setChannel(3); run("Enhance Contrast", "saturated=0.3");
saveAs("Tiff",pathToOutputFile+ "MAX_"+ BaseName2); MaxName=selectWindow("MAX_"+ BaseName2+".tif");
run("Split Channels");
selectWindow("C3-"+MaxName);saveAs("Tiff",NucDir+SaveName3+"_"+CH3);
selectWindow("C2-"+MaxName);saveAs("Tiff",CellDir+SaveName3+"_"+CH2);
selectWindow("C1-"+MaxName);saveAs("Tiff",ECMDir+SaveName3+"_"+CH1);

selectWindow(SaveName3+"_"+CH3);
//close("MAX_"+BaseName+".tif");
	//print("Saving to: " + pathToOutputFile);
}
//close("*");