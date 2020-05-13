input = getDirectory("Input directory");
ALDir = "G:\\Data\\Machine learning data\\3D Data Stacks\\Aligned Stacks\\";
ALMAXDir = "G:\\Data\\Machine learning data\\3D-to-2D Converted Data Stacks\\";
CellDir="G:\\Data\\Machine learning data\\3D-to-2D Converted Data Stacks\\Cell\\";
NucDir="G:\\Data\\Machine learning data\\3D-to-2D Converted Data Stacks\\Nucleus\\";
ECMDir="G:\\Data\\Machine learning data\\3D-to-2D Converted Data Stacks\\ECM\\";
CellDir8="G:\\Data\\Machine learning data\\3D-to-2D Converted Data Stacks\\Cell\\8-bit Cell\\";
NucDir8="G:\\Data\\Machine learning data\\3D-to-2D Converted Data Stacks\\Nucleus\\8-bit Nucleus\\";
processFolder(input);
 
function processFolder(input) {
    list = getFileList(input);
    for (i = 0; i < list.length; i++) {
        if(File.isDirectory(list[i]))
            processFolder("" + input + list[i]);
        if(endsWith(list[i],".tif"))
            processFile(input, ALDir, list[i]);
    }
}
 
function processFile(input, output, file) {
    // do the processing here by replacing
    // the following two lines by your own code
          print("Processing: " + input + file);
    //run("Bio-Formats Importer", "open=" + input + file + " color_mode=composite view=Hyperstack stack_order=XYCZT");
    open(input + file);SaveName=getTitle();SaveName2=replace(SaveName,".tif","");
    //targetD= output+SaveName2+File.separator;
	//File.makeDirectory(targetD);
	//targetECM= targetD+"ECM files"+File.separator;
	//File.makeDirectory(targetECM);
//close("C3-ECM-Dup"); close("C1-ECM-Dup");
//selectWindow("C2-ECM-Dup");saveAs("Tiff",targetECM+ "ECM_"+ file);close();


//removing the "black" area of the image
selectWindow(SaveName);run("Make Composite");
run("Z Project...", "projection=[Max Intensity] all");
selectWindow("MAX_"+ SaveName);
run("Z Project...", "projection=[Min Intensity]");
run("Split Channels");
selectWindow("C2-MIN_MAX_" +SaveName);
close();
selectWindow("C1-MIN_MAX_"+SaveName);
close();
selectWindow("C3-MIN_MAX_"+SaveName);
setThreshold(1, 65535);


setTool("wand");
doWand(250,250);
//waitForUser("Using the wand tool select the middle of the thresholded area");
run("ROI Manager...");
roiManager("Add");
selectWindow(SaveName);
roiManager("Select", 0);
run("Crop");
close("MIN_MAX_"+SaveName);
close("MAX_"+SaveName);
close("C3-MIN_MAX_"+SaveName);
selectWindow(SaveName);
  
    print("Saving to: " + ALDir);
    saveAs("TIFF", ALDir+"C"+SaveName2);close(SaveName);
    
    run("Z Project...", "projection=[Max Intensity] all");close("C"+SaveName2+".tif"); 
selectWindow("MAX_C"+SaveName2+".tif");
Stack.setChannel(1); run("Enhance Contrast", "saturated=0.1");
Stack.setChannel(2); run("Enhance Contrast", "saturated=0.2");
Stack.setChannel(3); run("Enhance Contrast", "saturated=0.3");
saveAs("Tiff",ALMAXDir+ "MAX_C"+ SaveName2);
selectWindow("MAX_C"+ SaveName2+".tif");
//rename("MaxName");
//close("MAX_AL_"+file); close(file);

//saveAs("Tiff",pathToOutputFile+ "MAX_"+ BaseName2); MaxName=selectWindow("MAX_"+ BaseName2+".tif");
run("Split Channels");
selectWindow("C3-MAX_C"+ SaveName2+".tif");saveAs("Tiff",NucDir+SaveName2+"_Nuc");rename("Nuc");
selectWindow("C2-MAX_C"+ SaveName2+".tif");saveAs("Tiff",ECMDir+SaveName2+"_ECM");rename("ECM");
selectWindow("C1-MAX_C"+ SaveName2+".tif");saveAs("Tiff",CellDir+SaveName2+"_Cell");rename("Cell");
run("Merge Channels...", "c1=Nuc c2=Cell create keep");selectWindow("Merged");saveAs("Tiff",ALMAXDir+SaveName2+"_Cell-Nuc"); close();
//Converting Nucleus image to 8-bit
selectWindow("Nuc");
run("Median...", "radius=1.5 stack");
selectWindow("Nuc");
run("8-bit");
run("Make Binary", "method=Otsu background=Default calculate black");saveAs("Tiff",NucDir8+"8bit-"+SaveName2+"_Nuc");close();

//converting Cell image to 8-bit
selectWindow("Cell");
run("Median...", "radius=1.5 stack");
run("Unsharp Mask...", "radius=1.5 mask=0.60 stack");run("Convolve...", "text1=[1 2 3 2 1\n2 6 9 6 2\n3 9 81 9 3\n2 6 9 6 2\n1 2 3 2 1] normalize stack");
run("Enhance Contrast", "saturated=0.2");run("Apply LUT", "stack");
run("Make Binary", "method=RenyiEntropy background=Default calculate black");saveAs("Tiff",CellDir8+"8bit-"+SaveName2+"_Cell");close();
roiManager("Delete");
run("Close All");
}