package com.hcl.atma.converter.processor;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Scanner;

import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.Lexer;
import org.antlr.runtime.RecognitionException;
import org.antlr.stringtemplate.StringTemplate;
import org.antlr.stringtemplate.StringTemplateGroup;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.jdt.core.ToolFactory;
import org.eclipse.jdt.core.formatter.CodeFormatter;
import org.eclipse.jdt.core.formatter.DefaultCodeFormatterConstants;
import org.eclipse.jface.text.IDocument;
import org.eclipse.text.edits.MalformedTreeException;
import org.eclipse.text.edits.TextEdit;

import com.hcl.atma.converter.generator.NamingUtil;
import com.hcl.atma.converter.generator.TargetWorkspaceManager;
import com.hcl.atma.converter.parsers.CSharp;
import com.hcl.atma.converter.parsers.CSharpAngular;
import com.hcl.atma.converter.parsers.CSharpJason;
import com.hcl.atma.converter.util.ANTLRFileStreamWithBOM;
import com.hcl.atma.converter.util.CSharpPreProcessorImpl;
import com.hcl.atma.converter.util.FileUtil;

public class TranslationProcessor {
    CommonTokenStream tokens;
    public static String inputFileName;
    public static boolean createInterface=false;
    public static String dirName;
    static List<String> methodList= null;


    public static String readFile(File file) throws IOException {
	BufferedReader reader = new BufferedReader(new FileReader(file));
	String lineText = null;
	StringBuffer fileContent = new StringBuffer();
	while ((lineText = reader.readLine()) != null) {		
	    fileContent.append(lineText);
	    fileContent.append("\n");		
	}
	reader.close();
	//	File tempFile = new File(TargetWorkspaceManager.getInputFolder() + File.separator + "temp" + File.separator + "processedSource.txt");
	//	FileUtil.writeContentToFile(tempFile, fileContent.toString(), true);
	return fileContent.toString();
    }


    public String processFile(String fileContent, String fileName, String dir)
	    throws IOException, RecognitionException {

	if (dir.endsWith("class")) {
		createInterface = true;
	    ANTLRFileStreamWithBOM charStream = new ANTLRFileStreamWithBOM(dir+File.separator+fileName);
	    if(createInterface){
			fileName = fileName.replace(".cs", ".java");
			String fileNamefortype = fileName.replace(".java", "");
			String path = "D:\\workspace\\ATMA_Conversion\\Conversion\\CSharpConverter\\resources_nbcu\\output\\Interface"+File.separator+"I"+fileName;
			File file = new File(path);
			FileWriter writer = new FileWriter(file);
			BufferedWriter bffileWriter = new BufferedWriter(writer);
			Scanner sc = new Scanner(fileContent);
			StringBuilder interfacefile = new StringBuilder();
			interfacefile.append("package com.nbcu.compass;\n\n"+
					"import java.util.Date;\n"+
					"import java.util.List;\n\n"+
					"public interface "+"I"+fileNamefortype +"{\n\n" );
			while (sc.hasNextLine()) {
				String i = sc.nextLine();
				if(i.contains("public")){
					if(i.contains("IEnumerable")){
						i = i.replaceAll("IEnumerable", "List");
					}
					if(i.contains("string")){
						i = i.replaceAll("string", "String");
					}
					if(i.contains("class")){
//						goto while;
					}
					interfacefile.append(i +";"+"\n");				
				}

				System.out.println(i);
			}
			if(interfacefile != null){
				try {			
					interfacefile.append("\n}\n");
					bffileWriter.write(interfacefile.toString());
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			sc.close();
			bffileWriter.close();
		}
	    Lexer lexi = new CSharpPreProcessorImpl(charStream);
	    CommonTokenStream tokenStream = new CommonTokenStream(lexi);
	    CSharp treeParser = new CSharp(tokenStream);
	    setupTemplates(treeParser,dir);
	    CSharp.cSharp_return retu =treeParser.cSharp();
	    System.out.println("Java file generated " + NamingUtil.toClassName(fileName.contains(".cs") ? fileName.replace(".cs", ".java") : fileName.replace(".CS", ".java")));
	    return retu.javaContent;

	}
	if (dir.endsWith("service")) {
	    ANTLRFileStreamWithBOM charStream = new ANTLRFileStreamWithBOM(dir+File.separator+fileName);
	    Lexer lexi = new CSharpPreProcessorImpl(charStream);
	    CommonTokenStream tokenStream = new CommonTokenStream(lexi);
	    CSharpJason treeParser = new CSharpJason(tokenStream);
	    setupTemplates(treeParser,dir);
	    CSharpJason.cSharp_return retu =treeParser.cSharp();
	     methodList=treeParser.methodList;
	    System.out.println("Java file generated " + NamingUtil.toClassName(fileName.contains(".cs") ? fileName.replace(".cs", ".java") : fileName.replace(".CS", ".java")));
	    return retu.javaContent;

	}
	else if (dir.endsWith("controller")) {
	    ANTLRFileStreamWithBOM charStream = new ANTLRFileStreamWithBOM(dir+File.separator+fileName);
	    Lexer lexi = new CSharpPreProcessorImpl(charStream);
	    CommonTokenStream tokenStream = new CommonTokenStream(lexi);
	    CSharpAngular treeParser = new CSharpAngular(tokenStream);
	    setupTemplates(treeParser,dir);
	    CSharpAngular.cSharpAngular_return retu =treeParser.cSharpAngular();
	    System.out.println("Java file generated " + NamingUtil.toClassName(fileName.contains(".cs") ? fileName.replace(".cs", ".js") : fileName.replace(".CS", ".js")));
	    return retu.javaContent;
	}
	else if (dir.endsWith("viewdata")) {
	    ANTLRFileStreamWithBOM charStream = new ANTLRFileStreamWithBOM(dir+File.separator+fileName);
	    Lexer lexi = new CSharpPreProcessorImpl(charStream);
	    CommonTokenStream tokenStream = new CommonTokenStream(lexi);
	    CSharpAngular treeParser = new CSharpAngular(tokenStream);
	    setupTemplates(treeParser,dir);
	    CSharpAngular.cSharpAngular_return retu =treeParser.cSharpAngular();
	    System.out.println("Java file generated " + NamingUtil.toClassName(fileName.contains(".cs") ? fileName.replace(".cs", ".js") : fileName.replace(".CS", ".js")));
	    return retu.javaContent;
	}
	return "";
    }

    private static void setupTemplates(Object treeParser,String dir) throws IOException {
	Reader reader = null;
	if (treeParser instanceof CSharpAngular) {
	    if (dir.endsWith("controller")) {
		reader = new FileReader("st" + File.separator + "cSharpAngular.stg");
	    }
	    else	if (dir.endsWith("viewdata")) {
		reader = new FileReader("st" + File.separator + "cSharpAngularViewData.stg");
	    }

	    ((CSharpAngular) treeParser).setTemplateLib(new StringTemplateGroup(reader));
	} 
	else if (treeParser instanceof CSharp) {
	    reader = new FileReader("st" + File.separator + "cSharpSpring.stg");
	    ((CSharp) treeParser).setTemplateLib(new StringTemplateGroup(reader));
	} 
	else if (treeParser instanceof CSharpJason) {
	    reader = new FileReader("st" + File.separator + "cSharp.stg");
	    ((CSharpJason) treeParser).setTemplateLib(new StringTemplateGroup(reader));
	} 
	reader.close();
    }


    

    public static void main(String[] args) throws IOException,
    RecognitionException {
	if (args.length < 3) {
	    System.out.println("Incorrect usage; Please provide correct program arguments");
	    System.out.println("<resources folder> <application name> <company name> [sourcetype (class/all)]");
	    return;
	}
	String sourceType = "all";
	if (args.length > 3) {
	    sourceType = args[3];
	}
	TargetWorkspaceManager.setApplicationName(args[1]);
	TargetWorkspaceManager.setCompanyName(args[2]);
	TargetWorkspaceManager.setResourcesFolder(args[0]);

	String outputDir = TargetWorkspaceManager.getOutputFolder();
	String inputDir = TargetWorkspaceManager.getInputFolder();
	String viewdataDir = inputDir + File.separator + "viewdata";
	String classDir = inputDir + File.separator + "class";
	String controllerDir = inputDir + File.separator + "controller";
	String serviceDir = inputDir + File.separator + "service";
	List<String> dirList = new ArrayList<String>();
	if (sourceType.equalsIgnoreCase("viewdata")) {
	    dirList.add(viewdataDir);
	}else if (sourceType.equalsIgnoreCase("controller")) {
	    dirList.add(controllerDir);
	} else if (sourceType.equalsIgnoreCase("class")) {
	    dirList.add(classDir);
	}
    else if (sourceType.equalsIgnoreCase("service")) {
	    dirList.add(serviceDir);
	}
	else {
	    dirList.add(viewdataDir);
	    dirList.add(controllerDir);
	    dirList.add(classDir);
	    dirList.add(serviceDir);
	} 
	List<String> successList = new ArrayList<String>();
	List<String> failedList = new ArrayList<String>();
	int totalCount = 0;
	String outputFolderDir = null;
	    String outputPackage = "";
	for (String input : dirList) {
	    for (File file : ProcessorUtil.listDirectory(input,ProcessorUtil.suffixes)) {
		totalCount++;
		try {
		    System.out.println("Processing the file " + file.getName());
		    String fileName = file.getName();
		    inputFileName = fileName;
		    dirName = input;
		    String javaFile = new TranslationProcessor().processFile(readFile(file), fileName, input);
		    File outputFolder = null;
		    outputFolder = new File(outputDir);
		    if (input.contains("controller")) {
		    	if(fileName.contains("Model")){
		    		fileName = fileName.replace("Model", "");
		    	}else if(fileName.contains("Helper")){
		    		fileName = fileName.replace("Helper", "");
		    	}
			outputFolderDir = outputDir + File.separator + "controller";
			outputPackage = outputFolder + File.separator + "controller" + File.separator + NamingUtil.getControllerName(NamingUtil.toClassName(fileName.contains(".cs") ? fileName.replace(".cs", "Controller.js") : fileName.replace(".CS", "Controller.js")));
			if(new File(outputPackage).exists()){
	    		String line = "";
	    		StringBuilder firstBuilder = new StringBuilder();
	    		File firstFile = new File(outputPackage);
	    		BufferedReader br = new BufferedReader(new FileReader(firstFile)); 
	    		while ((line=br.readLine())!=null) {
	    			firstBuilder.append(line);
	    			firstBuilder.append("\n");
	    		}
	    		br.close();
	    		line = firstBuilder.toString();
	    		line = line.substring(0, line.lastIndexOf("}"));
	    		javaFile = javaFile.substring(javaFile.indexOf("{")+1);
	    		javaFile = line +"\n\n /*  -------MODEL LAYER------ */\n"+ javaFile;
	    		if(new File(outputPackage).delete()){
	    		}
	    	}
		    }else if (input.contains("viewdata")) {
		    	if(fileName.contains("UIEntity")){
		    		fileName = fileName.replace("UIEntity", "");
		    	}
			outputFolderDir = outputDir + File.separator + "viewdata";
			outputPackage = outputFolder + File.separator + "viewdata" + File.separator + NamingUtil.getControllerName(NamingUtil.toClassName(fileName.contains(".cs") ? fileName.replace(".cs", ".js") : fileName.replace(".CS", ".js")));
		    }else if (input.contains("class")) {
		    	if(fileName.contains("Entity") || fileName.contains("Data")){
		    		fileName = fileName;
		    	}else{
		    		fileName = fileName.replace(".cs", "Dao.cs");
		    	}
			outputFolderDir = outputDir + File.separator + "class";
			outputPackage = outputFolder + File.separator + "class" + File.separator + NamingUtil.toClassName(fileName.contains(".cs") ? fileName.replace(".cs", ".java") : fileName.replace(".CS", ".java"));
		    }
		    else if (input.contains("service")) {
		    	outputFolderDir = outputDir + File.separator + "service";
		    	outputPackage = outputFolder + File.separator + "service" + File.separator + NamingUtil.toClassName(fileName.contains(".cs") ? fileName.replace(".cs", ".js") : fileName.replace(".CS", ".js"));
		    	StringBuilder output = new StringBuilder();
		    	output.append("app.service(\'adminService\', function (ajaxService) {\n");
		    	output.append(" var config = {\n"+
		    			"headers : {\n"+
		    			"'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8;' }\n"+
		    			"}\n");

		    	for (Iterator iterator = methodList.iterator(); iterator.hasNext();) {
		    		String methodName = (String) iterator.next();
		    		output.append(createJasonService(methodName)+"\n");
		    	}
		    	output.append("});");
		    	FileUtil.writeContentToFile(new File(outputPackage), output.toString(), true);
		    	outputPackage = outputFolder + File.separator + "service" + File.separator + NamingUtil.toClassName(fileName.contains(".cs") ? fileName.replace(".cs", ".java") : fileName.replace(".CS", ".java"));
		    }
		    else {
			outputPackage = outputFolder + File.separator + "other" + File.separator + NamingUtil.toClassName(fileName.replace( ".txt", ".java"));
		    }
		    File outputDirFolder = new File(outputFolderDir);
		    if(!outputDirFolder.exists()) {
			outputDirFolder.mkdirs();
		    }
		    File outputFile = new File(outputPackage);
		    OutputStreamWriter out = new OutputStreamWriter(new FileOutputStream(outputFile));
		    out.write(javaFile);
		    Runtime.getRuntime().exec("lib/AStyle/bin/AStyle.exe -A2 -s4 -p -N -f -E --mode=java --suffix=none "+outputFile);
		    out.close();
		    successList.add(file.getName());
		    outputPackage = "";
		    outputFolderDir = null;
		} catch (Exception ex) {
		    ex.printStackTrace();
		    System.out.println("Failed ---- " + file.getName());
		    failedList.add(file.getName());
		}
	    }
	}
	try {
	    Thread.sleep(100);
	} catch (InterruptedException e) {
	}
	System.out.println("Summary:");
	System.out.println("=================================");
	System.out.println("Total Processed = " + totalCount);
	System.out.println("Success = " + successList.size());
	System.out.println("Failed = " + failedList.size());
	System.out.println("=================================");
	System.out.println("Success: ");
	for (String success : successList) {
	    System.out.println(success);
	}
	System.out.println("Failed: ");
	for (String failed : failedList) {
	    System.out.println(failed);
	}
    }
    public static String createJasonService(String methodName){
		 Reader reader = null;
		 StringTemplateGroup group;
		 StringTemplate st = null;
		 try {
				reader = new FileReader("st\\cSharp.stg");
			} catch (FileNotFoundException e1) {
					e1.printStackTrace();
			}

			group = new StringTemplateGroup(reader);
			st = group.getInstanceOf("jasonService");
			st.setAttribute("methodName", methodName);
			return st.toString();
	}

    @SuppressWarnings("unused")
	private static String getJavaFileName(String fileName) {
	String javaName = null;
	if (fileName.contains(".cs")) {
	    javaName = fileName.replace(".cs", ".java");
	} else {
	    javaName = fileName.replace(".txt", ".java");
	}
	return javaName;
    }



    @SuppressWarnings({ "rawtypes", "unchecked" })
    public static String formatOutput(String inputContent) throws IOException {
	// System.out.println("formatting the output");
	Map options = DefaultCodeFormatterConstants.getEclipseDefaultSettings();
	// initialize the compiler settings to be able to format 1.5 code
	options.put(JavaCore.COMPILER_COMPLIANCE, JavaCore.VERSION_1_6);
	options.put(JavaCore.COMPILER_CODEGEN_TARGET_PLATFORM,
		JavaCore.VERSION_1_6);
	options.put(JavaCore.COMPILER_SOURCE, JavaCore.VERSION_1_6);

	// change the option to wrap each enum constant on a new line
	options.put(
		DefaultCodeFormatterConstants.FORMATTER_BRACE_POSITION_FOR_METHOD_DECLARATION,
		DefaultCodeFormatterConstants.createAlignmentValue(true,
			DefaultCodeFormatterConstants.WRAP_ONE_PER_LINE,
			DefaultCodeFormatterConstants.INDENT_DEFAULT));
	// instantiate the default code formatter with the given options
	final CodeFormatter codeFormatter = ToolFactory
		.createCodeFormatter(options);

	final TextEdit edit = codeFormatter.format(
		CodeFormatter.K_MULTI_LINE_COMMENT, // format a compilation unit
		inputContent, // source to format
		0, // starting position
		inputContent.length(), // length
		0, // initial indentation
		System.getProperty("line.separator") // line separator
		);

	IDocument document = new org.eclipse.jface.text.Document(inputContent);
	try {
	    if (edit != null) {
		edit.apply(document);
	    }
	} catch (MalformedTreeException e) {
	    e.printStackTrace();
	} catch (org.eclipse.jface.text.BadLocationException e) {
	    e.printStackTrace();
	}
	return document.get();
    }
}
