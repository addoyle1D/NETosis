input = getDirectory("Input directory");
output = getDirectory("Output directory");
Dialog.create("File type");
Dialog.addString("File suffix: ", ".tif", 5);//Dialog.addString("Date", "1-11-11_");
Dialog.show();
suffix = Dialog.getString();
//Date = Dialog.getString();; 
//targetD= output+"Aligned"+File.separator;
//File.makeDirectory(targetD);

processFolder(input);
 
function processFolder(input) {
    list = getFileList(input);
    for (i = 0; i < list.length; i++) {
        if(File.isDirectory(list[i]))
            processFolder("" + input + list[i]);
        if(endsWith(list[i], suffix))
            processFile(input, output, list[i]);
    }
}
 
function processFile(input, output, file) {
    // do the processing here by replacing
    // the following two lines by your own code
          print("Processing: " + input + file);
    //run("Bio-Formats Importer", "open=" + input + file + " color_mode=Default view=Hyperstack stack_order=XYCZT");
    open(input + file);SaveName=getTitle();
        run("Correct 3D drift", "channel=2 multi_time_scale edge_enhance only=5000 lowest=1 highest=21");
selectWindow("registered time points"); //saveAs("Tiff", output+"AL-"+SaveName2);//rename("registered time points");
  
    print("Saving to: " + output); 
    saveAs("TIFF", output+"AL_"+file);close();
    close(SaveName);
}