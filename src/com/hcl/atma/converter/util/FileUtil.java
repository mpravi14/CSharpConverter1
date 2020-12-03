package com.hcl.atma.converter.util;

import japa.parser.JavaParser;
import japa.parser.ParseException;
import japa.parser.ast.CompilationUnit;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import com.hcl.atma.converter.generator.TargetWorkspaceManager;

/**
 *     
 * @author Shivaramesh
 */
public class FileUtil {
	
	public static void appendToEntityMappingsFile(String entityName, String entityMapping) throws IOException {
		String emFileName = TargetWorkspaceManager.getWebProjectRoot() + File.separator + "config" 
				+ File.separator + "sqlMap" + File.separator + entityName.toLowerCase() + ".xml";
		File emFile = new File(emFileName);
		if(!emFile.exists()) {
			FileUtil.prepareEntityMappingsFile(entityName);
		}
		RandomAccessFile raFile = new RandomAccessFile(emFile, "rw");
		raFile.seek(raFile.length());
		raFile.writeBytes(entityMapping);
		raFile.writeBytes("\n");
		raFile.close();
	}
	
	private static void prepareEntityMappingsFile(String entityName) throws IOException {
		String emFileName = TargetWorkspaceManager.getWebProjectRoot() + File.separator + "config" 
							+ File.separator + "sqlMap" + File.separator + entityName.toLowerCase() + ".xml";
		File emFile = new File(emFileName);
		if(!emFile.exists()) {
			StringBuilder header = new StringBuilder();
			header.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
			header.append("\n");
			header.append("<entity-mappings version=\"1.0\" xmlns=\"http://java.sun.com/xml/ns/persistence/orm\""); 
			header.append("\n");
			header.append("			xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"");
			header.append("\n");
			header.append("			xsi:schemaLocation=\"http://java.sun.com/xml/ns/persistence/orm http://java.sun.com/xml/ns/persistence/orm_1_0.xsd\">");
			header.append("\n\n");
			FileUtil.writeContentToFile(emFile, header.toString(), true);
		}
	}
	
	public static void finalizeEntityMappingsFile(String entityName) throws IOException {
		String emFileName = TargetWorkspaceManager.getWebProjectRoot() + File.separator + "config" 
				+ File.separator + "sqlMap" + File.separator + entityName.toLowerCase() + ".xml";
		File emFile = new File(emFileName);
		if(emFile.exists()) {
			RandomAccessFile raFile = new RandomAccessFile(emFile, "rw");
			raFile.seek(raFile.length());
			raFile.writeBytes("</entity-mappings>");
			raFile.writeBytes("\n");
			raFile.close();
		}
	}
	
	public static boolean checkFileExists(String fileName) {
		File f = new File(fileName);
		return f.exists();
	}
	
	public static CompilationUnit loadCompilationUnitFromFile(File fbFile) {
		CompilationUnit javaCU = null;
		try {
			if(!fbFile.exists()) {
				return null;
			} else {
				FileInputStream fis = new FileInputStream(fbFile);
				javaCU = JavaParser.parse(fis);
				fis.close();
			}
		} catch (ParseException pe) {
			System.out.println("Error: Parse error while loading java file into Compilation Unit" + fbFile.getName());
			pe.printStackTrace();
		} catch (FileNotFoundException fne) {
			System.out.println("Error: File not found while loading java file into Compilation Unit" + fbFile.getName());
			fne.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return javaCU;
	}

	
	public static void writeCompilationUnitToFile(File dir, String fileName, CompilationUnit cu){
		
		FileWriter fw;
		try {
			if(!dir.exists()) {
				boolean created = dir.mkdirs();
				if(!created) {
					System.out.println("Error while creating output folder "+dir.getName());
					return;
				}
			}
			File targetFile = new File(dir, fileName);
			if(targetFile.exists()) {
				targetFile.delete();
			}
			boolean created = targetFile.createNewFile();
			if(!created) {
				System.out.println("Error while creating output file "+targetFile.getName());
				return;
			}
			fw = new FileWriter(targetFile);
			fw.write(cu.toString());
			fw.flush();
			fw.close();
			System.out.println("Write compilation unit successful: " + targetFile.getName());
		} catch (IOException e) {
			System.out.println("Error while creating output file "+dir.getName());
			e.printStackTrace();
		}
	}	

	
	public static BufferedReader getFileAsBufferedReader(String fileName) throws IOException {
		return getFileAsBufferedReader(new File(fileName));
	}
	
	public static BufferedReader getFileAsBufferedReader(File f) throws IOException{
		BufferedReader br;
		if(!f.exists())
			throw new IOException("File " + f.getAbsolutePath()+" is not found!!!");
		try {
			br = new BufferedReader(new FileReader(f));
			return br;
		} catch (FileNotFoundException e) {
			throw new IOException(e);
		}
	}
	
	public static LinkedList<String> getLinesFromFile(String fileName) throws IOException{
		LinkedList<String> list = new LinkedList<String>();
		BufferedReader br = getFileAsBufferedReader(fileName);
		String line;
		try {
			while((line = br.readLine()) != null){
				list.add(line);
			}
		} catch (IOException e) {
			throw new IOException(e);
		} finally {
			br.close();
		}
		return list;
	}
	
	public static LinkedList<String> getLinesFromString(String inputString) throws IOException{
		LinkedList<String> list = new LinkedList<String>();
		BufferedReader br = new BufferedReader(new StringReader(inputString));
		String line;
		try {
			while((line = br.readLine()) != null){
				list.add(line);
			}
		} catch (IOException e) {
			throw new IOException(e);
		} finally {
			br.close();
		}
		return list;
	}
	
	public static BufferedWriter getFileAsBufferedWriter(String fileName) throws IOException{
		File f = new File(fileName);
		BufferedWriter br;
		String folderName = fileName.substring(0,fileName.lastIndexOf(File.separator));
		File folder = new File(folderName);
		if(!folder.exists()){
			folder.mkdirs();
		}
		try {
			br = new BufferedWriter(new FileWriter(f));
			return br;
		} catch (FileNotFoundException e) {
			throw new IOException(e);
		} catch (IOException e) {
			throw new IOException(e);
		}
	}
	
	public static StringBuilder getFileContents(String fileName) throws IOException {
		StringBuilder sb = new StringBuilder();
		checkFileExists(fileName);
		BufferedReader br = FileUtil.getFileAsBufferedReader(fileName);
		int temp;
		try {
			temp = br.read();
			while(temp != -1){
				sb.append((char)temp);
				temp = br.read();
			}
			br.close();
			return sb;
		} catch (Exception e) {
			throw new IOException(e);
		} 
		
	}
	
	public static void writeContentToFile(File fileName, String content, boolean overwrite) throws IOException {
		if(fileName.exists() ) {
			if(overwrite)
				fileName.delete();
			else
				new IOException("File "+ fileName.getAbsolutePath() + " already exists!");
		} else {
			fileName.getParentFile().mkdirs();
			fileName.createNewFile();
		}
		FileWriter fw = new FileWriter(fileName);
		fw.write(content);
		fw.flush();
		fw.close();
	}

	public static void copy(File srcFile,File destFile) throws IOException{
		BufferedReader br = FileUtil.getFileAsBufferedReader(srcFile);
		BufferedWriter bw = FileUtil.getFileAsBufferedWriter(destFile.getAbsolutePath());
		int ch;
		try {
			while((ch = br.read())!=-1){
				bw.write(ch);
			}
			bw.flush();
			bw.close();
			br.close();
		} catch (IOException e) {
			throw new IOException(e);
		}
	}
	
	public static boolean isFolder(String folderName){
		File f = new File(folderName);
		return f.exists()&&f.isDirectory();		
	}
	
	public static boolean isFolder(File f){
		return f.exists() && f.isDirectory();		
	}
	
	public static List<File> listDirectory(String dir, List<String> suffixes)
	{
		File folder = new File(dir);
		File[] listOfFiles = folder.listFiles();
		List<File> retval = new ArrayList<File>();

		for (File file : listOfFiles)
			for (String suffix : suffixes)
				if (file.getPath().endsWith(suffix) == true) {
					retval.add(file);
					break;
				}					

		return retval;
	}

	public static List<File> listsDirectory(String dir, List<String> suffixes)
	{
		File folder = new File(dir);
		File[] listOfFiles = folder.listFiles();
		List<File> retval = new ArrayList<File>();

		for (File file : listOfFiles)
			for (String suffix : suffixes)
				if (file.getPath().endsWith(suffix) == true) {
					retval.add(file);
					//break;
				}					

		return retval;
	}
	

}
