package com.hcl.atma.converter.processor;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.util.Arrays;
import java.util.LinkedList;

import com.hcl.atma.converter.generator.TargetWorkspaceManager;
import com.hcl.atma.converter.util.FileUtil;

public class InventoryManager {
	
	/* reads frm files from forms_pending folder and removes controller code*/
	private static void prepareFormSources() {
		String inputDir = TargetWorkspaceManager.getInputFolder();
		String formsDir = inputDir + File.separator + "form_pending";
		for (File file : ProcessorUtil.listDirectory(formsDir, Arrays.asList(".frm"))) {
			try {
				StringBuilder formContent = new StringBuilder();
				System.out.println("Processing the file " + file.getName());
				String fileName = file.getAbsolutePath(); //  file.getName();
				LinkedList<String> lines = FileUtil.getLinesFromFile(fileName);
				boolean skip = true;
				for (String lineString : lines) {
					if(skip == true 
							&& (lineString.startsWith("Begin VB.Form")
									|| lineString.startsWith("Begin VB.MDIForm"))) {
						skip = false;
					}
					if(skip == false 
							&& (lineString.startsWith("Attribute ")
									|| lineString.startsWith("Option Explicit"))) {
						skip = true;
					}
					if(!skip) {
						if(!lineString.contains(".ValueItems")) {
							formContent.append(lineString);
							formContent.append("\n");
						}
					}
				}
//				File outputFile = new File();
//				if(!outputFile.exists()) {
//					outputFile.createNewFile();
//				}
				OutputStreamWriter out = new OutputStreamWriter(new FileOutputStream(file));
				out.write(formContent.toString());
				out.close();
				System.out.println("Processing for form completed! ");
			} catch(Exception ex) {
				ex.printStackTrace();
			}
		}
	}
	
	private static void prepareControllerSources() {
		String inputDir = TargetWorkspaceManager.getInputFolder();
		String controllersDir = inputDir + File.separator + "controller";
		for (File file : ProcessorUtil.listDirectory(controllersDir, Arrays.asList(".frm"))) {
			try {
				StringBuilder formContent = new StringBuilder();
				System.out.println("Processing the file " + file.getName());
				String fileName = file.getAbsolutePath(); 
				LinkedList<String> lines = FileUtil.getLinesFromFile(fileName);
				boolean skip = false;
				for (String lineString : lines) {
					if(skip == false 
							&& (lineString.startsWith("Begin VB.Form")
									|| lineString.startsWith("Begin VB.MDIForm"))) {
						skip = true;
					}
					if(skip == true 
							&& (lineString.startsWith("Attribute ")
									|| lineString.startsWith("Option Explicit"))) {
						skip = false;
						formContent.append("\n");
					}
					if(!skip) {
						formContent.append(lineString);
						formContent.append("\n");
					}
				}
				OutputStreamWriter out = new OutputStreamWriter(new FileOutputStream(file));
				out.write(formContent.toString());
				out.close();
				System.out.println("Processing for controller completed! ");
			} catch(Exception ex) {
				ex.printStackTrace();
			}
		}
	}

	public static void main(String[] args) {
		if (args.length < 1) {
			System.out.println("Incorrect usage; Please provide correct program arguments");
			System.out.println("<resources folder> [sourcetype (form/controller/loc/all)]");
			return;
		}
		String sourceType = "all";
		if (args.length > 1) {
			sourceType = args[1];
		}
		TargetWorkspaceManager.setResourcesFolder(args[0]);

		if (sourceType.equalsIgnoreCase("form")) {
			prepareFormSources();
		} else if (sourceType.equalsIgnoreCase("controller")) {
			prepareControllerSources();
		} else if (sourceType.equalsIgnoreCase("loc")) {
			if (args.length < 3) {
				System.out.println("Incorrect usage; Please provide source location");
				System.out.println("<resources folder> loc <source folder>");
			} else {
				int loc = 0;
				int fileCount = 0;
				int formCount = 0;
				String countLocation = args[2];
				for (File file : ProcessorUtil.listDirectory(countLocation, Arrays.asList(".frm", ".cls", ".bas", ".mod", ".FRM", ".CLS", ".BAS", ".MOD"))) {
					fileCount++;
					try {
						String fileName = file.getAbsolutePath(); 
						LinkedList<String> lines = FileUtil.getLinesFromFile(fileName);
						loc+= lines.size();
						if(fileName.endsWith(".frm") || fileName.endsWith(".FRM")) {
							System.out.println(file.getName() + ", " + lines.size());
							formCount++;
						}
					} catch (Exception ex) {
						ex.printStackTrace();
					}
				}
				System.out.println("LoC Count: " + loc);
				System.out.println("File Count: " + fileCount);
				System.out.println("Form Count: " + formCount);
				
			}
		} else {
			prepareFormSources();
			prepareControllerSources();
		}
		
	}

}
