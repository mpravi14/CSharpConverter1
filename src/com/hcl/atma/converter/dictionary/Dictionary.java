package com.hcl.atma.converter.dictionary;

import org.antlr.stringtemplate.StringTemplate;

/**
 * interface definition PB type to java meaning dictionary
 * @author sathyanarayanan
 */
public interface Dictionary {

	public void setConfigFolder(String folder);
	public String lookupSynonyms(String word);
	public String lookupSynonyms(StringTemplate wordTemplate);
	public void loadDictionary();
	public void saveDictionary();
}
