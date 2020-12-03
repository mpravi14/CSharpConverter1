package com.hcl.atma.converter.generator;

import japa.parser.JavaParser;
import japa.parser.ParseException;
import japa.parser.ast.CompilationUnit;
import japa.parser.ast.PackageDeclaration;
import japa.parser.ast.expr.NameExpr;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;

import com.hcl.atma.converter.util.FileUtil;


public class WorkspaceHelper {

	private TargetWorkspaceManager wkspManager; 
	
	WorkspaceHelper(TargetWorkspaceManager wkspManager) {
		super();
		this.wkspManager = wkspManager;
	}

	void prepareHelper(File templatesDir) {
		
		FileInputStream fis;
		try {
			File helperFile = new File(templatesDir, "Helper.java");
			fis = new FileInputStream(helperFile);
			CompilationUnit helperCu = JavaParser.parse(fis);
			String newPackage = "com." + wkspManager.getCompanyName().toLowerCase() 
								+ "." + wkspManager.getApplicationName().toLowerCase()
								+ ".util"; 
			File helperFileDir = new File(wkspManager.getWebProjectSourceDir() + File.separator + 
					newPackage.replace(".", File.separator));
			PackageDeclaration packageDecl = new PackageDeclaration(new NameExpr(newPackage));
			helperCu.setPackage(packageDecl);
			FileUtil.writeCompilationUnitToFile(helperFileDir, "Helper.java", helperCu);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (ParseException e) {
			e.printStackTrace();
		}
	}

	void prepareModelHelperRemote(File templatesDir) {
		
		FileInputStream fis;
		try {
			File modelHelperRemoteFile = new File(templatesDir, "ModelHelperRemote.java");
			fis = new FileInputStream(modelHelperRemoteFile);
			CompilationUnit modelHelperRemoteCu = JavaParser.parse(fis);
			String newPackage = "com." + wkspManager.getCompanyName().toLowerCase() 
								+ "." + wkspManager.getApplicationName().toLowerCase()
								+ ".service"; 
			File modelHelperRemoteFileDir = new File(wkspManager.getWebProjectSourceDir() + File.separator + 
					newPackage.replace(".", File.separator));
			PackageDeclaration packageDecl = new PackageDeclaration(new NameExpr(newPackage));
			modelHelperRemoteCu.setPackage(packageDecl);
			FileUtil.writeCompilationUnitToFile(  modelHelperRemoteFileDir, "ModelHelperRemote.java", modelHelperRemoteCu);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (ParseException e) {
			e.printStackTrace();
		}
	}
	

	
}
