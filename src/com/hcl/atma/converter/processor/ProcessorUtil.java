package com.hcl.atma.converter.processor;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.antlr.stringtemplate.StringTemplate;

/**
 * utility class for translation processor
 * 
 * @author HCL
 */
public class ProcessorUtil {
	public static final List<String> suffixes;
	public static final List<String> globalFunctionSuffixes;
	public static final List<String> globalApplicationSuffixes;
	private static final List<String> camelCaseExceptionList;
	static {
		suffixes = Arrays.asList(".txt",".frm",".cls",".bas",".CLS",".mod",".cs");
		globalFunctionSuffixes = Arrays.asList(".srf");
		globalApplicationSuffixes = Arrays.asList(".sra");
		camelCaseExceptionList = Arrays.asList("KEYDOWN", "GETFOCUS");
	}

	public static String toProperCase(String paramName) {
		String[] tokens;
		String methodName = paramName;
		if (paramName == null || paramName.equals(""))
			return paramName;
		StringBuffer sb = new StringBuffer();
		if (methodName.contains("_")) {
			tokens = methodName.split("_");
		} else {
			tokens = methodName.split("-");
		}
		if (tokens.length == 1)
			return paramName;
		sb.append(String.valueOf(tokens[0].charAt(0)).toUpperCase());
		sb.append(tokens[0].substring(1, tokens[0].length()).toLowerCase());
		for (int i = 1; i < tokens.length; i++) {
			String s = tokens[i];
			sb.append(Character.toUpperCase(s.charAt(0)));
			if (s.length() > 1) {
				sb.append(s.substring(1, s.length()).toLowerCase());
			}
		}
		if (tokens.length > 0) {
			return sb.toString();
		}
		return paramName;
	}

	public static String toJavaCase(String paramName) {
		String methodName = paramName;
		if (paramName == null || paramName.equals(""))
			return paramName;
		StringBuffer sb = new StringBuffer();
		String[] tokens = methodName.split("_");
		if (tokens.length == 1) {
			sb.append(String.valueOf(tokens[0].charAt(0)).toUpperCase());
			sb.append(tokens[0].substring(1, tokens[0].length()));
			return sb.toString();
		}
		sb.append(String.valueOf(tokens[0].charAt(0)).toUpperCase());
		sb.append(tokens[0].substring(1, tokens[0].length()).toLowerCase());
		for (int i = 1; i < tokens.length; i++) {
			String s = tokens[i];
			sb.append(Character.toUpperCase(s.charAt(0)));
			if (s.length() > 1) {
				sb.append(s.substring(1, s.length()).toLowerCase());
			}
		}
		if (tokens.length > 0) {
			return sb.toString();
		}
		return paramName;
	}

	public static String toPropertyName(String paramName) {
		String methodName = "";
		if (paramName.charAt(0) == '"') {
			methodName = paramName.substring(1, paramName.length() - 1);
		} else {
			methodName = paramName;
		}

		StringBuffer sb = new StringBuffer();
		String[] tokens = methodName.split("_");

		sb.append(String.valueOf(tokens[0].charAt(0)).toUpperCase());
		sb.append(tokens[0].substring(1, tokens[0].length()).toLowerCase());
		for (int i = 1; i < tokens.length; i++) {
			String s = tokens[i];
			sb.append(Character.toUpperCase(s.charAt(0)));
			if (s.length() > 1) {
				sb.append(s.substring(1, s.length()).toLowerCase());
			}
		}
		if (tokens.length > 0) {
			return sb.toString();
		}
		return paramName;
	}

	public static String toCamelCase(String paramName) {
		String[] tokens;
		String methodName = paramName;
		if (methodName == null)
			return paramName;
		if (camelCaseExceptionList.contains(paramName))
			return paramName;
		StringBuffer sb = new StringBuffer();
		if (methodName.contains("_")) {
			tokens = methodName.split("_");
		} else {
			tokens = methodName.split("-");
		}
		sb.append(tokens[0].toLowerCase());
		for (int i = 1; i < tokens.length; i++) {
			String s = tokens[i];
			sb.append(Character.toUpperCase(s.charAt(0)));
			if (s.length() > 1) {
				sb.append(s.substring(1, s.length()).toLowerCase());
			}
		}
		if (tokens.length > 0) {
			return sb.toString();
		}
		return paramName;
	}

	public static String isReturnNull(String s) {
		return s.replace("null", "");
	}

	public static List<File> listDirectory(String dir, List<String> suffixes) {

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

	// public static String translateFormProperty(String id, ScreenInfo datamod,
	// boolean isGet) {
	// StringBuilder sb = new StringBuilder();
	// ScreenDataTableInfo currentDW = datamod.isEntityProperty(id);
	// if (currentDW != null) {
	// if (isGet) {
	// sb.append(datamod.getControllerInstanceName(currentDW
	// .getDataObjectName()) + "Bean");
	// sb.append(".getCurrent().");
	// sb.append("get" + toPropertyName(id) + "()");
	// } else {
	// sb.append(datamod.getControllerInstanceName(currentDW
	// .getDataObjectName()) + "Bean");
	// sb.append(".getCurrent().");
	// sb.append("set" + toPropertyName(id));
	// }
	// return sb.toString();
	// }
	//
	// return id;
	// }
	//
	// public static boolean checkIsFormProperty(String id, ScreenInfo datamod)
	// {
	// ScreenDataTableInfo currentDW = datamod.isEntityProperty(id);
	// if (currentDW != null) {
	// return true;
	// }
	//
	// return false;
	// }

	public static String removeEnumSymbol(String s) {
		return s.replace("!", "");
	}

	public static String removeEnumQuotes(StringTemplate s) {
		if (s != null)
			return s.toString().replace("\"", "");
		return null;
	}

	public static String checkStatementAndComment(StringTemplate input) {
		String[] exceptions = { "SQLCA", "OPEN", "CLOSE", "KEYDOWN",
				"PARENTWINDOW", "SETCOLUMN", "GETACTIVESHEET",
				"W_GL_MDI_S_PARENT", "CB_CLEAR", "CB_SAVE", "CB_INSERT",
				"CB_MODIFY", "CB_QUERY", "CB_DELETE", "SQLSTATEMENT",
				"TRIGGEREVENT" };

		if (input == null)
			return null;
		for (int i = 0; i < exceptions.length; i++) {
			if (input.toString().toUpperCase().contains(exceptions[i])) {
				String updatedInput = input.toString().replace("*/", "");
				return "/*" + updatedInput + "*/";
			}
		}
		String retn = input.toString().replace(",+", "+");
		return retn;

	}

	public static int getJavaIndex(String expr) {
		if (expr == null)
			return 0;
		return Integer.valueOf(expr) - 1;
	}

	public static String toPropCase(String paramName) {
		String[] tokens;
		String methodName = paramName;
		if (paramName == null || paramName.equals(""))
			return paramName;
		StringBuffer sb = new StringBuffer();
		if (methodName.contains("_")) {
			tokens = methodName.split("_");
		} else if (methodName.contains(" ")) {
			tokens = methodName.split(" ");
		} else {
			tokens = methodName.split("-");
		}
		if (tokens.length == 1) {
			StringBuffer buf = new StringBuffer();
			buf.append(Character.toUpperCase(paramName.charAt(0)));
			buf.append(paramName.substring(1, paramName.length()).toLowerCase());
			return buf.toString();
		}

		sb.append(String.valueOf(tokens[0].charAt(0)).toUpperCase());
		sb.append(tokens[0].substring(1, tokens[0].length()).toLowerCase());
		for (int i = 1; i < tokens.length; i++) {
			String s = tokens[i];
			sb.append(""+ Character.toUpperCase(s.charAt(0)));
			if (s.length() > 1) {
				sb.append(s.substring(1, s.length()).toLowerCase());
			}
		}
		if (tokens.length > 0) {
			return sb.toString();
		}
		return paramName;
	}

}
