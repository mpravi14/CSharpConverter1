package com.hcl.atma.converter.util;

import japa.parser.ASTHelper;
import japa.parser.ast.CompilationUnit;
import japa.parser.ast.ImportDeclaration;
import japa.parser.ast.PackageDeclaration;
import japa.parser.ast.body.BodyDeclaration;
import japa.parser.ast.body.ClassOrInterfaceDeclaration;
import japa.parser.ast.body.FieldDeclaration;
import japa.parser.ast.body.MethodDeclaration;
import japa.parser.ast.body.ModifierSet;
import japa.parser.ast.body.Parameter;
import japa.parser.ast.body.VariableDeclarator;
import japa.parser.ast.body.VariableDeclaratorId;
import japa.parser.ast.expr.AnnotationExpr;
import japa.parser.ast.expr.AssignExpr;
import japa.parser.ast.expr.AssignExpr.Operator;
import japa.parser.ast.expr.CastExpr;
import japa.parser.ast.expr.ClassExpr;
import japa.parser.ast.expr.Expression;
import japa.parser.ast.expr.FieldAccessExpr;
import japa.parser.ast.expr.IntegerLiteralExpr;
import japa.parser.ast.expr.LongLiteralExpr;
import japa.parser.ast.expr.MarkerAnnotationExpr;
import japa.parser.ast.expr.MemberValuePair;
import japa.parser.ast.expr.MethodCallExpr;
import japa.parser.ast.expr.NameExpr;
import japa.parser.ast.expr.NormalAnnotationExpr;
import japa.parser.ast.expr.NullLiteralExpr;
import japa.parser.ast.expr.SingleMemberAnnotationExpr;
import japa.parser.ast.expr.StringLiteralExpr;
import japa.parser.ast.expr.ThisExpr;
import japa.parser.ast.expr.VariableDeclarationExpr;
import japa.parser.ast.stmt.BlockStmt;
import japa.parser.ast.stmt.ExpressionStmt;
import japa.parser.ast.stmt.ReturnStmt;
import japa.parser.ast.stmt.Statement;
import japa.parser.ast.type.ClassOrInterfaceType;
import japa.parser.ast.type.PrimitiveType;
import japa.parser.ast.type.PrimitiveType.Primitive;
import japa.parser.ast.type.ReferenceType;
import japa.parser.ast.type.Type;
import japa.parser.ast.type.VoidType;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import com.hcl.atma.converter.generator.NamingUtil;
import com.hcl.atma.converter.generator.TargetWorkspaceManager;

public class JavaParserUtil {
	
	public static Type getJapaType(Object obj) {
		if(obj instanceof String) {
			return new ReferenceType(new ClassOrInterfaceType("String"));
		} else if(obj instanceof Integer) {
			return new PrimitiveType(Primitive.Int);
		} else {
			return null;
		}
	}
	
	public static FieldDeclaration createFieldDeclaration(String fieldName, String fieldClass) {
		return createFieldDeclaration(fieldName, fieldClass, ModifierSet.PRIVATE);
	}
	
	public static FieldDeclaration createFieldDeclaration(String fieldName, String fieldClass, int modifier) {
		Type stringType = new ReferenceType(new ClassOrInterfaceType(fieldClass));
		VariableDeclarator vd = null;
		if(fieldClass.equalsIgnoreCase("int") || fieldClass.equalsIgnoreCase("double")) {
			vd = new VariableDeclarator(new VariableDeclaratorId(fieldName), new IntegerLiteralExpr("0"));
		} else if(fieldClass.equalsIgnoreCase("long")) {
			vd = new VariableDeclarator(new VariableDeclaratorId(fieldName), new LongLiteralExpr("0"));
		} else {
			vd = new VariableDeclarator(new VariableDeclaratorId(fieldName), new NullLiteralExpr());
		}
		FieldDeclaration fd = new FieldDeclaration(modifier, stringType, vd);
		return fd;
	}

	public static MethodDeclaration createGetterMethodDeclaration(String fieldName, String fieldClass) {
		Type fieldDeclType = new ReferenceType(new ClassOrInterfaceType(fieldClass)); 
		String getterMethodName = NamingUtil.getGetterMethodName(fieldName);
		MethodDeclaration getterDecl = new MethodDeclaration(ModifierSet.PUBLIC, fieldDeclType, getterMethodName);
		ReturnStmt returnStmt = new ReturnStmt(new NameExpr(fieldName));
		List<Statement> stmts = new LinkedList<Statement>();
		stmts.add(returnStmt);
		BlockStmt blockStmt = new BlockStmt();
		blockStmt.setStmts(stmts);
		getterDecl.setBody(blockStmt);
		return getterDecl;
	}
	
	public static MethodDeclaration createSetterMethodDeclaration(String fieldName, String fieldClass) {
		String fieldNameLocal = fieldName + "Local";
		Type fieldDeclType = new ReferenceType(new ClassOrInterfaceType(fieldClass));
		String setterMethodName = NamingUtil.getSetterMethodName(fieldName);
		MethodDeclaration setterDecl = new MethodDeclaration(ModifierSet.PUBLIC, new VoidType(), setterMethodName);
		List<Parameter> paramsList = new LinkedList<Parameter>();
		Parameter param = new Parameter(fieldDeclType, new VariableDeclaratorId(fieldNameLocal));
		paramsList.add(param);
		setterDecl.setParameters(paramsList);
		
		AssignExpr assignExpr = new AssignExpr( new FieldAccessExpr(new ThisExpr(), fieldName), new NameExpr(fieldNameLocal), AssignExpr.Operator.assign);
		
		ExpressionStmt exprStmt = new ExpressionStmt(assignExpr);
		List<Statement> setterStmts = new LinkedList<Statement>();
		setterStmts.add(exprStmt);
		BlockStmt setterBlockStmt = new BlockStmt();
		setterBlockStmt.setStmts(setterStmts);
		setterDecl.setBody(setterBlockStmt);
		return setterDecl;
	}
	
	public static FieldDeclaration createFieldInstanceDeclaration(String fieldName, String fieldClass) {
		Type stringType = new ReferenceType(new ClassOrInterfaceType(fieldClass));
		VariableDeclarator vd = null;
		vd = new VariableDeclarator(new VariableDeclaratorId(fieldName));
		FieldDeclaration fd = new FieldDeclaration(ModifierSet.PRIVATE, stringType, vd);
		return fd;
	}

//	public static List<Statement> prepareGetValueMethodStatements(HPSEntity entity) {
//		List<Statement> methodStmts = new LinkedList<Statement>();
//
//		// statement for:     	HPSEntityTemplate type = null;
//		List<VariableDeclarator> varList = new LinkedList<VariableDeclarator>();
//		varList.add(new VariableDeclarator(new VariableDeclaratorId("type"), new NullLiteralExpr()));
//		VariableDeclarationExpr vdExpr = new VariableDeclarationExpr(new ReferenceType(new ClassOrInterfaceType(entity.getName())), varList);
//		ExpressionStmt exprStmt = new ExpressionStmt(vdExpr);
//		methodStmts.add(exprStmt);
//		// statement for:     	HPSEntityTemplate[] values = HPSEntityTemplate.values();
//		MethodCallExpr valuesMethodCallExpr = new MethodCallExpr(new NameExpr(entity.getName()), "values");
//		List<VariableDeclarator> var2List = new LinkedList<VariableDeclarator>();
//		var2List.add(new VariableDeclarator(new VariableDeclaratorId("values"), valuesMethodCallExpr));
//		VariableDeclarationExpr vd2Expr = new VariableDeclarationExpr(new ReferenceType(new ClassOrInterfaceType(entity.getName()),1), var2List);
//		ExpressionStmt arrayStmt = new ExpressionStmt(vd2Expr);
//		methodStmts.add(arrayStmt);
//
//		// statement for:     	for (HPSEntityTemplate hpsEntityTemplate : values)
//		List<VariableDeclarator> var3List = new LinkedList<VariableDeclarator>();
//		var3List.add(new VariableDeclarator(new VariableDeclaratorId("item")));
//		VariableDeclarationExpr forVdExpr = new VariableDeclarationExpr(new ReferenceType(new ClassOrInterfaceType(entity.getName())), var3List);
//		List<Statement> forStmts = new LinkedList<Statement>();
//
//		List<Expression> args = new LinkedList<Expression>();
//		args.add(new NameExpr("val"));
//		FieldAccessExpr faExpr = new FieldAccessExpr(new NameExpr("item"), "value");
//		//		MethodCallExpr conditionScope = new MethodCallExpr(faExpr, "toString");
//		MethodCallExpr condition = new MethodCallExpr(faExpr, "equals", args);
//		BlockStmt thenStmtBlock = new BlockStmt();
//		AssignExpr assignExpr = new AssignExpr(new NameExpr("type"), new NameExpr("item"), AssignExpr.Operator.assign);
//		ExpressionStmt thenStmt = new ExpressionStmt(assignExpr);
//		List<Statement> thenStmts = new LinkedList<Statement>();
//		thenStmts.add(thenStmt);
//		thenStmts.add(new BreakStmt());
//		thenStmtBlock.setStmts(thenStmts);
//
//		IfStmt ifStmt = new IfStmt(condition, thenStmtBlock, null);
//		forStmts.add(ifStmt);
//		BlockStmt body = new BlockStmt(forStmts);
//		ForeachStmt forStmt = new ForeachStmt(forVdExpr, new NameExpr("values"), body);
//		methodStmts.add(forStmt);
//		// statement for:     	return type;
//		ReturnStmt returnStmt = new ReturnStmt(new NameExpr("type"));
//		methodStmts.add(returnStmt);
//
//		return methodStmts;
//	}
//
//	public static CompilationUnit generateComponentClass(HPSEntity entity, String basePackagePath, String componentPackagePath) {
//		CompilationUnit cu = new CompilationUnit();
//		String compdotPackagePath = componentPackagePath.replace(File.separator, ".");
//
//		cu.setPackage(new PackageDeclaration(ASTHelper.createNameExpr(compdotPackagePath)));
//		List<ImportDeclaration> imports = new LinkedList<ImportDeclaration>();
//		cu.setImports(imports);
//		imports.add(new ImportDeclaration(new NameExpr(basePackagePath.replace(File.separator, ".") + ".shared.exception.ComponentException"),false, false));
//		imports.add(new ImportDeclaration(new NameExpr(basePackagePath.replace(File.separator, ".") + ".shared.dataobject.BaseView"),false, false));
//
//		ClassOrInterfaceDeclaration type = new ClassOrInterfaceDeclaration(ModifierSet.PUBLIC, false, entity.getNameInCamelCase());
//		List<ClassOrInterfaceType> extendsList = new ArrayList<ClassOrInterfaceType>();
//		ClassOrInterfaceType extendsType = new ClassOrInterfaceType("BaseComponent");
//		extendsList.add(extendsType);
//		type.setExtends(extendsList);
//		ASTHelper.addTypeDeclaration(cu, type);
//
//		List<BodyDeclaration> members = new LinkedList<BodyDeclaration>();
//		type.setMembers(members);
//
//		// add evaluateCompnent method
//		MethodDeclaration methodDec = new MethodDeclaration(ModifierSet.PUBLIC,	new PrimitiveType(Primitive.Boolean), "evaluateComponent");
//		List<NameExpr> throwsList = new LinkedList<NameExpr>();
//		throwsList.add(new NameExpr("ComponentException"));
//		methodDec.setThrows(throwsList);
//		BlockStmt methodBlock = new BlockStmt();
//		List<Statement> methodStmts = new LinkedList<Statement>();
//		List<Parameter> paramsList = new LinkedList<Parameter>();
//		Type fieldDeclType = new ReferenceType(new ClassOrInterfaceType("BaseView"));
//		Parameter param = new Parameter(fieldDeclType, new VariableDeclaratorId("input"));
//		paramsList.add(param);
//		methodDec.setParameters(paramsList);
//		// statement for:     	return type;
//		ReturnStmt returnStmt = new ReturnStmt(new NameExpr("true"));
//		methodStmts.add(returnStmt);
//		methodBlock.setStmts(methodStmts);
//		methodDec.setBody(methodBlock);
//		members.add(methodDec);
//		//Another method
//		MethodDeclaration methodDec1 = new MethodDeclaration(ModifierSet.PUBLIC,	new PrimitiveType(Primitive.Boolean), "evaluateComponent");
//		List<NameExpr> throwsList1 = new LinkedList<NameExpr>();
//		throwsList1.add(new NameExpr("ComponentException"));
//		methodDec1.setThrows(throwsList1);
//		BlockStmt methodBlock1 = new BlockStmt();
//		List<Statement> methodStmts1 = new LinkedList<Statement>();
//		List<Parameter> paramsList1 = new LinkedList<Parameter>();
//		Type fieldDeclType1 = new ReferenceType(new ClassOrInterfaceType("BaseView"));
//		Parameter param1 = new Parameter(fieldDeclType1, new VariableDeclaratorId("input"));
//		paramsList1.add(param1);
//		Type fieldDeclType2 = new ReferenceType(new ClassOrInterfaceType("BaseView"));
//		Parameter param2 = new Parameter(fieldDeclType2, new VariableDeclaratorId("output"));
//		paramsList1.add(param2);
//		methodDec1.setParameters(paramsList1);
//		// statement for:     	return type;
//		ReturnStmt returnStmt1 = new ReturnStmt(new NameExpr("true"));
//		methodStmts1.add(returnStmt1);
//		methodBlock1.setStmts(methodStmts1);
//		methodDec1.setBody(methodBlock1);
//		members.add(methodDec1);
//		return cu;
//	}
//
	
	public static CompilationUnit generateDAOImplClass(String className) {
		CompilationUnit cu = new CompilationUnit();
		String basePackagePath = "com." + TargetWorkspaceManager.getCompanyName().toLowerCase() 
				+ "." + TargetWorkspaceManager.getApplicationName().toLowerCase();

		String daoPackagePath = basePackagePath + ".server.data.dao.impl";
		cu.setPackage(new PackageDeclaration(ASTHelper.createNameExpr(daoPackagePath)));
		List<ImportDeclaration> imports = new LinkedList<ImportDeclaration>();
		cu.setImports(imports);
		imports.add(new ImportDeclaration(new NameExpr("java.util"),false, true));
		imports.add(new ImportDeclaration(new NameExpr("javax.persistence.EntityManager"),false, false));
		imports.add(new ImportDeclaration(new NameExpr("javax.persistence.PersistenceContext"),false, false));
		imports.add(new ImportDeclaration(new NameExpr("javax.persistence.Query"),false, false));
		imports.add(new ImportDeclaration(new NameExpr("javax.persistence.TypedQuery"),false, false));
		imports.add(new ImportDeclaration(new NameExpr("org.springframework.stereotype.Repository"),false, false));
		imports.add(new ImportDeclaration(new NameExpr("org.springframework.transaction.annotation.Propagation"),false, false));
		imports.add(new ImportDeclaration(new NameExpr("org.springframework.transaction.annotation.Transactional"),false, false));
		imports.add(new ImportDeclaration(new NameExpr(basePackagePath + ".shared.exception.DataAccessException"),false, false));
		imports.add(new ImportDeclaration(new NameExpr(basePackagePath + ".server.data.domain"),false, true));
		imports.add(new ImportDeclaration(new NameExpr(basePackagePath + ".shared.dataobject"),false, true));
		imports.add(new ImportDeclaration(new NameExpr(basePackagePath + ".shared.set"),false, true));

		ClassOrInterfaceDeclaration classDecl = new ClassOrInterfaceDeclaration(ModifierSet.PUBLIC, false, className+"DaoImpl");
		// implements
		List<ClassOrInterfaceType> implementsList = new LinkedList<ClassOrInterfaceType>();
		ClassOrInterfaceType implementsType = new ClassOrInterfaceType(className+"Dao");
		implementsList.add(implementsType);
		classDecl.setImplements(implementsList);
		ASTHelper.addTypeDeclaration(cu, classDecl);
		// annotations
		List<AnnotationExpr> annotationsList = new LinkedList<AnnotationExpr>();
		SingleMemberAnnotationExpr repoAnnot = new SingleMemberAnnotationExpr(new NameExpr("Repository"), 
								new StringLiteralExpr(TargetWorkspaceManager.getApplicationName() + "Dao"));
		List<MemberValuePair> members = new ArrayList<MemberValuePair>();
		members.add(new MemberValuePair("propagation", new FieldAccessExpr(new NameExpr("Propagation"), "REQUIRED")));
		NormalAnnotationExpr transAnnot = new NormalAnnotationExpr(new NameExpr("Transactional"), members);
		annotationsList.add(repoAnnot);
		annotationsList.add(transAnnot);
		classDecl.setAnnotations(annotationsList);
		
		List<BodyDeclaration> classMembers = new LinkedList<BodyDeclaration>();
		classDecl.setMembers(classMembers);

		Type emType = new ReferenceType(new ClassOrInterfaceType("EntityManager"));
		VariableDeclarator vd = new VariableDeclarator(new VariableDeclaratorId("entityManager"), new NullLiteralExpr());
		FieldDeclaration emField = new FieldDeclaration(ModifierSet.PRIVATE, emType, vd);
		List<AnnotationExpr> fieldAnnots = new LinkedList<AnnotationExpr>();
		fieldAnnots.add(new MarkerAnnotationExpr(new NameExpr("PersistenceContext")));
		emField.setAnnotations(fieldAnnots);
		classMembers.add(emField);
		
		// getter method
		MethodDeclaration getMethodDec = new MethodDeclaration(ModifierSet.PUBLIC,	emType, "getEntityManager");
		BlockStmt methodBlock = new BlockStmt();
		List<Statement> methodStmts = new LinkedList<Statement>();
		ReturnStmt returnStmt = new ReturnStmt(new NameExpr("entityManager"));
		methodStmts.add(returnStmt);
		methodBlock.setStmts(methodStmts);
		getMethodDec.setBody(methodBlock);
		classMembers.add(getMethodDec);
		// setter method
		MethodDeclaration setMethodDec = new MethodDeclaration(ModifierSet.PUBLIC, new VoidType(), "setEntityManager");
		BlockStmt setMethodBlock = new BlockStmt();
		List<Statement> setMethodStmts = new LinkedList<Statement>();
		List<Parameter> setterParamsList = new LinkedList<Parameter>();
		Type emParamType = new ReferenceType(new ClassOrInterfaceType("EntityManager"));
		Parameter emParam = new Parameter(emParamType, new VariableDeclaratorId("em"));
		setterParamsList.add(emParam);
		setMethodDec.setParameters(setterParamsList);
		AssignExpr assignExpr = new AssignExpr( new FieldAccessExpr(new ThisExpr(), "entityManager"), new NameExpr("em"), AssignExpr.Operator.assign);
		ExpressionStmt exprStmt = new ExpressionStmt(assignExpr);
		setMethodStmts.add(exprStmt);
		setMethodBlock.setStmts(setMethodStmts);
		setMethodDec.setBody(setMethodBlock);
		classMembers.add(setMethodDec);
		//FileUtil.writeCompilationUnitToFile(new File(baseClassSourceDir + File.separator + daoPackagePath) , className + "DaoImpl.java", cu);
		return cu;
	}

	private static CompilationUnit prepareDAOCompilationUnit(String className, boolean impl) {
		CompilationUnit cu = new CompilationUnit();
		String basePackage = "com." + TargetWorkspaceManager.getCompanyName().toLowerCase() + "." 
				+ TargetWorkspaceManager.getApplicationName().toLowerCase();
		String daoPackage = basePackage + ".server.data.dao";
		List<ImportDeclaration> imports = new LinkedList<ImportDeclaration>();
		cu.setImports(imports);
		if(impl) {
			daoPackage = daoPackage + ".impl";
			imports.add(new ImportDeclaration(new NameExpr(basePackage + ".server.data.dao"),false, true));
		}
		cu.setPackage(new PackageDeclaration(ASTHelper.createNameExpr(daoPackage)));
		imports.add(new ImportDeclaration(new NameExpr("java.util"),false, true));
		imports.add(new ImportDeclaration(new NameExpr(basePackage + ".shared.exception.DataAccessException"),false, false));
		imports.add(new ImportDeclaration(new NameExpr(basePackage + ".server.data.domain"),false, true));
		imports.add(new ImportDeclaration(new NameExpr(basePackage + ".shared.dataobject"),false, true));
		ClassOrInterfaceDeclaration classDecl = new ClassOrInterfaceDeclaration(ModifierSet.PUBLIC, !impl, className + (impl ? "DaoImpl" : "Dao"));
		ASTHelper.addTypeDeclaration(cu, classDecl);
		
		List<BodyDeclaration> classMembers = new LinkedList<BodyDeclaration>();
		classDecl.setMembers(classMembers);
		return cu;
	}

	public static void appendMethodToDAOInterface(String queryId, boolean listRetType, String domObjName, Set<String> params, HashMap<String, String> varMap) {
		String basePackagePath = TargetWorkspaceManager.getWebProjectSourceDir() + File.separator + "com" 
				+ File.separator + TargetWorkspaceManager.getCompanyName().toLowerCase() + File.separator 
				+ TargetWorkspaceManager.getApplicationName().toLowerCase();
		
		String ifcFileDir = basePackagePath + File.separator + "server" + File.separator + "data" + File.separator + "dao";
		CompilationUnit daoIfcCU = FileUtil.loadCompilationUnitFromFile(new File(ifcFileDir + File.separator + domObjName + "Dao.java"));
		if(daoIfcCU == null) {
			daoIfcCU = prepareDAOCompilationUnit(domObjName, false);
		}
		Type methodType = null;
		if(listRetType) {
			List<Type> typeArgs = new LinkedList<Type>();
			typeArgs.add(new ReferenceType(new ClassOrInterfaceType(domObjName)));
			ClassOrInterfaceType listType = new ClassOrInterfaceType("List");
			listType.setTypeArgs(typeArgs);
			methodType = new ReferenceType(listType);
		} else {
			methodType = new PrimitiveType(Primitive.Int);
		}
		MethodDeclaration ifcMethodDec = new MethodDeclaration(ModifierSet.PUBLIC, methodType, queryId);
		List<Parameter> ifcParamsList = new LinkedList<Parameter>();
		String paramClass = null;
		String paramVarName = null;
		Set<String> parameterSet = new HashSet<String>();
		for (String param : params) {
			// param is in upper case with underscores and attribute in upper case with underscore if exists
			if(param.indexOf(".") > -1) {
				paramClass = NamingUtil.toCamelCase(param.substring(0, param.indexOf(".")));
				paramVarName = NamingUtil.toCamelCase(param.substring(0, param.indexOf(".")), true);
			} else {
				paramClass = varMap.get(NamingUtil.toCamelCase(param, true));
				if(paramClass == null || paramClass.trim().equals("null")) {
					paramClass =  NamingUtil.toCamelCase(param);
				}
				paramVarName = NamingUtil.toCamelCase(param, true);
			} 
			// to avoid same parameter multiple times
			if(!parameterSet.contains(paramClass)) {
				Type emParamType = new ReferenceType(new ClassOrInterfaceType(paramClass));
				Parameter emParam = new Parameter(emParamType, new VariableDeclaratorId(paramVarName));
				ifcParamsList.add(emParam);
				parameterSet.add(paramClass);
			}
		}
		ifcMethodDec.setParameters(ifcParamsList);
		daoIfcCU.getTypes().get(0).getMembers().add(ifcMethodDec);
		FileUtil.writeCompilationUnitToFile(new File(ifcFileDir) , domObjName + "Dao.java", daoIfcCU);
	}
	
	public static void appendMethodToDAOImpl(String queryId, boolean listRetType, String domObjName, Set<String> params, HashMap<String, String> varMap) {
		String basePackagePath = TargetWorkspaceManager.getWebProjectSourceDir() + File.separator + "com" 
				+ File.separator + TargetWorkspaceManager.getCompanyName().toLowerCase() + File.separator 
				+ TargetWorkspaceManager.getApplicationName().toLowerCase();
		
		String ifcFileDir = basePackagePath + File.separator + "server" + File.separator + "data" + File.separator + "dao" + File.separator + "impl";
		CompilationUnit daoImplCU = FileUtil.loadCompilationUnitFromFile(new File(ifcFileDir + File.separator + domObjName + "DaoImpl.java"));
		if(daoImplCU == null) {
			daoImplCU = generateDAOImplClass(domObjName);
		}
		Type methodType = null;
		if(listRetType) {
			List<Type> typeArgs = new LinkedList<Type>();
			typeArgs.add(new ReferenceType(new ClassOrInterfaceType(domObjName)));
			ClassOrInterfaceType listType = new ClassOrInterfaceType("List");
			listType.setTypeArgs(typeArgs);
			methodType = new ReferenceType(listType);
		} else {
			methodType = new PrimitiveType(Primitive.Int);
		}
		MethodDeclaration implMethodDec = new MethodDeclaration(ModifierSet.PUBLIC, methodType, queryId);
		List<Parameter> ifcParamsList = new LinkedList<Parameter>();
		String paramClass = null;
		String paramVarName = null;
		Set<String> parameterSet = new HashSet<String>();
		for (String param : params) {
			// param is in upper case with underscores and attribute in upper case with underscore if exists
			if(param.indexOf(".") > -1) {
				paramClass = NamingUtil.toCamelCase(param.substring(0, param.indexOf(".")));
				paramVarName = NamingUtil.toCamelCase(param.substring(0, param.indexOf(".")), true);
			} else {
				paramClass = varMap.get(NamingUtil.toCamelCase(param, true));
				if(paramClass == null || paramClass.trim().equals("null")) {
					paramClass =  NamingUtil.toCamelCase(param);
				}
				paramVarName = NamingUtil.toCamelCase(param, true);
			} 
			// to avoid same parameter multiple times
			if(!parameterSet.contains(paramClass)) {
				Type emParamType = new ReferenceType(new ClassOrInterfaceType(paramClass));
				Parameter emParam = new Parameter(emParamType, new VariableDeclaratorId(paramVarName));
				ifcParamsList.add(emParam);
				parameterSet.add(paramClass);
			}
		}
		implMethodDec.setParameters(ifcParamsList);
		daoImplCU.getTypes().get(0).getMembers().add(implMethodDec);
		BlockStmt implBlock = new BlockStmt();
		List<Statement> implStmts = new LinkedList<Statement>();
		implBlock.setStmts(implStmts);
		
		List<VariableDeclarator> varDeclList = new LinkedList<VariableDeclarator>();
		List<Expression> callArgs = new LinkedList<Expression>();
		callArgs.add(new StringLiteralExpr(queryId));
		callArgs.add(new ClassExpr(new ReferenceType(new ClassOrInterfaceType("Count"))));
		varDeclList.add(new VariableDeclarator(new VariableDeclaratorId("typedQuery"), new MethodCallExpr(new NameExpr("entityManager"), "createNamedQuery", callArgs)));
		VariableDeclarationExpr qryVarDecl = new VariableDeclarationExpr(new ReferenceType(new ClassOrInterfaceType("TypedQuery")), varDeclList);
		ExpressionStmt queryDeclStmt = new ExpressionStmt(qryVarDecl);
		implStmts.add(queryDeclStmt);

		for (String paramName : params) {
			List<Expression> paramCallArgs = new LinkedList<Expression>();
			paramCallArgs.add(new StringLiteralExpr(paramName.toLowerCase()));
			if(paramName.indexOf(".") > -1) {
				paramClass = paramName.substring(0, paramName.indexOf("."));
				String attribName = paramName.substring(paramName.indexOf(".")+1);
				paramCallArgs.add(new MethodCallExpr(new NameExpr(NamingUtil.toCamelCase(paramClass, true)), "get"+NamingUtil.toCamelCase(attribName, false)));
			} else {
				paramCallArgs.add(new NameExpr(NamingUtil.toCamelCase(paramName, true)));
			}
			AssignExpr paramAssign = new AssignExpr(new NameExpr("typedQuery"), new MethodCallExpr(new NameExpr("typedQuery"), "setParameter", paramCallArgs), Operator.assign);
			ExpressionStmt setParamStmt = new ExpressionStmt(paramAssign);
			implStmts.add(setParamStmt);
		}
		ReturnStmt retStmt = null;
		if(listRetType) {
			ClassOrInterfaceType castType = new ClassOrInterfaceType("List");
			List<Type> typeArgs = new LinkedList<Type>();
			typeArgs.add(new ReferenceType(new ClassOrInterfaceType(domObjName)));
			castType.setTypeArgs(typeArgs);
			retStmt = new ReturnStmt(new CastExpr(new ReferenceType(castType),   
										new MethodCallExpr(new NameExpr("typedQuery"), "getResultList")));
		} else {
			retStmt = new ReturnStmt(new MethodCallExpr(new NameExpr("typedQuery"), "executeUpdate"));
		}
		
		implStmts.add(retStmt);
		
		implMethodDec.setBody(implBlock);
		FileUtil.writeCompilationUnitToFile(new File(ifcFileDir) , domObjName + "DaoImpl.java", daoImplCU);
	}
	
}
