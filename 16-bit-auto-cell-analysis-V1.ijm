inputFolder = getDirectory("Input directory");
//output = getDirectory("Output directory");
//Dialog.create("Naming");
//Dialog.addString("File suffix: ", ".tif", 5);
//Dialog.addString("Date", "01-11-11_");
//Dialog.show();
//suffix = Dialog.getString();
//Date = Dialog.getString();; 
//parentFolder = getPath(inputFolder); //inputFolderPrefix = getPathFilenamePrefix(inputFolder);
outputData = inputFolder + "Output-Data" + File.separator;
if ( !(File.exists(outputData)) ) { File.makeDirectory(outputData); }
outputImages = inputFolder + "Output-Images" + File.separator;
if ( !(File.exists(outputImages)) ) { File.makeDirectory(outputImages); }


processFolder(inputFolder);
 
function processFolder(input) {
    list = getFileList(input);
    for (i = 0; i < list.length; i++) {
        if(File.isDirectory(list[i]))
            processFolder("" + input + list[i]);
        if(endsWith(list[i], ".tif"))
            processFile(input, list[i]);
    }
}
 
function processFile(input, file) {
    // do the processing here by replacing
    // the following two lines by your own code
          print("Processing: " + input + file);
    //run("Bio-Formats Importer", "open=" + input + file + " color_mode=Default view=Hyperstack stack_order=XYCZT");
    open(inputFolder + file);SaveName2=getTitle();SaveName=replace(SaveName2,".tif","");rename(SaveName);
    
//Create a filtered image stack of the 16-bit data, threshold and measure it, then convert to a 8-bit mask.
run("Median...", "radius=1.5 stack");
run("Unsharp Mask...", "radius=1.5 mask=0.60 stack");
run("Convolve...", "text1=[1 2 3 2 1\n2 6 9 6 2\n3 9 81 9 3\n2 6 9 6 2\n1 2 3 2 1] normalize stack");
run("Bleach Correction", "correction=[Simple Ratio] background=600");
resetMinAndMax();
run("Enhance Contrast", "saturated=0.2");run("8-bit");
setAutoThreshold("RenyiEntropy dark");
run("Set Measurements...", "area centroid center perimeter bounding fit shape stack limit redirect=None decimal=3");
run("Analyze Particles...", "size=100-Infinity pixel show=Masks display clear stack");
selectWindow("Results");Table.rename("Results", SaveName+"_WCell");
Table.save(outputData+SaveName+"_WCell.csv");//run("Clear Results"); 
selectWindow("Mask of DUP_"+SaveName);run("Invert LUT");
saveAs("Tiff", outputImages+"8-bit_"+SaveName);rename("Mask");

// Remove masked image planes, duplicate and then substract, save and analyze
selectWindow("Mask");
run("Duplicate...", "duplicate");
selectWindow("Mask");setSlice(1);run("Delete Slice");run("Add...", "value=1 stack");
selectWindow("Mask-1");SliceN=nSlices;
setSlice(SliceN);run("Delete Slice");run("Add...", "value=1 stack");
run("Subtract...", "value=1 stack");
imageCalculator("Subtract create stack", "Mask","Mask-1");
selectWindow("Result of Mask");
setMinAndMax(0, 2);
setThreshold(2, 255);
run("Set Measurements...", "area centroid center perimeter bounding fit shape stack limit redirect=None decimal=3");
run("Analyze Particles...", "size=5-Infinity pixel show=Nothing display clear stack");
selectWindow("Results");Table.rename("Results", SaveName+"_Pro");
Table.save(outputData+SaveName+"_Pro.csv");//run("Clear Results"); 
selectWindow("Result of Mask");
setThreshold(0, 0);
run("Set Measurements...", "area centroid center perimeter bounding fit shape stack limit redirect=None decimal=3");
run("Analyze Particles...", "size=5-Infinity pixel show=Nothing display clear stack");
selectWindow("Results");Table.rename("Results", SaveName+"_Ret");
Table.save(outputData+SaveName+"_Ret.csv");//run("Clear Results"); 
selectWindow("Result of Mask");saveAs("Tiff", outputImages+"P-R_"+SaveName);
    run("Close All");
}


