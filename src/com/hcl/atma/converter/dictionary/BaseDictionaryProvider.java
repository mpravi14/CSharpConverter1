package com.hcl.atma.converter.dictionary;

import java.util.HashMap;
import java.util.Map;

/**
 * dictionary provider where PB type to java meaning is built as ENUMs
 * @author Saravananand
 */
public class BaseDictionaryProvider /*implements Dictionary */ {
	
	private static Map<String, String> knownTypes = new HashMap<String, String>();
	static {
		knownTypes.put("Control", "Object");
		knownTypes.put("Object", "Object");
		knownTypes.put("Integer", "Integer");
		knownTypes.put("Double", "Double");
		knownTypes.put("Date", "Date");
		knownTypes.put("Boolean", "Boolean");
		knownTypes.put("Long", "Long");
		knownTypes.put("String", "String");
		knownTypes.put("Collection", "Hashmap");
		knownTypes.put("Set", "Set");
		knownTypes.put("Variant", "Variant");
	}
	
	private enum VBType {
	      ERR("null"),
	      FALSE("Boolean.FALSE"),
	      TRUE("Boolean.TRUE"),
	      FORMAT("VBUtilFunctions.format"),
	      TRIM("VBUtilFunctions.trim"),
	      REPLACE("VBUtilFunctions.replace"),
	      ISARRAY("VBUtilFunctions.isArray"),
	      LBOUND("VBUtilFunctions.lBound"),
	      UBOUND("VBUtilFunctions.UBound"),
	      ISNULL("VBUtilFunctions.isNull"),
	      CLNG("VBUtilFunctions.clng"),
	      LEFT("VBUtilFunctions.left"),
	      RIGHT("VBUtilFunctions.right"),
	      MID("VBUtilFunctions.mid"),
	      INSTR("VBUtilFunctions.inStr"),
	      INSTRREV("VBUtilFunctions.inStrRev"),
	      LEN("VBUtilFunctions.len"),
	      DIR("VBUtilFunctions.isDir"),
	      CDATE("VBUtilFunctions.convertToDate"),
	      KILL("VBUtilFunctions.killFile"),
	      M_FSOFILEEXISTS("VBUtilFunctions.FileExists"),
	      SPACE("VBUtilFunctions.getSpace")
	     ;

	    String javaType;

	    VBType(String type) {
	        this.javaType= type;
	    }

	    public String getJavaType() { 
	    	return javaType; 
	    }

	}
	
	public static String getKnownType(String type) {
		return knownTypes.get(type);
	}
	
//	protected void addNewWord(String newWord)  {
//		String token=removeSpecialChar(newWord);
//		if(!dictionaryContent.contains("$"+token+"$")){
//			dictionaryContent=dictionaryContent+"\n"+"$"+token+"$="+newWord;
//		}	
//	}

	protected  String removeSpecialChar(String newWord){
		newWord = newWord.replace(".", "");
		newWord = newWord.replace("(", "");
		newWord = newWord.replace(")", "");
		newWord = newWord.replace(" ", "");
		newWord = newWord.replace("'", "");
		newWord = newWord.replace(",", "");
		newWord = newWord.replace("+", "");
		newWord = newWord.replace("!", "");
		newWord = newWord.trim();
		return newWord;
	}

	public  String getJavaMeaning(String word) {
		word=removeSpecialChar(word);
		return VBType.valueOf(word.toUpperCase()).getJavaType();
	}

//	@Override
//	public String lookupSynonyms(String word) {
//		
//		try {
//			return getJavaMeaning(word);
//		} catch (IllegalArgumentException e) {
//			addNewWord(word);
//		}
//		return word;
//	}

//	@Override
//	public void setConfigFolder(String folder) {
//		this.folder = folder;
//		
//	}

//	@Override
//	public void loadDictionary() {
//		BufferedReader reader;
//		try {
//			reader = new BufferedReader(new FileReader(folder+File.separator+file));
//    		int v;
//		    while ((v = reader.read()) != -1) {
//			    dictionaryContent = dictionaryContent + Character.toString((char) v);
//		    }
//		} catch (FileNotFoundException e) {
//			e.printStackTrace();
//		} catch (IOException e) {
//			e.printStackTrace();
//		}
//	}

//	@Override
//	public void saveDictionary() {
//		OutputStreamWriter out;
//		try {
//			out = new OutputStreamWriter(new FileOutputStream(new File(folder+File.separator+file)));
//			out.write(dictionaryContent);
//			out.close();
//		} catch (FileNotFoundException e) {
//			e.printStackTrace();
//		} catch (IOException e) {
//			e.printStackTrace();
//		}
//	}
//
//	@Override
//	public String lookupSynonyms(StringTemplate wordTemplate) {
//		if(wordTemplate==null){
//			return null;
//		} else{
//			return lookupSynonyms(wordTemplate.toString());
//		}
//	}
}
