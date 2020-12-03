package com.hcl.atma.converter.generator;

import java.util.Properties;

import com.google.common.base.CaseFormat;

public class NamingUtil implements SourceConstants {
	
	private static Properties customNames = null;
	
	private static Properties customDomainModelNames = null;
	
	private static String[] excludeNames = new String[]{"int", "double", "float", "boolean", "char", "String"};
	
	static {
		customNames = new Properties();
		customDomainModelNames = new Properties();
	}
	
	public static void recordCustomName(String actualName, String customName) {
		customNames.setProperty(actualName, customName);
	}
	
	/**
	 * This method helps to retrieve custom name for a given name. Useful to rename IDs in certain 
	 * unwanted patterns such as ID0XXXX. 
	 * 
	 * @param actualName
	 * @return custom name
	 */
	public static String getCustomName(String actualName) {
		String givenName = customNames.getProperty(actualName);
		if(givenName == null) {
			givenName = actualName;
		}
		return givenName;
	}
	
	public static String toUpperUnderscore(String camelCaseName) {
		String upperUnd = new String();
		camelCaseName = camelCaseName.substring(0,1).toUpperCase() + camelCaseName.substring(1);
		camelCaseName = CaseFormat.UPPER_CAMEL.to(CaseFormat.UPPER_UNDERSCORE, camelCaseName);
		// workaround to overcome the bug removing underscore between alphabets and numbers in the name
		// start=0; digit=1; char=2
		boolean digit = false;
		for (int i = 0; i < camelCaseName.length(); i++) {
			if(Character.isDigit(camelCaseName.charAt(i))) {
				if(upperUnd.length() == 0 || digit) {
					upperUnd+= camelCaseName.charAt(i);
				} else {
					upperUnd+= "_" + camelCaseName.charAt(i);
				}
				digit = true;
			} else {
				if(upperUnd.length() == 0 || !digit) {
					upperUnd+= camelCaseName.charAt(i);
				} else {
					upperUnd+= "_" + camelCaseName.charAt(i);
				}
				digit = false;
			}
		}
		return upperUnd;
	}
	
	public static String toDomainModelName(String origSchemaName, boolean lower) {
		String customTableName = null;
		customTableName = customDomainModelNames.getProperty(origSchemaName);
		if(customTableName == null) {
			customTableName = CaseFormat.UPPER_UNDERSCORE.to(CaseFormat.UPPER_CAMEL, origSchemaName);
			customDomainModelNames.setProperty(origSchemaName, customTableName);
		} 
		if(lower) {
			customTableName = customTableName.substring(0, 1).toLowerCase() + customTableName.substring(1);
		}
		return customTableName;
	}
	
	public static String toDomainModelName(String origName) {
		return toCamelCase(origName, false);
	}
	
	
	public static String toCamelCase(String hpsName, boolean lower) {
		boolean braceSuffix = false;
		if(hpsName == null) {
			return hpsName;
		} else if(hpsName.indexOf("().") > -1) {
			braceSuffix = true;
			hpsName = hpsName.substring(0, hpsName.indexOf("()."));
		}
		if(isExcluded(hpsName)) {
			return hpsName;
		}
		String camelCaseName = hpsName;
		if(isUpperUnderscore(hpsName)) {
			camelCaseName = customNames.getProperty(hpsName);
			if(camelCaseName == null) {
				camelCaseName = CaseFormat.UPPER_UNDERSCORE.to(CaseFormat.UPPER_CAMEL, hpsName);
				customNames.setProperty(hpsName, camelCaseName);
			} 
			if(lower) {
				camelCaseName = camelCaseName.substring(0, 1).toLowerCase() + camelCaseName.substring(1);
			}
			camelCaseName = braceSuffix ? camelCaseName + "()." : camelCaseName;
		} else if(lower) {
			camelCaseName = toVarName(hpsName);
		}
		return camelCaseName;
	}
	
	
	/**
	 * method to convert the lower underscore to camelcase
	 * @param varName - varibale name input parameter
	 * @param lower - first letter to be lower case
	 * @return varName in lowerCamel case letter
	 */
	public static String changeToCamelCase(String varName, boolean lower) {
		varName = varName.replace("$", "");
		if(isExcluded(varName)) {
			return varName;
		}
		String camelCaseName = varName;
		camelCaseName = customNames.getProperty(varName);
		if(camelCaseName == null) {
			if(!varName.contains("_")) {
				return toVarName(varName);
			}	
			camelCaseName = CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, varName);
			customNames.setProperty(varName, camelCaseName);
		}
		if(lower) {
			camelCaseName = camelCaseName.substring(0, 1).toLowerCase() + camelCaseName.substring(1);
		}
		return camelCaseName;
	}

	public static String toCamelCase(String hpsName) {
			return toCamelCase(hpsName, true);
	}

	private static boolean isExcluded(String name) {
		boolean ret = false;
		for (String excludedName : excludeNames) {
			if(excludedName.equals(name)) {
				ret = true;
				break;
			}
		}
		return ret;
	}
	
	/**
	 * Converts the variable name in camel case into class name in camel case (first letter to Upper)
	 * @param varNameCC - variable name in camel case
	 * @return name in upper camel case 
	 */
	public static String toClassName(String varNameCC) {
		if(varNameCC != null && isUpperUnderscore(varNameCC)) {
			varNameCC = toCamelCase(varNameCC);
		}
		if(varNameCC != null && varNameCC.length() > 1 ) {
			return varNameCC.substring(0, 1).toUpperCase() + varNameCC.substring(1);
		} else {
			return varNameCC.toUpperCase();
		}
	}

	public static boolean isUpperUnderscore(String name) {
		boolean upperUnderscore = true;
		name = name.indexOf(".") > -1 ? name = name.substring(0, name.indexOf(".")) : name;
		if(name.indexOf("_") > -1) {
			upperUnderscore = true;
		} else {
			
			for (int i = 0; i < name.length(); i++) {
				if(Character.isLowerCase(name.charAt(i))) {
					upperUnderscore = false;
					break;
				}
			}
		}
		return upperUnderscore;
	}
	/**
	 * Converts the class name in camel case into variable name in camel case (first letter to lower)
	 * @param varNameCC - variable name in camel case
	 * @return name in upper camel case 
	 */
	public static String toVarName(String classNameCC) {
		return classNameCC.substring(0, 1).toLowerCase() + classNameCC.substring(1);
	}

	public static String getGetterMethodName(String fieldName) {
		String getterName = "get" + fieldName.substring(0, 1).toUpperCase() + fieldName.substring(1);
		return getterName;
	}
	
	public static String getSetterMethodName(String fieldName) {
		String setterName = "set" + fieldName.substring(0, 1).toUpperCase() + fieldName.substring(1);
		return setterName;
	}
	
	public static String getManagedFormBeanClassName(String s) {
		CaseFormat cf = CaseFormat.LOWER_UNDERSCORE;
		String res = cf.to(CaseFormat.UPPER_CAMEL, s.toLowerCase());
		return (res + BEAN_SUFFIX);
	}

	public static String getManagedFormBeanVariableName(String s) {
		CaseFormat cf = CaseFormat.LOWER_UNDERSCORE;
		String res = cf.to(CaseFormat.LOWER_CAMEL, s.toLowerCase());
		return(res + BEAN_SUFFIX);
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
	public static String getControllerName(String inputString){
		return inputString.replace("Model", "Model");
	}
	
	
}
