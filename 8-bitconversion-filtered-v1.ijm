inputFolder = getDirectory("Input directory");
//output = getDirectory("Output directory");
//Dialog.create("Naming");
//Dialog.addString("File suffix: ", ".tif", 5);
//Dialog.addString("Date", "01-11-11_");
//Dialog.show();
//suffix = Dialog.getString();
//Date = Dialog.getString();; 
//parentFolder = getPath(inputFolder); //inputFolderPrefix = getPathFilenamePrefix(inputFolder);
outputImages = inputFolder + "New 8_bit" + File.separator;
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
saveAs("Tiff", outputImages+"8-bit_"+SaveName);
run("Close All");;
}
