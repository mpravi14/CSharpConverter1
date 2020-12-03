package com.hcl.atma.converter.generator;

import java.io.File;


/**
 * Component to manage the contents of the target workspace. Provides methods to access 
 * target workspace folders and their content. Also handles creation / updation of various 
 * types of constituents of the workspace
 *   
 * @author Shivaramesh
 */
public class TargetWorkspaceManager {

    private static TargetWorkspaceManager instance = null;

    private static String applicationName = "i3m"; // default app name
    private static String companyName = "nordea"; // default company name

    private static String resourcesDirectory = null; 
    private static String inputDirectory = null; 
    private static String outputDirectory = null; 

    private TargetWorkspaceManager() {
    }

    public File getTemplatesDirectory() {
	File javaTemplatesDir = new File(getInputFolder() + File.separator + "javatemplates");
	return javaTemplatesDir;
    }

    //	public boolean createViewFile(String title, StringBuffer viewSource) {
    //		try {
    //			File viewFile = new File(getWebContentDirectory(), title.toLowerCase() + ".xhtml");
    //			FileUtil.writeContentToFile(viewFile, viewSource.toString(), true);
    //		} catch (IOException ioe) {
    //			ioe.printStackTrace();
    //			return false;
    //		}
    //		return true;
    //	}
    //	

    public static File getTargetWorkspaceDirectory() {

	// TODO read from props file / program arguments
	File wsp = new File(outputDirectory + File.separator + applicationName + "Workspace"); 
	if(!wsp.exists()) {
	    boolean created = wsp.mkdirs();
	    if(!created) {
		System.out.println("Unable to create target workspace directory; exiting...");
		System.exit(1);
		return null;
	    }
	}
	return wsp;
    }

    public static File getWebProjectRoot() {
	File wsp = getTargetWorkspaceDirectory();
	File webProjectRoot = new File(wsp, applicationName+"_Java");
	if(!webProjectRoot.exists()) {
	    boolean created = webProjectRoot.mkdirs();
	    if(!created) {
		System.out.println("Unable to create web project directory; exiting...");
		System.exit(1);
		return null;
	    }
	}
	return webProjectRoot;
    }

    public static File getWebProjectSourceDir() {
	File webProjectSourceDir = new File(getWebProjectRoot(), "src");
	if(!webProjectSourceDir.exists()) {
	    boolean created = webProjectSourceDir.mkdirs();
	    if(!created) {
		System.out.println("Warning: Unable to create src dirictory in web project root");
		return null;
	    }
	}
	return webProjectSourceDir;
    }

    public static File getMapperXMLDir() {
	//		String ret = getWebProjectSourceDir().getAbsolutePath() + File.separator
	//				 + "com" + File.separator
	//				 + getCompanyName() + File.separator
	//				 + getApplicationName() + File.separator
	//				 + "server" + File.separator + "data" + File.separator + "xml";
	String ret = getWebProjectRoot().getAbsolutePath() + File.separator
		+ "config" + File.separator
		+ "sqlMap" ;
	return new File(ret);
    }

    public static File getMapperInterfaceDir() {
	String ret = getWebProjectSourceDir().getAbsolutePath() + File.separator
		+ "com" + File.separator
		+ getCompanyName() + File.separator
		+ getApplicationName() + File.separator
		+ "server" + File.separator + "data" + File.separator + "dao";
	return new File(ret);
    }
    public static File getWebContentDirectory() {
	File webProj = getWebProjectRoot();
	File webContentRoot = new File(webProj, "WebContent");
	if(!webContentRoot.exists()) {
	    boolean created = webContentRoot.mkdir();
	    if(!created) {
		System.out.println("Unable to create web content directory; exiting...");
		System.exit(1);
		return null;
	    }
	}
	return webContentRoot;
    }

    public static String getApplicationName() {
	return applicationName;
    }

    public static void setApplicationName(String name) {
	applicationName = name;
    }

    public static void setOutputFolder(String dir) {
	outputDirectory = dir;
    }

    public static String getOutputFolder() {
	return outputDirectory;
    }

    public static String getCompanyName() {
	return companyName;
    }

    public static void setCompanyName(String companyName) {
	TargetWorkspaceManager.companyName = companyName;
    }

    public static String getInputFolder() {
	return inputDirectory;
    }

    public static void setInputFolder(String sourcesDirectory) {
	TargetWorkspaceManager.inputDirectory = sourcesDirectory;
    }

    public static String getResourcesFolder() {
	return resourcesDirectory;
    }

    public static void setResourcesFolder(String resources) {
	resourcesDirectory = resources;
	setInputFolder(resourcesDirectory + File.separator + "input");
	setOutputFolder(resourcesDirectory + File.separator + "output");
    }

}
