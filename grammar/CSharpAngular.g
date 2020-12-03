parser grammar CSharpAngular;

options {
  language     = Java;
  tokenVocab = CSharpPreProcessor;
  output       = template;
  rewrite      = false;
  
}

@header {
package com.hcl.atma.converter.parsers;

import java.util.LinkedList;

import com.hcl.atma.converter.util.*;
import com.hcl.atma.converter.generator.*;
}

@members {
// the following methods are only used for debug purposes
private List<String> errors = new LinkedList<String>();

@Override
public void displayRecognitionError(String[] tokenNames, RecognitionException e) {
    super.displayRecognitionError(tokenNames, e);
    String hdr = getErrorHeader(e);
    String msg = getErrorMessage(e, tokenNames);
//    errors.add(hdr + " " + msg);
//    System.err.println("Error--");
    
}

public List<String> getErrors() {
    return errors;
}

private void next(int n) {
  System.err.print("next: ");
  for (int i=1; i<=n; i++) {
//    System.err.print(" | " + input.LT(i).getType() + "=" + input.LT(i).getText());
  }
//  System.err.println("Error--");
}

private String className;

public String getClassName() {
    return className;
}
  
public void setClassName(String className) {
    this.className = className;
}
  
private String updateClassName(String className){
  setClassName(className);
  return "";
}

private String idName;

public String getIdName() {
    return idName;
}
  
public void setIdName(String idName) {
    this.idName = idName;
}
  
private String updateIdName(String idName){
  setIdName(idName);
  return "";
}

private String expressionStmt;

public String getExpressionStmt() {
    return expressionStmt;
}
  
public void setExpressionStmt(String expressionStmt) {
    this.expressionStmt = expressionStmt;
}

private String updateExpressionStmt(String expressionStmt){
  setExpressionStmt(expressionStmt);
  return "";
}

private String expressionStmt2;

public String getExpressionStmt2() {
    return expressionStmt2;
}
  
public void setExpressionStmt2(String expressionStmt2) {
    this.expressionStmt2 = expressionStmt2;
}

private String updateExpressionStmt2(String expressionStmt2){
  setExpressionStmt2(expressionStmt2);
  return "";
}

private boolean isLinq;

public boolean isLinq() {
    return isLinq;
  }

public void setLinq(boolean isLinq) {
    this.isLinq = isLinq;
  } 
  
private String updateLinqStatus(boolean isLinq){
  setLinq(isLinq);
  return "";
}
  
}


cSharpAngular returns [String javaContent]
  :
  module EOF
  {
    $javaContent = $module.st.toString();
  }
;
//B.2 Syntactic grammar

//B.2.1 Basic concepts

module
  :
  cb=compilation_unit
  ->createClass(classBody={cb})
  ;
  
namespace_name 
	: 
	nms=namespace_or_type_name         
	 ->namespaceName(value={nms})
	;
type_name 
	: 
	nmsName=namespace_or_type_name       
	->typeName(value={nmsName})
	;
/*
namespace_or_type_name 
	: IDENTIFIER type_argument_list?
	| namespace_or_type_name DOT IDENTIFIER type_argument_list?
	| qualified_alias_member
	;
*/
namespace_or_type_name 
  :
  id=observableCollection_contextual_keyword typArg=type_argument_list_opt  (nmsTypChld1+=namespace_or_type_name_Chld )*
  ->namespaceOrTypeName(firstPart={CSharpAngularHelper.replaceJavaType(id.st.toString().trim())},argList={typArg},secondPart={$nmsTypChld1})
  |fstPrt=qualified_alias_member (nmsTypChld2+=namespace_or_type_name_Chld )*
  ->namespaceOrTypeName2(firstPart={$fstPrt.text},secondPart={$nmsTypChld2})
  ;
  
observableCollection_contextual_keyword
  : {!input.LT(1).getText().equals("ObservableCollection")}? IDENTIFIER
    ->text(value={$IDENTIFIER.text})
  |{input.LT(1).getText().equals("ObservableCollection")}? IDENTIFIER
    -> text(value={"List"})
  ;
  
namespace_or_type_name_Chld
  :
  (( DOT IDENTIFIER OPEN_PARENS) => DOT id=IDENTIFIER argLst=type_argument_list_opt )
  ->namespaceOrTypeNameChld1(identifier={$id.text},argumentList={argLst})
  |
  (( DOT IDENTIFIER LT) =>  DOT id=IDENTIFIER argLst=type_argument_list_opt )
  ->namespaceOrTypeNameChld1(identifier={$id.text},argumentList={argLst})
  |
  DOT id=IDENTIFIER argLst=type_argument_list_opt 
  ->namespaceOrTypeNameChld(identifier={$id.text},argumentList={argLst})
  ;
/** represents type_argument_list? */
// added by chw
//Child Rule
type_argument_list_opt
  : 
  ((type_argument_list) => tal=type_argument_list)  
  ->typeArgumentListOpt(argList={tal})
  |
  ->typeArgumentListOpt(argList={null})
  ;
//B.2.2 Types
/*
type 
	: value_type
	| reference_type
	| type_parameter
	| type_unsafe
	;
*/
type 
  : 
  bTyp=base_type ((typeChld) => (chld+=typeChld))*
  ->dattype(firstType={bTyp},list={$chld})
  ;
  
typeChld
  :
  inter=INTERR            ->typeChld(value={""})
  | rnkSp=rank_specifier  ->typeChld(value={rnkSp})
  | st=STAR               ->typeChld(value={$STAR.text})
  ;
// added by chw
//Child Rule
base_type
  : 
  simpType=simple_type          
  ->baseType(type={simpType})
  | cType=class_type              
  ->baseType(type={cType})   // represents types: enum, class, interface, delegate, type_parameter
  | VOID STAR                     ->text(value={" void *"})
  ;
/*
value_type 
	: struct_type
	| enum_type
	;
struct_type 
	: type_name
	| simple_type
	| nullable_type
	;
*/
/** primitive types */
//Child Rule
simple_type 
	: 
	numType=numeric_type           ->simpleType(type={numType})
	| boolType=BOOL                ->simpleType(type={$BOOL.text})
	;
numeric_type 
	: 
	intType=integral_type          ->numericType(type={intType})
	| fpType=floating_point_type   ->numericType(type={fpType})
	| dec=DECIMAL                  ->numericType(type={$DECIMAL.text})
	;
//Child Rule	
integral_type 
	: 
	SBYTE
	->text(value={$SBYTE.text})
	| BYTE
	->text(value={$BYTE.text})
	| SHORT
	->text(value={$SHORT.text})
	| USHORT
	->text(value={$USHORT.text})
	| INT
	->text(value={$INT.text})
	| UINT
	->text(value={$UINT.text})
	| LONG
	->text(value={$LONG.text})
	| ULONG
	->text(value={$ULONG.text})
	| CHAR
	->text(value={$CHAR.text})
	;
	
//Child Rule	
floating_point_type 
	: 
	FLOAT 
	->text(value={$FLOAT.text})
	|DOUBLE
	->text(value={$DOUBLE.text})
	;
nullable_type 
	: 
	val=non_nullable_value_type INTERR
	->nullableType(value={val},kwd={""})
	;
/*
non_nullable_value_type 
  : type
  ;
*/
// type without INTERR; undocumented but VS checks for this constraint
non_nullable_value_type 
	: btype=base_type
    ( (rank_specifier) => rank_specifier
    | STAR
    )*
     ->nonnullablevaluetype(basetype={btype})
	;
/* not used anymore
enum_type 
	: type_name
	;
*/
/*
reference_type 
	: class_type
	| interface_type
	| array_type
	| delegate_type
	;
*/
reference_type 
@init {boolean oneOrMore = false;}
  : ( simple_type {oneOrMore=true;}
    | class_type
    | VOID STAR {oneOrMore=true;}
  ) ((STAR | INTERR)* rank_specifier)*
    ({oneOrMore}? (STAR | INTERR)* rank_specifier)
  ;
/** type_name, OBJECT, STRING */
//Child Rule
class_type 
	: 
	typName=type_name                  ->classType(value={typName})
	| obj=OBJECT                       ->classType(value={"Object"})      
	| dck=dynamic_contextual_keyword   ->classType(value={dck})
	| str=STRING                       ->classType(value={"String"})
	;
/** type_name */
//Child Rule
interface_type 
	: 
	typName=type_name        ->interfaceType(value={typName})
	;
/** type_name */
//Child Rule
delegate_type 
	: 
	typName=type_name        ->text(value={typName})
	;
type_argument_list 
	: 
	LT args=type_arguments GT
	->typeArgumentList(arguments={$args.st.toString().trim()})
	;
type_arguments 
	: 
	fstArg=type_argument (tChld+=type_arguments_Chld)*
	->typeArguments(firstArg={fstArg},chldLst={$tChld})
	;
	
type_arguments_Chld
	:
	COMMA arg=type_argument
	->typeArgumentsChld(args={arg})
	;
	
type_argument 
	: 
	ta=type          ->typeArgument(value={ta})
	;
// added by chw
type_void
  : 
  v=VOID
  ->text(value={""})
  ;

//B.2.3 Variables
/** expression */
variable_reference 
	: 
	expr=expression
	->variableReference(ref={expr})
	;

//B.2.4 Expressions
argument_list 
	: 
	fstArg=argument (lst+=argument_list_Chld )*
	->argumentList(firstArgmnt={fstArg},list={$lst})
	;

argument_list_Chld
  :
	COMMA (cmnt=comments)? arg=argument
	->argumentListChld(cmnts={cmnt},args={arg})
	;
	
argument
	: 
	(argNam=argument_name)? val=argument_value
	->argument(argName={argNam},argValue={val})
	;
argument_name 
	: 
	IDENTIFIER COLON
	->argumentName(id={NamingUtil.toCamelCase($IDENTIFIER.text)})
	;
argument_value 
	: 
	expr=expression
	->argumentValue(value={expr})
	| REF varRef=variable_reference
	->argumentValue2(type={$REF.text},value={expr})
	| OUT variable_reference
	->argumentValue2(type={$OUT.text},value={expr})
	;
/*
primary_expression 
	: primary_no_array_creation_expression
	| array_creation_expression
	;
*/

primary_expression 
  :
  pe=primary_expression_start  (fbe+=bracket_expression)* (pcl+=primary_expression_Chld)* (cmnts=comments)?
  ->primaryExpression(prmExprStrt={pe},frstBrktExpr={$fbe},prmChldLst={$pcl},cmnt={cmnts})
  ;
  
date_week_operations
  :
  ({input.LT(3).getText().equals("Sunday")}?) => IDENTIFIER DOT IDENTIFIER
  ->text(value={"Day[0]"})
  |
  ({input.LT(3).getText().equals("Monday")}?) => IDENTIFIER DOT IDENTIFIER
  ->text(value={"Day[1]"})
  |
  ({input.LT(3).getText().equals("Tuesday")}?) => IDENTIFIER DOT IDENTIFIER
  ->text(value={"Day[2]"})
  |
  ({input.LT(3).getText().equals("Wednesday")}?) => IDENTIFIER DOT IDENTIFIER
  ->text(value={"Day[3]"})
  |
  ({input.LT(3).getText().equals("Thursday")}?) => IDENTIFIER DOT IDENTIFIER
  ->text(value={"Day[4]"})
  |
  ({input.LT(3).getText().equals("Friday")}?) => IDENTIFIER DOT IDENTIFIER
  ->text(value={"Day[5]"})
  |
  ({input.LT(3).getText().equals("Saturday")}?) => IDENTIFIER DOT IDENTIFIER
  ->text(value={"Day[6]"})
  |
  ({input.LT(1).getText().equals("DayOfWeek")}?) IDENTIFIER
  ->text(value={"DayOfWeek"})
  | IDENTIFIER DOT id=IDENTIFIER
   ->text(value={id})
  ;
  
date_operations
  :
  ({input.LT(5).getText().equals("AddSeconds")}?) => IDENTIFIER DOT IDENTIFIER DOT IDENTIFIER par=parenthesized_expression
  ->text(value={"new Date(new Date().getFullYear(),new Date().getMonth(), new Date().getDate(),new Date().getHours(), new Date().getMinutes(), new Date().getSeconds()+"
        +CSharpAngularHelper.handleDateParenthesis(par.st.toString().trim())+", new Date().getMilliseconds())"})
  |
  ({input.LT(5).getText().equals("AddDays")}?) => IDENTIFIER DOT IDENTIFIER DOT IDENTIFIER par1=parenthesized_expression
  ->text(value={"new Date(new Date().getFullYear(),new Date().getMonth(), new Date().getDate()+"
        +CSharpAngularHelper.handleDateParenthesis(par1.st.toString().trim())+",new Date().getHours(), new Date().getMinutes(), new Date().getSeconds(), new Date().getMilliseconds())"})
  |
  ({input.LT(5).getText().equals("AddHours")}?) => IDENTIFIER DOT IDENTIFIER DOT IDENTIFIER par1=parenthesized_expression
  ->text(value={"new Date(new Date().getFullYear(),new Date().getMonth(), new Date().getDate(), new Date().getHours()+"
  +CSharpAngularHelper.handleDateParenthesis(par1.st.toString().trim())+", new Date().getMinutes(), new Date().getSeconds(), new Date().getMilliseconds())"})
  |
  ({input.LT(5).getText().equals("AddMilliseconds")}?) => IDENTIFIER DOT IDENTIFIER DOT IDENTIFIER par1=parenthesized_expression
  ->text(value={"new Date(new Date().getFullYear(),new Date().getMonth(), new Date().getDate(), new Date().getHours(), new Date().getMinutes(), new Date().getSeconds(), new Date().getMilliseconds()+"
        +CSharpAngularHelper.handleDateParenthesis(par1.st.toString().trim())+")"})
  |
  ({input.LT(5).getText().equals("AddMinutes")}?) => IDENTIFIER DOT IDENTIFIER DOT IDENTIFIER par1=parenthesized_expression
  ->text(value={"new Date(new Date().getFullYear(),new Date().getMonth(), new Date().getDate(), new Date().getHours(), new Date().getMinutes()+"
        +CSharpAngularHelper.handleDateParenthesis(par1.st.toString().trim())+", new Date().getSeconds(), new Date().getMilliseconds())"})
  |
  ({input.LT(5).getText().equals("AddMonths")}?) => IDENTIFIER DOT IDENTIFIER DOT IDENTIFIER par1=parenthesized_expression
  ->text(value={"new Date(new Date().getFullYear(),new Date().getMonth()+"
        +CSharpAngularHelper.handleDateParenthesis(par1.st.toString().trim())+", new Date().getDate(), new Date().getHours(), new Date().getMinutes(), new Date().getSeconds(), new Date().getMilliseconds())"})
  |
   ({input.LT(5).getText().equals("AddYears")}?) => IDENTIFIER DOT IDENTIFIER DOT IDENTIFIER par1=parenthesized_expression
  ->text(value={"new Date(new Date().getFullYear()+"+CSharpAngularHelper.handleDateParenthesis(par1.st.toString().trim())
        +",new Date().getMonth(), new Date().getDate(), new Date().getHours(), new Date().getMinutes(), new Date().getSeconds(), new Date().getMilliseconds())"})
  |
  ({input.LT(5).getText().equals("Subtract")}?) => IDENTIFIER DOT IDENTIFIER DOT IDENTIFIER par2=parenthesized_expression
  ->text(value={"( new Date() -"+par2+" )"})
  |
  (({input.LT(4).getText().equals(".") && input.LT(5).getText().equals("Month")}?) => IDENTIFIER DOT IDENTIFIER DOT IDENTIFIER )
  ->text(value={"( new Date().getMonth() + 1)"})
  |
  IDENTIFIER DOT IDENTIFIER
  ->text(value={"new Date()"})
  ;
  
string_operations
  :({input.LT(3).getText().equals("IsNullOrWhiteSpace")}?) STRING DOT IDENTIFIER par=parenthesized_expression
  ->stringnullcheck(value={par.st.toString().trim()})
  |
  ({input.LT(3).getText().equals("IsNullOrEmpty")}?) STRING DOT IDENTIFIER par2=parenthesized_expression
  ->stringnullcheck(value={par2.st.toString().trim()})
  | 
  ({input.LT(3).getText().equals("Empty")}?) STRING DOT IDENTIFIER
  ->text(value={"''"})
  |
  (({input.LT(3).getText().equals("Join")}? STRING DOT IDENTIFIER LT type GT ) => STRING DOT IDENTIFIER LT type GT OPEN_PARENS fstArg=argument COMMA sndArg=argument CLOSE_PARENS)
  ->memberaccess3join(fstArg1={fstArg},sndArg1={sndArg})
  |
  (({input.LT(3).getText().equals("Join")}?) => STRING DOT IDENTIFIER OPEN_PARENS fstArg=argument COMMA sndArg=argument CLOSE_PARENS)
  ->memberaccess3join(fstArg1={fstArg},sndArg1={sndArg})
  |
  ({input.LT(3).getText().equals("Format")}? STRING DOT IDENTIFIER method_invocation2 )=> STRING DOT IDENTIFIER met2=method_invocation2
  ->text(value={"String.format"+met2.st.toString().trim()})
  |
  ({input.LT(3).getText().equals("Format")}? ) STRING DOT IDENTIFIER par1=parenthesized_expression
  ->text(value={"String.format"+par1.st.toString().trim()})
  |
  ({input.LT(3).getText().equals("Concat")}? STRING DOT IDENTIFIER OPEN_PARENS argument COMMA argument COMMA argument COMMA argument CLOSE_PARENS) => STRING DOT IDENTIFIER OPEN_PARENS fstArg=argument COMMA sndArg=argument COMMA thrdArg=argument COMMA frthArg=argument CLOSE_PARENS
  ->text(value={fstArg.st.toString().trim()+sndArg.st.toString().trim()+thrdArg.st.toString().trim()+frthArg.st.toString().trim()})
  |
  ({input.LT(3).getText().equals("Concat")}? STRING DOT IDENTIFIER OPEN_PARENS argument COMMA argument CLOSE_PARENS) => STRING DOT IDENTIFIER OPEN_PARENS fstArg=argument COMMA sndArg=argument CLOSE_PARENS
  ->text(value={fstArg.st.toString().trim()+".concat("+sndArg.st.toString().trim()+")"})
  |
  ({input.LT(3).getText().equals("Concat")}? ) STRING DOT IDENTIFIER OPEN_PARENS fstArg=argument CLOSE_PARENS
  ->text(value={fstArg.st.toString().trim()})
  |
  ({input.LT(3).getText().equals("Compare")}?) STRING DOT IDENTIFIER met3=method_invocation2
  ->text(value={"compare"+met3.st.toString().trim()})
  | 
  ({input.LT(3).getText().equals("Equals")}?) STRING DOT IDENTIFIER
  ->text(value={""})
  ;

primary_expression_Chld
  :
  (cmnts=comments)? pesc=primary_expression_sub_Chld (brktExpr+=bracket_expression)*
  ->primaryExpressionChld(cmnt={cmnts}, peChild={pesc},bracketExpr={$brktExpr})
  ;
  
primary_expression_sub_Chld
 :
  (( DOT IDENTIFIER OPEN_PARENS) => memAc=member_access3)
  ->primaryExpressionSubChld(expressionChild={memAc})
  |
  (( DOT IDENTIFIER LT) => memAc=member_access3)
  ->primaryExpressionSubChld(expressionChild={memAc})
  | memAcc=member_access2
  ->primaryExpressionSubChld(expressionChild={memAcc})
  | methdInc=method_invocation2
  ->primaryExpressionSubChld(expressionChild={methdInc})
  | OP_INC
  ->primaryExpressionSubChld(expressionChild={$OP_INC.text})
  | OP_DEC
  ->primaryExpressionSubChld(expressionChild={$OP_DEC.text})
  | OP_PTR IDENTIFIER 
  ->primaryExpressionSubChld2(expressionChildprt1={$OP_PTR.text},expressionChildprt2={$IDENTIFIER.text})                       
 ;
 
member_access3
  :
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("ToString") && input.LT(3).getText().equals("(") && !input.LT(4).getText().equals(")") }? DOT IDENTIFIER method_invocation2) => DOT IDENTIFIER met=method_invocation2)
  ->text(value={".toString"+met.st.toString().trim()})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("ToString")}?) => DOT IDENTIFIER OPEN_PARENS CLOSE_PARENS)
  ->text(value={".toString()"})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("ToShortDateString")}?) => DOT IDENTIFIER OPEN_PARENS CLOSE_PARENS)
  ->text(value={".toLocaleDateString()"})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("Split")}? DOT IDENTIFIER method_invocation2) => DOT IDENTIFIER  met1=method_invocation2 )
  ->text(value={".split"+met1.st.toString().trim()})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("Split")}?) => DOT IDENTIFIER  par1=parenthesized_expression )
  ->text(value={".split"+CSharpAngularHelper.handleSplitParenthesis(par1.st.toString().trim())})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("ToList")}?   DOT IDENTIFIER LT type GT) => DOT IDENTIFIER LT type GT OPEN_PARENS CLOSE_PARENS)
  ->text(value={""})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("ToList")}?) => DOT IDENTIFIER OPEN_PARENS CLOSE_PARENS)
  ->text(value={""})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("Insert")}?) => DOT IDENTIFIER OPEN_PARENS fstArg=argument COMMA sndArg=argument CLOSE_PARENS )
  ->text(value={".splice( "+fstArg.st.toString().trim()+" , 0 , "+sndArg.st.toString().trim()+" )"})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("Clear")}?) => DOT IDENTIFIER OPEN_PARENS CLOSE_PARENS )
  ->text(value={" = []"})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("RemoveAt")}?) => DOT IDENTIFIER par5=parenthesized_expression )
  ->text(value={".splice( "+CSharpAngularHelper.handleRemoveParenthesis(par5.st.toString().trim())+" , 1)"})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("Add") }?) => DOT IDENTIFIER met3=method_invocation2 )
  ->text(value={".push"+met3.st.toString().trim()})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("Add") }?) => DOT IDENTIFIER par2=parenthesized_expression )
  ->text(value={".push"+par2.st.toString().trim()})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("Trim")}?) => DOT IDENTIFIER OPEN_PARENS CLOSE_PARENS )
  ->text(value={".trim()"})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("IndexOf")}?) => DOT IDENTIFIER met6=method_invocation2 )
  ->text(value={".indexOf"+met6.st.toString().trim()})
  |
  (({isLinq() && input.LT(1).getText().equals(".") && input.LT(2).getText().equals("FirstOrDefault")}?) => DOT IDENTIFIER OPEN_PARENS CLOSE_PARENS )
  ->text(value={""})
  |
  DOT id=IDENTIFIER tal=type_argument_list_opt
  ->memberAccess3(memName={NamingUtil.toCamelCase($id.text)},argLst={tal})
  ;
  
primary_expression_start
  : 
  exp1=literal
  ->primaryExpressionStart(expression={exp1})
  | exp2=simple_name
  ->primaryExpressionStart(expression={exp2})
  | exp3=parenthesized_expression
  ->primaryExpressionStart(expression={exp3})
  | exp4=predefined_type // member_access
  ->primaryExpressionStart(expression={exp4})
  | exp5=qualified_alias_member  // member_access
  ->primaryExpressionStart(expression={exp5})
  | exp6=this_access
  ->primaryExpressionStart(expression={exp6})
  | exp7=base_access
  ->primaryExpressionStart(expression={exp7})
  | exp8=primary_expression_start_Chld   
  ->primaryExpressionStart(expression={exp8})  
  | exp9=typeof_expression
  ->primaryExpressionStart(expression={exp9})
  | exp10=checked_expression
  ->primaryExpressionStart(expression={exp10})
  | exp11=unchecked_expression
  ->primaryExpressionStart(expression={exp11})
  | exp12=default_value_expression
  ->primaryExpressionStart(expression={exp12})
  | exp13=anonymous_method_expression
  ->primaryExpressionStart(expression={exp13})
  | exp14=sizeof_expression
  ->primaryExpressionStart(expression={exp14})
  ;    

primary_expression_start_Chld
  :
  NEW  t=type prc=primary_expression_start_sub_Chld
  ->primaryExpressionStartChld(type={t},expression={prc})
  |NEW aoi=anonymous_object_initializer
  ->primaryExpressionStartChld2(anyObjInit={aoi})
  |NEW rs=rank_specifier ai=array_initializer
  ->primaryExpressionStartChld3(rnkSpcr={rs},arrInit={ai})
  ;
  
primary_expression_start_sub_Chld
  :
  objExpr=object_creation_expression2
  ->primaryExpressionStartSubChld(expr={objExpr})
  | objOrColInit=object_or_collection_initializer
    ->primaryExpressionStartSubChld(expr={objOrColInit})  
  | OPEN_BRACKET el=expression_list CLOSE_BRACKET (rs=rank_specifiers)? (arinit=array_initializer)? 
  ->primaryExpressionStartSubChld2(exprList={el},rnkSpecfr={rs},arryInit={arinit})
  | rnkSpr=rank_specifiers arrInit=array_initializer
  ->primaryExpressionStartSubChld3(expr1={rnkSpr},expr2={arrInit})
  ;
/*
bracket_expression
  : OPEN_BRACKET expression_list CLOSE_BRACKET
  | OPEN_BRACKET expression CLOSE_BRACKET
  ;
*/
bracket_expression
  : 
  OPEN_BRACKET exprLst=expression_list CLOSE_BRACKET
  ->bracketExpression(expressionList={exprLst})
  ;
/*
primary_no_array_creation_expression 
	: literal
	| simple_name
	| parenthesized_expression
	| member_access
	| invocation_expression
	| element_access
	| this_access
	| base_access
	| post_increment_expression
	| post_decrement_expression
	| object_creation_expression
	| delegate_creation_expression
	| anonymous_object_creation_expression
	| typeof_expression
	| checked_expression
	| unchecked_expression
	| default_value_expression
	| anonymous_method_expression
	| primary_no_array_creation_expression_unsafe
	;
*/
/*
primary_no_array_creation_expression 
	: ( literal
		| simple_name
		| parenthesized_expression
		| new_expression
		// member_access
    | predefined_type DOT IDENTIFIER type_argument_list?
    | (IDENTIFIER DOUBLE_COLON) => qualified_alias_member DOT IDENTIFIER
    | this_access
    | base_access
		| typeof_expression
		| checked_expression
		| unchecked_expression
		| default_value_expression
		| anonymous_method_expression
		// pointer_element_access
	  | sizeof_expression
	  ) ( DOT IDENTIFIER type_argument_list?
      | OPEN_PARENS argument_list? CLOSE_PARENS
      | OPEN_BRACKET expression_list CLOSE_BRACKET
      | OP_INC
      | OP_DEC
      | OP_PTR IDENTIFIER
      )*
	;
new_expression
  : NEW ( type ( OPEN_BRACKET expression_list CLOSE_BRACKET rank_specifiers? array_initializer? array_creation_tail
				       | rank_specifiers array_initializer array_creation_tail
				       | OPEN_PARENS argument_list? CLOSE_PARENS object_or_collection_initializer? // inludes delegate
				       | object_or_collection_initializer
				       )
	      | rank_specifier array_initializer array_creation_tail
	      | anonymous_object_initializer
	      )
  ;
array_creation_tail
    // member_access
  : DOT IDENTIFIER type_argument_list?
    // invocation_expression (but only one possibility)
  | OPEN_PARENS argument_list? CLOSE_PARENS
    // post inc
  | OP_INC
    // post dec
  | OP_DEC
    // pointer_member_access
  | OP_PTR IDENTIFIER
  ;
*/
/** IDENTIFIER type_argument_list? */
simple_name 
  :
  (({input.LT(1).getText().equals("DateTime") && input.LT(3).getText().equals("Now")}?) => str1=date_operations)
  ->text(value={str1})
  |
  (({input.LT(1).getText().equals("DayOfWeek")}?) => str2=date_week_operations)
  ->text(value={str2})
  | 
  (({input.LT(1).getText().equals("DateTime") && input.LT(3).getText().equals("MinValue")}?) => IDENTIFIER DOT IDENTIFIER )
  ->text(value={"(new Date('0001-01-01'))"})
  |
  (({input.LT(1).getText().equals("DateTime") && input.LT(3).getText().equals("MaxValue")}?) => IDENTIFIER DOT IDENTIFIER )
  ->text(value={"(new Date(\"Dec 31, 9999 23:59:59\"))"})
  |
  (({input.LT(1).getText().equals("Convert") && input.LT(2).getText().equals(".") && input.LT(3).getText().equals("ToString")}?)IDENTIFIER DOT IDENTIFIER par=parenthesized_expression)
  ->text(value={par.st.toString().trim()+".toString()"})
  |
   (({input.LT(1).getText().equals("Convert") && input.LT(2).getText().equals(".") && input.LT(3).getText().equals("ToDecimal")}?)IDENTIFIER DOT IDENTIFIER par=parenthesized_expression)
  ->text(value={"parseInt"+par.st.toString().trim()})
  |
   (({input.LT(1).getText().equals("Convert") && input.LT(2).getText().equals(".") && input.LT(3).getText().equals("ToInt32")}?)IDENTIFIER DOT IDENTIFIER par=parenthesized_expression)
  ->text(value={"parseInt"+par.st.toString().trim()})
  |
  (({input.LT(1).getText().equals("Convert") && input.LT(2).getText().equals(".") && input.LT(3).getText().equals("ToInt64")}?)IDENTIFIER DOT IDENTIFIER par=parenthesized_expression)
  ->text(value={"parseInt"+par.st.toString().trim()})
  |
  (({input.LT(1).getText().equals("Services") && input.LT(2).getText().equals(".")}?) => IDENTIFIER DOT clsid=IDENTIFIER DOT mtdid=IDENTIFIER met=method_invocation2)
  ->text(value={CSharpAngularHelper.serviceDOGenerator(clsid.getText().toString().trim(),mtdid.getText().toString().trim(),met.st.toString().trim())})
  |
  ((simple_name1)+ ) =>  (sim+=simple_name1)+ pare=method_invocation2
  ->simplename1(sim1={$sim} ,value1={CSharpAngularHelper.handleRemoveParenthesis(pare.st.toString().trim())})
  |
  ((simple_remove_name)+ ) =>  (srn+=simple_remove_name)+ pare=method_invocation2
  ->simpleremovename(sim2={$srn} ,value2={CSharpAngularHelper.handleRemoveParenthesis(pare.st.toString().trim())})
  |
  IDENTIFIER talo=type_argument_list_opt
  ->simpleName(name={NamingUtil.toCamelCase($IDENTIFIER.text)},argList={talo})
  ;
  
simple_remove_name
  :
  ({input.LT(1).getText().equals("Remove")}?) IDENTIFIER
  ->text(value={""})
  |
  id=IDENTIFIER DOT
  ->text(value={NamingUtil.toCamelCase($id.text)+"."})
  ;
  
/** OPEN_PARENS expression CLOSE_PARENS */
parenthesized_expression 
	: 
	OPEN_PARENS expr=expression CLOSE_PARENS
	->parenthesizedExpression(expression={expr})
	;

simple_name1
  :
  ({input.LT(1).getText().equals("ToString") && input.LT(2).getText().equals("(") && !input.LT(3).getText().equals(")")}?) IDENTIFIER
  ->text(value={""})
  |
  ({input.LT(3).getText().equals("ToString") && input.LT(4).getText().equals("(") && !input.LT(5).getText().equals(")")}?) id1=IDENTIFIER DOT
  ->text(value={NamingUtil.toCamelCase($id1.text)})
  |
  id=IDENTIFIER DOT
  ->text(value={NamingUtil.toCamelCase($id.text)+"."})
  ;
/*
member_access 
	: primary_expression DOT IDENTIFIER type_argument_list?
	| predefined_type DOT IDENTIFIER type_argument_list?
	| qualified_alias_member DOT IDENTIFIER type_argument_list?
	;
*/
/** primary_expression */
member_access 
  : 
  ma=primary_expression
  ->memberAccess(expr={ma})
  ;
  
predefined_cast_type 
  : 
  BOOL
  ->text(value={"boolean"})
  | BYTE
  ->text(value={$BYTE.text})
  | CHAR
  ->text(value={$CHAR.text})
  | DECIMAL
  ->text(value={$DECIMAL.text})
  | DOUBLE
  ->text(value={$DOUBLE.text})
  | FLOAT
  ->text(value={$FLOAT.text})
  | INT
  ->text(value={$INT.text})
  | LONG
  ->text(value={$LONG.text})
  | OBJECT
  ->text(value={"Object"})
  | SBYTE
  ->text(value={$SBYTE.text})
  | SHORT
  ->text(value={$SHORT.text})
  | STRING
  ->text(value={"String"})
  | UINT
  ->text(value={$UINT.text})
  | ULONG
  ->text(value={$ULONG.text})
  | USHORT
  ->text(value={$USHORT.text})
  ;

predefined_type 
	: 
	BOOL
	->text(value={"boolean"})
	| BYTE
	->text(value={$BYTE.text})
	| CHAR
	->text(value={$CHAR.text})
	| DECIMAL
	->text(value={$DECIMAL.text})
	| DOUBLE
	->text(value={$DOUBLE.text})
	| FLOAT
	->text(value={$FLOAT.text})
	| INT
	->text(value={$INT.text})
	| LONG
	->text(value={$LONG.text})
	| OBJECT
	->text(value={"Object"})
	| SBYTE
	->text(value={$SBYTE.text})
	| SHORT
	->text(value={$SHORT.text})
	| (({input.LT(1).getText().equals("string") && input.LT(2).getText().equals(".")}?) => str=string_operations)
  ->text(value={str})
	| STRING
	->text(value={"String"})
	| UINT
	->text(value={$UINT.text})
	| ULONG
	->text(value={$ULONG.text})
	| USHORT
	->text(value={$USHORT.text})
	;
/** primary_expression OPEN_PARENS argument_list? CLOSE_PARENS */
/* not used anymore; included in primary_expression
invocation_expression 
	: primary_expression OPEN_PARENS argument_list? CLOSE_PARENS
	;
*/
/*
element_access 
	: primary_no_array_creation_expression OPEN_BRACKET expression_list CLOSE_BRACKET
	;
*/
expression_list 
	: 
	frstExpr=expression (ChldLst+=expression_list_Chld)*
	->expressionList(firstExpr={frstExpr},list={$ChldLst})
	;
	
expression_list_Chld
	:
	COMMA expr=expression
	->expressionListChld(expression={expr})
	;
	
this_access 
	: 
	t=THIS
	->text(value={$t.text})
	;
/** BASE and more */
base_access
	: 
	BASE DOT IDENTIFIER typarglst=type_argument_list_opt
	->baseaccess(typarg={typarglst})
	| BASE OPEN_BRACKET expression_list CLOSE_BRACKET
	;
/* not used anymore; included in primary_expression
post_increment_expression 
	: primary_expression OP_INC
	;
post_decrement_expression 
	: primary_expression OP_DEC
	;
*/
/*
object_creation_expression 
	: NEW type OPEN_PARENS argument_list? CLOSE_PARENS object_or_collection_initializer?
	| NEW type object_or_collection_initializer
	;
*/
/** NEW type (OPEN_PARENS ... | OPEN_BRACE ...) */
object_creation_expression 
  : 
  NEW t=type chld=object_creation_expression_Chld
  ->objectCreationExpression(type={t}, child={chld})
  ;
object_creation_expression_Chld
   :  
   OPEN_PARENS (lst=argument_list)? CLOSE_PARENS (ObjInit=object_or_collection_initializer)? 
   ->objectCreationExpressionChld(argLst={$lst.st.toString().trim()},init={ObjInit})
   | ObjColInit=object_or_collection_initializer
   ->objectCreationExpressionChld(argLst={null},init={ObjColInit})
   ;
/** starts with OPEN_BRACE */
object_or_collection_initializer 
	: 
	objInit=object_initializer
	->objectOrCollectionInitializer(init={objInit})
	| colInit=collection_initializer
	->objectOrCollectionInitializer(init={colInit})
	;
/*
object_initializer 
	: OPEN_BRACE member_initializer_list? CLOSE_BRACE
	| OPEN_BRACE member_initializer_list COMMA CLOSE_BRACE
	;
*/
/** starts with OPEN_BRACE */
object_initializer 
  : 
  OPEN_BRACE CLOSE_BRACE
  ->text(value={"{}"})
  | OPEN_BRACE mil=member_initializer_list COMMA? CLOSE_BRACE
  ->objectInitializer(memInitList={mil})
  ;
member_initializer_list 
	: 
	frstInit=member_initializer (memChldLst+=member_initializer_list_Chld)*
	->memberInitializerList(firstInit={frstInit},list={$memChldLst})
	;
	
member_initializer_list_Chld
	:
	COMMA mi=member_initializer
	->memberInitializerListChld(memInit={mi})
	;
	
member_initializer 
	: 
	(cmnts=comments)? id=IDENTIFIER ASSIGNMENT ival=initializer_value
	->memberInitializer(cmnt={cmnts},memberName={$id.text},initVal={ival})
	| (cmnts=comments)
	->comment(content={cmnts})
	;
	
initializer_value 
	: 
	expr=expression
	->initializerValue(expression={expr})
	| objCrtInit=object_or_collection_initializer
	->initializerValue(expression={objCrtInit})
	;
/*
collection_initializer 
	: OPEN_BRACE element_initializer_list CLOSE_BRACE
	| OPEN_BRACE element_initializer_list COMMA CLOSE_BRACE
	;
*/
/** starts with OPEN_BRACE */
collection_initializer 
  : 
  OPEN_BRACE elemntLst=element_initializer_list COMMA? CLOSE_BRACE
  ->collectionInitializer(elementList={elemntLst})
  ;
element_initializer_list 
	: 
	(cmnt=comments)? fstElmnt=element_initializer (chld+=element_initializer_list_Chld)*
	->elementInitializerList(cmnts={cmnt},firstElement={fstElmnt},chldList={$chld})
	;
	
element_initializer_list_Chld
	:
	COMMA (cmnt=comments)? eleInit=element_initializer
	->elementInitializerListChld(cmnts={cmnt},init={eleInit})
	;
element_initializer 
	: 
	expr=non_assignment_expression
	->elementInitializer(expression={expr})
	| OPEN_BRACE el=expression_list CLOSE_BRACE
	->elementInitializer(expression={el})
	;

//array_creation_expression 
//	: 
//	NEW nonArrTyp=non_array_type OPEN_BRACKET eLst=expression_list CLOSE_BRACKET (rs=rank_specifiers)? (aint=array_initializer)?
//	->arrayCreationExpression(arrTyp={nonArrTyp},expList={eLst},rnkSpcr={rs},arrInit={aint})
//	| NEW  (array_type OPEN_BRACKET) => aTyp=array_type arrInit=array_initializer
//	->arrayCreationExpression2(arrTyp={aTyp},arrInit={ai})
//	| NEW rs=rank_specifier arInit=array_initializer
//	->arrayCreationExpression3(rnkSpcr={rs},arrInit={arInit})
//	;
array_creation_expression 
  : 	
	NEW arc=array_creation_expression_Chld
  ->arrayCreationExpression(Chld={arc})    
  ;
   
array_creation_expression_Chld
   :
   (array_type OPEN_BRACKET) => acexpsChld=array_creation_expression_sub_Chld
   ->arrayCreationExpressionChld(subChld={acexpsChld})
   | (t=non_array_type)* OPEN_BRACKET eLst=expression_list CLOSE_BRACKET (rs=rank_specifiers)? (ai=array_initializer)?
   ->arrayCreationExpressionChld2(type={t},expList={eLst},rnkSpcr={rs},arrInitlr={ai})
//   | rsp=rank_specifier ait=array_initializer
//   ->arrayCreationExpressionChld3(rnkSpcr={rsp},aryInit={ait})
   ;
   
array_creation_expression_sub_Chld   
  :
   aType=array_type aInit=array_initializer
   ->arrayCreationExpressionSubChld(arryType={aType},arInit={aInit})
  ;
/*array_creation_expression 
  : NEW ( (array_type OPEN_BRACKET) => array_type array_initializer
        | non_array_type OPEN_BRACKET expression_list CLOSE_BRACKET rank_specifiers? array_initializer?
        | rank_specifier array_initializer
        )
  ;*/
/** NEW delegate_type OPEN_PARENS expression CLOSE_PARENS */
delegate_creation_expression 
	: NEW delegate_type OPEN_PARENS expression CLOSE_PARENS
	;
/** starts with NEW OPEN_BRACE */
anonymous_object_creation_expression 
	: 
	NEW aobjInit=anonymous_object_initializer
	->anonymousObjectCreationExpression(anyObjInit={aobjInit})
	;
/*
anonymous_object_initializer 
	: OPEN_BRACE member_declarator_list? CLOSE_BRACE
	| OPEN_BRACE member_declarator_list COMMA CLOSE_BRACE
	;
*/
/** starts with OPEN_BRACE */
anonymous_object_initializer 
  : 
  OPEN_BRACE CLOSE_BRACE
  ->anonymousObjectInitializer(memDeclLst={null})
  | OPEN_BRACE lst=member_declarator_list (COMMA)? CLOSE_BRACE
  ->anonymousObjectInitializer(memDeclLst={lst})
  ;
member_declarator_list 
	: 
	md=member_declarator ( memlst+=member_declarator_list_Chld)*
	->memberDeclaratorList(memberDecl={md},list={$memlst})
	;
	
member_declarator_list_Chld
	:
	COMMA (cmnt=comments)? memDcl=member_declarator
	->memberDeclaratorListChld(cmnts={cmnt},decl={memDcl})
	;
/*
member_declarator 
	: simple_name
	| member_access
	| base_access
	| IDENTIFIER ASSIGNMENT expression
	;
*/
member_declarator 
  : 
  expr1=primary_expression
  ->memberDeclarator(expression={expr1})
  | id=IDENTIFIER ASSIGNMENT expr2=expression
  ->memberDeclarator(expression={expr2})
  ;
typeof_expression 
	: TYPEOF OPEN_PARENS
	  ( (unbound_type_name) => typ=unbound_type_name CLOSE_PARENS
	  | type CLOSE_PARENS
	  | VOID CLOSE_PARENS
	  )
	  ->typeofexpression(typename={NamingUtil.toCamelCase($typ.text)})
	;
/*
unbound_type_name 
	: IDENTIFIER generic_dimension_specifier?
	| IDENTIFIER DOUBLE_COLON IDENTIFIER generic_dimension_specifier?
	| unbound_type_name DOT IDENTIFIER generic_dimension_specifier?
	;
*/
unbound_type_name 
  : id=IDENTIFIER ( generic_dimension_specifier?
               | DOUBLE_COLON IDENTIFIER generic_dimension_specifier?
               )
    (DOT IDENTIFIER generic_dimension_specifier?)*
    ->unboundtypename(tkn={$id.text})
  ;
generic_dimension_specifier 
	: 
	LT (cl=commas)? GT
	->genericDimensionSpecifier(cList={"<"+cl+">"})
	;
commas 
	: 
	COMMA (lst+=commas_Chld)*
	->commas(list={$lst})
	;
	
commas_Chld
	:
	COMMA 
	->text(value={$COMMA.text})
	;
checked_expression 
	: CHECKED OPEN_PARENS expression CLOSE_PARENS
	;
unchecked_expression 
	: UNCHECKED OPEN_PARENS expression CLOSE_PARENS
	;
default_value_expression 
	: DEFAULT OPEN_PARENS typ=type CLOSE_PARENS
	->defaultvalueexpression(tpe={typ})
	;
/*
unary_expression 
	: primary_expression
	| PLUS unary_expression
	| MINUS unary_expression
	| BANG unary_expression
	| TILDE unary_expression
	| pre_increment_expression
	| pre_decrement_expression
	| cast_expression
	| unary_expression_unsafe
	;
*/
unary_expression 
	: 
	((scan_for_cast_generic_precedence | OPEN_PARENS predefined_cast_type) => val1=cast_expression)
	->unaryExpression(value={val1})
	| val2=primary_expression
	->unaryExpression(value={val2})
	| PLUS val3=unary_expression
	->unaryExpression(value={val3})
	| MINUS val4=unary_expression
	->unaryExpression(value={val4})
	| BANG val5=unary_expression
	->unaryExpression(value={val5})
	| TILDE val6=unary_expression
	->unaryExpression(value={val6})
	| val7=pre_increment_expression
	->unaryExpression(value={val7})
	| val8=pre_decrement_expression
	->unaryExpression(value={val8})
	| val9=unary_expression_unsafe
	->unaryExpression(value={val9})

	;
// The sequence of tokens is correct grammar for a type, and the token immediately
// following the closing parentheses is the token TILDE, the token BANG, the token OPEN_PARENS,
// an IDENTIFIER, a literal, or any keyword except AS and IS.
scan_for_cast_generic_precedence
  : 
  OPEN_PARENS typ=type CLOSE_PARENS cadt=cast_disambiguation_token
  ->scanForCastGenericPrecedence(type={typ},castDisAmbTok={cadt})
  ;

// One of these tokens must follow a valid cast in an expression, in order to
// eliminate a grammar ambiguity.
cast_disambiguation_token
  : 
  TILDE                 ->text(value={$TILDE.text})
  | BANG                ->text(value={$BANG.text})
  | OPEN_PARENS         ->text(value={$OPEN_PARENS.text})
  | notselect=not_select_contextual_keyword          ->text(value={notselect})
  | lit=literal         ->text(value={lit})
  | ABSTRACT            ->text(value={$ABSTRACT.text})
  | BASE                ->text(value={$BASE.text})
  | BOOL                ->text(value={$BOOL.text})
  | BREAK               ->text(value={$BREAK.text})
  | BYTE                ->text(value={$BYTE.text})
  | CASE                ->text(value={$CASE.text})
  | CATCH               ->text(value={$CATCH.text})
  | CHAR                ->text(value={$CHAR.text})
  | CHECKED             ->text(value={$CHECKED.text})
  | CLASS               ->text(value={$CLASS.text})
  | CONST               ->text(value={$CONST.text})
  | CONTINUE            ->text(value={$CONTINUE.text})
  | DECIMAL             ->text(value={$DECIMAL.text})
  | DEFAULT             ->text(value={$DEFAULT.text})
  | DELEGATE            ->text(value={$DELEGATE.text})
  | DO                  ->text(value={$DO.text})
  | DOUBLE              ->text(value={$DOUBLE.text})
  | ELSE                ->text(value={$ELSE.text})
  | ENUM                ->text(value={$ENUM.text})
  | EVENT               ->text(value={$EVENT.text})
  | EXPLICIT            ->text(value={$EXPLICIT.text})
  | EXTERN              ->text(value={$EXTERN.text})
  | FINALLY             ->text(value={$FINALLY.text})
  | FIXED               ->text(value={$FIXED.text})
  | FLOAT               ->text(value={$FLOAT.text})
  | FOR                 ->text(value={$FOR.text})
  | FOREACH             ->text(value={$FOREACH.text})
  | GOTO                ->text(value={$GOTO.text})
  | IF                  ->text(value={$IF.text})
  | IMPLICIT            ->text(value={$IMPLICIT.text})
  | IN                  ->text(value={$IN.text})
  | INT                 ->text(value={$INT.text})
  | INTERFACE           ->text(value={$INTERFACE.text})
  | INTERNAL            ->text(value={$INTERNAL.text})
  | LOCK                ->text(value={$LOCK.text})
  | LONG                ->text(value={$LONG.text})
  | NAMESPACE           ->text(value={$NAMESPACE.text})
  | NEW                 ->text(value={$NEW.text})
  | OBJECT              ->text(value={"Object"})
  | OPERATOR            ->text(value={$OPERATOR.text})
  | OUT                 ->text(value={$OUT.text})
  | OVERRIDE            ->text(value={$OVERRIDE.text})
  | PARAMS              ->text(value={$PARAMS.text})
  | PRIVATE             ->text(value={$PRIVATE.text})
  | PROTECTED           ->text(value={$PROTECTED.text})
  | PUBLIC              ->text(value={$PUBLIC.text})
  | READONLY            ->text(value={$READONLY.text})
  | REF                 ->text(value={$REF.text})
  | RETURN              ->text(value={$RETURN.text})
  | SBYTE               ->text(value={$SBYTE.text})
  | SEALED              ->text(value={$SEALED.text})
  | SHORT               ->text(value={$SHORT.text})
  | SIZEOF              ->text(value={$SIZEOF.text})
  | STACKALLOC          ->text(value={$STACKALLOC.text})
  | STATIC              ->text(value={$STATIC.text})
  | STRING              ->text(value={"String"})
  | STRUCT              ->text(value={$STRUCT.text})
  | SWITCH              ->text(value={$SWITCH.text})
  | THIS                ->text(value={$THIS.text})
  | THROW               ->text(value={$THROW.text})
  | TRY                 ->text(value={$TRY.text})
  | TYPEOF              ->text(value={$TYPEOF.text})
  | UINT                ->text(value={$UINT.text})
  | ULONG               ->text(value={$ULONG.text})
  | UNCHECKED           ->text(value={$UNCHECKED.text})
  | UNSAFE              ->text(value={$UNSAFE.text})
  | USHORT              ->text(value={$USHORT.text})
  | USING               ->text(value={$USING.text})
  | VIRTUAL             ->text(value={$VIRTUAL.text})
  | VOID                ->text(value={$VOID.text})
  | VOLATILE            ->text(value={$VOLATILE.text})
  | WHILE               ->text(value={$WHILE.text})
  ;

pre_increment_expression 
	: 
	OP_INC expr=unary_expression
	->preIncrementExpression(optr={$OP_INC.text},expression={expr})
	;
pre_decrement_expression 
	: 
	OP_DEC expr=unary_expression
	->preDecrementExpression(optr={$OP_DEC.text},expression={expr})
	;
cast_expression 
	: 
	OPEN_PARENS t=type CLOSE_PARENS uExpr=unary_expression
	->castExpression(type={t},unaryExpr={uExpr})
	;
multiplicative_expression 
	: 
	lhs=unary_expression (rhs+=multiplicative_expression_Chld)*
	->multiplicativeExpression(lhs={lhs},rhs={$rhs})
	;
	
multiplicative_expression_Chld
	:
	STAR  rhs=unary_expression
	->multiplicativeExpressionChld(optr={$STAR.text},rhs={rhs}) 
	|DIV  rhs=unary_expression 
	->multiplicativeExpressionChld(optr={$DIV.text},rhs={rhs})
	|PERCENT  rhs=unary_expression
	->multiplicativeExpressionChld(optr={$PERCENT},rhs={rhs})
	;
additive_expression 
	: 
	lhs=multiplicative_expression (rhs+=additive_expression_Chld)*
	->additiveExpression(lhs={lhs},rhs={$rhs})
	;
	
additive_expression_Chld
	:
	(cmnt1=comments)? PLUS (cmnt=comments)? rhs1=multiplicative_expression
	->additiveExpressionChld(optr={$PLUS.text},rhs={rhs1})
	|MINUS  rhs2=multiplicative_expression
	->additiveExpressionChld(optr={$MINUS.text},rhs={rhs2})
	;
	
shift_expression 
	: 
	lhs=additive_expression (rhs+=shift_expression_Chld)*
	->shiftExpression(lhs={lhs},rhs={rhs})
	;
	
shift_expression_Chld
	:
	OP_LEFT_SHIFT  rhs1=additive_expression
	->shiftExpressionChld(optr={$OP_LEFT_SHIFT.text},rhs={rhs1})
	|rs=right_shift  rhs2=additive_expression
	->shiftExpressionChld(optr={rs},rhs={rhs2})
	;
	
relational_expression
  :
  (shift_expression ({input.LT(1).getText().equals("as")}?)) => lhs1=shift_expression  (rhs1+=relational_expression_Chld)*
  ->relationalasExpression(lhs={lhs1}, rhs={rhs1})
  |
  lhs=shift_expression  (rhs+=relational_expression_Chld)*
	 ->relationalExpression(lhs={lhs},rhs={$rhs})                  
	;
	
relational_expression_Chld
	:
	LT rhs1=shift_expression
	->relationalExpressionChld(optr={$LT.text},rhs={rhs1})
  | GT rhs2=shift_expression
  ->relationalExpressionChld(optr={$GT.text},rhs={rhs2})
  | OP_LE rhs3=shift_expression
  ->relationalExpressionChld(optr={$OP_LE.text},rhs={rhs3})
  | OP_GE rhs4=shift_expression
  ->relationalExpressionChld(optr={$OP_GE.text},rhs={rhs4})
  | IS rhs5=isType
  ->relationalExpressionChld(optr={$IS.text},rhs={rhs5})
  | AS rhs6=type
  ->text(value={"("+rhs6+")"})
  ;                   
// Syntactic predicate rule to disambiguate  "a<b,c>d" and a<b,c>(0)"
// added by chw
scan_for_shift_generic_precedence
  : IDENTIFIER LT type (COMMA type)* GT shift_disambiguation_token
  ;
// One of these tokens must follow a valid generic in an expression, in order to
// eliminate a grammar ambiguity.
// added by chw
shift_disambiguation_token
  : 
  OPEN_PARENS          ->text(value={$OPEN_PARENS.text})
  | CLOSE_PARENS       ->text(value={$CLOSE_PARENS.text})
  | CLOSE_BRACKET      ->text(value={$CLOSE_BRACKET.text})
  | COLON              ->text(value={$COLON.text})
  | SEMICOLON          ->text(value={$SEMICOLON.text})
  | COMMA              ->text(value={$COMMA.text})
  | DOT                ->text(value={$DOT.text})
  | INTERR             ->text(value={""})
  | OP_EQ              ->text(value={$OP_EQ.text})
  | OP_NE              ->text(value={$OP_NE.text})
  | GT                 ->text(value={$GT.text})
  ;

// added by chw
isType
  : 
  typ=non_nullable_value_type ( (INTERR is_disambiguation_token) => INTERR)?
  ->isType(type={typ},opt={""})
  ;
is_disambiguation_token
  : 
  CLOSE_PARENS        ->text(value={$CLOSE_PARENS.text})
  | OP_AND            ->text(value={$OP_AND.text})
  | OP_OR             ->text(value={$OP_OR.text})
  | INTERR            ->text(value={""})
  ;

equality_expression 
	: 
	lhs=relational_expression (rhs+=equality_expression_Chld)*
	->equalityExpression(lhs={lhs},rhs={$rhs})
	;
	
equality_expression_Chld
	:
	OP_EQ  rhs1=relational_expression
	->equalityExpressionChld(optr={$OP_EQ.text},rhs={rhs1})
	|OP_NE  rhs2=relational_expression
	->equalityExpressionChld(optr={$OP_NE.text},rhs={rhs2})
	;
and_expression 
  : 
  lhs=equality_expression ( rhs+=and_expression_Chld)*
  ->andExpression(lhs={lhs},rhs={$rhs})
  ;
  
and_expression_Chld
  :
  AMP rhs=equality_expression
  ->andExpressionChld(optr={$AMP.text},rhs={rhs})
  ;
  
exclusive_or_expression 
  : 
  lhs=and_expression (rhs+=exclusive_or_expression_Chld)*
  ->exclusiveOrExpression(lhs={lhs},rhs={$rhs})
  ;
  
exclusive_or_expression_Chld
  :
  CARET rhs=and_expression
  ->exclusiveOrExpressionChld(optr={$CARET.text},rhs={rhs})
  ;
  
inclusive_or_expression 
	: 
  lhs=exclusive_or_expression (rhs+=inclusive_or_expression_Chld)*
  ->inclusiveOrExpression(lhs={lhs},rhs={$rhs})
  ;
  
inclusive_or_expression_Chld
  :
  BITWISE_OR rhs=exclusive_or_expression
  ->inclusiveOrExpressionChld(optr={$BITWISE_OR.text},rhs={rhs})
  ;
    
conditional_and_expression 
	: 
  lhs=inclusive_or_expression (rhs+=conditional_and_expression_Chld)*
  ->conditionalAndExpression(lhs={lhs},rhs={$rhs})
  ;
  
conditional_and_expression_Chld
  :
  OP_AND rhs=inclusive_or_expression
  ->conditionalAndExpressionChld(optr={$OP_AND.text},rhs={rhs})
  ;
conditional_or_expression 
	: 
  lhs=conditional_and_expression (rhs+=conditional_or_expression_Chld)*
  ->conditionalOrExpression(lhs={lhs},rhs={$rhs})
  ;
  
conditional_or_expression_Chld
  :
  OP_OR rhs=conditional_and_expression  
  ->conditionalOrExpressionChld(optr={$OP_OR.text},rhs={rhs})
  ;  
/*
null_coalescing_expression 
	: conditional_or_expression
	| conditional_or_expression OP_COALESCING null_coalescing_expression
	;
*/
null_coalescing_expression 
  : 
  lhs=conditional_or_expression (OP_COALESCING rhs=null_coalescing_expression)?
  ->nullCoalescingExpression(lhs={lhs},optr={$OP_COALESCING.text},rhs={rhs})
  ; 
  
/*
conditional_expression 
	: null_coalescing_expression
	| null_coalescing_expression INTERR expression COLON expression
	;
*/
/** starts with unary_expression */
conditional_expression 
  : 
  lhs=null_coalescing_expression (INTERR exp1=expression COLON exp2=expression)?
  ->conditionalExpression(lhs={lhs},optr1={"?"},optr2={$COLON.text},expr1={exp1},expr2={exp2})
  ;
/** starts with OPEN_PARENS or IDENTIFIER */
lambda_expression 
	: 
	sign=anonymous_function_signature right_arrow (cmnt=comments)? bdy=anonymous_function_body
	->lambdaExpression(signature={sign},cmnts={cmnt},body={bdy})
	;
/** starts with DELEGATE */
anonymous_method_expression 
	: 
	DELEGATE (sign=explicit_anonymous_function_signature)? blk=block
	->anonymousMethodExpression(signature={sign},body={blk})
	;
/*
anonymous_function_signature 
	: explicit_anonymous_function_signature
	| implicit_anonymous_function_signature
	;
*/
/** starts with OPEN_PARENS or IDENTIFIER */
anonymous_function_signature 
  : 
  OPEN_PARENS CLOSE_PARENS          
  ->text(value={"()"})
  | OPEN_PARENS lst1=explicit_anonymous_function_parameter_list CLOSE_PARENS
  ->anonymousFunctionSignature(list={lst1})
  | OPEN_PARENS lst2=implicit_anonymous_function_parameter_list CLOSE_PARENS
  ->anonymousFunctionSignature(list={lst2})
  | par=implicit_anonymous_function_parameter
  ->anonymousFunctionSignature2(parameter={par})
  ;
explicit_anonymous_function_signature 
	: 
	OPEN_PARENS (lst=explicit_anonymous_function_parameter_list)? CLOSE_PARENS
	->explicitAnonymousFunctionSignature(list={lst})
	;
explicit_anonymous_function_parameter_list 
	: 
	par=explicit_anonymous_function_parameter (chld+=explicit_anonymous_function_parameter_list_Chld)*
	->explicitAnonymousFunctionParameterList(firstPar={par},list={$chld})
	;
	
explicit_anonymous_function_parameter_list_Chld
	:
	COMMA par=explicit_anonymous_function_parameter
	->explicitAnonymousFunctionParameterListChld(parameter={par})
	;
	
explicit_anonymous_function_parameter 
	: 
	(modfr=anonymous_function_parameter_modifier)? t=type IDENTIFIER
	->explicitAnonymousFunctionParameter(modifier={modfr},type={t},name={$IDENTIFIER.text})
	;
anonymous_function_parameter_modifier 
	: 
	REF        ->text(value={$REF.text})
	| OUT      ->text(value={$OUT.text})
	;
implicit_anonymous_function_signature 
	: 
	OPEN_PARENS (parLst=implicit_anonymous_function_parameter_list)? CLOSE_PARENS
	->implicitAnonymousFunctionSignature(paramList={parLst})
	| par=implicit_anonymous_function_parameter
	->implicitAnonymousFunctionSignature2(param={par})
	;
implicit_anonymous_function_parameter_list 
	: 
	fstPar=implicit_anonymous_function_parameter (chld+=implicit_anonymous_function_parameter_list_Chld)*
	->implicitAnonymousFunctionParameterList(firstPar={fstPar},list={$chld})
	;
	
implicit_anonymous_function_parameter_list_Chld
	:
	COMMA par=implicit_anonymous_function_parameter
	->implicitAnonymousFunctionParameterListChld(parameter={par})
	;
/** IDENTIFIER */
implicit_anonymous_function_parameter 
	: 
	IDENTIFIER     ->text(value={$IDENTIFIER.text})
	;
anonymous_function_body 
	: 
	expr=expression
	->anonymousFunctionBody(body={expr})
	| blk=block
	->anonymousFunctionBody(body={blk})
	;
/** starts with from_contextual_keyword */
query_expression 
	:
	frmCls=from_clause bdy=query_body
	->queryExpression(fromClause={frmCls+updateLinqStatus(true)},body={bdy})
	;
//from_clause 
//	: 
//	frmKWd=from_contextual_keyword ((type IDENTIFIER IN) => t=type)? IDENTIFIER IN exp=expression
//	->fromClause(keyWrd={frmKWd},type={t},als={$IDENTIFIER.text},expression={exp})
//	;

from_clause 
  : 
  frmKWd=from_contextual_keyword ((type IDENTIFIER IN) => t=type)? id2=IDENTIFIER IN frm=from_clause_chld
  ->fromClause(keyWrd={frmKWd},type={t},als={$id2.text+updateIdName($id2.text)},expression={frm})
  ;
  
from_clause_chld
  :(expression {input.LT(1).getText().equals("where")}?) => exp=expression
  ->text(value={NamingUtil.toVarName(CSharpAngularHelper.prefixGetKeyword($exp.text))+updateExpressionStmt2(NamingUtil.toVarName($exp.text))+".stream()"})
  |
  (expression {input.LT(1).getText().equals("from")}?) => exp=expression
  ->text(value={NamingUtil.toClassName(CSharpAngularHelper.linqFromPart($exp.text))+".stream(), "})
  |
  (expression {input.LT(1).getText().equals("group")}?) => exp=expression
  ->text(value={NamingUtil.toClassName(CSharpAngularHelper.linqFromPart($exp.text))+".stream()"})
  |
  (expression {input.LT(1).getText().equals("select")}?) => exp=expression
  ->text(value={NamingUtil.toClassName(CSharpAngularHelper.linqFromPart($exp.text))+".stream().filter("+updateExpressionStmt(CSharpAngularHelper.prefixGetKeyword(NamingUtil.toVarName($exp.text)))})
  |
  exp=expression
  ->text(value={NamingUtil.toClassName(CSharpAngularHelper.linqFromPart($exp.text))+".stream()"})
  ;
/*
query_body 
	: query_body_clauses? select_or_group_clause query_continuation?
	;
*/
query_body 
  : 
  (qryBdyCls=query_body_clauses)? slctOrGrpCls=select_or_group_clause ((into_contextual_keyword) => cond=query_continuation)?
  ->queryBody(bodyClauses={qryBdyCls},selectOrGrpCls={slctOrGrpCls},quryCond={cond})
  ;
  
//query_body_clauses 
//	: 
//	fstCls=query_body_clause (chld+=query_body_clauses_Chld)*
//	->queryBodyClauses(firstClause={fstCls},list={$chld})
//	;

query_body_clauses 
  : 
  (lst+=query_body_clause)+
  ->queryBodyClauses(list={$lst})
  ;
  
query_body_clauses_Chld
	:
	cls=query_body_clause
	->queryBodyClausesChld(clause={cls})
	;
/*
query_body_clause 
	: from_clause
	| let_clause
	| where_clause
	| join_clause
	| join_into_clause
	| orderby_clause
	;
*/
query_body_clause 
  : 
  cls1=from_clause
  ->queryBodyClause(clause={cls1})
  | cls2=let_clause
  ->queryBodyClause(clause={cls2})
  | cls3=where_clause
  ->queryBodyClause(clause={cls3})
  | cls4=combined_join_clause
  ->queryBodyClause(clause={cls4})
  | cls5=orderby_clause
  ->queryBodyClause(clause={cls5})
  ;
 
let_clause 
	: 
	letkWd=let_contextual_keyword id=IDENTIFIER ASSIGNMENT expr=expression
	->letClause(letKeyWrd={letkWd},name={$id.text},expression={expr})
	;
where_clause1
  :
  whrKwd=where_contextual_keyword expr=boolean_expression
  ->whereClause(whereKeyWrd={whrKwd},expression={updateExpressionStmt(CSharpAngularHelper.prefixGetKeyword((getExpressionStmt2()!=null && !getExpressionStmt2().equals("") )?$expr.text.replaceAll(getIdName(), getExpressionStmt2()):$expr.text))+updateExpressionStmt2("")+updateIdName("")})
  ;

where_clause 
	:
	 ((where_clause1 orderby_clause ) => (whr=where_clause1 ord=orderby_clause))
  ->text(value={").sorted"+whr.st.toString()})
  |
   whr=where_clause1 
  ->text(value={whr})
	;
	
//join_clause 
//	: 
//	(jKwd=join_contextual_keyword t=type)? id1=IDENTIFIER IN expr1=expression onKwd=on_contextual_keyword expr2=expression eqKwd=equals_contextual_keyword expr3=expression
//	->joinClause(joinKeyWrd={$jKwd.text},type={t},joinId={$id1.text},expression1={expr1},onKeyWrd={onKwd},expression2={expr2},equalsKeyWrd={eqKwd},expression3={expr3})
//	;
join_clause 
  : 
//join                                        node      in MainViewModel.AdminMasterData.NodeAspects on row.AspectName.Trim().ToUpper() equals node.AspectName.Trim().ToUpper() 
  join_contextual_keyword (t=type)? id1=IDENTIFIER IN expr1=expression on_contextual_keyword expr2=expression equals_contextual_keyword expr3=expression
  ->joinClause(type={t},joinId={$id1.text},expression1={expr1},expression2={expr2},expression3={expr3})
  ;

join_into_clause 
	: 
	(jKwd=join_contextual_keyword t=type)? id1=IDENTIFIER IN expr1=expression onKwd=on_contextual_keyword expr2=expression eqKwd=equals_contextual_keyword expr3=expression into_contextual_keyword id2=IDENTIFIER
	->joinIntoClause(joinKeyWrd={$jKwd.text},type={t},joinId={$id1.text},expression1={expr1},onKeyWrd={onKwd},expression2={expr2},equalsKeyWrd={eqKwd},expression3={expr3},intoId={$id2.text})
	;
// added by chw
//combined_join_clause
//  : 
//  (jKwd=join_contextual_keyword t=type)? id1=IDENTIFIER IN expr1=expression onKwd=on_contextual_keyword expr2=expression eqKwd=equals_contextual_keyword expr3=expression (into_contextual_keyword id2=IDENTIFIER)?
//  ->combinedJoinClause(joinKeyWrd={$jKwd.text},type={t},joinId={$id1.text},expression1={expr1},onKeyWrd={onKwd},expression2={expr2},equalsKeyWrd={eqKwd},expression3={expr3},intoId={$id2.text})
//  ;
combined_join_clause
  : 
  jck=join_contextual_keyword (t=type)? id1=IDENTIFIER IN expr1=expression ock=on_contextual_keyword expr2=expression eck=equals_contextual_keyword expr3=expression (into=into_query_clause)?
  ->combinedJoinClause(expression1={CSharpAngularHelper.linqFromPart($expr1.text)},expression3={updateExpressionStmt(CSharpHelper.prefixGetKeyword($expr2.text)+".equals( "+CSharpHelper.prefixGetKeyword($expr3.text)+" )")},intoval={into!=null?into.st.toString()+ getExpressionStmt():null })
  ;
  
into_query_clause
  :((into_contextual_keyword IDENTIFIER from_contextual_keyword IDENTIFIER IN expression where_clause ) =>
         into1=into_contextual_keyword id1=IDENTIFIER from_contextual_keyword id3=IDENTIFIER IN exp=expression  )
  ->text(value={$id1.text+" -> "+updateIdName($id3.text)+updateExpressionStmt2($exp.text)})
  |into=into_contextual_keyword id2=IDENTIFIER
  ->text(value={$id2.text+" -> "})
  ;
  

  
//orderby_clause 
//	: 
//	ordKwd=orderby_contextual_keyword ods=orderings
//	->orderbyClause(keyWord={ordKwd},ordngs={ods})
//	;

orderby_clause 
  : 
  orderby_contextual_keyword ods=orderings
  ->text(value={""})
  ;

orderings 
	: 
	fstOrd=ordering (chld+=orderings_Chld)*
	->orderings(firstOrdrng={fstOrd},list={$chld})
	;
	
orderings_Chld
  :
  COMMA  od=ordering
  ->orderingsChld(ordrng={od})
  ;

//ordering 
//	: 
//	expr=expression (orng=ordering_direction)?
//	->ordering(expression={expr},direction={orng})
//	;
ordering 
  : 
  expr=expression (orng=ordering_direction)?
  ->ordering(expression={$expr.st.toString().trim()},direction={orng})
  ;
//ordering_direction 
//	: 
//	keyWrd1=ascending_contextual_keyword
//	->orderingDirection(dir={keyWrd1})
//	| keyWrd2=descending_contextual_keyword
//	->orderingDirection(dir={keyWrd2})
//	;
ordering_direction 
  : 
  ascending_contextual_keyword
  ->orderingDirectionAsc()
  | descending_contextual_keyword
  ->orderingDirectionDesc()
  ;
select_or_group_clause 
	: 
	cls1=select_clause
	->selectOrGroupClause(clause={cls1})
	| cls2=group_clause
	->selectOrGroupClause(clause={cls2})
	;
	
//select_clause 
//	: 
//	slctKwd=select_contextual_keyword expr=expression
//	->selectClause(keyWrd={slctKwd},expression={expr})
//	;
select_clause 
  : 
  slctKwd=select_contextual_keyword expr=expression
  ->text(value={expr.st.toString()+" -> " + getExpressionStmt() + updateExpressionStmt("")})
  ;
group_clause 
	: 
	grpKwd=group_contextual_keyword expr1=expression byKwrd=by_contextual_keyword expr2=expression
	->groupClause(groupkeyWrd={grpKwd},expression1={CSharpAngularHelper.prefixGetKeyword($expr1.text)},byKeyWrd={" -> "},expression2={CSharpAngularHelper.prefixGetKeyword($expr2.text)+")"})
	;

/** starts with into_contextual_keyword */
query_continuation 
	: 
	intoKwd=into_contextual_keyword IDENTIFIER qBdy=query_body
	->queryContinuation(intoKeyWrd={intoKwd},name={$IDENTIFIER.text},queryBody={qBdy})
	;
/** starts with unary_expression */
assignment 
	: 
	unExpr=unary_expression optr=assignment_operator ((({input.LT(1).getText().equals("Services") && input.LT(2).getText().equals(".")}?) expr=expression
	->text(value={expr}))|(expr=expression 
	->assignment(unaryExpr={CSharpAngularHelper.processAssignmentStmtsNew(unExpr.st.toString().trim(),optr.st.toString().trim(),expr.st.toString().trim())})))
	;
assignment_operator 
	: 
	ASSIGNMENT
	->text(value={$ASSIGNMENT.text})
	| OP_ADD_ASSIGNMENT
	->text(value={$OP_ADD_ASSIGNMENT.text})
	| OP_SUB_ASSIGNMENT
	->text(value={$OP_SUB_ASSIGNMENT.text})
	| OP_MULT_ASSIGNMENT
	->text(value={$OP_MULT_ASSIGNMENT.text})
	| OP_DIV_ASSIGNMENT
	->text(value={$OP_DIV_ASSIGNMENT.text})
	| OP_MOD_ASSIGNMENT
	->text(value={$OP_MOD_ASSIGNMENT.text})
	| OP_AND_ASSIGNMENT
	->text(value={$OP_AND_ASSIGNMENT.text})
	| OP_OR_ASSIGNMENT
	->text(value={$OP_OR_ASSIGNMENT.text})
	| OP_XOR_ASSIGNMENT
	->text(value={$OP_XOR_ASSIGNMENT.text})
	| OP_LEFT_SHIFT_ASSIGNMENT
	->text(value={$OP_LEFT_SHIFT_ASSIGNMENT.text})
	| rshftAsgn=right_shift_assignment
	->text(value={rshftAsgn})
	;
expression 
	: 
	(assignment)=> asgn=assignment
	->expression(assignment={asgn})
	| nonAsgn=non_assignment_expression
	->expression(assignment={nonAsgn})
	;
	
non_assignment_expression
	: 
	((lambda_expression) => le=lambda_expression)
	->nonAssignmentExpression(expression={le})
	| ((query_expression) => qe=query_expression)
	->nonAssignmentExpression(expression={qe})
	| ce=conditional_expression
	->nonAssignmentExpression(expression={ce})
	;
	
constant_expression 
	: 
	expr=expression
	->constantExpression(expression={expr})
	;
boolean_expression 
	: 
	expr=expression
	->booleanExpression(boolExpr={expr})
	;

//B.2.5 Statements
statement 
	: 
	((labeled_statement) => lblStmt=labeled_statement)
	->statement(stmt={isLinq()?CSharpAngularHelper.linqSourceTargetAppend($lblStmt.text,lblStmt.st.toString())+updateLinqStatus(false):lblStmt})
	|( (declaration_statement) => decStmt=declaration_statement)
	->statement(stmt={isLinq()?CSharpAngularHelper.linqSourceTargetAppend($decStmt.text,decStmt.st.toString())+updateLinqStatus(false):decStmt})
	| embdStmt=embedded_statement (cmnt=comments)?
	->statement(stmt={isLinq()?CSharpAngularHelper.linqSourceTargetAppend($embdStmt.text,embdStmt.st.toString())+updateLinqStatus(false):embdStmt}, cmnts={cmnt})
	;
embedded_statement 
	: 
	blck=block
	->embeddedStatement(stmt={blck})
	| emptStmt=empty_statement
	->embeddedStatement(stmt={emptStmt})
	| exprStmt=expression_statement
	->embeddedStatement(stmt={exprStmt})
	| selctStmt=selection_statement
	->embeddedStatement(stmt={selctStmt})
	| iterStmt=iteration_statement
	->embeddedStatement(stmt={iterStmt})
	| jmpStmt=jump_statement
	->embeddedStatement(stmt={jmpStmt})
	| tryStmt=try_statement
	->embeddedStatement(stmt={tryStmt})
	| chkdStmt=checked_statement
	->embeddedStatement(stmt={chkdStmt})
	| unChkdStmt=unchecked_statement
	->embeddedStatement(stmt={unChkdStmt})
	| lckStmt=lock_statement
	->embeddedStatement(stmt={lckStmt})
	| usngStmt=using_statement
	->embeddedStatement(stmt={usngStmt})
	| yldStmt=yield_statement
	->embeddedStatement(stmt={yldStmt})
	| embdStmtUnsf=embedded_statement_unsafe
	->embeddedStatement(stmt={embdStmtUnsf})
	| cmnts=comments
	->comment(content={cmnts})
	;
/** starts with OPEN_BRACE */
block 
	: 
	OPEN_BRACE (comts= comments )? (lst= statement_list )?  CLOSE_BRACE
	->block(blockStmtLst={lst},comt={comts})
	;

statement_list 
	: 
	(stmts+=statement)+ (cmnts+=comments)*
	->statementList(list={$stmts},cmntts={$cmnts})
	;
empty_statement 
	: 
	val=SEMICOLON (comts=comments)?
	->emptyStatement(value={$val.text},comments={comts})
	;
/** starts with IDENTIFIER COLON */
labeled_statement 
	: 
	id=IDENTIFIER COLON stmt=statement
	->labeledStatement(labelName={id},labelBody={stmt})
	;
/** starts with type, VAR, or CONST */
declaration_statement 
	: 
	varDec=local_variable_declaration SEMICOLON (comts1=comments)?
	->declarationStatement(variableDecl={$varDec.st.toString().trim()},comments={comts1})
	| constDec=local_constant_declaration SEMICOLON (comts2=comments)?
	->declarationStatement(variableDecl={constDec},comments={comts2})
	;
local_variable_declaration 
	: 
	typ=local_variable_type (arr=array_initializer)? decls=local_variable_declarators
	->localVariableDeclaration(varType={"var"},arr1={arr},declarators={decls})
	;
/*
local_variable_type 
  : type
  | 'var'
  ;
*/
local_variable_type 
	: 
	t=type // includes 'var'
	->localVariableType(type={$t.text})
	;
/** starts with IDENTIFIER */
local_variable_declarators 
	: 
	frstDec=local_variable_declarator ( lvdChld+=local_variable_declarators_Chld )*
	->localVariableDeclarators(firstDeclaration={frstDec},declarationChld={$lvdChld})
	;
	
local_variable_declarators_Chld
	:
	COMMA  lvd=local_variable_declarator
	->localVariableDeclaratorsChld(localVarDec={lvd})
	;
/*
local_variable_declarator 
	: IDENTIFIER
	| IDENTIFIER ASSIGNMENT local_variable_initializer
	;
*/
local_variable_declarator 
  : 
  id=IDENTIFIER  (ASSIGNMENT lvInit=local_variable_initializer)?
  ->localVariableDeclarator(lvdName={$id.text},localVarInit={lvInit})
  ;
local_variable_initializer
	: 
	expr=expression
	->localVariableInitializer(init={expr})
	| arrInit=array_initializer
	->localVariableInitializer(init={arrInit})
	| lvInitUnsafe=local_variable_initializer_unsafe
	->localVariableInitializer(init={lvInitUnsafe})
	;
	
local_constant_declaration 
	: 
	CONST t=type cd=constant_declarators
	->localConstantDeclaration(type={t},constDecls={cd})
	;
	
expression_statement
	: 
	stmt=statement_expression SEMICOLON (comts=comments)?
	->expressionStatement(statement={$stmt.st.toString().trim()},comments={comts})
	;
/*
statement_expression 
	: invocation_expression
	| object_creation_expression
	| assignment
	| post_increment_expression
	| post_decrement_expression
	| pre_increment_expression
	| pre_decrement_expression
	;
*/
// primary_expression includes invocation_expression,
//    object_creation_expression, post_increment_expression, and post_decrement_expression
statement_expression 
  : 
  expr=expression
  ->statementExpression(expression={expr})
  ;
//selection_statement 
//  : 
//  if_statement
//  | switch_statement
//  ;
	
selection_statement
	:
	ifStmt=if_statement
	->selectionStatement(stmt={ifStmt})
	|swStmt=switch_statement
	->selectionStatement(stmt={swStmt})
	;
/*
if_statement 
	: IF OPEN_PARENS boolean_expression CLOSE_PARENS embedded_statement
	| IF OPEN_PARENS boolean_expression CLOSE_PARENS embedded_statement ELSE embedded_statement
	;
*/
if_statement 
  : 
  IF OPEN_PARENS (cmnts2=comments)? cond=boolean_expression CLOSE_PARENS (cmnts1=comments)? ifBdystmts=embedded_statement (cmnts=comments)? ( (ELSE) => ELSE elsBdy=embedded_statement )?
  ->ifStatement(cmnt2={cmnts2},condition={cond.toString().trim()},cmnt1={cmnts1},ifBody={ifBdystmts},cmnt={cmnts},elseBody={elsBdy})
  ;
switch_statement 
	: SWITCH OPEN_PARENS expr=expression CLOSE_PARENS (cmnts=comments)? switchblk=switch_block
	->switchstatement(exprsn={expr},cmnt={cmnts},swiblk={switchblk})
	;
switch_block 
	: OPEN_BRACE (cmnts=comments)? (switchsecns=switch_sections)? CLOSE_BRACE
	->switchblock(cmnt={cmnts},sectns={switchsecns})
	;
switch_sections 
	: (switchsecn+=switch_section)+
	->switchsections(sectn={$switchsecn})
	;
switch_section 
	: label=switch_labels stmt=statement_list
	->switchsection(labels={label},stmts={stmt})
	;
switch_labels 
	: (label+=switch_label)+
	->switchlabels(labels={$label})
	;
switch_label 
	: CASE cnst=constant_expression COLON
	->switchlabel(cnsts={cnst})
	| DEFAULT COLON
	->
	;
iteration_statement 
	: 
	whlStmt=while_statement
	->iterationStatement(stmt={whlStmt})
	| doStmt=do_statement
	->iterationStatement(stmt={doStmt})
	| forStmt=for_statement
	->iterationStatement(stmt={forStmt})
	| forEchStmt=foreach_statement
	->iterationStatement(stmt={forEchStmt})
	;
while_statement 
	: 
	WHILE OPEN_PARENS cond=boolean_expression CLOSE_PARENS bdy=embedded_statement
	->whileStatement(condition={cond},body={bdy})
	;
do_statement 
	: 
	DO bdy=embedded_statement WHILE OPEN_PARENS cond=boolean_expression CLOSE_PARENS SEMICOLON (comts=comments)?
	->doStatement(doBody={bdy},condition={cond},comments={comts})
	;
for_statement 
	: 
	FOR OPEN_PARENS (init=for_initializer)? SEMICOLON (cond=for_condition)? SEMICOLON (itr=for_iterator)? CLOSE_PARENS frBdy=embedded_statement
	->forStatement(initialization={init},condition={cond},iterator={itr},forBody={frBdy})
	;
for_initializer 
	: (local_variable_declaration) => lvd=local_variable_declaration
	->forInitializer(init={lvd})
	| stlist=statement_expression_list
	->forInitializer(init={stlist})
	;
	
for_condition 
	: expr=boolean_expression
  ->forCondition(expression={expr})
	;
for_iterator 
  : 
  eL=statement_expression_list
  ->forIterator(exprList={eL})
  ;

statement_expression_list 
  : 
  fstExpr=statement_expression (lst+=statement_expression_list_Chld)*
  ->statementExpressionList(firstExpr={fstExpr},list={$lst})
  ;
  
statement_expression_list_Chld
  :
  COMMA  expr=statement_expression
  ->statementExpressionListChld(expression={expr})
  ;

foreach_statement 
	: 
	FOREACH OPEN_PARENS varTyp=local_variable_type var=IDENTIFIER IN expr=expression CLOSE_PARENS frEchBdy=embedded_statement
	->foreachStatement(variableType={"var"},variable={$var.text},expression={expr},forEachBody={frEchBdy})
	;
jump_statement 
	: 
	brkStmt=break_statement
	->jumpStatement(stmt={brkStmt})
	| contStmt=continue_statement
	->jumpStatement(stmt={contStmt})
	| gotoStmt=goto_statement
	->jumpStatement(stmt={gotoStmt})
	| retStmt=return_statement
	->jumpStatement(stmt={retStmt})
	| thrwStmt=throw_statement
	->jumpStatement(stmt={thrwStmt})
	;
break_statement 
	: 
	brk=BREAK SEMICOLON (comts=comments)?
	->breakStatement(value={$brk.text+";"},comments={comts})
	;
continue_statement 
	: 
	cont=CONTINUE SEMICOLON (comts=comments)?
	->continueStatement(value={$cont.text+";"},comments={comts})
	;
goto_statement 
	: 
	GOTO id=IDENTIFIER SEMICOLON (comts1=comments)?
	->simpleGotoStatement(labelName={$id.text},comments={comts1})
	| GOTO CASE expr=constant_expression SEMICOLON (comts2=comments)?
	->gotoCaseStmt(caseExpr={expr},comments={comts2})
	| GOTO DEFAULT SEMICOLON (comts3=comments)?
	->gotoDefaultStmt(comments={comts3})
	;
return_statement 
	: 
	RETURN (expr=expression)? SEMICOLON (comts=comments)?
	->returnStatement(returnExpr={expr},comments={comts})
	;
throw_statement 
	: 
	THROW (expr=expression)? SEMICOLON (comts=comments)?
	->throwStatement(throwExpr={$expr.st.toString().trim()},comments={comts})
	;
/*
try_statement 
	: TRY block catch_clauses
	| TRY block finally_clause
	| TRY block catch_clauses finally_clause
	;
*/
try_statement 
  : 
  TRY bdy=block (cmnt=comments)? (cls=catch_clauses)? (finly=finally_clause)?
  ->tryStatement(tryBody={bdy},cmnts={cmnt},catchClas={cls},finallyBlk={finly})
  ;
/*
catch_clauses 
	: specific_catch_clauses general_catch_clause?
	| specific_catch_clauses? general_catch_clause
	;
*/

catch_clauses 
  : 
  spCtch=specific_catch_clauses (gnrlCtch=general_catch_clause)?
  ->catchClauses(specificCatch={spCtch},generalCatch={gnrlCtch})
  | ctch=general_catch_clause
  ->catchClauses2(catchCls={ctch})
  ;
  
specific_catch_clauses 
	:(spccatch=specific_catch_clause)+
	->specificCatchClauses(clauses={spccatch})
	;
specific_catch_clause 
	: CATCH OPEN_PARENS clstype=class_type (tname=IDENTIFIER)? CLOSE_PARENS blk=block
	->specificCatchClause(classtype={clstype},typeName={$tname.text},body={blk})
	;
general_catch_clause 
  : 
  CATCH blk=block
  ->generalCatchClause(body={blk})
  ;
finally_clause 
  : 
  FINALLY blk=block
  ->finallyClause(body={blk})
  ;
checked_statement 
	: CHECKED block
	;
unchecked_statement 
	: UNCHECKED block
	;
lock_statement 
	: LOCK OPEN_PARENS expression CLOSE_PARENS embedded_statement
	;
using_statement 
	: 
	kwd=USING OPEN_PARENS raq=resource_acquisition CLOSE_PARENS bdy=embedded_statement
	->usingStatement(resourceAcq={$raq.text},body={$bdy.text})
	;
/*
resource_acquisition 
	: local_variable_declaration
	| expression
	;
*/
resource_acquisition 
	: 
	(local_variable_declaration) => lvd=local_variable_declaration
	->resourceAcquisition(stmt={lvd})
	| expr=expression
	->resourceAcquisition(stmt={expr})
	;
yield_statement 
	: key=yield_contextual_keyword RETURN exp=expression SEMICOLON
	->yieldstatement(yieldkey={key},expr={exp})
	| key1=yield_contextual_keyword BREAK SEMICOLON
	->yieldstatement1(yieldkey={key1})
	;

// not used anymore; we use namespace_member_declaration+ directly

//B.2.6 Namespaces;
// entry point/ start rule
/*
compilation_unit 
	: extern_alias_directives? using_directives? namespace_member_declarations? global_attribute_sections? EOF
	;
*/
compilation_unit 
  : 
  (adtvs=extern_alias_directives)? (imprtStmts=using_directives)?
    ( ((global_attribute_section) => glbAttSec=global_attribute_section) )*
    (nspcmems=namespace_member_declarations)? EOF
    ->writeCompUnit(alisDRctv={adtvs},imports={imprtStmts},gas={glbAttSec},nmspMemDec={nspcmems})
  ;
namespace_declaration 
	: NAMESPACE qi=qualified_identifier nmsBdy=namespace_body (dl=SEMICOLON)? (comts=comments)?
	->pkgDeclarationandClassBody(packageName={""},nameSpaceBody={nmsBdy},deleimiter={dl},comments={comts})
	;
qualified_identifier 
	: 
	id1=IDENTIFIER (idChldLst+=qualified_identifier_Chld)*
	->pkgDeclChld(root={$id1.text},chldLst={$idChldLst})
	;
qualified_identifier_Chld
  :
  DOT  id=IDENTIFIER
  ->text(value={"."+NamingUtil.toCamelCase($id.text)})
  ;
  	
namespace_body 
	:
	OPEN_BRACE (cmnts=comments)? (alsDct=extern_alias_directives)? (imps=using_directives)? (nspcmems=namespace_member_declarations)? CLOSE_BRACE
	->createClassBody(cmnt={cmnts},alisDRctv={alsDct},imports={imps},nmspMemDec={nspcmems})
	;
extern_alias_directives 
	: 
	(extrnLst+=extern_alias_directive)+
	->lineIterator(list={$extrnLst})
	;
extern_alias_directive 
	: 
	EXTERN alias_contextual_keyword IDENTIFIER SEMICOLON
	->text(value={"//TODO Extern alias directive"})
	;
using_directives 
	: 
	(dirLst+=using_directive)+
	->importStmts(lstImports={$dirLst})
	;
using_directive 
	: 
	usngalsDrctv=using_alias_directive          ->text(value={$usngalsDrctv.text})
	|usngnmsDrctv=using_namespace_directive     ->text(value={usngnmsDrctv})
	;
using_alias_directive 
	: 
	USING IDENTIFIER ASSIGNMENT namespace_or_type_name SEMICOLON
	->text(value={"//TODO Using alias directive"})
	;
using_namespace_directive 
	: 
	USING pkgName=namespace_name SEMICOLON (comts=comments)?
	->importStmt(packName={$pkgName.text},comments={comts})
	;
namespace_member_declarations 
	: 
	(nameSpaceMemLst+=namespace_member_declaration)+
	->lineIterator(list={CSharpHelper.filterOriginalMember($nameSpaceMemLst)})
	;
namespace_member_declaration 
	: 
	nmsDec=namespace_declaration          ->text(value={nmsDec})
	|typeDec=type_declaration             ->text(value={typeDec})
	;
/*
type_declaration 
	: class_declaration
	| struct_declaration
	| interface_declaration
	| enum_declaration
	| delegate_declaration
	;
*/
/*type_declaration 
  : 
  attributes? (accModfs1=all_member_modifiers)? classDef= class_definition
	->typeDeclaration(text={""},bodyDefintion={classDef})
	|attributes? (accModfs2=all_member_modifiers)? structDef= struct_definition
  ->typeDeclaration(accessModifiers={$accModfs2.text},bodyDefintion={structDef})
  |attributes? (accModfs3=all_member_modifiers)? interfaceDef= interface_definition
  ->typeDeclaration(accessModifiers={$accModfs3.text},bodyDefintion={interfaceDef})
  |attributes? (accModfs4=all_member_modifiers)? enumDef= enum_definition
  ->typeDeclaration(accessModifiers={$accModfs4.text},bodyDefintion={enumDef})
   |attributes? (accModfs5=all_member_modifiers)? delegateDef= delegate_definition
  ->typeDeclaration(accessModifiers={$accModfs5.text},bodyDefintion={delegateDef})
  ;
  */
type_declaration 
  : 
  (at=attributes)? (comts=comments)? (accModfs=all_member_modifiers)? chld= type_declaration_Chld
  ->typeDeclaration(attributes={at},comments={comts},accessModifiers={accModfs},bodyDefintion={chld})
  ;
  
type_declaration_Chld
  :
  classDef= class_definition
  ->typeDeclarationChld(decl={classDef})
  |structDef= struct_definition
  ->typeDeclarationChld(decl={structDef})
  |interfaceDef= interface_definition
  ->typeDeclarationChld(decl={interfaceDef})
  |enumDef= enum_definition
  ->typeDeclarationChld(decl={enumDef})
  |delegateDef= delegate_definition
  ->typeDeclarationChld(decl={delegateDef})
  ;
/** starts with IDENTIFIER DOUBLE_COLON */
//Child Rule
qualified_alias_member 
	: 
	rlNm=IDENTIFIER DOUBLE_COLON alsNam=IDENTIFIER tal=type_argument_list_opt
	->qualifiedAliasMember(actName={rlNm},aliasName={alsNam},argList={tal})
	;

//B.2.7 Classes;
// not used anymore
class_declaration 
	: attributes? class_modifiers? partial_contextual_keyword? CLASS IDENTIFIER type_parameter_list?
	    class_base? type_parameter_constraints_clauses? class_body SEMICOLON?
	;
class_modifiers 
	: class_modifier ( class_modifier )*
	;
class_modifier 
	:       
		NEW                                    ->text(value={$NEW.text})
	 | PUBLIC                               ->text(value={$PUBLIC.text})
	 | PROTECTED                            ->text(value={$PROTECTED.text})
	 | INTERNAL                             ->text(value={$INTERNAL.text})
	 | PRIVATE                              ->text(value={$PRIVATE.text})
	 | ABSTRACT                             ->text(value={$ABSTRACT.text})
	 | SEALED                               ->text(value={$SEALED.text})
	 | STATIC                               ->text(value={$STATIC.text})
	 | cmu=class_modifier_unsafe            ->text(value={cmu})
	;
type_parameter_list 
	: 
	LT lst=type_parameters GT
	->typeParameterList(paramList={"<"+$lst.st.toString().trim()+">"})
	;
type_parameters 
	: 
	(at=attributes)? tp=type_parameter ( chld+=type_parameters_Chld )*
	->typeParameters(attr={at},type={tp},chldList={$chld})
	;

type_parameters_Chld
	:
  COMMA  (attr=attributes)?  par=type_parameter
  ->typeParametersChld(attribytes={attr},param={par})
  ;	
/** IDENTIFIER */
type_parameter 
	: 
	IDENTIFIER       ->text(value={$IDENTIFIER.text})
	;
/*
class_base 
	: COLON class_type
	| COLON interface_type_list
	| COLON class_type COMMA interface_type_list
	;
*/
// class_type includes interface_type
class_base 
  : 
  COLON cType=class_type (clsInfChldLst+=classbaseandInterfaceChld)*
  ->text(value={""})
  ;
  
interface_type_list 
	: 
	iType=interface_type (clsInfChldLst+=classbaseandInterfaceChld)*
	->interfacetypelist(val1={$iType.text},val2={$clsInfChldLst})
	;
	
classbaseandInterfaceChld
  :
  COMMA  intFaceName=interface_type 
  ->text(value={","+$intFaceName.text})
  ;
	
type_parameter_constraints_clauses 
	: (clauses=type_parameter_constraints_clause)+
	->typeparameterconstraintsclauses(tclauses={clauses})
	;
type_parameter_constraints_clause 
	: wkey=where_contextual_keyword tparam=type_parameter COLON tcons=type_parameter_constraints
	->typeparameterconstraintsclause(wkeyword={wkey},typaram={tparam},tpcons={tcons})
	;
/*
type_parameter_constraints 
	: primary_constraint
	| secondary_constraints
	| constructor_constraint
	| primary_constraint COMMA secondary_constraints
	| primary_constraint COMMA constructor_constraint
	| secondary_constraints COMMA constructor_constraint
	| primary_constraint COMMA secondary_constraints COMMA constructor_constraint
	;
*/
type_parameter_constraints 
  : constructor_constraint
  | pri=primary_constraint (COMMA secondary_constraints)? (COMMA constructor_constraint)?
  ->typeparameterconstraints(prim={pri})
  ;
primary_constraint 
	:        
	clstyp=class_type      ->text(value={clstyp})
 | CLASS                ->text(value={$CLASS.text})
 | STRUCT               ->text(value={$STRUCT.text})
	;
/**
secondary_constraints 
	: interface_type
	| type_parameter
	| secondary_constraints COMMA interface_type
	| secondary_constraints COMMA type_parameter
	;
*/
// interface_type includes type_parameter
secondary_constraints
  : interface_type (COMMA interface_type)*
  ;
constructor_constraint 
	: NEW OPEN_PARENS CLOSE_PARENS
	;
class_body 
	: 
	OPEN_BRACE  (clsMemDecs=class_member_declarations)?  CLOSE_BRACE
	->classBody(classMemdeclarations={clsMemDecs})
	;
class_member_declarations 
	: 
	(clsmemDecLst+=class_member_declaration)+
	->classMemberDeclarations(classMembersList={$clsmemDecLst},className={CSharpAngularHelper.classNameDataUpdater(getClassName())})
	;
/*
class_member_declaration 
	: constant_declaration
	| field_declaration
	| method_declaration
	| property_declaration
	| event_declaration
	| indexer_declaration
	| operator_declaration
	| constructor_declaration
	| destructor_declaration
	| static_constructor_declaration
	| type_declaration
	;
*/
class_member_declaration 
  : 
  (attrs1=attributes)? (acsModfrs1=all_member_modifiers)? cmd=common_member_declaration
	->classMemberDeclaration(attributes={attrs1},accessModifiers={acsModfrs1},comMemDec={cmd})
	|(attrs2=attributes)? (acsModfrs2=all_member_modifiers)? TILDE IDENTIFIER OPEN_PARENS CLOSE_PARENS destructor_body
  ->classMemberDeclaration(attributes={attrs2},accessModifiers={acsModfrs1})
  ;
// added by chw
// combines all available modifiers
all_member_modifiers
  : 
  (m+=all_member_modifier)+
  ->text(value={""})
  ;
all_member_modifier
  : 
  accsMod1=NEW
  ->allMemberModifier(value={$accsMod1.text})
  | accsMod2=PUBLIC
  ->allMemberModifier(value={$accsMod2.text})
  | accsMod3=PROTECTED
  ->allMemberModifier(value={$accsMod3.text})
  | accsMod4=INTERNAL
  ->allMemberModifier(value={$accsMod4.text})
  | accsMod5=PRIVATE
  ->allMemberModifier(value={$accsMod5.text})
  | accsMod6=READONLY
  ->allMemberModifier(value={$accsMod6.text})
  | accsMod7=VOLATILE
  ->allMemberModifier(value={$accsMod7.text})
  | accsMod8=VIRTUAL
  ->allMemberModifier(value={$accsMod8.text})
  | accsMod9=SEALED
  ->allMemberModifier(value={$accsMod9.text})
  | accsMod10=OVERRIDE
  ->allMemberModifier(value={$accsMod10.text})
  | accsMod11=ABSTRACT
  ->allMemberModifier(value={$accsMod11.text})
  | accsMod12=STATIC
  ->allMemberModifier(value={$accsMod12.text})
  | accsMod13=UNSAFE
  ->allMemberModifier(value={$accsMod13.text})
  | accsMod14=EXTERN
  ->allMemberModifier(value={$accsMod14.text})
  | pck=partial_contextual_keyword
  ->allMemberModifier(value={pck})
  ;
/** represents the intersection of struct_member_declaration and class_member_declaration */
/*common_member_declaration
  : constant_declaration
  | field_declaration
  | method_declaration
  | property_declaration
  | event_declaration
  | indexer_declaration
  | operator_declaration
  | constructor_declaration
  | static_constructor_declaration
  | type_declaration
  ;
*/
// added by chw
common_member_declaration
scope {
Object type;
}
  : 
  coms=comments
  ->commonMemberDeclaration(arg1={null},arg2={coms})
  |constDedcl=constant_declaration2
  ->commonMemberDeclaration(arg1={null},arg2={constDedcl})
  | typMemDecl=typed_member_declaration
  ->commonMemberDeclaration(arg1={null},arg2={typMemDecl})
  | evntDecl=event_declaration2
  ->commonMemberDeclaration(arg1={null},arg2={evntDecl})
  | convOprtDecl=conversion_operator_declarator oprtrBdy=operator_body
  ->commonMemberDeclaration(arg1={convOprtDecl},arg2={oprtrBdy})
  | conDec2=constructor_declaration2
  ->commonMemberDeclaration(arg1={null},arg2={conDec2})
  | typVoid=type_void   methdDecl=method_declaration2  // we use type_void instead of VOID to switch rules
  ->commonMemberDeclaration(arg1={typVoid},arg2={methdDecl})
  | clsDef=class_definition
  ->commonMemberDeclaration(arg1={null},arg2={clsDef})
  | strtDef=struct_definition
  ->commonMemberDeclaration(arg1={null},arg2={strtDef})
  | infcDecl=interface_definition
  ->commonMemberDeclaration(arg1={null},arg2={infcDecl})
  | enumDef=enum_definition
  ->commonMemberDeclaration(arg1={null},arg2={enumDef})
  | delgDef=delegate_definition
  ->commonMemberDeclaration(arg1={null},arg2={delgDef})
  ;
// added by chw

typed_member_declaration
  : 
  t=type {$common_member_declaration::type = $type.tree;} bdy=typed_member_declaration_Chld
  ->typedMemberDeclaration(type={"var"},body={bdy})
  ;
typed_member_declaration_Chld
  :
    (interface_type DOT THIS) => interface_type DOT indexerDecl=indexer_declaration2
    ->typedMemberDeclarationChld(declaration={indexerDecl})
    | (member_name type_parameter_list? OPEN_PARENS) => methdDec=method_declaration2
    ->typedMemberDeclarationChld(declaration={methdDec})
    | (member_name OPEN_BRACE) => propDecl=property_declaration2
    ->typedMemberDeclarationChld(declaration={propDecl})
    | indDecl=indexer_declaration2
    ->typedMemberDeclarationChld(declaration={indDecl})
    | optrDecl=operator_declaration2
    ->typedMemberDeclarationChld(declaration={optrDecl})
    | fldDecl=field_declaration2
    ->typedMemberDeclarationChld(declaration={fldDecl})
  ;

//typed_member_declaration
//
//  : 
////  t=type {$common_member_declaration::type = $type.tree;} ((member_name type_parameter_list? OPEN_PARENS)=> method_declaration2)
////  ->typedMemberDeclaration(type={t},body={methdDecl})
//    t=type {$common_member_declaration::type = $type.tree;} methdDecl=method_declaration2
//  ->typedMemberDeclaration(type={t},body={methdDecl})
//   |t=type {$common_member_declaration::type = $type.tree;} methdDecl=member_name
//  ->typedMemberDeclaration(type={t},body={methdDecl})
//  
//  ;
/*
constant_declaration 
	: attributes? constant_modifiers? CONST type constant_declarators SEMICOLON
	;
constant_modifiers 
	: constant_modifier+
	;
constant_modifier 
	: NEW
	| PUBLIC
	| PROTECTED
	| INTERNAL
	| PRIVATE
	;
*/
constant_declarators 
	: 
	fstDec=constant_declarator ( conDecLst+=constant_declarators_Chld)*
	->constantDeclarators(firstDecl={fstDec},list={$conDecLst})
	;
constant_declarators_Chld
  :
  COMMA  conDec=constant_declarator
  ->constantDeclaratorsChld(constDecl={conDec})
  ;
   	
constant_declarator 
	: IDENTIFIER ASSIGNMENT constexpr=constant_expression
	->constantDeclarator(constexpr={constexpr})
	;
/* not used anymore;
field_declaration 
	: attributes? field_modifiers? type variable_declarators SEMICOLON
	;
field_modifiers 
	: field_modifier ( field_modifier )*
	;
field_modifier 
	: NEW
	| PUBLIC
	| PROTECTED
	| INTERNAL
	| PRIVATE
	| STATIC
	| READONLY
	| VOLATILE
	| field_modifier_unsafe
	;
*/
/** starts with IDENTIFIER */
variable_declarators
	: 
	fstDec=variable_declarator (  lst+=variable_declarators_Chld)*
	->variableDeclarators(firstDecl={fstDec},list={$lst})
	;

variable_declarators_Chld
  :
  COMMA  vd=variable_declarator
  ->variableDeclaratorsChld(decl={vd})
  ;
	
variable_declarator 
	: 
	IDENTIFIER
	->variableDeclarator(value={NamingUtil.toCamelCase($IDENTIFIER.text)})
	| IDENTIFIER ASSIGNMENT rside=variable_initializer
	->variableDeclarator2(lhs={NamingUtil.toCamelCase($IDENTIFIER.text)},rhs={rside})
	;
variable_initializer 
	: 
	vi1=expression
	->variableInitializer(init={$vi1.text})
	| vi2=array_initializer
	->variableInitializer(init={vi2})
	;
method_declaration 
	: method_header method_body
	;
method_header 
	: attributes? method_modifiers? partial_contextual_keyword? return_type member_name type_parameter_list? OPEN_PARENS formal_parameter_list? CLOSE_PARENS type_parameter_constraints_clauses?
	;
method_modifiers 
	: method_modifier+
	;
method_modifier 
	: NEW
	| PUBLIC
	| PROTECTED
	| INTERNAL
	| PRIVATE
	| STATIC
	| VIRTUAL
	| SEALED
	| OVERRIDE
	| ABSTRACT
	| EXTERN
	| method_modifier_unsafe
	;
/** type | VOID */
return_type 
	: type
	| VOID
	;
/*
member_name 
	: IDENTIFIER
	| interface_type DOT IDENTIFIER
	;
*/
/** interface_type */
member_name 
  : 
  intFTyp=interface_type
  ->memberName(type={intFTyp})
  ;
method_body 
	: 
	blk=block 
	->methodBody(body={blk})
	| scln=SEMICOLON (comts2=comments)?
	->methodBody(body={$scln.text},comments={comts2})
	;
/*
formal_parameter_list 
	: fixed_parameters
	| fixed_parameters COMMA parameter_array
	| parameter_array
	;
*/
formal_parameter_list 
  : 
  (attributes? PARAMS) => parArr=parameter_array
  ->formalParameterList(fixedParams={null},list={parArr})
  | fp=fixed_parameters ( list=formal_parameter_list_Chld)?
  ->formalParameterList(fixedParams={fp},list={parArr})
  ;
  
formal_parameter_list_Chld
  :
  (COMMA parameter_array) => COMMA arr=parameter_array
  ->formalParameterListChld(params={arr})
  ;
fixed_parameters 
	: 
	fp=fixed_parameter ( fpLst+=fixed_parameters_Chld )*
	->fixedParameters(firstParam={fp},list={$fpLst})
	;
	
fixed_parameters_Chld
	:
	(COMMA fixed_parameter) => COMMA fixParam=fixed_parameter
	->fixedParametersChld(param={fixParam})
	;
/*
fixed_parameter 
  : attributes? parameter_modifier? type IDENTIFIER default_argument?
  ;
*/
// TODO add | '__arglist' etc.
fixed_parameter
  : 
  (at=attributes)? (parModf=parameter_modifier)?  fixed=fixed_parameter_child (defArg=default_argument)?
  ->fixedParameter(attributes={at},paramModifier={parModf},fixedparam={fixed},defaultArgs={defArg})
  | arLst=arglist
  ->fixedParameter2(argumentList={arLst})
  ;
  
fixed_parameter_child
  :
  par=parameter_array 
  ->fixedparameterchild(pararray={par})
  |t=type parNam=IDENTIFIER
  ->fixedparameterchild1(dataType={t},paramName={NamingUtil.toCamelCase($parNam.text)})
  ;
  
default_argument 
	: 
	ASSIGNMENT expn=expression
	->defaultargument(expns={expn})
	;
	
parameter_modifier 
	: 
	REF          ->text(value={$REF.text})
	| OUT        ->text(value={$OUT.text})
	| THIS       ->text(value={$THIS.text})
	;
parameter_array 
	: 
	(atrs=attributes)? par=PARAMS arr=array_type id=IDENTIFIER
	->parameterArray(atbts={atrs},param={$par.text},type={arr},idName={NamingUtil.toCamelCase($id.text)})
	;
property_declaration 
	: 
	(attr=attributes)? (modfs=property_modifiers)? t=type mname=member_name OPEN_BRACE acDecls=accessor_declarations CLOSE_BRACE
	->propertyDeclaration(attributes={attr},propModfs={modfs},typ={t},memName={mname},accessDecls={acDecls})
	;
property_modifiers 
	: 
	(lst+=property_modifier)+
	->propertyModifiers(list={$lst})
	;
property_modifier 
	: 
  NEW                                   ->text(value={$NEW.text})
  | PUBLIC                              ->text(value={$PUBLIC.text})
  | PROTECTED                           ->text(value={$PROTECTED.text})
  | INTERNAL                            ->text(value={$INTERNAL.text})
  | PRIVATE                             ->text(value={$PRIVATE.text})
  | STATIC                              ->text(value={$STATIC.text})
  | VIRTUAL                             ->text(value={$VIRTUAL.text})
  | SEALED                              ->text(value={$SEALED.text})
  | OVERRIDE                            ->text(value={$OVERRIDE.text})
  | ABSTRACT                            ->text(value={$ABSTRACT.text})
  | EXTERN                              ->text(value={$EXTERN.text})
  | pmod=property_modifier_unsafe       ->text(value={pmod})
	;
/*
accessor_declarations 
	: get_accessor_declaration set_accessor_declaration?
	| set_accessor_declaration get_accessor_declaration?
	;
*/
accessor_declarations 
  : 
  (attrs1=attributes)? (mods1=accessor_modifier)?  gck1=get_contextual_keyword aBdy1=accessor_body (sck1=set_accessor_declaration)?
  ->accessorDeclarations(attributes={attrs1},acsModfs={mods1},body={aBdy1},ck1={gck1},ck2={sck1}) 
  |(attrs2=attributes)? (mods2=accessor_modifier)? sck2=set_contextual_keyword aBdy2=accessor_body (gck2=get_accessor_declaration)? 
  ->accessorDeclarations(attributes={attrs2},acsModfs={mods2},body={aBdy2},ck1={sck2},ck2={gck2}) 
  ;
get_accessor_declaration 
	: 
	(at=attributes)? (am=accessor_modifier)? gck=get_contextual_keyword ab=accessor_body
	->getAccessorDeclaration(attrs={at},accsModfs={am},ck={gck},body={ab})
	;
set_accessor_declaration 
	: 
	(at=attributes)? (am=accessor_modifier)? sck=set_contextual_keyword ab=accessor_body
	->setAccessorDeclaration(attrs={at},accsModfs={am},ck={sck},body={ab})
	;
accessor_modifier 
	: 
	PROTECTED                ->text(value={$PROTECTED.text})
 | INTERNAL               ->text(value={$INTERNAL.text})
 | PRIVATE                ->text(value={$PRIVATE.text})
 | PROTECTED INTERNAL     ->text(value={$PROTECTED.text+" "+$INTERNAL.text})
 | INTERNAL PROTECTED     ->text(value={$INTERNAL.text+" "+$PROTECTED.text})
	;
accessor_body 
	: 
	blk=block
	->accessorBody(body={blk})
	| SEMICOLON
	->text(value={$SEMICOLON.text})
	;
/*
event_declaration 
	: attributes? event_modifiers? EVENT type variable_declarators SEMICOLON
	| attributes? event_modifiers? EVENT type member_name OPEN_BRACE event_accessor_declarations CLOSE_BRACE
	;
*/
event_declaration 
  : attributes? event_modifiers? EVENT type
    ( variable_declarators SEMICOLON
    | member_name OPEN_BRACE event_accessor_declarations CLOSE_BRACE
    )
  ;
event_modifiers 
	: event_modifier ( event_modifier )*
	;
event_modifier 
	: NEW                                ->text(value={$NEW.text})
   | PUBLIC                           ->text(value={$PUBLIC.text})
   | PROTECTED                        ->text(value={$PROTECTED.text})
   | INTERNAL                         ->text(value={$INTERNAL.text})
   | PRIVATE                          ->text(value={$PRIVATE.text})
   | STATIC                           ->text(value={$STATIC.text})
   | VIRTUAL                          ->text(value={$VIRTUAL.text})
   | SEALED                           ->text(value={$SEALED.text})
   | OVERRIDE                         ->text(value={$OVERRIDE.text})
   | ABSTRACT                         ->text(value={$ABSTRACT.text})
   | EXTERN                           ->text(value={$EXTERN.text})
   | evntmod=event_modifier_unsafe    ->text(value={evntmod})
	;
event_accessor_declarations 
	: attributes?
	  ( add_contextual_keyword block remove_accessor_declaration
	  | remove_contextual_keyword block add_accessor_declaration
	  )
	;
add_accessor_declaration 
	: attributes? add_contextual_keyword block
	;
remove_accessor_declaration 
	: attributes? remove_contextual_keyword block
	;
indexer_declaration 
	: attributes? indexer_modifiers? indexer_declarator OPEN_BRACE accessor_declarations CLOSE_BRACE
	;
indexer_modifiers 
	: indexer_modifier ( indexer_modifier )*
	;
indexer_modifier 
	:        
	NEW                                    ->text(value={$NEW.text})
	| PUBLIC                               ->text(value={$PUBLIC.text})
	| PROTECTED                            ->text(value={$PROTECTED.text})
	| INTERNAL                             ->text(value={$INTERNAL.text})
	| PRIVATE                              ->text(value={$PRIVATE.text})
	| VIRTUAL                              ->text(value={$VIRTUAL.text})
	| SEALED                               ->text(value={$SEALED.text})
	| OVERRIDE                             ->text(value={$OVERRIDE.text})
	| ABSTRACT                             ->text(value={$ABSTRACT.text})
	| EXTERN                               ->text(value={$EXTERN.text})
	| indmod=indexer_modifier_unsafe       ->text(value={indmod})
	;
/*
indexer_declarator 
	: type THIS OPEN_BRACKET formal_parameter_list CLOSE_BRACKET
	| type interface_type DOT THIS OPEN_BRACKET formal_parameter_list CLOSE_BRACKET
	;
*/
indexer_declarator 
  : type (interface_type DOT)? THIS OPEN_BRACKET formal_parameter_list CLOSE_BRACKET
  ;
operator_declaration 
	: attributes? operator_modifiers operator_declarator operator_body
	;
operator_modifiers 
	: operator_modifier ( operator_modifier )*
	;
operator_modifier 
  : 
  PUBLIC                                ->text(value={$PUBLIC.text})
  | STATIC                              ->text(value={$STATIC.text})
  | EXTERN                              ->text(value={$EXTERN.text})
  | oprmod=operator_modifier_unsafe     ->text(value={oprmod})
  ;

/*
operator_declarator 
	: unary_operator_declarator
	| binary_operator_declarator
	| conversion_operator_declarator
	;
*/
operator_declarator 
  : (unary_operator_declarator) => unary_operator_declarator
  | binary_operator_declarator
  | conversion_operator_declarator
  ;
unary_operator_declarator 
	: type OPERATOR overloadable_unary_operator OPEN_PARENS type IDENTIFIER CLOSE_PARENS
	;
overloadable_unary_operator 
  : 
  PLUS            ->text(value={$PLUS.text})
  | MINUS         ->text(value={$MINUS.text})
  | BANG          ->text(value={$BANG.text})
  | TILDE         ->text(value={$TILDE.text})
  | OP_INC        ->text(value={$OP_INC.text})
  | OP_DEC        ->text(value={$OP_DEC.text})
  | TRUE          ->text(value={$TRUE.text})
  | FALSE         ->text(value={$FALSE.text})
  ;

binary_operator_declarator 
	: type OPERATOR overloadable_binary_operator OPEN_PARENS type IDENTIFIER COMMA type IDENTIFIER CLOSE_PARENS
	;
overloadable_binary_operator 
   : 
   PLUS                    ->text(value={$PLUS.text})
   | MINUS                 ->text(value={$MINUS.text})
   | STAR                  ->text(value={$STAR.text})
   | DIV                   ->text(value={$DIV.text})
   | PERCENT               ->text(value={$PERCENT.text})
   | AMP                   ->text(value={$AMP.text})
   | BITWISE_OR            ->text(value={$BITWISE_OR.text})
   | CARET                 ->text(value={$CARET.text})
   | OP_LEFT_SHIFT         ->text(value={$OP_LEFT_SHIFT.text})
   | rst=right_shift       ->text(value={rst})
   | OP_EQ                 ->text(value={$OP_EQ.text})
   | OP_NE                 ->text(value={$OP_NE.text})
   | GT                    ->text(value={$GT.text})
   | LT                    ->text(value={$LT.text})
   | OP_GE                 ->text(value={$OP_GE.text})
   | OP_LE                 ->text(value={$OP_LE.text})
   ;

// added by chw
/** includes the unary and the binary operators */
overloadable_operator
  : PLUS                    ->text(value={$PLUS.text})
  | MINUS                   ->text(value={$MINUS.text})
  | BANG                    ->text(value={$BANG.text})
  | TILDE                   ->text(value={$TILDE.text})
  | OP_INC                  ->text(value={$OP_INC.text})
  | OP_DEC                  ->text(value={$OP_DEC.text})
  | TRUE                    ->text(value={$TRUE.text})
  | FALSE                   ->text(value={$FALSE.text})
  | STAR                    ->text(value={$STAR.text})
  | DIV                     ->text(value={$DIV.text})
  | PERCENT                 ->text(value={$PERCENT.text})
  | AMP                     ->text(value={$AMP.text})
  | BITWISE_OR              ->text(value={$BITWISE_OR.text})
  | CARET                   ->text(value={$CARET.text})
  | OP_LEFT_SHIFT           ->text(value={$OP_LEFT_SHIFT.text})
  | rst=right_shift         ->text(value={rst})
  | OP_EQ                   ->text(value={$OP_EQ.text})
  | OP_NE                   ->text(value={$OP_NE.text})
  | GT                      ->text(value={$GT.text})
  | LT                      ->text(value={$LT.text})
  | OP_GE                   ->text(value={$OP_GE.text})
  | OP_LE                   ->text(value={$OP_LE.text})
  ;

/** starts with IMPLICIT or EXPLICIT */
conversion_operator_declarator
	: IMPLICIT OPERATOR type OPEN_PARENS type IDENTIFIER CLOSE_PARENS
	| EXPLICIT OPERATOR type OPEN_PARENS type IDENTIFIER CLOSE_PARENS
	;
operator_body 
   : 
   blk=block       ->text(value={blk})
   | SEMICOLON     ->text(value={$SEMICOLON.text})
   ;

constructor_declaration 
	: attributes? constructor_modifiers? constructor_declarator constructor_body
	;
constructor_modifiers 
	: constructor_modifier+
	;
constructor_modifier 
  : 
  PUBLIC                                    ->text(value={$PUBLIC.text})
  | PROTECTED                               ->text(value={$PROTECTED.text})
  | INTERNAL                                ->text(value={$INTERNAL.text})
  | PRIVATE                                 ->text(value={$PRIVATE.text})
  | EXTERN                                  ->text(value={$EXTERN.text})
  | consmd=constructor_modifier_unsafe      ->text(value={consmd})
  ;
constructor_declarator 
	: IDENTIFIER OPEN_PARENS formal_parameter_list? CLOSE_PARENS constructor_initializer?
	;
constructor_initializer 
  : 
  COLON BASE OPEN_PARENS (al=argument_list)? CLOSE_PARENS
  ->constructorInitializer(kwd={$BASE.text},argList={al})
  | COLON THIS OPEN_PARENS argument_list? CLOSE_PARENS
  ->constructorInitializer(kwd={$THIS.text},argList={al})
  ;
  
constructor_body 
  : 
  blk=block          ->text(value={blk})
  | SEMICOLON        ->text(value={$SEMICOLON.text})
  ;

static_constructor_declaration 
	: attributes? static_constructor_modifiers IDENTIFIER OPEN_PARENS CLOSE_PARENS static_constructor_body
	;
/*
static_constructor_modifiers 
	: EXTERN? STATIC
	| STATIC EXTERN?
	| static_constructor_modifiers_unsafe
	;
*/
static_constructor_modifiers 
  : static_constructor_modifiers_unsafe
  ;
static_constructor_body 
   : 
   blk=block          ->text(value={blk})
   | SEMICOLON        ->text(value={$SEMICOLON.text})
   ;

/*
destructor_declaration 
	: attributes? EXTERN? TILDE IDENTIFIER OPEN_PARENS CLOSE_PARENS destructor_body
	| destructor_declaration_unsafe
	;
*/
destructor_declaration 
	: destructor_declaration_unsafe
	;
destructor_body 
  : 
  blk=block          ->text(value={blk})
  | SEMICOLON        ->text(value={$SEMICOLON.text})
  ;

// added by chw
body
  : 
  bdy=block
  ->body(value={bdy})
  | empStmt=SEMICOLON
  ->body(value={$empStmt.text})
  ;

//B.2.8 Structs
struct_declaration 
	: attributes? struct_modifiers? partial_contextual_keyword? STRUCT IDENTIFIER type_parameter_list? struct_interfaces? type_parameter_constraints_clauses? struct_body SEMICOLON?
	;
struct_modifiers 
	: struct_modifier ( struct_modifier )*
	;
struct_modifier 
  : 
  NEW                                  ->text(value={$NEW.text})
  | PUBLIC                             ->text(value={$PUBLIC.text})
  | PROTECTED                          ->text(value={$PROTECTED.text})
  | INTERNAL                           ->text(value={$INTERNAL.text})
  | PRIVATE                            ->text(value={$PRIVATE.text})
  | strmod=struct_modifier_unsafe      ->text(value={strmod})
  ;

struct_interfaces 
	: COLON interface_type_list
	;
struct_body 
	: OPEN_BRACE struct_member_declarations? CLOSE_BRACE
	;
struct_member_declarations 
	: struct_member_declaration ( struct_member_declaration )*
	;
/*
struct_member_declaration 
	: constant_declaration
	| field_declaration
	| method_declaration
	| property_declaration
	| event_declaration
	| indexer_declaration
	| operator_declaration
	| constructor_declaration
	| static_constructor_declaration
	| type_declaration
	| struct_member_declaration_unsafe
	;
*/
struct_member_declaration 
	: attributes? all_member_modifiers?
		( common_member_declaration
		| FIXED buffer_element_type fixed_size_buffer_declarators SEMICOLON
		)
	;
//B.2.9 Arrays
/*
array_type 
	: non_array_type rank_specifiers
	;
*/
/** non_array_type rank_specifiers */
array_type 
	: 
	bTyp=base_type (chld+=array_type_Chld)+
	->arrayType(type={bTyp},chldLst={$chld})
	;

array_type_Chld
	:
	(st+=STAR)* rs=rank_specifier
	->arrayTypeChld(symbolLst={$st},rnkSpcr={rs})
	| (intr+=INTERR)* rns=rank_specifier
	->arrayTypeChld(symbolLst={$intr},rnkSpcr={rns})
	;
/*
non_array_type 
	: type
	;
*/
/** type */
non_array_type 
	: 
	typ1=base_type (chld1+=non_array_type_Chld)* 
	->nonArrayType(type={typ1},rankSpcr={$chld1})
	;
	
non_array_type_Chld
	:
	rs=rank_specifier
	->nonArrayTypeChld(chld={rs})
	|INTERR
	->nonArrayTypeChld(chld={""})
	|STAR
	->nonArrayTypeChld(chld={$STAR.text})
	;
/*
rank_specifiers 
	: rank_specifier ( rank_specifier )*
	;
*/
/** starts with OPEN_BRACKET */
rank_specifiers 
  : 
  (rnkspLst+=rank_specifier)+
  ->lineIterator(value={$rnkspLst})
  ;
/** OPEN_BRACKET dim_separators? CLOSE_BRACKET */
//Child Rule
rank_specifier 
	: 
	OPEN_BRACKET (sep=dim_separators)? CLOSE_BRACKET
	->rankSpecifier(separatorLst={sep})
	;
dim_separators 
	: 
	COMMA (lst+=dim_separators_Chld)*
	->dimSeparators(list={$lst})
	;
	
dim_separators_Chld
	:
  COMMA 
  ->text(value={$COMMA.text})
  ;	
/*
array_initializer 
	: OPEN_BRACE variable_initializer_list? CLOSE_BRACE
	| OPEN_BRACE variable_initializer_list COMMA CLOSE_BRACE
	;
*/
/** starts with OPEN_BRACE */
array_initializer 
  : 
  OPEN_BRACE CLOSE_BRACE
  ->text(value={"[]"})
  | OPEN_BRACE vil=variable_initializer_list COMMA? CLOSE_BRACE
  ->arrayInitializer(varInitList={vil})
  ;
variable_initializer_list 
	: 
	vini=variable_initializer (varLst+=variable_initializer_list_Chld)*
	->variableInitializerList(varIni={vini},list={$varLst})
	;
	
variable_initializer_list_Chld
	:
	COMMA  vrinit=variable_initializer
	->variableInitializerListChld(init={vrinit})
	;
//B.2.10 Interfaces
interface_declaration 
	: attributes? interface_modifiers? partial_contextual_keyword? INTERFACE IDENTIFIER variant_type_parameter_list? interface_base? type_parameter_constraints_clauses? interface_body SEMICOLON?
	;
interface_modifiers 
	: interface_modifier ( interface_modifier )*
	;
interface_modifier 
  : 
  NEW                                     ->text(value={$NEW.text})
  | PUBLIC                                ->text(value={$PUBLIC.text})
  | PROTECTED                             ->text(value={$PROTECTED.text})
  | INTERNAL                              ->text(value={$INTERNAL.text})
  | PRIVATE                               ->text(value={$PRIVATE.text})
  | intrmod=interface_modifier_unsafe     ->text(value={intrmod})
  ;

variant_type_parameter_list 
	: LT variant_type_parameters GT
	;
variant_type_parameters 
	: attributes? variance_annotation? type_parameter ( COMMA  attributes?  variance_annotation?  type_parameter )*
	;
variance_annotation 
  : 
  IN          ->text(value={$IN.text})
  | OUT       ->text(value={$OUT.text})
  ;

interface_base 
  : 
  COLON itl=interface_type_list
  ->interfaceBase(intfcTypLst={itl})
  ;
interface_body 
  : 
  OPEN_BRACE (cmnts=comments)? (imd=interface_member_declarations)? CLOSE_BRACE
  ->interfaceBody(members={imd},cmnt={cmnts})
  ;
interface_member_declarations 
  : 
  (lst+=interface_member_declaration)+
  ->interfaceMemberDeclarations(list={$lst})
  ;
/*
interface_member_declaration 
	: interface_method_declaration
	| interface_property_declaration
	| interface_event_declaration
	| interface_indexer_declaration
	;
*/
 
interface_member_declaration 
  : 
  (cmnt=comments)? (at=attributes)? (n=NEW)? chld=interface_member_declaration_Chld (cmnt2=comments)?
  ->interfaceMemberDeclaration(cmnts={cmnt},attributes={at},newKwd={$n.text},child={chld},cmnts2={cmnt2})
  ;
interface_member_declaration_Chld
  :
  t=type  subChld=interface_member_declaration_sub_Chld
  ->interfaceMemberDeclarationChld(type={CSharpAngularHelper.replaceJavaType($t.text)},subChild={subChld})
  | VOID IDENTIFIER (tpl=type_parameter_list)? OPEN_PARENS (fpl=formal_parameter_list)? CLOSE_PARENS (tpcc=type_parameter_constraints_clauses)? SEMICOLON
  ->interfaceMemberDeclarationChld2(memNam={NamingUtil.toCamelCase($IDENTIFIER.text)},typParLst={tpl},formlParLst={fpl},typParConstCls={tpcc})
  | EVENT t=type IDENTIFIER SEMICOLON
  ->interfaceMemberDeclarationChld3(type={t}, evntName={$IDENTIFIER.text})
  ;
  
interface_member_declaration_sub_Chld
  :
  IDENTIFIER (tpl=type_parameter_list)? OPEN_PARENS (fpl=formal_parameter_list)? CLOSE_PARENS (tpcc=type_parameter_constraints_clauses)? SEMICOLON
  ->interfaceMemberDeclarationSubChld(memName={NamingUtil.toCamelCase($IDENTIFIER.text)},typParLst={tpl},formlParLst={fpl},typParConstrCls={tpcc})
  | IDENTIFIER OPEN_BRACE ia=interface_accessors CLOSE_BRACE
  ->interfaceMemberDeclarationSubChld2(memName={NamingUtil.toCamelCase($IDENTIFIER.text)},accrs={ia})
  | THIS OPEN_BRACKET fpl=formal_parameter_list CLOSE_BRACKET OPEN_BRACE iacr=interface_accessors CLOSE_BRACE
  ->interfaceMemberDeclarationSubChld3(formlParLst={fpl},intfcAccrs={iacr})
  ;
interface_method_declaration 
	: attributes? NEW? return_type IDENTIFIER type_parameter_list? OPEN_PARENS formal_parameter_list? CLOSE_PARENS type_parameter_constraints_clauses? SEMICOLON
	;
interface_property_declaration 
	: attributes? NEW? type IDENTIFIER OPEN_BRACE interface_accessors CLOSE_BRACE
	;
/*
interface_accessors 
	: attributes? get_contextual_keyword SEMICOLON
	| attributes? set_contextual_keyword SEMICOLON
	| attributes? get_contextual_keyword SEMICOLON attributes? set_contextual_keyword SEMICOLON
	| attributes? set_contextual_keyword SEMICOLON attributes? get_contextual_keyword SEMICOLON
	;
*/
  
interface_accessors 
  : 
  (at=attributes)?
    ( getkey=get_contextual_keyword SEMICOLON (attributes? setkey=set_contextual_keyword SEMICOLON)?
    ->interfaceAccessors(attributes={at},getckey={getkey},setckey={setkey})
    | setkey2=set_contextual_keyword SEMICOLON (attributes? getkey2=get_contextual_keyword SEMICOLON)?
    ->interfaceAccessors(attributes={at},getckey={getkey2},setckey={setkey2})
    )
    
  ;
  
interface_event_declaration 
	: attributes? NEW? EVENT type IDENTIFIER SEMICOLON
	;
interface_indexer_declaration 
	: attributes? NEW? type THIS OPEN_BRACKET formal_parameter_list CLOSE_BRACKET OPEN_BRACE interface_accessors CLOSE_BRACE
	;


//B.2.11 Enums
enum_declaration 
	: attributes? enum_modifiers? ENUM IDENTIFIER enum_base? enum_body SEMICOLON?
	;
enum_base 
	: COLON integral_type
	;
/*
enum_body 
	: OPEN_BRACE enum_member_declarations? CLOSE_BRACE
	| OPEN_BRACE enum_member_declarations COMMA CLOSE_BRACE
	;
*/
enum_body 
  : OPEN_BRACE CLOSE_BRACE
  | OPEN_BRACE enumd=enum_member_declarations (com=COMMA)? CLOSE_BRACE
  ->enumbody(enumdec={enumd},comm={com})
  ;
enum_modifiers 
	: enum_modifier+
	;
enum_modifier 
  : 
  NEW               ->text(value={$NEW.text})
  | PUBLIC          ->text(value={$PUBLIC.text})
  | PROTECTED       ->text(value={$PROTECTED.text})
  | INTERNAL        ->text(value={$INTERNAL.text})
  | PRIVATE         ->text(value={$PRIVATE.text})
  ;

enum_member_declarations 
	: mem=enum_member_declaration ( COMMA  mem1+=enum_member_declaration )*
	->enummemberdeclarations(memb={mem},memb1={$mem1})
	;
/*
enum_member_declaration 
	: attributes? IDENTIFIER
	| attributes? IDENTIFIER ASSIGNMENT constant_expression
	;
*/
enum_member_declaration 
  : att=attributes? id=IDENTIFIER (ASSIGNMENT exp=constant_expression)?
  ->enummemberdeclaration(attr={att},identi={id},expr={exp})
  ;

//B.2.12 Delegates
delegate_declaration 
	: attributes? delegate_modifiers? DELEGATE return_type IDENTIFIER variant_type_parameter_list? 
	    OPEN_PARENS formal_parameter_list? CLOSE_PARENS type_parameter_constraints_clauses? SEMICOLON
	;
delegate_modifiers 
	: delegate_modifier ( delegate_modifier )*
	;
delegate_modifier 
  : 
  NEW                                    ->text(value={$NEW.text})
  | PUBLIC                               ->text(value={$PUBLIC.text})
  | PROTECTED                            ->text(value={$PROTECTED.text})
  | INTERNAL                             ->text(value={$INTERNAL.text})
  | PRIVATE                              ->text(value={$PRIVATE.text})
  | delmd=delegate_modifier_unsafe       ->text(value={delmd})
  ;



//B.2.13 Attributes
// not used anymore; we use global_attribute_section+ directly
global_attributes 
	: 
	attrs=global_attribute_sections
	->globalAttributes(attributes={attrs})
	;
global_attribute_sections 
	: 
	(secs+=global_attribute_section)+
	->globalAttributeSections(sections={$secs})
	;
/*
global_attribute_section 
	: OPEN_BRACKET global_attribute_target_specifier attribute_list CLOSE_BRACKET
	| OPEN_BRACKET global_attribute_target_specifier attribute_list COMMA CLOSE_BRACKET
	;
*/
global_attribute_section 
  : 
  OPEN_BRACKET global_attribute_target_specifier attribute_list COMMA? CLOSE_BRACKET
  ;
global_attribute_target_specifier 
	: global_attribute_target COLON
	;
global_attribute_target 
  : 
  kyd=keyword         ->text(value={kyd})
  | IDENTIFIER        ->text(value={$IDENTIFIER.text})
  ;

/*
global_attribute_target 
	: ASSEMBLY
	| MODULE
	;
*/
attributes 
	: 
	attSec=attribute_sections        ->text(value={attSec})
	;
attribute_sections 
	: 
	(attSecLst+=attribute_section)+
	->lineIterator(list={$attSecLst})
	;
/*
attribute_section 
	: OPEN_BRACKET attribute_target_specifier? attribute_list CLOSE_BRACKET
	| OPEN_BRACKET attribute_target_specifier? attribute_list COMMA CLOSE_BRACKET
	;
*/
attribute_section 
  : 
  OPEN_BRACKET (attTarSpec=attribute_target_specifier)? attLst=attribute_list COMMA? CLOSE_BRACKET
  ->attributeSection(attributeTargetSpecifier={attTarSpec},attributeList={attLst})
  ;
attribute_target_specifier 
	: 
	attTar=attribute_target COLON
	->text(value={$attTar.text})
	;
attribute_target 
  : keyWrd=keyword      ->text(value={$keyWrd.text})
  | id=IDENTIFIER       ->text(value={$id.text})
  ;
/*
attribute_target 
	: FIELD
	| EVENT
	| METHOD
	| PARAM
	| PROPERTY
	| RETURN
	| TYPE
	;
*/
attribute_list 
	: 
	fstAtt=attribute (attrLst+=attribute_list_Chld)*
	->attributeList(firstAttribute={fstAtt},attributeList={$attrLst})
	;
	
attribute_list_Chld
	:
	COMMA atr=attribute
	->text(value={","+$atr.text})
	;
	
attribute 
	: 
	attNam=attribute_name (attArgs=attribute_arguments)?
	->attribute1(attributeName={attNam},attributeArgs={attArgs})
	;

attribute_name 
	: 
	typName=type_name        ->text(value={typName})
	;
/*
attribute_arguments 
	: OPEN_PARENS positional_argument_list? CLOSE_PARENS
	| OPEN_PARENS positional_argument_list COMMA named_argument_list CLOSE_PARENS
	| OPEN_PARENS named_argument_list CLOSE_PARENS
	;
*/
/* positional_argument_list includes named_argument_list */ 
attribute_arguments 
  : 
  OPEN_PARENS (posArgsList=positional_argument_list)? CLOSE_PARENS
  ->attributeArguments(positionalArgumentList={posArgsList})
  ;
positional_argument_list 
	: 
	arg=positional_argument (posLst+=positional_argument_list_Chld)*
	->positionalArgumentList(firstArg={arg},restArgsLst={$posLst})
	;
	
positional_argument_list_Chld
	:
	COMMA  arg=positional_argument
	->text(value={","+arg})
	;
/** expression */
positional_argument 
	: 
	attArgExpr=attribute_argument_expression
	->positionalArgument(attributeArgExpr={attArgExpr})
	;
/** starts with "IDENTIFIER ASSIGNMENT expression" */
named_argument_list 
	: named_argument ( COMMA  named_argument )*
	;
/** IDENTIFIER ASSIGNMENT expression */
named_argument 
	: IDENTIFIER ASSIGNMENT attribute_argument_expression
	;
attribute_argument_expression 
	: 
	expr=expression
	->attributeArgumentExpression(expr={expr})
	;


//B.3 Grammar extensions for unsafe code
class_modifier_unsafe 
	: 
	UNSAFE       ->text(value={$UNSAFE.text})
	;
struct_modifier_unsafe 
	: UNSAFE     ->text(value={$UNSAFE.text})
	;
interface_modifier_unsafe 
	: UNSAFE     ->text(value={$UNSAFE.text})
	;
delegate_modifier_unsafe 
	: UNSAFE     ->text(value={$UNSAFE.text})
	;
field_modifier_unsafe 
	: UNSAFE      ->text(value={$UNSAFE.text})
	;
method_modifier_unsafe 
	: UNSAFE     ->text(value={$UNSAFE.text})
	;
property_modifier_unsafe 
	: 
	UNSAFE       ->text(value={$UNSAFE.text})
	;
event_modifier_unsafe 
	: UNSAFE     ->text(value={$UNSAFE.text})
	;
indexer_modifier_unsafe 
	: UNSAFE     ->text(value={$UNSAFE.text})
	;
operator_modifier_unsafe 
	: UNSAFE     ->text(value={$UNSAFE.text})
	;
constructor_modifier_unsafe 
	: UNSAFE     ->text(value={$UNSAFE.text})
	;
/*
destructor_declaration_unsafe 
	: attributes? EXTERN? UNSAFE? TILDE IDENTIFIER OPEN_PARENS CLOSE_PARENS destructor_body
	| attributes? UNSAFE? EXTERN? TILDE IDENTIFIER OPEN_PARENS CLOSE_PARENS destructor_body
	;
*/
destructor_declaration_unsafe 
  : attributes?
    ( EXTERN? UNSAFE?
    | UNSAFE EXTERN
    )  
    TILDE IDENTIFIER OPEN_PARENS CLOSE_PARENS destructor_body
  ;
/*
static_constructor_modifiers_unsafe 
	: EXTERN? UNSAFE? STATIC
	| UNSAFE? EXTERN? STATIC
	| EXTERN? STATIC UNSAFE?
	| UNSAFE? STATIC EXTERN?
	| STATIC EXTERN? UNSAFE?
	| STATIC UNSAFE? EXTERN?
	;
*/
static_constructor_modifiers_unsafe 
  : (EXTERN | UNSAFE)? STATIC
  | EXTERN UNSAFE STATIC
  | UNSAFE EXTERN STATIC
  | EXTERN STATIC UNSAFE
  | UNSAFE STATIC EXTERN
  | STATIC (EXTERN | UNSAFE)
  | STATIC EXTERN UNSAFE
  | STATIC UNSAFE EXTERN
  ;
/** starts with UNSAFE or FIXED */
embedded_statement_unsafe 
	: unsafe_statement
	| fixed_statement
	;
unsafe_statement 
	: UNSAFE block
	;
type_unsafe 
	: pointer_type
	;
/*
pointer_type 
	: unmanaged_type STAR
	| VOID STAR
	;
*/
// for explanations, see http://www.antlr.org/wiki/display/ANTLR3/Left-Recursion+Removal+-+Print+Edition
pointer_type 
@init {
    boolean allowAll = true;
}
  : ( simple_type
	  | class_type
	  | VOID {allowAll = false;}
  ) ( {allowAll}? => rank_specifier
    | {allowAll}? => INTERR
    | STAR {allowAll = true;}
    )* STAR
  ;
//pointer_type
//    :    type_name (rank_specifier | INTERR)* STAR
//    |    simple_type (rank_specifier | INTERR)* STAR
//    |    enum_type (rank_specifier | INTERR)* STAR
//    |    class_type (rank_specifier | INTERR)* STAR
//    |    interface_type (rank_specifier | INTERR)* STAR
//    |    delegate_type (rank_specifier | INTERR)* STAR
//    |    type_parameter (rank_specifier | INTERR)* STAR
//    |    pointer_type (rank_specifier | INTERR)* STAR
//    |    VOID STAR
//    ;
unmanaged_type 
	: 
	t=type
	->unmanagedType(type={t})
	;
/*
primary_no_array_creation_expression_unsafe 
	: pointer_member_access
	| pointer_element_access
	| sizeof_expression
	;
*/
primary_no_array_creation_expression_unsafe 
	: 
	expr=primary_expression
	->primaryNoArrayCreationExpressionUnsafe(expression={expr})
	;
/** starts with STAR or AMP */
unary_expression_unsafe 
	: pointer_indirection_expression
	| addressof_expression
	;
pointer_indirection_expression 
	: STAR unary_expression
	;
/* not used anymore; included in primary_expression
pointer_member_access 
	: primary_expression OP_PTR IDENTIFIER
	;
*/
/* not used anymore; included in primary_no_array_creation_expression
pointer_element_access 
	: primary_no_array_creation_expression OPEN_BRACKET expression CLOSE_BRACKET
	;
*/
/** AMP unary_expression */
addressof_expression 
	: AMP unary_expression
	;
sizeof_expression 
	: SIZEOF OPEN_PARENS unmanaged_type CLOSE_PARENS
	;
fixed_statement 
	: FIXED OPEN_PARENS pointer_type fixed_pointer_declarators CLOSE_PARENS embedded_statement
	;
fixed_pointer_declarators 
	: fixed_pointer_declarator ( COMMA  fixed_pointer_declarator )*
	;
fixed_pointer_declarator 
	: IDENTIFIER ASSIGNMENT fixed_pointer_initializer
	;
/*
fixed_pointer_initializer 
	: AMP variable_reference
	| expression
	;
*/
fixed_pointer_initializer 
  : (AMP) => AMP variable_reference
  | expression
  ;
struct_member_declaration_unsafe 
	: fixed_size_buffer_declaration
	;
fixed_size_buffer_declaration 
	: 
	attributes? fixed_size_buffer_modifiers? FIXED buffer_element_type fixed_size_buffer_declarators SEMICOLON
//	->fixedSizeBufferDeclaration
	;
fixed_size_buffer_modifiers 
	: 
	(modf+=fixed_size_buffer_modifier)+
	->fixedSizeBufferModifiers(modfs={$modf})
	;
fixed_size_buffer_modifier 
  : 
  NEW               ->text(value={$NEW.text})
  | PUBLIC          ->text(value={$PUBLIC.text})
  | PROTECTED       ->text(value={$PROTECTED.text})
  | INTERNAL        ->text(value={$INTERNAL.text})
  | PRIVATE         ->text(value={$PRIVATE.text})
  | UNSAFE          ->text(value={$UNSAFE.text})
  ;

buffer_element_type 
	: type
	;
fixed_size_buffer_declarators 
	: fixed_size_buffer_declarator+
	;
fixed_size_buffer_declarator 
	: IDENTIFIER OPEN_BRACKET constant_expression CLOSE_BRACKET
	;
/** starts with STACKALLOC */
local_variable_initializer_unsafe 
	: 
	stkInit=stackalloc_initializer
	->localVariableInitializerUnsafe(init={stkInit})
	;
stackalloc_initializer 
	: 
	STACKALLOC unmanaged_type OPEN_BRACKET expression CLOSE_BRACKET
	;

	
// ---------------------------------- rules not defined in the original parser ----------
// ---------------------------------- rules not defined in the original parser ----------
// ---------------------------------- rules not defined in the original parser ----------
// ---------------------------------- rules not defined in the original parser ----------


from_contextual_keyword
  :
  ({input.LT(1).getText().equals("from")}? (type)? IDENTIFIER IN expression join_contextual_keyword)=> IDENTIFIER
  ->text(value={"Stream.concat("}) 
  |
  ({input.LT(1).getText().equals("from")}? (type)? IDENTIFIER IN expression where_contextual_keyword)=> IDENTIFIER
  ->text(value={""})
  |
  ({input.LT(1).getText().equals("from")}? (type)? IDENTIFIER IN expression {input.LT(1).getText().equals("from")}?)=> IDENTIFIER
  ->text(value={"Stream.concat("})
  |
  ({input.LT(1).getText().equals("from")}? (type)? IDENTIFIER IN expression {input.LT(1).getText().equals("group")}?)=> IDENTIFIER
  ->text(value={""})
  |
  ({input.LT(1).getText().equals("from")}? (type)? IDENTIFIER IN expression {input.LT(1).getText().equals("orderby")}?)=> IDENTIFIER
  ->text(value={""})
  |
  ({input.LT(1).getText().equals("from")}? (type)? IDENTIFIER IN expression {input.LT(1).getText().equals("select")}?)=> IDENTIFIER
  ->text(value={""})
  |
  ({input.LT(1).getText().equals("from")}? (type)? IDENTIFIER IN expression {input.LT(1).getText().equals("let")}?)=> IDENTIFIER
  ->text(value={""})
  |
  {input.LT(1).getText().equals("from")}? IDENTIFIER
  ->text(value={"from"})
  ;
let_contextual_keyword
  : {input.LT(1).getText().equals("let")}? IDENTIFIER
   ->text(value={$IDENTIFIER.text})
  ;
where_contextual_keyword
  :
  {input.LT(1).getText().equals("where")}? IDENTIFIER
  ->text(value={".filter("})
  ;
  
join_contextual_keyword
  : {input.LT(1).getText().equals("join")}? IDENTIFIER
   ->text(value={"join "})
  ;
//join_contextual_keyword
//  : {input.LT(1).getText().equals("join")}? IDENTIFIER
//   ->text(value={$IDENTIFIER.text})
//  ;
on_contextual_keyword
  : {input.LT(1).getText().equals("on")}? IDENTIFIER
   ->text(value={$IDENTIFIER.text})
  ;
equals_contextual_keyword
  : 
  {input.LT(1).getText().equals("equals")}? IDENTIFIER
   ->text(value={$IDENTIFIER.text})
  ;
into_contextual_keyword
  : {input.LT(1).getText().equals("into")}? IDENTIFIER
   ->text(value={$IDENTIFIER.text})
  ;
orderby_contextual_keyword
  : {input.LT(1).getText().equals("orderby")}? IDENTIFIER
    ->text(value={$IDENTIFIER.text})
  ;
ascending_contextual_keyword
  : {input.LT(1).getText().equals("ascending")}? IDENTIFIER
    ->text(value={"ascending "+$IDENTIFIER.text})
  ;
descending_contextual_keyword
  : {input.LT(1).getText().equals("descending")}? IDENTIFIER
    ->text(value={"descending "+$IDENTIFIER.text})
  ;
select_contextual_keyword
  : {input.LT(1).getText().equals("select")}? IDENTIFIER
    ->text(value={$IDENTIFIER.text})
  ;
  
not_select_contextual_keyword
  : {!input.LT(1).getText().equals("select")}? IDENTIFIER
    ->text(value={$IDENTIFIER.text})
  ;
group_contextual_keyword
  : 
  {input.LT(1).getText().equals("group")}? id=IDENTIFIER
  ->text(value={".collect(Collectors.groupingBy("})
  ;
by_contextual_keyword
  : 
  {input.LT(1).getText().equals("by")}? id=IDENTIFIER
  ->text(value={$id.text})
  ;
partial_contextual_keyword
  : 
  {input.LT(1).getText().equals("partial")}? id=IDENTIFIER
  ->text(value={$id.text})
  ;
alias_contextual_keyword
  : {input.LT(1).getText().equals("alias")}? IDENTIFIER
     ->text(value={$IDENTIFIER.text})
  ;
yield_contextual_keyword
  : {input.LT(1).getText().equals("yield")}? IDENTIFIER
     ->text(value={$IDENTIFIER.text})
  ;
get_contextual_keyword
  : 
  {input.LT(1).getText().equals("get")}? IDENTIFIER
  ->getContextualKeyword(value={$IDENTIFIER.text})
  ;
set_contextual_keyword
  : 
  {input.LT(1).getText().equals("set")}? IDENTIFIER
  ->setContextualKeyword(value={$IDENTIFIER.text})
  ;
add_contextual_keyword
  : {input.LT(1).getText().equals("add")}? IDENTIFIER
    ->text(value={$IDENTIFIER.text})
  ;
remove_contextual_keyword
  : 
  {input.LT(1).getText().equals("remove")}? id=IDENTIFIER
  ->text(value={$id.text})
  ;
dynamic_contextual_keyword
  : 
  {input.LT(1).getText().equals("dynamic")}? id=IDENTIFIER
  ->text(value={$id.text})
  ;
arglist
  : 
  {input.LT(1).getText().equals("__arglist")}? id=IDENTIFIER
  ->text(value={"__arglist "+$id.text})
  ;
right_arrow
  : first=ASSIGNMENT second=GT {$first.index + 1 == $second.index}? // Nothing between the tokens?
  ;
right_shift
  : 
  first=GT second=GT {$first.index + 1 == $second.index}? // Nothing between the tokens?
  ->text(value={">>"})
  ;
right_shift_assignment
  : 
  first=GT second=OP_GE {$first.index + 1 == $second.index}? // Nothing between the tokens?
  ->text(value={">>="}) 
  ;
literal
  : 
  bl=boolean_literal
  ->literal(ltrl={bl})
  | INTEGER_LITERAL
  ->literal(ltrl={$INTEGER_LITERAL.text})
  | REAL_LITERAL
  ->literal(ltrl={$REAL_LITERAL.text})
  | CHARACTER_LITERAL
  ->literal(ltrl={$CHARACTER_LITERAL.text})
  | STRING_LITERAL
  ->literal(ltrl={$STRING_LITERAL.text})
  | NULL
  ->literal(ltrl={$NULL.text})
  ;
  

  
boolean_literal
  : 
  TRUE
  ->text(value={$TRUE.text})
  | FALSE
  ->text(value={$FALSE.text})
  ;
//B.1.7 Keywords
keyword
  : 
  ABSTRACT        ->text(value={$ABSTRACT.text})
   | AS           ->text(value={$AS.text})
   | BASE         ->text(value={$BASE.text})
   | BOOL         ->text(value={$BOOL.text})
   | BREAK        ->text(value={$BREAK.text})
   | BYTE         ->text(value={$BYTE.text})
   | CASE         ->text(value={$CASE.text})
   | CATCH        ->text(value={$CATCH.text})
   | CHAR         ->text(value={$CHAR.text})
   | CHECKED      ->text(value={$CHECKED.text})
   | CLASS        ->text(value={$CLASS.text})
   | CONST        ->text(value={$CONST.text})
   | CONTINUE     ->text(value={$CONTINUE.text})
   | DECIMAL      ->text(value={$DECIMAL.text})
   | DEFAULT      ->text(value={$DEFAULT.text})
   | DELEGATE     ->text(value={$DELEGATE.text})
   | DO           ->text(value={$DO.text})
   | DOUBLE       ->text(value={$DOUBLE.text})
   | ELSE         ->text(value={$ELSE.text})
   | ENUM         ->text(value={$ENUM.text})
   | EVENT        ->text(value={$EVENT.text})
   | EXPLICIT     ->text(value={$EXPLICIT.text})
   | EXTERN       ->text(value={$EXTERN.text})
   | FALSE        ->text(value={$FALSE.text})
   | FINALLY      ->text(value={$FINALLY.text})
   | FIXED        ->text(value={$FIXED.text})
   | FLOAT        ->text(value={$FLOAT.text})
   | FOR          ->text(value={$FOR.text})
   | FOREACH      ->text(value={$FOREACH.text})
   | GOTO         ->text(value={$GOTO.text})
   | IF           ->text(value={$IF.text})
   | IMPLICIT     ->text(value={$IMPLICIT.text})
   | IN           ->text(value={$IN.text})
   | INT          ->text(value={$INT.text})
   | INTERFACE    ->text(value={$INTERFACE.text})
   | INTERNAL     ->text(value={$INTERNAL.text})
   | IS           ->text(value={$IS.text})
   | LOCK         ->text(value={$LOCK.text})
   | LONG         ->text(value={$LONG.text})
   | NAMESPACE    ->text(value={$NAMESPACE.text})
   | NEW          ->text(value={$NEW.text})
   | NULL         ->text(value={$NULL.text})
   | OBJECT       ->text(value={"Object"})
   | OPERATOR     ->text(value={$OPERATOR.text})
   | OUT          ->text(value={$OUT.text})
   | OVERRIDE     ->text(value={$OVERRIDE.text})
   | PARAMS       ->text(value={$PARAMS.text})
   | PRIVATE      ->text(value={$PRIVATE.text})
   | PROTECTED    ->text(value={$PROTECTED.text})
   | PUBLIC       ->text(value={$PUBLIC.text})
   | READONLY     ->text(value={$READONLY.text})
   | REF          ->text(value={$REF.text})
   | RETURN       ->text(value={$RETURN.text})
   | SBYTE        ->text(value={$SBYTE.text})
   | SEALED       ->text(value={$SEALED.text})
   | SHORT        ->text(value={$SHORT.text})
   | SIZEOF       ->text(value={$SIZEOF.text})
   | STACKALLOC   ->text(value={$STACKALLOC.text})
   | STATIC       ->text(value={$STATIC.text})
   | STRING       ->text(value={"String"})
   | STRUCT       ->text(value={$STRUCT.text})
   | SWITCH       ->text(value={$SWITCH.text})
   | THIS         ->text(value={$THIS.text})
   | THROW        ->text(value={$THROW.text})
   | TRUE         ->text(value={$TRUE.text})
   | TRY          ->text(value={$TRY.text})
   | TYPEOF       ->text(value={$TYPEOF.text})
   | UINT         ->text(value={$UINT.text})
   | ULONG        ->text(value={$ULONG.text})
   | UNCHECKED    ->text(value={$UNCHECKED.text})
   | UNSAFE       ->text(value={$UNSAFE.text})
   | USHORT       ->text(value={$USHORT.text})
   | USING        ->text(value={$USING.text})
   | VIRTUAL      ->text(value={$VIRTUAL.text})
   | VOID         ->text(value={$VOID.text})
   | VOLATILE     ->text(value={$VOLATILE.text})
   | WHILE        ->text(value={$WHILE.text})
  ;


// -------------------- extra rules for modularization --------------------------------
class_name_definition
  :
  CLASS clsNam=IDENTIFIER
  ->text(value={$clsNam.text+updateClassName(NamingUtil.getControllerName($clsNam.text))})
  ;

class_definition
  : 
  clsNam=class_name_definition type_parameter_list? (basCls=class_base)? type_parameter_constraints_clauses?
      clsBdy=class_body (dl=SEMICOLON)? (comts=comments)?
  ->classDefinition(className={CSharpAngularHelper.modelHelperToController(clsNam.st.toString())},baseClass={basCls},classBody={clsBdy},delimiter={$dl.text},comments={comts})
  ;
struct_definition
  : STRUCT IDENTIFIER type_parameter_list? struct_interfaces? type_parameter_constraints_clauses?
      struct_body SEMICOLON?
  ;

interface_definition
  : 
  INTERFACE nam=IDENTIFIER (vtpl=variant_type_parameter_list)? (ib=interface_base)? (tpcc=type_parameter_constraints_clauses)? bdy=interface_body (dlMtr=SEMICOLON)?
  ->interfaceDefinition(kwd={$INTERFACE.text+" "},interfaceName={CSharpAngularHelper.modelHelperToController($nam.text)},varTypLst={vtpl},intfcBdy={ib},constrntCls={tpcc},body={bdy},delimiter={$dlMtr.text})
  ;
enum_definition
  : 
  ENUM IDENTIFIER (eb=enum_base)? bdy=enum_body dlMtr=SEMICOLON?
  ->enumDefinition(name={$IDENTIFIER.text},base={eb},body={bdy},delimiter={$dlMtr.text})
  ;
delegate_definition
  : DELEGATE return_type IDENTIFIER variant_type_parameter_list? OPEN_PARENS
      formal_parameter_list? CLOSE_PARENS type_parameter_constraints_clauses? SEMICOLON
  ;
event_declaration2
  : EVENT type {$common_member_declaration::type = $type.tree;}
      ( variable_declarators SEMICOLON
      | member_name OPEN_BRACE event_accessor_declarations CLOSE_BRACE
      )
  ;
field_declaration2
  : 
  varDec=variable_declarators SEMICOLON (comts=comments)?
  ->fieldDeclaration2(declaration={$varDec.st.toString().trim()},comments={comts})
  ;
property_declaration2
  : 
  mNam=member_name OPEN_BRACE (cmnt=comments)? ad=accessor_declarations CLOSE_BRACE
  ->propertyDeclaration2(memNameforDecl={NamingUtil.toCamelCase($mNam.text).trim()},cmnts={cmnt})
  ;
constant_declaration2
  : 
  CONST t=type decl=constant_declarators SEMICOLON (comts=comments)?
  ->constantDeclaration2(type={t},declarators={decl},comments={comts})
  ;
indexer_declaration2
  : 
  THIS OPEN_BRACKET fpl=formal_parameter_list CLOSE_BRACKET OPEN_BRACE ad=accessor_declarations CLOSE_BRACE
  ->indexerDeclaration2(formlParLst={fpl},accsDecls={ad})
  ;
destructor_definition
  : TILDE IDENTIFIER OPEN_PARENS CLOSE_PARENS destructor_body
  ;
constructor_declaration2
  : 
  id=IDENTIFIER OPEN_PARENS (fpl=formal_parameter_list)? CLOSE_PARENS (cotrInit=constructor_initializer)? (cmnt=comments)? bdy=body
  ->constructorDeclaration2(constrName={$id.text},formalParamLst={fpl},constrInit={cotrInit},cmnts={cmnt},constrBdy={bdy})
  ;

comments  
  :
  (comLst+=comment)+
  ->comments(list={$comLst})
  ;

comment
  :
  SINGLE_LINE_COMMENT  
  ->comment(content={$SINGLE_LINE_COMMENT.text})
  |SINGLE_LINE_DOC_COMMENT
  ->comment(content={CSharpAngularHelper.docCommentHandler($SINGLE_LINE_DOC_COMMENT.text)})
  ;
  
method_declaration2
  : 
  mthdNam=method_member_name (parLst=type_parameter_list)? OPEN_PARENS (fpl=formal_parameter_list)? CLOSE_PARENS (cmts=comments)?
      (cluses=type_parameter_constraints_clauses)? mBdy=method_body
  ->methodDeclaration2(methodName={mthdNam},typeParamLst={parLst},formalParamLst={fpl},cmnts={cmts},paramClauses={cluses},methodBody={mBdy})
  ;
// added by chw to allow detection of type parameters for methods
method_member_name
  : 
  mName=method_member_name2
  ->methodMemberName(methodName={$mName.st.toString().trim()})
  ;
method_member_name2
  : 
  strtId=IDENTIFIER (lst+=method_member_name2_chld)*
  ->methodMemberName2(startId={NamingUtil.toCamelCase($strtId.text)},list={$lst})
  | id1=IDENTIFIER DOUBLE_COLON id2=IDENTIFIER (lst+=method_member_name2_chld)*
  ->methodMemberName2(startId={$id1.text+" "+$id2.text},list={$lst})
  ;
  
method_member_name2_chld
  :
  tal=type_argument_list_opt DOT eId=IDENTIFIER
  ->methodMemberName2Chld(typArglst={tal},endId={NamingUtil.toCamelCase($eId.text)})
  ;
operator_declaration2
  : OPERATOR overloadable_operator OPEN_PARENS type IDENTIFIER
         (COMMA type IDENTIFIER)? CLOSE_PARENS operator_body
  ;
interface_method_declaration2
  : IDENTIFIER type_parameter_list? OPEN_PARENS formal_parameter_list? CLOSE_PARENS type_parameter_constraints_clauses? SEMICOLON
  ;
interface_property_declaration2
  : IDENTIFIER OPEN_BRACE interface_accessors CLOSE_BRACE
  ;
interface_event_declaration2
  : EVENT type IDENTIFIER SEMICOLON
  ;
interface_indexer_declaration2
  : 
  THIS OPEN_BRACKET formal_parameter_list CLOSE_BRACKET OPEN_BRACE interface_accessors CLOSE_BRACE
  ;
/** starts with DOT IDENTIFIER */
member_access2
  :
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("TotalSeconds")}?) => DOT IDENTIFIER )
  ->text(value={"/1000 "})
  | 
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("TotalMinutes")}?) => DOT IDENTIFIER )
  ->text(value={"/60000 "})
  | 
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("Millisecond")}?) => DOT IDENTIFIER )
  ->text(value={".getMilliseconds()"})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("Second")}?) => DOT IDENTIFIER )
  ->text(value={".getSeconds()"})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("Minute")}?) => DOT IDENTIFIER )
  ->text(value={".getMinutes()"})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("Hour")}?) => DOT IDENTIFIER )
  ->text(value={".getHours()"})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("Day")}?) => DOT IDENTIFIER )
  ->text(value={".getDate()"})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("Date")}?) => DOT IDENTIFIER )
  ->text(value={".toLocaleDateString()"})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("DayOfWeek")}?) => DOT IDENTIFIER )
  ->text(value={".getDay()"})
  |
  (({input.LT(1).getText().equals(".") && input.LT(2).getText().equals("Year")}?) => DOT IDENTIFIER )
  ->text(value={".getFullYear()"})
  |
  (({input.LT(1).getText().equals(".") && (input.LT(2).getText().equals("Count") || input.LT(2).getText().equals("Length"))}?) => DOT IDENTIFIER )
  ->text(value={".length"})
  |
  DOT id=IDENTIFIER tal=type_argument_list_opt
  ->memberAccess2(memName={NamingUtil.toCamelCase($id.text)},argLst={tal})
  ;
  
method_invocation2
  : 
  OPEN_PARENS (al=argument_list)? CLOSE_PARENS
  ->methodInvocation2(argLst={al})
  ;
object_creation_expression2
  : 
  OPEN_PARENS (argLst=argument_list)? CLOSE_PARENS (ObjColcInit=object_or_collection_initializer)?
  ->objectCreationExpression2(argumentList={argLst},init={ObjColcInit})
  ;
  
  