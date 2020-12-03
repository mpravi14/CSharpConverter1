package com.hcl.atma.converter.util;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;

import com.hcl.atma.converter.dictionary.BaseDictionaryProvider;
import com.hcl.atma.converter.generator.NamingUtil;
import com.hcl.atma.converter.processor.TranslationProcessor;

public class CSharpParserHelper {
	public static String className; 
	public static BaseDictionaryProvider dictionary = new BaseDictionaryProvider(); 
	public static Map<String, String> varMap = new HashMap<String, String>();

	public static String checkIfArray(String varName) {
	    if(varMap.containsKey(varName.trim())) {
	       if(varMap.get(varName.trim()) != null && varMap.get(varName.trim()).equals("Variant")) {
	          return "true";
	       } else {
	          return null;
	       }
	    }
	    return null;
	}

	
	public static String constantDeclaration(String accessSp, String dataType,String global , String constant, String name, String value) {
		StringBuffer constBuff = new StringBuffer();
		if(global != null && global.equals("Global")) {
			constBuff.append( " static ");
		}
		if(constant != null && constant.equals("Const")) {
			constBuff.append( "final ");
		}
		if(value != null && value.startsWith("\"")) {
			constBuff.append( "String ");
		} else {
			constBuff.append( "int ");
		}
		constBuff.append( name);
		constBuff.append( " = ");
		constBuff.append( value);
		constBuff.append( ";");
		return constBuff.toString();
	}

	public static String extractVariableList(String args) {
		String varString = "";
	    if(args == null || args.trim().length() == 0) {
	    	varString = "";
	    } else {
		    String[] parts = args.split(",");
		    for(String part : parts) {
		        part = part.trim();
		        varString +=  part.substring(part.indexOf(" "));
		        varString += ","; 
		    }
		    if(varString.endsWith(",")) {
		        varString = varString.substring(0,(varString.length()-1));
		    }
	    }
	    return varString.trim();
	}

	// getting the module class name
	public static String getClassName(){
	   String fileName = TranslationProcessor.inputFileName;
	   fileName = fileName.substring(0, fileName.indexOf('.'));
	   className = NamingUtil.toClassName(fileName);   
	   return className;
	}

	// gatting the java data type and util methods
	public static String getJavaType(String vbType) {
	  String javaType = null;
	  if(vbType != null && !vbType.isEmpty()) {
	    try {
	    	javaType = dictionary.getJavaMeaning(vbType);
	    } catch(IllegalArgumentException e){
	        javaType = vbType;
	    }
	  } else {
	     javaType = vbType;
	  }
	  return javaType;
	}

	public static String handleForNewInstance(Object n, String rhs, Object lhs, Object tp) {
	    rhs = rhs.trim();
		  if(n != null) {
		      String ret = "";
		      ret = " new " + NamingUtil.toClassName(rhs);
		      if(!ret.endsWith(")")) {
		          ret += "()";
		      }
		      return ret;
		  } else {
		      if(rhs.startsWith("null")) rhs = "null";
		      if(rhs.toUpperCase().equals("FALSE")) rhs = "false";
		      return rhs;
		  }
	}

	public static String prepareWithStatements(String var, List<Object> stmts) {
	    StringBuffer outBuff = new StringBuffer();
	    String prefix = "";	
	    if(stmts != null && stmts.size() > 0) {
		    for (Object ostmt : stmts) {
		        String stmt = ostmt.toString().trim();
		        if(stmt.contains("= .")){
		        	prefix = stmt.substring(0, stmt.indexOf("= ") + 2);
		        	stmt = stmt.substring(stmt.indexOf(" .")+2);
		        	outBuff.append(prefix + var + "." + stmt + "\n");	
		        } else if(stmt.contains(" .")) {
		        	stmt = stmt.substring(2);
		        	outBuff.append(var + "." + stmt + "\n");	
		        } else {
		        	outBuff.append(stmt + "\n");
		        }
		    }
	    }
	    return outBuff.toString();
	}

	
	@Deprecated
	public static String prepareWithStatements(String var, List<Object> stmts, String index) {
	    StringBuffer outBuff = new StringBuffer();
	    String prefix = "";		
	    if(index != null) {
	    	var = var + "(" + index + ")";
	    }
	    for(Object ostmt : stmts) {
	        String stmt = ostmt.toString().trim();
	        if(stmt.contains("= .")){
	        	prefix = stmt.substring(0, stmt.indexOf("= ") + 2);
	        	stmt = stmt.substring(stmt.indexOf(" .")+2);
	        	outBuff.append(prefix + var + "." + stmt + "\n");	
	        } else if(stmt.contains(" .")){
	        	stmt = stmt.substring(2);
	        	outBuff.append(var + "." + stmt + "\n");	
	        } else {
	        	outBuff.append(stmt + "\n");
	        }
	    }
	    return outBuff.toString();
	}

	public static String registerVariable(String var,String type) {
	    varMap.put(var, type);
	    return type + " " + var;
	}
	
	@Deprecated
	public static String captureVariable(String var, String asType, String bType, String list) {
		String type = null;
		if(asType != null) {
			type = asType;
		} else {
			if(bType != null) 
				type = bType;
		}
		String varName = NamingUtil.changeToCamelCase(var, true);
		varMap.put(varName, type);
	    return ( type + " " + varName);
	}

	
	public static String captureArgument(String var, String asType, String value) {
		String type = "";
		if(asType != null) {
			type = asType;
		}
		String varName = var;
		if(!varName.trim().startsWith("VBUtilFunctions")) {
			NamingUtil.changeToCamelCase(var, true);
		}
		varMap.put(varName, type);
	    return ( type + " " + varName + (value != null ? " = " + value : ""));
	}


	public static String variableDeclaration(List<Object> nameList, String type, Object newKeywrd) {
		StringBuffer varDecBuff = new StringBuffer();
		for(Object vName : nameList){
			String name = vName.toString().trim();
			String varName = NamingUtil.changeToCamelCase(name, true);
			if(varName != null && type != null ){
				if(varName.toLowerCase().contains("array")){
					varDecBuff.append("List<"+type+"> "+varName);
				}
				varDecBuff.append(type+" "+varName);
			}else{
				varDecBuff.append("Object "+varName);
			}

			if(newKeywrd != null ) {
				if(varName.toLowerCase().contains("array")){
					varDecBuff.append(" = new ArrayList<" + type + ">();");
				}else{
					varDecBuff.append(" = new " + type + "();");
				}

			}else {
				varDecBuff.append(" = null;");
			}
			registerVariable(name , type);
		}
		return varDecBuff.toString();
	}
	
	public static String stringConcatination(List<Object> inputString){
		StringBuffer strBuff = new StringBuffer();
		for(Object obj : inputString){
			String input = obj.toString();
			if(input.equals("&")){
				input = input.replace("&_", "+");
				input = input.replace("&","+");
				strBuff.append(input);
			}else{
				strBuff.append(obj.toString());
			}
		}
		return strBuff.toString();
		
	}
	
	public static String isLibFunction(String methdName){
		String methodName = null;
		if(methdName.trim().equalsIgnoreCase("m_FSO.FileExists")){
			methodName = "m_FSOFileExists";
			methodName = getJavaType(methdName);
		}else if(methdName.contains(".ReDim")){
			String arrayName = methdName.substring(0,methdName.indexOf(".ReDim"));
			arrayName = NamingUtil.changeToCamelCase(arrayName,false);
			methodName = arrayName + " = VBUtilFunctions.redim";  
		}else{
			methodName = getJavaType(methdName);
		}
		
		return methodName;
	}
	
	public static String generateMethodCall(String inputString){
		String methodCall = null;
		if(inputString != null && !inputString.isEmpty()){
			if(inputString.contains("(")){
				methodCall = inputString + ";";
			}else{
				methodCall = NamingUtil.changeToCamelCase(inputString, true);
				methodCall = methodCall + "();";
			}
		}
		return methodCall;
	}
	
	public static String getVbProperty(String parent,List<Object> childList){
		StringBuffer propBuff = new StringBuffer();
		if(childList != null && childList.size() > 0){
			if(childList.size() == 1){
				propBuff.append(parent.toLowerCase() + childList.get(0));
			}else{
				for(int i = 0;i < childList.size(); i++){
					if(i == 0 ){
						propBuff.append(parent.toLowerCase());
					}
					propBuff.append(childList.get(i));
				}
			}
							
		} else {
			if(parent.equalsIgnoreCase("Me")) parent = "this";
			propBuff.append(NamingUtil.changeToCamelCase(parent,true));
		}
		return propBuff.toString();
	}
	
	public static String checkIfProperty(Object propertyString,Object dataType){
		String output = null;
		if(propertyString != null && propertyString.toString().contains(".")){
			String parentObject = propertyString.toString().substring(0,propertyString.toString().indexOf("."));
			String property = propertyString.toString().substring(propertyString.toString().indexOf(".")+1);
			output = parentObject + ".set" + property + "(";
			
		}else if(dataType != null && dataType.toString().contains(".")){
			String parentObject = dataType.toString().substring(0,dataType.toString().indexOf("."));
			String property = dataType.toString().substring(dataType.toString().indexOf(".")+1);
			output = parentObject + ".set" + property + "(";
		}
//		else{
//			output = propertyString.toString();
//		}
		return output;
	}
	
	public static String getOperator(Object oper,Object notOp){
		String opertr = null;
		if(oper!=null){
			if(oper.toString().trim().equals("==") && notOp!=null){
				opertr = "=";
				return opertr;
			}
			opertr = oper.toString();
			return opertr;
		}
		return opertr;
	}
	
	public static String checkIfResultSet(List<Object> condList){
		String output = null;
		if(condList != null && condList.size() > 0 ){
			for(Object cond : condList){
				if(cond.toString().endsWith("ResultSet")){
					output = "ResultSet"; 
					return output;
				}
			}
		}
		return output;
	}
	
	public static String checkIfExpressions(String lhs, List<Object> arithOprList){
		StringBuffer outputBuff = new StringBuffer();
		outputBuff.append(lhs);
		if(arithOprList != null && arithOprList.size() > 0){
			for(Object arthop : arithOprList){
				outputBuff.append(arthop.toString());
			}
		}
		return outputBuff.toString();
	}
	
	public static String checkIfExpressions(String lhs,List<Object> arithOprList,String assgnVal){
		StringBuffer outputBuff = new StringBuffer();
		if (assgnVal != null && assgnVal.length() > 0) {
			if(assgnVal.trim().equalsIgnoreCase("false")) assgnVal = assgnVal.toLowerCase();
			outputBuff.append(lhs +" = "+ assgnVal);
		} else {
			outputBuff.append(lhs);
		}
		if(arithOprList != null && arithOprList.size() > 0){
			for (Object arthop : arithOprList) {
				outputBuff.append(arthop.toString());
			}
		}
		return outputBuff.toString();
	}
	
	public static String getStepOpr(String incrDec){
		String incrDecr = "";
		if(incrDec != null){
			incrDecr = incrDec;
		} else{
			incrDecr = "++";
		}
		return incrDecr;
	}
	
	public static String validateCaseId(List<Object> caseIds) {
		StringBuffer output = new StringBuffer();
		if(caseIds != null && caseIds.size() == 1) {
			output.append("case "+caseIds.get(0)+" :"); 
		} else {
			for (Object caseId : caseIds ){
				output.append("case "+caseId+" :\n");
			}
		}
		return output.toString();
	}
	
	public static String  checkLhsIsKeyword(Object rhs){
		String input = rhs.toString().trim();
		if(input != null && (input.equalsIgnoreCase("true") || input.equalsIgnoreCase("true") )){
			System.out.println("lhs "+ rhs);
			input = input.toLowerCase(); 
			return input;
		}else{
			if(input != null){
				return rhs.toString();
			}
			return "";
		}
		
	}
	
	public static String reDimArray(String arrayLine, Object preserve) {
		StringBuffer output = new StringBuffer();
		String arrayName = arrayLine.substring(0,arrayLine.indexOf("("));
		arrayName = NamingUtil.changeToCamelCase(arrayName, true);
		String newDims = arrayLine.substring((arrayLine.indexOf("(") + 1), arrayLine.lastIndexOf(")"));
		output.append("/* redimension the array to new size */");
		output.append("\n");
		output.append(arrayName.trim() + "Temp = new Object[");
		String[] indexes = newDims.split(",");
		boolean isFirst = true;
		for(String index : indexes) {
			output.append(index);
			if(!isFirst) {
				output.append("][");
			}
			isFirst = false;
		}
		output.append("];");
		output.append("\n");
		if(preserve != null) {
			output.append("int i = 0;\n");
			output.append("for(Object obj : " + arrayName + ") {\n");
			output.append("	  " + arrayName + "Temp[i++] = obj;\n");
			output.append("}\n");
			
		}
		output.append(arrayName + " = " + arrayName.trim() + "Temp;");
		return output.toString();
	}
	
	
	@Deprecated
	public static String checkReDeimensions(String methodName, String params){
		String output = "";
		if (methodName.contains(".ReDim")){
			String arrayName = methodName.substring(0,methodName.indexOf(".ReDim"));
			output = translateRedim(methodName,arrayName,params);
		}else if(methodName.contains("ReDim")){
			String arrayName = params.substring(0,params.indexOf("("));
			output = translateRedim(methodName,arrayName,params);
		} else{
			// do the coding for other lib functions
			output = methodName+"("+ params + ");";
		}
		return output.toString();
	}

	@Deprecated
	private static String translateRedim(String methodName, String arrayName, String params) {
		StringBuffer redefBuff = new StringBuffer();
		arrayName = NamingUtil.changeToCamelCase(arrayName,false);
		methodName = arrayName + " = VBUtilFunctions.redim";
		redefBuff.append(methodName+"(");
		String param = getParameter(params);
		redefBuff.append(arrayName+","+param.trim() + ");");
		return redefBuff.toString();
	}

	@Deprecated
	private static String getParameter(String params) {
		StringBuffer redefParm = new StringBuffer();
		if (params.contains(",")) {
			StringTokenizer paramToken = new StringTokenizer(params, ",");
			int i = 1;
			while (paramToken.hasMoreTokens()) {
				String param = paramToken.nextToken();
				if (i == 2) {
					redefParm.append(param + ",");
				} else if (i == 4) {
					redefParm.append(param);
				}
				i++;
			}
		}else{
			redefParm.append(params);
		}
		return redefParm.toString();
	}
	
	// to translate if the addItem has any data retrval based on the 
	public static String translateIfResulSet(String item){
		String output = "";
		if(item.contains(".Fields")){
			output = item.replace(".Fields", ".get(i).getObject");
		}else{
			output = item;
		}
		return output;
	}
	
	public static String checkIfEOF(String cond){
		String output = null;
		if(cond.contains(".EOF")){
			output = cond.replaceAll(".EOF", ".next()");
		}else{
			output = cond;
		}
		return output;
	}
	
}
