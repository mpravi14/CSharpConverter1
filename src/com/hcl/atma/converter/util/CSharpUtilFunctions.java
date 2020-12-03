package com.hcl.atma.converter.util;

import java.io.File;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.List;

public class CSharpUtilFunctions {
	
	public static String format(String inputDate,String reqFormat) throws ParseException{
		String outputDate=null;
		if (reqFormat.equals("yymmdd")) {
			DateFormat formatter1;
			formatter1 = new SimpleDateFormat("yyyy/MM/dd");
			outputDate=(String)formatter1.parse(inputDate).toString();
		}
		return outputDate;
	}
	
	public static String format(String inputString) {
		
		return inputString;
	}
	
	public static String trim(String inputString){
		return inputString.trim();
	}
	
	public static String toLowerCase(String inputString){
		String output = null;
		if(inputString != null){
			output = inputString.toLowerCase();
		}
		return output;
	}
	
	public static String toUpperCase(String inputString){
		return inputString.toUpperCase();
	}
	
	public static String replace(String inputString, String findPattern, String repPattern) {
		String outputString = null;
		if (repPattern.contains("&")) {
			repPattern = repPattern.replace('&', '+');
		}
		if (inputString.contains(findPattern)) {
			outputString = inputString.replace(findPattern, repPattern);
		}
		return outputString;
	}
	
	public static String left(String inputString,String sleftIndex) throws StringIndexOutOfBoundsException{
		String outputString=null;
		int leftIndex=Integer.parseInt(sleftIndex);
			if (!inputString.isEmpty() && inputString!=null) {
				outputString=inputString.substring(0, leftIndex);
			}
		return outputString;
	}
	
	public static String right(String inputString,int rightIndex) throws StringIndexOutOfBoundsException{
		String outputString=null;
			if (!inputString.isEmpty() && inputString!=null) {
				outputString=inputString.substring(inputString.length()- rightIndex,inputString.length());
			}
		return outputString;
	}

	public static String mid(String inputString,String stgstartIndex,String stgstopIndex) throws StringIndexOutOfBoundsException {
		String outputString=null;
		int startIndex = Integer.parseInt(stgstartIndex);
		int stopIndex = Integer.parseInt(stgstopIndex);
			if (!inputString.isEmpty() && inputString!=null) {
				outputString=inputString.substring(startIndex,stopIndex);
			}
		return outputString;
	}
	
	public static String mid(String inputString,String stgstartIndex) throws StringIndexOutOfBoundsException {
		String outputString=null;
		int startIndex=0;
		try {
			startIndex = Integer.parseInt(stgstartIndex);
		} catch (NumberFormatException e) {
			// TODO Auto-generated catch block
			return stgstartIndex;
			//e.printStackTrace();
		}
		
		int stopIndex = inputString.length() - 1;
			if (!inputString.isEmpty() && inputString!=null) {
				outputString=inputString.substring(startIndex,stopIndex);
			}
		return outputString;
	}
	
	public static int inStr(String firstString,String secondString) throws Exception{
		int position=0;
		if(secondString.contains(firstString)) {
			position=secondString.indexOf(firstString);
		}
		return position+1;
	}
	
	public static int inStrRev(String firstString,String secondString) throws Exception{
		int position=0;
		if(secondString.contains(firstString)) {
			position=secondString.length() - secondString.indexOf(firstString);
		}
		return position;
	}
	
	public static long cLng(double expression) {
		long outputNumber=0;
		outputNumber= (long) Math.floor(expression);
		return outputNumber;
	}
	
	public static int len(String inputString) throws IndexOutOfBoundsException {
		return inputString.length();
	}
	
	public static int uBound(ArrayList<Integer> inputArray) throws ArrayIndexOutOfBoundsException {
		int subscript=0;
		subscript= Collections.max(inputArray);
		return subscript;
	}
	
	public static boolean isArray(Object objct){
		if(objct instanceof List){
			return true;
		}
		return false;
	}
	
	public static boolean isNull(Object objt){
		if(objt == null){
			return true;
		}else{
			return false;
		}
	}
	
	public static void showMessageDlg(String msgTxt){
//		FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_INFO, msgTxt);
//		RequestContext.getCurrentInstance().showMessageInDialog(message);
	}
	
	public static String isDir(String dir){
		String isDir = "";
		File f = new File(dir);
		if(f.exists()) isDir = "true";
		return isDir;
	}
	
	public static Date convertToDate(String dateString){
		Date date = null;
		SimpleDateFormat formatter = new SimpleDateFormat("dd-MM-yyyy");
		try {

			date = formatter.parse(dateString);

		} catch (ParseException e) {
			e.printStackTrace();
		}
		
		return date;
	}
	
	public static void killFile(File file){
		if(file.exists()) file.delete();
	}
	
	public static boolean FileExists(File file){
		if(file.exists()) return true;
		return false;
	}
	
	public static List<?> executeCommand(String sql){
		List<?> resultList = null;
//		DataAccess dataAccess = new DataAccess();
//		List<?> resultList = dataAccess.executeCommand(sql);
		return resultList;
		
	}
	
	public static Object[][] redim(int i,int j, int x , int y){
		Object arr[][] = new Object[j][y];
		return arr;
	}
	
	public static String getSpace(int size){
		StringBuffer output = new StringBuffer("saravan");
		int i = 0;
		while(i < size){
			output.append(" ");
			i++;
		}
		System.out.println(i);
		output.append("anand");
		return output.toString();
	}
	
	public static Object[] redim(Object [] arr, int newSize){
		Object[] newArr = Arrays.copyOf(arr, newSize);
		return newArr;
	}
}
