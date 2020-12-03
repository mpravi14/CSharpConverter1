package com.hcl.atma.converter.util;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.util.LinkedList;
import java.util.List;
import java.util.Properties;

import org.antlr.stringtemplate.StringTemplate;
import org.antlr.stringtemplate.StringTemplateGroup;

import com.hcl.atma.converter.generator.NamingUtil;
import com.hcl.atma.converter.generator.TargetWorkspaceManager;
import com.hcl.atma.converter.processor.TranslationProcessor;

public class CSharpHelper {

	static String pkgDecl = null;

	public static String replaceJavaType(String type) {
		if ((type).contains("IEnumerable")) {
			type = type.replace("IEnumerable", "List").trim();
		} else if ((type).contains("string") || (type).equals("string")) {
			type = type.replace("string", "String").trim();
		} else if ((type).contains("DateTime")) {
			type = "TimeStamp";
		}
		return type;

	}

	public static String processEmbdStmtRhs(String statement) {
		// masterBatchQuery.Transalate<NetworkEntity>()
		StringBuilder finalStmt = new StringBuilder();
		String stmtRhs = null;
		finalStmt.append("resObj.get");
		if (statement.contains(".Transalate<")) {
			int index = 0;
			for (String var : statement.split("<")) {
				if (index == 1) {
					stmtRhs = var;
				}

				index++;
			}
			finalStmt = finalStmt.append(stmtRhs.replace(">();", "List()"));
			statement = finalStmt.toString();
		}
		int braceCount = 0;
		char[] charStmt = statement.toCharArray();
		for (int i = 0; i < charStmt.length; i++) {
			if (charStmt[i] == '(' && statement.toCharArray()[i + 1] != ')') {
				braceCount++;
			}
		}
		while (braceCount > 0) {
			statement = statement + ")";
			braceCount--;
		}
		return statement + ");";

	}

	public static String processAssignmentStmts(String statements) {
		statements = statements.replace("{", "");
		statements = statements.replace("}", "");
		StringBuilder statementsUnderBuild = new StringBuilder();
		List<String> stmtList;
		try {
			stmtList = FileUtil.getLinesFromString(statements.trim());

			List<String> modfStmtList = new LinkedList<String>();
			if (!stmtList.isEmpty()) {
				String stmt1 = "";
				String temp = "";
				for (int i = 0; i < stmtList.size(); i++) {
					String stmt = stmtList.get(i);
					if (!stmt1.equals("")) {
						stmt = stmt1 + stmt.trim();
						stmt1 = "";
					}
					if ((i + 1) < stmtList.size()) {
						if (stmt.contains("//")) {
							temp = temp + stmt.substring(stmt.indexOf("//"));
							stmt = stmt.substring(0, stmt.indexOf("//") - 1);
						}
						stmt1 = stmt1 + stmt;
						continue;
					}

					

					if (stmt.trim().startsWith("/")) {
						modfStmtList.add(stmt);
					} 
					else {
						String modfstmt = prefixGetSet(stmt);
						if (!temp.equals("")) {
							modfstmt = modfstmt + temp;
							temp = "";
						}
						modfStmtList.add(modfstmt);
					}

				}
			}

			for (String tempStr : modfStmtList) {
				statementsUnderBuild = statementsUnderBuild.append(tempStr
						+ "\n");
			}

		} catch (IOException e) {
			e.printStackTrace();
		}
		statements = statementsUnderBuild.toString();
		return statements.trim();

	}

	public static String prefixGetSet(String statement) {
		String stmtLhs = null;
		String stmtRhs = null;
		List<String> lhsPropertyList = new LinkedList<String>();
		List<String> rhsPropertyList = new LinkedList<String>();
		StringBuilder stringUnderSplitLhs = new StringBuilder();
		StringBuilder stringUnderSplitRhs = new StringBuilder();
		int splitCount = 0;
		for (String var : statement.split("=", 2)) {
			if (splitCount == 0) {
				stmtLhs = var.trim();
			} else if (splitCount == 1) {
				stmtRhs = var.trim();
			}
			splitCount++;
		}
		// to process LHS
		while (stmtLhs.contains(".")) {
			int splitCountIndex = 0;
			for (String var : stmtLhs.split("\\.", 2)) {
				if (splitCountIndex == 1) {
					stmtLhs = var;
				} else {
					lhsPropertyList.add(var);
				}
				splitCountIndex++;
			}
		}
		lhsPropertyList.add(stmtLhs);

		for (int index = 0; index < lhsPropertyList.size(); index++) {
			if (lhsPropertyList.size() - 1 > 2) {
				if (index == 0) {
					stringUnderSplitLhs.append(lhsPropertyList.get(index));
				} else if (index == lhsPropertyList.size() - 1) {
					stringUnderSplitLhs.append(".set"
							+ lhsPropertyList.get(index) + "(");
				} else {
					stringUnderSplitLhs.append(".get"
							+ lhsPropertyList.get(index) + "()");
				}
			} else if (lhsPropertyList.size() - 1 == 1) {
				if (index == 0) {
					stringUnderSplitLhs.append(lhsPropertyList.get(index));
				} else if (index == 1) {
					stringUnderSplitLhs.append(".set"
							+ lhsPropertyList.get(index) + "(");
				}
			} else {
				stringUnderSplitLhs = stringUnderSplitLhs.append(stmtLhs
						+ " = ");
			}
		}
		// to process RHS
		if (!stmtRhs.contains(".Transalate<")) {
			while (stmtRhs.contains(".")) {
				int splitCountIndex = 0;
				for (String var : stmtRhs.split("\\.", 2)) {
					if (splitCountIndex == 1) {
						stmtRhs = var;
					} else {
						rhsPropertyList.add(var);
					}
					splitCountIndex++;
				}
			}
			rhsPropertyList.add(stmtRhs);

			for (int index = 0; index < rhsPropertyList.size(); index++) {
				if (rhsPropertyList.size() - 1 >= 2) {
					if (index == 0) {
						stringUnderSplitRhs.append(rhsPropertyList.get(index));
					} else if (index == rhsPropertyList.size() - 1) {
						stringUnderSplitRhs.append(".get"
								+ rhsPropertyList.get(index) + "()");
					} else {
						stringUnderSplitRhs.append(".get"
								+ rhsPropertyList.get(index) + "()");
					}
				} else if (rhsPropertyList.size() - 1 == 1) {
					if (index == 0) {
						stringUnderSplitRhs.append(rhsPropertyList.get(index));
					} else if (index == 1) {
						stringUnderSplitRhs.append(".get"
								+ rhsPropertyList.get(index) + ";");
					}
				} else {
					stringUnderSplitRhs = stringUnderSplitRhs.append(stmtRhs);
				}
			}
			statement = stringUnderSplitLhs.toString()
					+ stringUnderSplitRhs.toString() + ")";
		} else if (stmtRhs.contains(".Transalate<")) {
			statement = stringUnderSplitLhs.toString()
					+ processEmbdStmtRhs(stmtRhs);
		}

		return statement;

	}

	public static String prefixGetKeyword(String inputExpr) {
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
		
		for (int index = 0; index < propertyList.size(); index++) {
			if (propertyList.size() - 1 >= 2) {
				if (index == 0) {
					stringUnderSplit.append(propertyList.get(index));
				} else if (index == propertyList.size() - 1) {
					stringUnderSplit.append(".get"
							+ replaceJavaMethod(propertyList.get(index))
									.replace("()", "") + "()");
				} else {
					stringUnderSplit.append(".get"
							+ replaceJavaMethod(propertyList.get(index))
									.replace("()", "") + "()");
				}
			} else if (propertyList.size() - 1 == 1) {
				if (index == 0) {
					stringUnderSplit.append(propertyList.get(index));
				} else if (index == 1) {
					stringUnderSplit.append(".get"
							+ replaceJavaMethod(propertyList.get(index))
									.replace("()", "") + "()");
				}
			} else {
				stringUnderSplit = stringUnderSplit.append(inputExpr);
			}
		}

		return inputExpr = stringUnderSplit.toString();

	}

	public static String processTypedMemberDeclaration(String type, String body) {
		String reproducedBody = body;
		if (body.contains("set;") || body.contains("get;")) {
			reproducedBody = generateGetterAndSetter(replaceJavaType(type),
					body);
		} else {
			reproducedBody = replaceJavaType(type);
		}

		return reproducedBody;

	}

	public static String compareTypeAndBody(String type, String body) {
		if (body.equalsIgnoreCase(type)) {
			body = null;
		} else {
			body = type + body;
		}
		return body;

	}

	public static String generateGetterAndSetter(String memType,
			String proDeclRet) {
		int index = 0;
		String memberName = null;
		for (String var : proDeclRet.split("\\{", 2)) {
			if (index == 0) {
				memberName = var.toString().trim();
			}

			index++;
		}
		String statementList = null;
		String memDecl = memType.trim() + " "
				+ NamingUtil.toCamelCase(memberName) + ";\n";
		String getterStmt = "\npublic " + memType.trim() + " get" + memberName
				+ "(){\n  return " + NamingUtil.toCamelCase(memberName)
				+ ";\n}";
		String setterStmt = "\npublic void set" + memberName.trim() + "("
				+ memType.trim() + " " + NamingUtil.toCamelCase(memberName)
				+ "){\n	this." + NamingUtil.toCamelCase(memberName) + "="
				+ NamingUtil.toCamelCase(memberName) + ";\n}\n";

		statementList = memDecl + getterStmt + setterStmt;
		return statementList;

	}

	public static String replaceSqlPart(String statement) {
		String sqlProcName = null;
		int splitCount = 0;
		for (String var : statement.split(",", 2)) {
			if (splitCount == 1) {
				sqlProcName = var.trim().replace(")", "");
			}
			splitCount++;
		}

		// String replace =
		// "CallableStatement q = dataSource.getConnection().prepareCall(\"{call \"+"+sqlProcName.trim()+"+\"}\");\n boolean suc = q.execute();\n ResultSet resObj = q.getResultSet();\n";
		String replace = "List<" + sqlProcName.trim()
				+ "> resObj = new LinkedList<" + sqlProcName.trim() + ">();";
		String last = statement.replace(statement, replace);
		return last;
	}

	public static String filterOriginalMember(List<Object> memberList) {
		StringBuilder output = new StringBuilder();
		String originalMember = null;
		for (int index = 0; index < memberList.size(); index++) {
			if (index == 0) {
				Object obj = memberList.get(index).toString();
				originalMember = obj.toString();
			} else {
				String otherMember = null;
				Object obj = memberList.get(index).toString();
				if(obj.toString().trim().startsWith("public class")){
				  output.append(getDataobjectHeader());
				}
				output.append(obj.toString());
				writeOtherMemberstoSuitableFiles(output.toString());
				output = new StringBuilder();
			}

		}

		return originalMember;

	}
	
	public static String getDataobjectHeader(){
		 Reader reader = null;
		 StringTemplateGroup group;
		 StringTemplate st = null;
		 try {
				reader = new FileReader("st\\cSharp.stg");
			} catch (FileNotFoundException e1) {
					e1.printStackTrace();
			}

			group = new StringTemplateGroup(reader);
			st = group.getInstanceOf("dataObjectHeader");
			return st.toString();
	}

	public static String extractMemberNameFromString(String memberAsString) {
		String memberName = null;
		int firstSplitCount = 0;
		for (String var : memberAsString.split("class", 2)) {
			if (firstSplitCount == 1) {
				String memNameAndBdy = var.toString();
				int secondSplitIndex = 0;
				for (String var2 : memNameAndBdy.split("\\{", 2)) {
					if (secondSplitIndex == 0) {
						memberName = var2.trim();
						if (memberName.contains("extends")) {
							memberName = memberName.substring(0,
									memberName.indexOf("extends") - 1);
						}
						secondSplitIndex++;
					}
				}
			}
			firstSplitCount++;
		}

		return memberName;
	}
	
	public static String extractClassNameForAngularJS(String memberAsString) {
		String memberName = null;
		if (memberAsString.trim().startsWith("interface")) {
			memberName = memberAsString.trim().substring(
					(memberAsString.trim().indexOf("interface") + 10),
					(memberAsString.trim().indexOf("{")));
		} else if(memberAsString.trim().startsWith("enum")){
			memberName = memberAsString.trim().substring(
					(memberAsString.trim().indexOf("enum") + 5),
					(memberAsString.trim().indexOf("{") - 1));
		}else{
			memberName = memberAsString.trim().substring(
					(memberAsString.trim().indexOf("app.controller") + 16),
					(memberAsString.trim().indexOf(",") - 1));
		}
		return memberName;
	}

	public static String extractMemberNameForAngularJS(String memberAsString) {
		String memberName = null;
		memberName = memberAsString.trim().substring(5,
				(memberAsString.indexOf("=") - 4));
		return memberName;
	}

	public static void writeOtherMemberstoSuitableFiles(String otherMember) {
		String javaFile = "\n\n" + otherMember.toString();
		try {

			File outputFolder = null;
			outputFolder = new File(TargetWorkspaceManager.getOutputFolder());
			if (!outputFolder.exists()) {
				outputFolder.mkdirs();
			}

			String outputPackage = "";
			if (TranslationProcessor.dirName.endsWith("viewdata")) {
				String outputDirc = TargetWorkspaceManager.getOutputFolder()
						+ File.separator + "viewdata";
				outputFolder = new File(outputDirc);
				outputFolder.mkdirs();
				// to point resource\output folder as default
				outputFolder = new File(
						TargetWorkspaceManager.getOutputFolder());
				outputPackage = outputFolder
						+ File.separator
						+ "viewdata"
						+ File.separator
						+ NamingUtil
								.toClassName(extractMemberNameForAngularJS(javaFile)
										+ ".js");
			} else if (TranslationProcessor.dirName.endsWith("class")) {
				// class
				String outputDirc = TargetWorkspaceManager.getOutputFolder()
						+ File.separator + "class";
				outputFolder = new File(outputDirc);
				outputFolder.mkdirs();
				// to point resource\output folder as default
				outputFolder = new File(
						TargetWorkspaceManager.getOutputFolder());
				outputPackage = outputFolder
						+ File.separator
						+ "class"
						+ File.separator
						+ NamingUtil
								.toClassName(extractMemberNameFromString(javaFile)
										+ ".java");

			}else if (TranslationProcessor.dirName.endsWith("controller")) {
				// controller
				String outputDirc = TargetWorkspaceManager.getOutputFolder()
						+ File.separator + "controller";
				outputFolder = new File(outputDirc);
				outputFolder.mkdirs();
				// to point resource\output folder as default
				outputFolder = new File(
						TargetWorkspaceManager.getOutputFolder());
				outputPackage = outputFolder
						+ File.separator
						+ "controller"
						+ File.separator
						+ NamingUtil
								.toClassName(extractClassNameForAngularJS(javaFile)
										+ ".js");

			}
			File outputFile = new File(outputPackage);
			if (!outputFile.exists()) {
				outputFile.createNewFile();
			}

			OutputStreamWriter out = new OutputStreamWriter(
					new FileOutputStream(outputFile));
			out.write(javaFile);
			Runtime.getRuntime().exec(
					"lib/AStyle/bin/AStyle.exe -A2 -s4 -p -N -f -E --mode=java --suffix=none "
							+ outputFile);
			out.close();
			outputPackage = "";
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public static void preservePackageDeclaration(String packageDecl) {
		pkgDecl = packageDecl;
	}

	public static String replaceAngulurJSVariableName(String input) {
		if (("insert").equalsIgnoreCase(input)
				|| (".insert").equalsIgnoreCase(input)) {
			return ".push";
		}
		if ((".empty").equalsIgnoreCase(input)
				|| ("empty").equalsIgnoreCase(input)
				|| (".\"\"").equalsIgnoreCase(input)
				|| ("string").equalsIgnoreCase(input)) {
			return "\'\'";
		} else if (("string").equalsIgnoreCase(input)) {
			return null;
		}
		if (input.startsWith(".")) {
			input = "." + NamingUtil.toCamelCase(input.substring(1));
		}
		return input;
	}

	public static String mappingVariableDataType(String input, String body) {
		if (TranslationProcessor.dirName.endsWith("viewdata")) {
			if (body != null && !body.contains("get"))
				return "";
			if (input.contains("string")) {
				return "= \'\';";
			} else if (("int").equalsIgnoreCase(input)
					|| ("int?").equalsIgnoreCase(input)) {
				return " = 0;";
			} else if (("DateTime").equalsIgnoreCase(input)
					|| ("DateTime?").equalsIgnoreCase(input)) {
				return "= null;";
			} else if (("bool").equalsIgnoreCase(input)) {
				return " = false;";
			} else {
				return "= [];";
			}
		}
		return input;
	}

	public static String prefixInheritanceType(String parentMember) {

		if (parentMember.startsWith("I")) {
			parentMember = "implements " + parentMember;
		} else {
			parentMember = "extends " + parentMember;
		}

		return parentMember;

	}

	public static String replaceJavaMethod(String methodName) {

		if (("single").equalsIgnoreCase(methodName)) {
			methodName = "getSingleResult";
		} else if (("EF").equalsIgnoreCase(methodName)) {
			methodName = methodName.toUpperCase();
		} else if (("Trim").equalsIgnoreCase(methodName)) {
			methodName = methodName.toLowerCase();
		}
		return methodName;

	}

	public static String preProcessSingleLineComment(String inputCommnet) {
		if (inputCommnet.startsWith("///")) {
			inputCommnet = inputCommnet.replace("///", "");
		} else if (inputCommnet.startsWith("//")) {
			inputCommnet = inputCommnet.replace("//", "");
		}
		if (inputCommnet != null && (inputCommnet.trim().equalsIgnoreCase("<summary>")||inputCommnet.trim().equalsIgnoreCase("</summary>"))) {
			inputCommnet = "";
		}
		return inputCommnet;

	}

	public static String prefixTempVar(String inputExpr) {
		int splitIndex = 0;
		String inputExprRhs = null;
		;
		for (String var : inputExpr.split("\\.")) {
			if (splitIndex == 1) {
				inputExprRhs = var.toString();
			}
			splitIndex++;
		}
		inputExpr = "tempList.get" + inputExprRhs + "()";
		return inputExpr;

	}

	public static String processSingleResultSet(String inputStmt) {
		StringBuilder finalStmt = new StringBuilder();
		if(inputStmt==null){
			return "";
		}
		if (inputStmt.contains("SQL.EF.Translate<")) {
			// SQL.EF.Translate<NetworkEntity>(sqlProc, "@UserIdNo",
			// UserIdNo).Single();
			inputStmt = inputStmt.replace("SQL.EF.Translate<", "resObj.get");
			int splitIndex = 0;
			for (String var : inputStmt.split(">")) {
				if (splitIndex == 0) {
					finalStmt.append(var.toString());
				}
				splitIndex++;
			}

			inputStmt = finalStmt.append("List().getSingleResultList();")
					.toString();
		}

		return inputStmt;

	}
	
	public static String intializeStoreProc(String varType,String decl){
		StringBuilder output = new StringBuilder();
		if(decl != null && decl.startsWith("sqlProc")){
			decl = decl.substring(decl.indexOf("sqlProc = ")+10,decl.length()).replace("\"", "");
			String[] array=decl.split("@");
			//output = "List<?> returnData= UspAdminGetFunctionalRoleMappings.execute(functionalRoleName)";
			if(array[0].contains("_")){
				array[0] = array[0].replaceAll("_", "");
			}
			output.append(NamingUtil.toClassName(array[0])+ " "+ NamingUtil.changeToCamelCase(array[0], true)+" = new  " + NamingUtil.toClassName(array[0]).trim() +"();");
			output.append("returnData=");
			output.append(array[0].trim());
			output.append(".execute(");
			int index = 1;
			if(array.length>1){
				do{
				output.append(array[index]);
				index++;
				}while(index < array.length);
			}
			output.append(");");
			output.append("\n  //TODO This snippet is extraced from the legagcy code and its only for the Refrence. Can be deleted post clean-up");
			output.append("\n /* ");
		}
		else{
			output.append(""+varType +" " +decl);
		}
	
		return output.toString();

	}
	public static String updateRetrunStatment(String stmt){
		StringBuilder output = new StringBuilder();
		int index = stmt.indexOf("return returnData;");
		if(index > 0){
			output.append(stmt.substring(0, index));
			output.append(stmt.substring(index+20, stmt.length()));
			output.append("LOGGER.debug(\"Response Params: \"+returnData);");
			output.append("return returnData;");
		}
		else{
			output.append(stmt);
		}
		return output.toString();
	}
	
	public static String validationMessageIntoPropertyFile(String inputStmt){
		try {
			Properties properties = new Properties();
			properties.setProperty("Validation", inputStmt);

			File file = new File("ValidationMessage.properties");
			FileOutputStream fileOut = new FileOutputStream(file);
			properties.store(fileOut, "Class Name");
			fileOut.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

		return inputStmt;

	}
	public static String updateLoggerRequest(String stmt){
		StringBuilder output = new StringBuilder();
		output.append("LOGGER.info(\"Request Params: ");
		if(stmt!= null && !stmt.isEmpty()){
			String[] argu= stmt.split(",");
			if(argu.length >0){
				for (int i = 0; i < argu.length; i++) {
					if(i > 0){
						output.append("\"");	
					}
					String[] argumentName = argu[i].trim().split(" ");
					output.append(argumentName[1]+" :\"+"+argumentName[1]);
					if(i < argu.length-1){
						output.append("+");	
					}
				}
			}
		}
		else{
			output.append("\"");	
		}
		output.append(");");
		return output.toString();
	}
	
//	public static void main(String args[]){
//		validationMessageIntoPropertyFile("a");
//	}

}
