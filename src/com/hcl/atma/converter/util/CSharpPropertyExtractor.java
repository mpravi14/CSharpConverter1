package com.hcl.atma.converter.util;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;

public class CSharpPropertyExtractor {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		try{
			File folder = new File("D:\\Praveen\\Total File List\\ViewData");
			File[] listOfFiles = folder.listFiles();
			BufferedReader br =null ; 
			String line="";
			String className = "", methodName = "", validationMsg= "";
			StringBuilder propertyLine = new StringBuilder();
			for (File file : listOfFiles) {
				br = new BufferedReader(new FileReader(file)); 
				while ((line=br.readLine())!=null) {
					if(line.contains(" class ")){
						className = line.substring(line.indexOf("class")+6, line.contains(":")?line.indexOf(":"):line.length()).trim();
					}
					if(line.contains("[Validate") && line.contains("Error")){
						validationMsg = line.substring(line.indexOf("[Validate"));
						if(validationMsg.contains("Error")){
							validationMsg = validationMsg.substring(validationMsg.indexOf("Error")+5).trim();
							String text="";
							int count=0;
							for (int i = 0; i < validationMsg.length(); i++) {
								if(Character.toString(validationMsg.charAt(i)).equals("\"")){
									++count;
									if(count==2){
										break;
									}
								}
								text = text+Character.toString(validationMsg.charAt(i));
							}
							text = text+"\"";
							validationMsg = text;
						}
						line = br.readLine();
						if((line.contains("public")||line.contains("private")||line.contains("protected"))
								&& line.contains("{")){
							methodName = line.substring(0,line.indexOf("{")).trim();
							methodName = methodName.substring(methodName.lastIndexOf(" ")).trim();
							propertyLine.append(className+"."+methodName+" "+validationMsg);
							propertyLine.append("\n");
						}
					}
				}
			}
			File file = new File("D://Praveen//New folder (2)//PropertyFile.txt");
			BufferedWriter bw = new BufferedWriter(new FileWriter(file));
			bw.append(propertyLine);
			bw.close();
			System.out.println(propertyLine);
		}catch(Exception e){
			
		}
	}
}
