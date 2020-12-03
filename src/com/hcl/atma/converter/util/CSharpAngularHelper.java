package com.hcl.atma.converter.util;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;

import com.hcl.atma.converter.generator.NamingUtil;


public class CSharpAngularHelper {
	static StringBuffer sb = new StringBuffer();
	
	public static String serviceDOGenerator(String className,String methodName,String paramList){
		StringBuilder sbDO = new StringBuilder();
		try{
		File file = new File("D:\\Praveen\\WorkspaceConversion\\CSharpConverter\\resources_nbcu\\input\\service\\"+className+"Service.cs");
		String line = null;
		BufferedReader br = new BufferedReader(new FileReader(file)); 
		String objectName =  NamingUtil.toVarName(methodName)+"DO";
		paramList = paramList.substring(1,paramList.length()-1);
		String controllerParams[] = paramList.split(",");
		sbDO.append(methodName+"DO "+ objectName+" = new " + methodName+"DO();\n");
		while ((line=br.readLine())!=null) {
			if(line.contains("public") || line.contains("private") || line.contains("protected")){
				if (line.contains(methodName)) {
					String[] parts = line.split("\\(",2);
					if(parts[1].length()>1){
						parts[1] = parts[1].substring(0, parts[1].length()-1);
						String params[] = parts[1].split(",");
						for (int i = 0; i < params.length; i++) {
							String args[] = params[i].trim().split(" ");
							sbDO.append(objectName+"."+args[1]+" = " + controllerParams[i]+";\n");
						}
					}
					break;
				}
			}
		}
		sbDO.append(className+"Service."+NamingUtil.toVarName(methodName)+"("+objectName+")");
		br.close();
		}catch(Exception e){
			
		}
		
		return sbDO.toString();
	}
	
	public static String processAssignmentStmtsNew(String unExpr, String optr, String expr) {
		String statment = "";
//		if (unExpr.contains("get") && unExpr.endsWith(")")) {
//			statment = unExpr.substring(0, unExpr.lastIndexOf("get")) + "set"
//					+ unExpr.substring(unExpr.lastIndexOf("get") + 3, unExpr.length() - 2);
//			statment = statment + "(" + expr + ")";
//		} else {
//			statment = unExpr + optr + expr;
//		}
		if(expr.contains("new List")){
			statment = unExpr + optr + "[]";
		}else{
			statment = unExpr + optr + expr;
		}
		return statment;
	}
	
	public static String handleDateParenthesis(String paren){
		paren = paren.substring(1,paren.length()-1);
		if(paren.trim().endsWith("d")){
			paren = paren.substring(0,paren.length()-1);
		}
		return paren;
	}
	
	public static String modelHelperToController(String className){
		if(className.endsWith("Model")){
			className = className.replace("Model", "Controller");
		} else{
			className = className.replace("Helper", "Controller");
		}
		return className;
	}
	
	public static String handleRemoveParenthesis(String paren){
		paren = paren.substring(1,paren.length()-1);
		
		return paren;
	}
	
	public static String handleDateDotParenthesis(List<String> paren){
		String ret = "";
		for (int i = 0; i < paren.size(); i++) {
			ret=ret+paren.get(i);
		}
		ret = ret.substring(0,ret.length()-1);
		return ret;
	}
	
	public static String handleSplitParenthesis(String paren) {
		if (paren.trim().startsWith("(") && paren.trim().endsWith(")")) {
			paren = paren.substring(1, paren.length() - 1);
		}

		if (paren.trim().startsWith("'") && paren.trim().endsWith("'")) {
			paren = paren.substring(1, paren.length() - 1);
			paren = "(\""+paren+"\")";
		}
		return paren;
	}
	
	public static String replaceJavaType(String type) {
		if ((type).contains("IEnumerable")) {
			type = type.replace("IEnumerable", "List").trim();
		} else if ((type).contains("string") || (type).equals("string")) {
			type = type.replace("string", "String").trim();
		} else if ((type).contains("DateTime")) {
			type = "Date";
		}
		return type;

	}
	
	public static String docCommentHandler(String stat){
		if(!stat.isEmpty()){
			stat = stat.replaceAll("///", "//");
			if(stat.trim().equalsIgnoreCase("// <summary>")){
				stat = stat.replaceAll("// <summary>", "/*");
			}
			if(stat.trim().equalsIgnoreCase("// </summary>")){
				stat = stat.replaceAll("// </summary>", "*/");
			}
		}
		return stat;
	}
	
	public static String classNameDataUpdater(String paren){
		if(paren.endsWith("Model")){
			paren=paren.substring(0, paren.indexOf("Model"));
			paren = paren+"Data";
		}else if(paren.endsWith("Helper")){
			paren=paren.substring(0, paren.indexOf("Helper"));
			paren = paren+"Data";
		}
		
		
		return paren;
	}
	
	public static void methodNameListGetter(String paren, String className) {
		try {
			sb.append(className+" -> "+paren);
			sb.append("\n");
			File file = new File("D://Praveen//New folder (2)//MethodList.txt");
			BufferedWriter bw = new BufferedWriter(new FileWriter(file));
			bw.append(sb);
			bw.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
	
	public static void linqListGetter(String paren) {
		try {
			sb.append("i=("+paren+");");
			sb.append("\n");
			File file = new File("D://Praveen//New folder (2)//linqList.txt");
			BufferedWriter bw = new BufferedWriter(new FileWriter(file));
			bw.append(sb);
			bw.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
	static int vali=0;
	public static void linqPatternListGetter(String paren) {
		++vali;
		if(paren.trim().equals("from  ID IN  exp  select  exp")){
			@SuppressWarnings("unused")
			int v=0;
		}
		try {
			sb.append(paren);
			sb.append("\n");
			File file = new File("D://Praveen//New folder (2)//linqPatternList.txt");
			BufferedWriter bw = new BufferedWriter(new FileWriter(file));
			bw.append(sb);
			
			bw.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
	public static String linqFirstOrDefault(String paren){
		if(paren.trim().equals("FirstOrDefault")){
			
		}
		return paren;
	}
	
	public static String linqSourceTargetAppend(String source, String target){
		StringBuilder sbr = new StringBuilder();
		sbr.append("/*\n" + source + "\n*/");
		sbr.append("\n" + target);
		return sbr.toString();
	}
	public static String linqFromPart(String paren){
		String parts[]=paren.split("\\.");
		return parts[parts.length-1];
	}
	
	public static String linqWherePart(String paren){
		if(paren.contains(".")){
			String parts[]=paren.split("\\.",2);
			if(parts[0].contains("=")){
				return paren;
			}else{
				return parts[1];
			}
		}
		return paren;
	}
	
	public static String prefixGetKeyword(String inputExpr) {
		StringBuilder stringUnderSplit = new StringBuilder();
		if(inputExpr.contains("&&")){
			String parts[]=inputExpr.split("&&");
			for(int i=0;i<parts.length;i++){
				stringUnderSplit = stringUnderSplit.append(prefixGetKeyword3(parts[i]));
				if(i!=parts.length-1){
					stringUnderSplit = stringUnderSplit.append("&&");
				}
			}
		}else{
			stringUnderSplit = stringUnderSplit.append(prefixGetKeyword3(inputExpr));
		}
		inputExpr = stringUnderSplit.toString();
		if(inputExpr.contains("getToLower()")){
			inputExpr = inputExpr.replaceAll("getToLower", "toLowerCase");
		}
		if(inputExpr.contains("getToString()")){
			inputExpr = inputExpr.replaceAll("getToString", "toString");
		}
		if(inputExpr.contains("getTrim()")){
			inputExpr = inputExpr.replaceAll("getTrim", "trim");
		}
		if(inputExpr.contains("getIndexOf()")){
			inputExpr = inputExpr.replaceAll("getIndexOf", "indexOf");
		}
		if(inputExpr.contains("getToShortDateString()")){
			inputExpr = inputExpr.replaceAll("getToShortDateString", "toLocaleString");
		}
		if(inputExpr.contains("getSplit")){
			inputExpr = inputExpr.replaceAll("getSplit", "split");
		}
		if(inputExpr.contains("getClear()")){
			inputExpr = inputExpr.replaceAll("getClear", "clear");
		}
		return inputExpr;
	}
	
	public static String prefixGetKeyword3(String inputExpr) {
		StringBuilder stringUnderSplit = new StringBuilder();
		if(inputExpr.contains("||")){
			String parts[]=inputExpr.split("\\|\\|");
			for(int i=0;i<parts.length;i++){
				stringUnderSplit = stringUnderSplit.append(prefixGetKeyword2(parts[i]));
				if(i!=parts.length-1){
					stringUnderSplit = stringUnderSplit.append("||");
				}
			}
		}else{
			stringUnderSplit = stringUnderSplit.append(prefixGetKeyword2(inputExpr));
		}
		inputExpr = stringUnderSplit.toString();
		return inputExpr;
	}
	
	public static String prefixGetKeyword2(String inputExpr) {
		StringBuilder stringUnderSplit = new StringBuilder();
		if(inputExpr.contains("==")){
			String parts[]=inputExpr.split("==");
			for(int i=0;i<parts.length;i++){
				stringUnderSplit = stringUnderSplit.append(prefixGetKeyword4(parts[i]));
				if(i!=parts.length-1){
					stringUnderSplit = stringUnderSplit.append("==");
				}
			}
		}else{
			stringUnderSplit = stringUnderSplit.append(prefixGetKeyword4(inputExpr));
		}
		inputExpr = stringUnderSplit.toString();
		
		return inputExpr;
	}
	
	public static String prefixGetKeyword4(String inputExpr) {
		StringBuilder stringUnderSplit = new StringBuilder();
		if(inputExpr.contains("!=")){
			String parts[]=inputExpr.split("!=");
			for(int i=0;i<parts.length;i++){
				stringUnderSplit = stringUnderSplit.append(prefixGetKeyword1(parts[i]));
				if(i!=parts.length-1){
					stringUnderSplit = stringUnderSplit.append("!=");
				}
			}
		}else{
			stringUnderSplit = stringUnderSplit.append(prefixGetKeyword1(inputExpr));
		}
		inputExpr = stringUnderSplit.toString();
		
		return inputExpr;
	}
	
	public static String prefixGetKeyword1(String inputExpr) {
		List<String> propertyList = new LinkedList<String>();
		StringBuilder stringUnderSplit = new StringBuilder();
		while (inputExpr.contains(".")) {
			int splitCountIndex = 0;
			for (String var : inputExpr.split("\\.", 2)) {
				if (splitCountIndex == 1) {
					inputExpr = var;
				} else {
					propertyList.add(var);
				}
				splitCountIndex++;
			}
		}
		propertyList.add(inputExpr);
		for (int index = 0; index < propertyList.size(); index++) {
			if (propertyList.size() - 1 >= 2) {
				if (index == 0) {
					stringUnderSplit.append(NamingUtil.toVarName(propertyList.get(index)));
				} else if (index == propertyList.size() - 1) {
					stringUnderSplit.append(".get"
							+ CSharpHelper.replaceJavaMethod(propertyList.get(index)).trim());
					if(!propertyList.get(index).trim().endsWith(")")){
						stringUnderSplit.append("()");
					}
				} else {
					stringUnderSplit.append(".get"
							+ CSharpHelper.replaceJavaMethod(propertyList.get(index)).trim());
					if(!propertyList.get(index).trim().endsWith(")")){
						stringUnderSplit.append("()");
					}
				}
			} else if (propertyList.size() - 1 == 1) {
				if (index == 0) {
					stringUnderSplit.append(NamingUtil.toVarName(propertyList.get(index)));
				} else if (index == 1) {
					stringUnderSplit.append(".get"
							+ CSharpHelper.replaceJavaMethod(propertyList.get(index)).trim());
					if(!propertyList.get(index).trim().endsWith(")")){
						stringUnderSplit.append("()");
					}
				}
			} else {
				stringUnderSplit = stringUnderSplit.append(NamingUtil.toVarName(inputExpr));
			}
		}
		if( stringUnderSplit.length()!=0){
			return inputExpr = stringUnderSplit.toString();
		}else{
			return inputExpr;
		}

		

	}

//	public static String processAssignmentStmts(String statements) {
//		statements = statements.replace("{", "");
//		statements = statements.replace("}", "");
//		StringBuilder statementsUnderBuild = new StringBuilder();
//		List<String> stmtList;
//		try {
//			stmtList = FileUtil.getLinesFromString(statements.trim());
//
//			List<String> modfStmtList = new LinkedList<String>();
//			if (!stmtList.isEmpty()) {
//				String stmt1 = "";
//				String temp = "";
//				for (int i = 0; i < stmtList.size(); i++) {
//					String stmt = stmtList.get(i);
//					if (!stmt1.equals("")) {
//						stmt = stmt1 + stmt.trim();
//						stmt1 = "";
//					}
//					if ((i + 1) < stmtList.size()) {
//						if (stmt.contains("//")) {
//							temp = temp + stmt.substring(stmt.indexOf("//"));
//							stmt = stmt.substring(0, stmt.indexOf("//") - 1);
//						}
//						stmt1 = stmt1 + stmt;
//						continue;
//					}
//
//					if (stmt.trim().startsWith("/")) {
//						modfStmtList.add(stmt);
//					} else {
//						String modfstmt = prefixGetSet(stmt);
//						if (!temp.equals("")) {
//							modfstmt = modfstmt + temp;
//							temp = "";
//						}
//						modfStmtList.add(modfstmt);
//					}
//
//				}
//			}
//
//			for (String tempStr : modfStmtList) {
//				statementsUnderBuild = statementsUnderBuild.append(tempStr
//						+ "\n");
//			}
//
//		} catch (IOException e) {
//			e.printStackTrace();
//		}
//		statements = statementsUnderBuild.toString();
//		return statements.trim();
//
//	}
//
//	public static String prefixGetSet(String statement) {
//		String stmtLhs = null;
//		String stmtRhs = null;
//		List<String> lhsPropertyList = new LinkedList<String>();
//		
//		StringBuilder stringUnderSplitLhs = new StringBuilder();
//		StringBuilder stringUnderSplitRhs = new StringBuilder();
//		int splitCount = 0;
//		for (String var : statement.split("=", 2)) {
//			if (splitCount == 0) {
//				stmtLhs = var.trim();
//			} else if (splitCount == 1) {
//				stmtRhs = var.trim();
//			}
//			splitCount++;
//		}
//		// to process LHS
//		while (stmtLhs.contains(".")) {
//			int splitCountIndex = 0;
//			for (String var : stmtLhs.split("\\.", 2)) {
//				if (splitCountIndex == 1) {
//					stmtLhs = var;
//				} else {
//					lhsPropertyList.add(var);
//				}
//				splitCountIndex++;
//			}
//		}
//		lhsPropertyList.add(stmtLhs);
//
//		for (int index = 0; index < lhsPropertyList.size(); index++) {
//			if (lhsPropertyList.size() - 1 >= 2) {
//				if (index == 0) {
//					stringUnderSplitLhs.append(NamingUtil.toCamelCase(lhsPropertyList.get(index)));
//				} else if (index == lhsPropertyList.size() - 1) {
//					stringUnderSplitLhs.append(".set"
//							+ lhsPropertyList.get(index) + "(");
//				} else {
//					stringUnderSplitLhs.append(".get"
//							+ lhsPropertyList.get(index) + "()");
//				}
//			} else if (lhsPropertyList.size() - 1 == 1) {
//				if (index == 0) {
//					stringUnderSplitLhs.append(NamingUtil.toCamelCase(lhsPropertyList.get(index)));
//				} else if (index == 1) {
//					stringUnderSplitLhs.append(".set"
//							+ lhsPropertyList.get(index) + "(");
//				}
//			} else {
//				stringUnderSplitLhs = stringUnderSplitLhs.append(NamingUtil.toCamelCase(stmtLhs)
//						+ " = ");
//			}
//		}
//		// to process RHS
//		
//		if (!stmtRhs.contains(".Transalate<")) {
////			if(stmtRhs.contains("?") && stmtRhs.contains(":")){
////				String condition = null;
////				String trueStat = null;
////				String falseStat = null;
////				condition = stmtRhs.substring(0, stmtRhs.indexOf("?"));
////				trueStat = stmtRhs.substring(stmtRhs.indexOf("?")+1,stmtRhs.indexOf(":"));
////				falseStat = stmtRhs.substring(stmtRhs.indexOf(":")+1);
////				stringUnderSplitRhs = processRHSStmt(condition, stringUnderSplitRhs);
////				stringUnderSplitRhs.append("?");
////				stringUnderSplitRhs = processRHSStmt(trueStat , stringUnderSplitRhs);
////				stringUnderSplitRhs.append(":");
////				stringUnderSplitRhs = processRHSStmt(falseStat , stringUnderSplitRhs);
////			}else{
//				stringUnderSplitRhs = processRHSStmt(stmtRhs, stringUnderSplitRhs);
////			}
//			
//			if (stringUnderSplitLhs.toString().trim().endsWith("+=")
//					|| stringUnderSplitLhs.toString().trim().endsWith("+ =")
//					|| !stringUnderSplitLhs.toString().contains("(")) {
//				statement = stringUnderSplitLhs.toString()
//						+ stringUnderSplitRhs.toString();
//			}else{
//				statement = stringUnderSplitLhs.toString()
//						+ stringUnderSplitRhs.toString() + ")";
//			}
//			
//		} else if (stmtRhs.contains(".Transalate<")) {
//			statement = stringUnderSplitLhs.toString()
//					+ processEmbdStmtRhs(stmtRhs);
//		}
//
//		return statement;
//
//	}
//	
//	public static StringBuilder processRHSStmt(String stmtRhs, StringBuilder stringUnderSplitRhs){
//		List<String> rhsPropertyList = new LinkedList<String>();
//		if (stmtRhs.contains("+")) {
//			int firstStmt = 1;
//			for (String stmt : stmtRhs.split("\\+")) {
//				if (firstStmt != 1) {
//					stringUnderSplitRhs.append("+");
//				}
//				++firstStmt;
//				stmt = stmt.trim();
//				rhsPropertyList = new LinkedList<String>();
//				if(stmt.startsWith("\"") && stmt.endsWith("\"")){
//				}else{
//					if (stmt.equals("\".\"")) {
//
//					} else {
//						while (stmt.contains(".")) {
//							int splitCountIndex = 0;
//							for (String var : stmt.split("\\.", 2)) {
//								if (splitCountIndex == 1) {
//									stmt = var;
//									
//								} else {
//									rhsPropertyList.add(var);
//								}
//								splitCountIndex++;
//							}
//						}
//					}
//				}
//				rhsPropertyList.add(stmt);
//				stringUnderSplitRhs=prefixGetSetChild(rhsPropertyList,stringUnderSplitRhs, stmt);
//			}
//		} else {
//			if(stmtRhs.startsWith("\"") && stmtRhs.endsWith("\"")){
//			}else{
//				while (stmtRhs.contains(".")) {
//					int splitCountIndex = 0;
//					String var[]=stmtRhs.split("\\.", 2);
//					for (int j = 0; j<var.length; j++) {
//						if(var[j].contains("(")){
//							
//							if(var[j].contains(")")){
//								
//								int openPar=0, closePar=0;
//								for (int i = 0; i < var[j].length(); i++) {
//									
//									if(var[j].contains(".") && var[j].contains("(")){
//										int dotPosition = var[j].indexOf(".");
//										int parenPosition = var[j].indexOf("(");
//										if(dotPosition<parenPosition){
//											break;
//										}
//									}
//									
//									if((""+var[j].charAt(i)).equals("(")){
//										++openPar;
//									}
//									if((""+var[j].charAt(i)).equals(")")){
//										++closePar;
//									}
//								}
//								if(openPar>closePar){
//									String temp= var[j]+"."+var[j+1];
//									temp=temp.trim();
//									String withinParen = temp.substring(temp.indexOf("(")+1,temp.lastIndexOf(")"));
//									withinParen= withinParen.trim();
//								
//									List<String> rhsPropertyList1 = new LinkedList<String>();
//									StringBuilder stringUnderSplitRhs1 = new StringBuilder();
//									if(withinParen.contains(".")){
//										while (withinParen.contains(".")) {
//											int splitCountIndex1 = 0;
//											for (String var1 : withinParen.split("\\.", 2)) {
//												var1=var1.trim();
//												if (splitCountIndex1 == 1) {
//													
//													if(var1.contains(",")){
//														String[] commaSplitList = var1.split("\\,",2);
//														rhsPropertyList1.add(commaSplitList[0].trim());
//														rhsPropertyList1.add(",");
//														withinParen = commaSplitList[1].trim();
//													}else{
//														withinParen = var1;
//													}
//													
//													
//												} else {
//													rhsPropertyList1.add(var1);
//												}
//												splitCountIndex1++;
//											}
//										}
//										rhsPropertyList1.add(withinParen);
//										stringUnderSplitRhs1=prefixGetSetChild(rhsPropertyList1, stringUnderSplitRhs1, withinParen);
//										if(temp.lastIndexOf(")")+1==temp.length()){
//											temp = temp.substring(0,temp.indexOf("(")) + "( " + stringUnderSplitRhs1 + " )";
//											rhsPropertyList.add(temp);
//											stmtRhs = "";
//											break;
//										} else{
//											stmtRhs=temp.substring(temp.lastIndexOf(")")+1);
//											if(stmtRhs.startsWith(".")){
//												stmtRhs = stmtRhs.substring(1);
//											}
//											temp = temp.substring(0,temp.indexOf("(")) + "( " + stringUnderSplitRhs1 + " )";
//											rhsPropertyList.add(temp);
//											break;
//										}
//									}else{
//										break;
//									}
//								}
//							}else{
//								String temp= var[j]+"."+var[j+1];
//								temp=temp.trim();
//								String withinParen = temp.substring(temp.indexOf("(")+1,temp.lastIndexOf(")"));
//								withinParen= withinParen.trim();
//							
//								List<String> rhsPropertyList1 = new LinkedList<String>();
//								StringBuilder stringUnderSplitRhs1 = new StringBuilder();
//								if(withinParen.contains(".")){
//									while (withinParen.contains(".")) {
//										int splitCountIndex1 = 0;
//										for (String var1 : withinParen.split("\\.", 2)) {
//											var1=var1.trim();
//											if (splitCountIndex1 == 1) {
//												
//												if(var1.contains(",")){
//													String[] commaSplitList = var1.split("\\,",2);
//													rhsPropertyList1.add(commaSplitList[0].trim());
//													rhsPropertyList1.add(",");
//													withinParen = commaSplitList[1].trim();
//												}else{
//													withinParen = var1;
//												}
//												
//												
//											} else {
//												rhsPropertyList1.add(var1);
//											}
//											splitCountIndex1++;
//										}
//									}
//									rhsPropertyList1.add(withinParen);
//									stringUnderSplitRhs1=prefixGetSetChild(rhsPropertyList1, stringUnderSplitRhs1, withinParen);
//									if(temp.lastIndexOf(")")+1==temp.length()){
//										temp = temp.substring(0,temp.indexOf("(")) + "( " + stringUnderSplitRhs1 + " )";
//										rhsPropertyList.add(temp);
//										stmtRhs = "";
//										break;
//									} else{
//										stmtRhs=temp.substring(temp.lastIndexOf(")")+1);
//										if(stmtRhs.startsWith(".")){
//											stmtRhs = stmtRhs.substring(1);
//										}
//										temp = temp.substring(0,temp.indexOf("(")) + "( " + stringUnderSplitRhs1 + " )";
//										rhsPropertyList.add(temp);
//										break;
//									}
//								}else{
//									break;
//								}
//							}
//						}
//						if (splitCountIndex == 1) {
//							stmtRhs = var[j];
//						} else {
//							rhsPropertyList.add(var[j]);
//						}
//						splitCountIndex++;
//					}
//				}
//			}
//			if(!stmtRhs.equals("")){
//				rhsPropertyList.add(stmtRhs);
//			}
//			stringUnderSplitRhs=prefixGetSetChild(rhsPropertyList, stringUnderSplitRhs, stmtRhs);
//		}
//		return stringUnderSplitRhs;
//	}
//	
//	public static StringBuilder prefixGetSetChild(List<String> rhsPropertyList, StringBuilder stringUnderSplitRhs, String stmtRhs){
//		for (int index = 0; index < rhsPropertyList.size(); index++) {
//			if(rhsPropertyList.get(index).equals(",")){
//				List<String> commaPropertyList = new LinkedList<String>();
//				stringUnderSplitRhs.append(" , ");
//				for (int i = index+1; ; i++) {
//					if(i <  rhsPropertyList.size()){
//						if(!rhsPropertyList.get(i).equals(",")){
//							commaPropertyList.add(rhsPropertyList.get(i));
//						}else{
//							index= i-1;
//							break;
//						}
//					} else {
//						index= i-1;
//						break;
//					}
//				}
//				stringUnderSplitRhs = prefixGetSetChild(commaPropertyList, stringUnderSplitRhs, stmtRhs);
//				continue;
//			}
//			if (rhsPropertyList.size() - 1 >= 2) {
//				if (index == 0) {
//					stringUnderSplitRhs.append(NamingUtil.toCamelCase(rhsPropertyList
//							.get(index)));
//				} else if (index == rhsPropertyList.size() - 1) {
//					if (!Character.isDigit(rhsPropertyList.get(
//							index).charAt(0))) {// checks for a
//												// double type
//												// number
//						if (rhsPropertyList.get(index).contains(
//								"==")) {// checks conditon after a
//										// method for adding ()
//							String temp[] = rhsPropertyList.get(
//									index).split("\\==", 2);
//							stringUnderSplitRhs.append(".get"
//									+ temp[0].trim() + "() =="
//									+ temp[1]);
//						} else {
//							if (rhsPropertyList.get(index).trim()
//									.equals("ToString()")) {
//								stringUnderSplitRhs
//										.append(".toString");
//							} else {
//								stringUnderSplitRhs.append(".get"
//										+ rhsPropertyList
//												.get(index));
//							}
//						}
//					} else {
//						stringUnderSplitRhs.append("."
//								+ rhsPropertyList.get(index));
//						continue;
//					}
//					if (!(rhsPropertyList.get(index).endsWith(")"))
//							&& !(rhsPropertyList.get(index)
//									.endsWith("\""))) {
//						if (!(Character
//								.isDigit(rhsPropertyList
//										.get((rhsPropertyList
//												.size() > (index + 1) ? index + 1
//												: index)).charAt(0)))) {
//							stringUnderSplitRhs.append("()");
//						} else {
//							if (rhsPropertyList.size() == (index + 1)) {
//								stringUnderSplitRhs.append("()");
//							} else {
//								stringUnderSplitRhs.append("."
//										+ rhsPropertyList
//												.get(++index));
//							}
//						}
//					}
//				} else {// else start
//					if (!Character.isDigit(rhsPropertyList.get(
//							index).charAt(0))) {
//						if (rhsPropertyList.get(index).contains(
//								"==")) {// checks conditon after a
//										// method for adding ()
//							String temp[] = rhsPropertyList.get(
//									index).split("\\==", 2);
//							stringUnderSplitRhs.append(".get"
//									+ temp[0].trim() + "() =="
//									+ temp[1]);
//
//						} else {
//							if (rhsPropertyList.get(index).trim()
//									.equals("ToString()")) {
//								stringUnderSplitRhs
//										.append(".toString");
//							} else {
//								stringUnderSplitRhs.append(".get"
//										+ rhsPropertyList
//												.get(index));
//							}
//
//						}
//					} else {
//						stringUnderSplitRhs.append("."
//								+ rhsPropertyList.get(index));
//						continue;
//					}
//					if (!(rhsPropertyList.get(index).endsWith(")"))
//							&& !(rhsPropertyList.get(index)
//									.endsWith("\""))) {
//						if (!(Character
//								.isDigit(rhsPropertyList
//										.get((rhsPropertyList
//												.size() > (index + 1) ? index + 1
//												: index)).charAt(0)))) {
//							stringUnderSplitRhs.append("()");
//						} else {
//							if (rhsPropertyList.size() == (index + 1)) {
//								stringUnderSplitRhs.append("()");
//							} else {
//								stringUnderSplitRhs.append("."
//										+ rhsPropertyList
//												.get(++index));
//							}
//						}
//					}
//				}
//			} else if (rhsPropertyList.size() - 1 == 1) {
//				if (index == 0) {
//					stringUnderSplitRhs.append(NamingUtil.toCamelCase(rhsPropertyList
//							.get(index)));
//				} else if (index == 1) {
//					stringUnderSplitRhs.append(".get"
//							+ rhsPropertyList.get(index));
//					if (!(rhsPropertyList.get(index).endsWith(")"))
//							&& !(rhsPropertyList.get(index)
//									.endsWith("\""))) {
//						stringUnderSplitRhs.append("()");
//					}
//				}
//			} else {
//				stringUnderSplitRhs.append(NamingUtil.toCamelCase(rhsPropertyList
//						.get(index)));
//			}
//		}
//		return stringUnderSplitRhs;
//	}
//	
//	 public static List<String> returnRHSPropertyList(String stmtRhs){
//		 List<String> rhsPropertyList = new LinkedList<String>();
//		while (stmtRhs.contains(".")) {
//			int splitCountIndex = 0;
//			for (String var : stmtRhs.split("\\.", 2)) {
//				if (splitCountIndex == 1) {
//					stmtRhs = var;
//				} else {
//					rhsPropertyList.add(var);
//				}
//				splitCountIndex++;
//			}
//		}
//		rhsPropertyList.add(stmtRhs);
//		return rhsPropertyList;
//	}
//
//	public static String prefixGetSet1(String statement) {
//		String stmtLhs = null;
//		String stmtRhs = null;
//		List<String> lhsPropertyList = new LinkedList<String>();
//		List<String> rhsPropertyList = new LinkedList<String>();
//		StringBuilder stringUnderSplitLhs = new StringBuilder();
//		StringBuilder stringUnderSplitRhs = new StringBuilder();
//		int splitCount = 0;
//		for (String var : statement.split("=", 2)) {
//			if (splitCount == 0) {
//				stmtLhs = var.trim();
//			} else if (splitCount == 1) {
//				stmtRhs = var.trim();
//			}
//			splitCount++;
//		}
//		// to process LHS
//		while (stmtLhs.contains(".")) {
//			int splitCountIndex = 0;
//			for (String var : stmtLhs.split("\\.", 2)) {
//				if (splitCountIndex == 1) {
//					stmtLhs = var;
//				} else {
//					lhsPropertyList.add(var);
//				}
//				splitCountIndex++;
//			}
//		}
//		lhsPropertyList.add(stmtLhs);
//
//		for (int index = 0; index < lhsPropertyList.size(); index++) {
//			if (lhsPropertyList.size() - 1 > 2) {
//				if (index == 0) {
//					stringUnderSplitLhs.append(lhsPropertyList.get(index));
//				} else if (index == lhsPropertyList.size() - 1) {
//					stringUnderSplitLhs.append(".set"
//							+ lhsPropertyList.get(index) + "(");
//				} else {
//					stringUnderSplitLhs.append(".get"
//							+ lhsPropertyList.get(index) + "()");
//				}
//			} else if (lhsPropertyList.size() - 1 == 1) {
//				if (index == 0) {
//					stringUnderSplitLhs.append(lhsPropertyList.get(index));
//				} else if (index == 1) {
//					stringUnderSplitLhs.append(".set"
//							+ lhsPropertyList.get(index) + "(");
//				}
//			} else {
//				stringUnderSplitLhs = stringUnderSplitLhs.append(stmtLhs
//						+ " = ");
//			}
//		}
//		// to process RHS
//		if (!stmtRhs.contains(".Transalate<")) {
//			while (stmtRhs.contains(".")) {
//				int splitCountIndex = 0;
//				for (String var : stmtRhs.split("\\.", 2)) {
//					if (splitCountIndex == 1) {
//						stmtRhs = var;
//					} else {
//						rhsPropertyList.add(var);
//					}
//					splitCountIndex++;
//				}
//			}
//			rhsPropertyList.add(stmtRhs);
//
//			for (int index = 0; index < rhsPropertyList.size(); index++) {
//				if (rhsPropertyList.size() - 1 >= 2) {
//					if (index == 0) {
//						stringUnderSplitRhs.append(rhsPropertyList.get(index));
//					} else if (index == rhsPropertyList.size() - 1) {
//
//						stringUnderSplitRhs.append(".get"
//								+ rhsPropertyList.get(index));
//						if (!(rhsPropertyList.get(index).endsWith(")"))
//								&& !(rhsPropertyList.get(index).endsWith("\""))) {
//							stringUnderSplitRhs.append("()");
//						}
//					} else {
//						stringUnderSplitRhs.append(".get"
//								+ rhsPropertyList.get(index));
//						if (!(rhsPropertyList.get(index).endsWith(")"))
//								&& !(rhsPropertyList.get(index).endsWith("\""))) {
//							stringUnderSplitRhs.append("()");
//						}
//					}
//				} else if (rhsPropertyList.size() - 1 == 1) {
//					if (index == 0) {
//						stringUnderSplitRhs.append(rhsPropertyList.get(index));
//					} else if (index == 1) {
//						stringUnderSplitRhs.append(".get"
//								+ rhsPropertyList.get(index) + ";");
//					}
//				} else {
//					stringUnderSplitRhs = stringUnderSplitRhs.append(stmtRhs);
//				}
//			}
//			statement = stringUnderSplitLhs.toString()
//					+ stringUnderSplitRhs.toString() + ")";
//		} else if (stmtRhs.contains(".Transalate<")) {
//			statement = stringUnderSplitLhs.toString()
//					+ processEmbdStmtRhs(stmtRhs);
//		}
//
//		return statement;
//
//	}
//	
//	public static String prefixGetSet3(String statement) {
//		String stmtLhs = null;
//		String stmtRhs = null;
//		List<String> lhsPropertyList = new LinkedList<String>();
//		List<String> rhsPropertyList = new LinkedList<String>();
//		StringBuilder stringUnderSplitLhs = new StringBuilder();
//		StringBuilder stringUnderSplitRhs = new StringBuilder();
//		int splitCount = 0;
//		for (String var : statement.split("=", 2)) {
//			if (splitCount == 0) {
//				stmtLhs = var.trim();
//			} else if (splitCount == 1) {
//				stmtRhs = var.trim();
//			}
//			splitCount++;
//		}
//		// to process LHS
//		while (stmtLhs.contains(".")) {
//			int splitCountIndex = 0;
//			for (String var : stmtLhs.split("\\.", 2)) {
//				if (splitCountIndex == 1) {
//					stmtLhs = var;
//				} else {
//					lhsPropertyList.add(var);
//				}
//				splitCountIndex++;
//			}
//		}
//		lhsPropertyList.add(stmtLhs);
//
//		for (int index = 0; index < lhsPropertyList.size(); index++) {
//			if (lhsPropertyList.size() - 1 > 2) {
//				if (index == 0) {
//					stringUnderSplitLhs.append(lhsPropertyList.get(index));
//				} else if (index == lhsPropertyList.size() - 1) {
//					stringUnderSplitLhs.append(".set"
//							+ lhsPropertyList.get(index) + "(");
//				} else {
//					stringUnderSplitLhs.append(".get"
//							+ lhsPropertyList.get(index) + "()");
//				}
//			} else if (lhsPropertyList.size() - 1 == 1) {
//				if (index == 0) {
//					stringUnderSplitLhs.append(lhsPropertyList.get(index));
//				} else if (index == 1) {
//					stringUnderSplitLhs.append(".set"
//							+ lhsPropertyList.get(index) + "(");
//				}
//			} else {
//				stringUnderSplitLhs = stringUnderSplitLhs.append(stmtLhs
//						+ " = ");
//			}
//		}
//		// to process RHS
//		if (!stmtRhs.contains(".Transalate<")) {
//			while (stmtRhs.contains(".")) {
//				int splitCountIndex = 0;
//				for (String var : stmtRhs.split("\\.", 2)) {
//					if (splitCountIndex == 1) {
//						stmtRhs = var;
//					} else {
//						rhsPropertyList.add(var);
//					}
//					splitCountIndex++;
//				}
//			}
//			rhsPropertyList.add(stmtRhs);
//
//			for (int index = 0; index < rhsPropertyList.size(); index++) {
//				if (rhsPropertyList.size() - 1 >= 2) {
//					if (index == 0) {
//						stringUnderSplitRhs.append(rhsPropertyList.get(index));
//					} else if (index == rhsPropertyList.size() - 1) {
//						stringUnderSplitRhs.append(".get"
//								+ rhsPropertyList.get(index) + "()");
//					} else {
//						stringUnderSplitRhs.append(".get"
//								+ rhsPropertyList.get(index) + "()");
//					}
//				} else if (rhsPropertyList.size() - 1 == 1) {
//					if (index == 0) {
//						stringUnderSplitRhs.append(rhsPropertyList.get(index));
//					} else if (index == 1) {
//						stringUnderSplitRhs.append(".get"
//								+ rhsPropertyList.get(index) + ";");
//					}
//				} else {
//					stringUnderSplitRhs = stringUnderSplitRhs.append(stmtRhs);
//				}
//			}
//			statement = stringUnderSplitLhs.toString()
//					+ stringUnderSplitRhs.toString() + ")";
//		} else if (stmtRhs.contains(".Transalate<")) {
//			statement = stringUnderSplitLhs.toString()
//					+ processEmbdStmtRhs(stmtRhs);
//		}
//
//		return statement;
//
//	}
//	
//
//
//	public static String processEmbdStmtRhs(String statement) {
//		// masterBatchQuery.Transalate<NetworkEntity>()
//		StringBuilder finalStmt = new StringBuilder();
//		String stmtRhs = null;
//		finalStmt.append("resObj.get");
//		if (statement.contains(".Transalate<")) {
//			int index = 0;
//			for (String var : statement.split("<")) {
//				if (index == 1) {
//					stmtRhs = var;
//				}
//
//				index++;
//			}
//			finalStmt = finalStmt.append(stmtRhs.replace(">();", "List()"));
//			statement = finalStmt.toString();
//		}
//		int braceCount = 0;
//		char[] charStmt = statement.toCharArray();
//		for (int i = 0; i < charStmt.length; i++) {
//			if (charStmt[i] == '(' && statement.toCharArray()[i + 1] != ')') {
//				braceCount++;
//			}
//		}
//		while (braceCount > 0) {
//			statement = statement + ")";
//			braceCount--;
//		}
//		return statement + ");";
//
//	}

}
