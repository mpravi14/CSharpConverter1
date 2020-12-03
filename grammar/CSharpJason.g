parser grammar CSharpJason;

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
public List<String> methodList = new LinkedList<String>();

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

 private String methodName;

 public String getMethodName() {
    return methodName;
  }

public String assignMethodName(String methodName) {
    setMethodName(methodName);
    methodList.add(methodName);
    return "";
  }

  public void setMethodName(String methodName) {
    this.methodName = methodName;
  }
private void next(int n) {
  System.err.print("next: ");
  for (int i=1; i<=n; i++) {
//    System.err.print(" | " + input.LT(i).getType() + "=" + input.LT(i).getText());
  }
//  System.err.println("Error--");
}

}


cSharp returns [String javaContent]
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
  id=IDENTIFIER typArg=type_argument_list_opt  (nmsTypChld1+=namespace_or_type_name_Chld )*
  ->namespaceOrTypeName(firstPart={CSharpHelper.replaceJavaType($id.text)},argList={typArg},secondPart={$nmsTypChld1})
  |fstPrt=qualified_alias_member (nmsTypChld2+=namespace_or_type_name_Chld )*
  ->namespaceOrTypeName2(firstPart={$fstPrt.text},secondPart={$nmsTypChld2})
  ;
  
namespace_or_type_name_Chld
  :
  DOT id=IDENTIFIER argLst=type_argument_list_opt 
  ->namespaceOrTypeNameChld(identifier={NamingUtil.toCamelCase($id.text)},argumentList={argLst})
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
  bTyp=base_type (chld+=typeChld)*
  ->dattype(firstType={bTyp},list={$chld})
  ;
  
typeChld
  :
  ((INTERR) => inter=INTERR)                    ->typeChld(value={""})
  | ((rank_specifier) => rnkSp=rank_specifier)  ->typeChld(value={rnkSp})
  | st=STAR                                     ->typeChld(value={$STAR.text})
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
	| boolType=BOOL                ->simpleType(type={"boolean"})
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
	: base_type
    ( (rank_specifier) => rank_specifier
    | STAR
    )*
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
	ta=type          
	->typeArgument(value={CSharpHelper.replaceJavaType($ta.text)})
	;
// added by chw
type_void
  : 
  v=VOID
  ->text(value={" "+$v.text})
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
	->argumentList(firstArgmnt={NamingUtil.toCamelCase($fstArg.text)},list={$lst})
	;

argument_list_Chld
  :
	COMMA arg=argument
	->argumentListChld(args={NamingUtil.toCamelCase($arg.text).toString().trim()})
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
  pe=primary_expression_start  (fbe+=bracket_expression)* (pcl+=primary_expression_Chld)*
  ->primaryExpression(prmExprStrt={pe},frstBrktExpr={$fbe},prmChldLst={$pcl})
  ;

primary_expression_Chld
  :
  pesc=primary_expression_sub_Chld (brktExpr+=bracket_expression)*
  ->primaryExpressionChld(peChild={pesc},bracketExpr={$brktExpr})
  ;
  
primary_expression_sub_Chld
 :
  memAcc=member_access2
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
	IDENTIFIER talo=type_argument_list_opt
	->simpleName(name={$IDENTIFIER.text},argList={talo})
	;
/** OPEN_PARENS expression CLOSE_PARENS */
parenthesized_expression 
	: 
	OPEN_PARENS expr=expression CLOSE_PARENS
	->parenthesizedExpression(expression={expr})
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
	BASE DOT IDENTIFIER type_argument_list_opt
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
	id=IDENTIFIER ASSIGNMENT ival=initializer_value
	->memberInitializer(memberName={$id.text},initVal={ival})
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
	fstElmnt=element_initializer (chld+=element_initializer_list_Chld)*
	->elementInitializerList(firstElement={fstElmnt},chldList={$chld})
	;
	
element_initializer_list_Chld
	:
	COMMA eleInit=element_initializer
	->elementInitializerListChld(init={eleInit})
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
	COMMA memDcl=member_declarator
	->memberDeclaratorListChld(decl={memDcl})
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
	  ( (unbound_type_name) => (unboundtyp=unbound_type_name) CLOSE_PARENS
	  ->typeofexpression(unboundtype={unboundtyp})
	  | type CLOSE_PARENS
	  | VOID CLOSE_PARENS
	  )
	;
/*
unbound_type_name 
	: IDENTIFIER generic_dimension_specifier?
	| IDENTIFIER DOUBLE_COLON IDENTIFIER generic_dimension_specifier?
	| unbound_type_name DOT IDENTIFIER generic_dimension_specifier?
	;
*/  
  unbound_type_name 
  : IDENTIFIER genericdim=generic_dimension_specifier? (DOT IDENTIFIER genericdim1=generic_dimension_specifier?)*
  ->unboundtypename(genericdim={genericdim},genericdim1={genericdim1})
   | IDENTIFIER DOUBLE_COLON IDENTIFIER genericdim=generic_dimension_specifier? (DOT IDENTIFIER genericdim1=generic_dimension_specifier?)*
  ->unboundtypename(genericdimsp={genericdim},genericdim1={genericdim1})
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
	: DEFAULT OPEN_PARENS type CLOSE_PARENS
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
	((scan_for_cast_generic_precedence | OPEN_PARENS predefined_type) => val1=cast_expression)
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
  | IDENTIFIER          ->text(value={$IDENTIFIER.text})
  | lit=literal         ->text(value={lit})
  | ABSTRACT            ->text(value={$ABSTRACT.text})
  | BASE                ->text(value={$BASE.text})
  | BOOL                ->text(value={"boolean"})
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
  | INTERNAL            ->text(value={"private"})
  | LOCK                ->text(value={$LOCK.text})
  | LONG                ->text(value={$LONG.text})
  | NAMESPACE           ->text(value={$NAMESPACE.text})
  | NEW                 ->text(value={$NEW.text})
  | OBJECT              ->text(value={"Object"})
  | OPERATOR            ->text(value={$OPERATOR.text})
  | OUT                 ->text(value={$OUT.text})
  | OVERRIDE            ->text(value={"@Override\n"})
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
	PLUS  rhs1=multiplicative_expression
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
  ->relationalExpressionChld(optr={$AS.text},rhs={rhs6})
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
  OP_AND rhs=inclusive_or_expression (cmnts=comments)?
  ->conditionalAndExpressionChld(optr={$OP_AND.text},rhs={rhs},comments={cmnts})
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
  ->conditionalExpression(lhs={lhs},optr1={""},optr2={$COLON.text},expr1={exp1},expr2={exp2})
  ;
/** starts with OPEN_PARENS or IDENTIFIER */
lambda_expression 
	: 
	sign=anonymous_function_signature right_arrow bdy=anonymous_function_body
	->lambdaExpression(signature={sign},body={bdy})
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
	->queryExpression(fromClause={frmCls},body={bdy})
	;
from_clause 
	: 
	frmKWd=from_contextual_keyword ((type IDENTIFIER IN) => t=type)? id2=IDENTIFIER IN exp=expression
	->fromClause(keyWrd={frmKWd},type={t},als={$id2.text},expression={NamingUtil.toClassName($exp.text)})
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
query_body_clauses 
	: 
	(lst+=query_body_clause)+
	->queryBodyClauses(list={$lst})
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
where_clause 
	: 
	whrKwd=where_contextual_keyword expr=boolean_expression
	->whereClause(whereKeyWrd={whrKwd},expression={expr})
	;
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
combined_join_clause
  : 
  join_contextual_keyword (t=type)? id1=IDENTIFIER IN expr1=expression on_contextual_keyword expr2=expression equals_contextual_keyword expr3=expression (into_contextual_keyword id2=IDENTIFIER)?
  ->combinedJoinClause(type={t},joinId={$id1.text},expression1={CSharpHelper.prefixGetKeyword($expr1.text)},expression2={CSharpHelper.prefixGetKeyword($expr2.text)},expression3={CSharpHelper.prefixGetKeyword($expr3.text)},intoId={$id2.text})
  ;
  
orderby_clause 
	: 
	orderby_contextual_keyword ods=orderings
	->orderbyClause(ordngs={ods})
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
	
ordering 
	: 
	expr=expression (orng=ordering_direction)?
	->ordering(expression={$expr.st.toString().trim()},direction={orng})
	;
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
	
select_clause 
	: 
	slctKwd=select_contextual_keyword expr=expression
	->selectClause(keyWrd={slctKwd},expression={CSharpHelper.prefixTempVar($expr.text)})
	;
group_clause 
	: 
	grpKwd=group_contextual_keyword expr1=expression byKwrd=by_contextual_keyword expr2=expression
	->groupClause(groupkeyWrd={grpKwd},expression1={expr1},byKeyWrd={byKwrd},expression2={expr2})
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
	unExpr=unary_expression optr=assignment_operator expr=expression
	->assignment(unaryExpr={unExpr},operator={optr},expression={expr})
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
	->expression(assignment={CSharpHelper.processAssignmentStmts($asgn.text)})
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
	->statement(stmt={lblStmt})
	|( (declaration_statement) => decStmt=declaration_statement)
	->statement(stmt={decStmt})
	| embdStmt=embedded_statement
	->statement(stmt={embdStmt})
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
	;
/** starts with OPEN_BRACE */
block 
	: 
	OPEN_BRACE (comts=comments)? (lst=statement_list)? CLOSE_BRACE
	->block(comments={comts},blockStmtLst={lst})
	;
	
statement_list 
	: 
	(stmts+=statement)+
	->statementList(list={$stmts})
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
	typ=local_variable_type  decls=local_variable_declarators
	->tsqlStatment(value={CSharpHelper.intializeStoreProc($typ.text,$decls.text)})
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
	->localVariableType(type={t})
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
  IF OPEN_PARENS cond=boolean_expression CLOSE_PARENS ifBdystmts=embedded_statement ( (ELSE) => ELSE elsBdy=embedded_statement )? (cmnts=comments)?
  ->ifStatement(condition={cond},ifBody={ifBdystmts},elseBody={elsBdy},comment={cmnts})
  ;
switch_statement 
	: SWITCH OPEN_PARENS expr=expression CLOSE_PARENS switchblck=switch_block
	->switchstatement(expr={expr},switchblck={switchblck})
	;
switch_block 
	: OPEN_BRACE switchsec=switch_sections? CLOSE_BRACE
	->switchblock(switchsec={switchsec})
	;
switch_sections 
	: switchsect=switch_section ( switchsect1=switch_section )*
	->switchsections(switchsect={switchsect},switchsect1={switchsect1})
	;
switch_section 
	: switchlabl=switch_labels statmntlst=statement_list
	->switchsection(switchlabl={switchlabl},statmntlst={statmntlst})
	;
switch_labels 
	: swtchlabl=switch_label ( swtchlabl1=switch_label )*
	->switchlabels(swtchlabl={swtchlabl},swtchlabl1={swtchlabl1})
	;
switch_label 
	: CASE constntexpr=constant_expression COLON
	->switchlabel(constntexpr={constntexpr})
	| DEFAULT COLON
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
	: 
	(local_variable_declaration) => lvd=local_variable_declaration
	->forInitializer(init={lvd})
	| eList=statement_expression_list
	->forInitializer(init={eList})
	;
for_condition 
	: 
	expr=boolean_expression
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
	FOREACH OPEN_PARENS varTyp=local_variable_type var=IDENTIFIER IN expr=expression CLOSE_PARENS frEchBdy=embedded_statement (cmnts=comments)?
	->foreachStatement(variableType={varTyp},variable={$var.text},expression={expr},forEachBody={frEchBdy},comment={cmnts})
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
	->returnStatement(returnExpr={CSharpHelper.processSingleResultSet($expr.text)},comments={comts})
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
  TRY bdy=block (cls=catch_clauses)? (finly=finally_clause)?
  ->tryStatement(tryBody={bdy},catchClas={cls},finallyBlk={finly})
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
	: 
	(cls+=specific_catch_clause)+
	->specificCatchClauses(clauses={$cls})
	;
specific_catch_clause 
	: 
	CATCH OPEN_PARENS t=class_type (nam=IDENTIFIER)? CLOSE_PARENS blk=block
	->specificCatchClause(type={t},typeName={$nam.text},body={blk})
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
	: 
	CHECKED blk=block
	->checkedStatement(body={blk})
	;
unchecked_statement 
	: 
	UNCHECKED blk=block
	->uncheckedStatement(body={blk})
	;
lock_statement 
	: LOCK OPEN_PARENS expression CLOSE_PARENS embedded_statement
	;
using_statement 
	: 
	kwd=USING OPEN_PARENS raq=resource_acquisition CLOSE_PARENS bdy=embedded_statement
	->usingStatement(resourceAcq={CSharpHelper.replaceSqlPart($raq.text)},body={bdy})
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
	: yield_contextual_keyword RETURN expression SEMICOLON
	| yield_contextual_keyword BREAK SEMICOLON
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
	->pkgDeclarationandClassBody(packageName={NamingUtil.toLowerCase($qi.text)},nameSpaceBody={nmsBdy},deleimiter={dl},comments={comts})
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
	OPEN_BRACE (alsDct=extern_alias_directives)? (imps=using_directives)? (nspcmems=namespace_member_declarations)? CLOSE_BRACE
	->createClassBody(alisDRctv={alsDct},imports={imps},nmspMemDec={nspcmems})
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
	->writeFormerClass(originalMember={CSharpHelper.filterOriginalMember($nameSpaceMemLst).toString()})
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
	 | INTERNAL                             ->text(value={"private"})
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
	IDENTIFIER       ->text(value={CSharpHelper.replaceJavaType($IDENTIFIER.text)})
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
  ->classBase(parentClass={CSharpHelper.prefixInheritanceType($cType.text)},classBody={$clsInfChldLst})
  ;
  
interface_type_list 
	: 
	iType=interface_type (clsInfChldLst+=classbaseandInterfaceChld)*
	->text(value={$iType.text+" "+$clsInfChldLst})
	;
	
classbaseandInterfaceChld
  :
  COMMA  intFaceName=interface_type 
  ->text(value={","+$intFaceName.text})
  ;
	
type_parameter_constraints_clauses 
	: 
	(consts+=type_parameter_constraints_clause)+
	->typeParameterConstraintsClauses(constraints={$consts})
	;
type_parameter_constraints_clause 
	: 
	whrKwd=where_contextual_keyword tp=type_parameter COLON tpc=type_parameter_constraints
	->typeParameterConstraintsClause(whereKwd={whrKwd},typPar={tp},typParConst={tpc})
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
  : 
  constr=constructor_constraint
  ->typeParameterConstraints(constraint={constr})
  | pc=primary_constraint (COMMA sc=secondary_constraints)? (COMMA cc=constructor_constraint)?
  ->typeParameterConstraints2(primaryConstr={pc},secondaryConstr={sc},constrCon={cc})
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
  : 
  it=interface_type (lst+=secondary_constraints_Chld)*
  ->secondaryConstraints(firstTyp={it},list={$lst})
  ;
secondary_constraints_Chld
  :
  COMMA it=interface_type
  ->secondaryConstraintsChld(iType={it}) 
  ;
   
constructor_constraint 
	: 
	NEW OPEN_PARENS CLOSE_PARENS
	->text(value={"new ()"})
	;
class_body 
	: 
	OPEN_BRACE  (clsMemDecs=class_member_declarations)?  CLOSE_BRACE
	->classBody(classMemdeclarations={clsMemDecs})
	;
class_member_declarations 
	: 
	(clsmemDecLst+=class_member_declaration)+
	->classMemberDeclarations(classMembersList={$clsmemDecLst})
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
	->classMemberDeclaration(attributes={attrs1},accessModifiers={acsModfrs1},comMemDec={cmd},methodName={getMethodName()})
	|(attrs2=attributes)? (acsModfrs2=all_member_modifiers)? TILDE IDENTIFIER OPEN_PARENS CLOSE_PARENS destructor_body
  ->classMemberDeclaration(attributes={attrs2},accessModifiers={acsModfrs1})
  ;
// added by chw
// combines all available modifiers
all_member_modifiers
  : 
  (m+=all_member_modifier)+
  ->spaceIterator(list={$m})
  ;
all_member_modifier
  : 
  NEW
  ->allMemberModifier(value={$NEW.text})
  | PUBLIC
  ->allMemberModifier(value={$PUBLIC.text})
  | PROTECTED
  ->allMemberModifier(value={$PROTECTED.text})
  | INTERNAL
  ->allMemberModifier(value={"private"})
  |PRIVATE
  ->allMemberModifier(value={$PRIVATE.text})
  | accsMod6=READONLY
  ->allMemberModifier(value={$accsMod6.text})
  | VOLATILE
  ->allMemberModifier(value={$VOLATILE.text})
  | VIRTUAL
  ->allMemberModifier(value={$VIRTUAL.text})
  | SEALED
  ->allMemberModifier(value={$SEALED.text})
  |OVERRIDE
  ->allMemberModifier(value={"@Override\n"})
  | ABSTRACT
  ->allMemberModifier(value={$ABSTRACT.text})
  |STATIC
  ->allMemberModifier(value={$STATIC.text})
  | UNSAFE
  ->allMemberModifier(value={$UNSAFE.text})
  | EXTERN
  ->allMemberModifier(value={$EXTERN.text})
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
  ->typedMemberDeclaration(type={CSharpHelper.replaceJavaType($t.text)},typeDecl={CSharpHelper.processTypedMemberDeclaration($t.text,$bdy.text)},body1={CSharpHelper.compareTypeAndBody(CSharpHelper.replaceJavaType($t.text),CSharpHelper.processTypedMemberDeclaration($t.text,$bdy.text))},body2={bdy})
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
	: 
	IDENTIFIER ASSIGNMENT expr=constant_expression
	->constantDeclarator(lhs={$IDENTIFIER.text},rhs={expr})
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
	->variableInitializer(init={vi1})
	| vi2=array_initializer
	->variableInitializer(init={vi2})
	;
method_declaration 
	: 
	mh=method_header mb=method_body
	->methodDeclaration(head={mh},body={mb})
	;
method_header 
	: 
	(at=attributes)? (mm=method_modifiers)? (pck=partial_contextual_keyword)? rt=return_type mn=member_name (tpl=type_parameter_list)? OPEN_PARENS (fpl=formal_parameter_list)? CLOSE_PARENS (tpcc=type_parameter_constraints_clauses)?
	->methodHeader(attributes={at},methodModifiers={mm},partialKwd={pck},retTyp={CSharpHelper.replaceJavaType($rt.text)},memNam={NamingUtil.toCamelCase($mn.text)},typParLst={tpl},formlParLst={fpl},typParConCls={tpcc})
	;
method_modifiers 
	: 
	(lst+=method_modifier)+
	->methodModifiers(list={$lst})
	;
method_modifier 
	: 
	NEW                  ->text(value={$NEW.text})
	| PUBLIC             ->text(value={$PUBLIC.text})
	| PROTECTED          ->text(value={$PROTECTED.text})
	| INTERNAL           ->text(value={"private"})
	| PRIVATE            ->text(value={$PRIVATE.text})
	| STATIC             ->text(value={$STATIC.text})
	| VIRTUAL            ->text(value={$VIRTUAL.text})
	| SEALED             ->text(value={$SEALED.text})
	| OVERRIDE           ->text(value={$OVERRIDE.text})
	| ABSTRACT           ->text(value={$ABSTRACT.text})
	| EXTERN             ->text(value={$EXTERN.text})
	| mmu=method_modifier_unsafe     ->text(value={$mmu.text})
	;
/** type | VOID */
return_type 
	: 
	t=type       ->returnType(type={t})
	| VOID       ->text(value={" void "})
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
	blk=block (comts1=comments)?
	->methodBody(body={blk},comments={comts1})
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
  (at=attributes)? (parModf=parameter_modifier)? t=type parNam=IDENTIFIER (defArg=default_argument)?
  ->fixedParameter(attributes={at},paramModifier={parModf},dataType={t},paramName={NamingUtil.toCamelCase($parNam.text)},defaultArgs={defArg})
  | arLst=arglist
  ->fixedParameter2(argumentList={arLst})
  ;
default_argument 
	: 
	ASSIGNMENT expr=expression
	->defaultArgument(expression={expr})
	;
parameter_modifier 
	: 
	REF          ->text(value={$REF.text})
	| OUT        ->text(value={$OUT.text})
	| THIS       ->text(value={$THIS.text})
	;
parameter_array 
	: 
	(atrs=attributes)? par=PARAMS array_type id=IDENTIFIER
	->parameterArray(atbts={atrs},param={$par.text},idName={NamingUtil.toCamelCase($id.text)})
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
  | INTERNAL                            ->text(value={"private"})
  | PRIVATE                             ->text(value={$PRIVATE.text})
  | STATIC                              ->text(value={$STATIC.text})
  | VIRTUAL                             ->text(value={$VIRTUAL.text})
  | SEALED                              ->text(value={$SEALED.text})
  | OVERRIDE                            ->text(value={"@Override\n"})
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
	PROTECTED               ->text(value={$PROTECTED.text})
 | INTERNAL               ->text(value={"private"})
 | PRIVATE                ->text(value={$PRIVATE.text})
 | PROTECTED INTERNAL     ->text(value={$PROTECTED.text+" "+"private"})
 | INTERNAL PROTECTED     ->text(value={"private"+" "+$PROTECTED.text})
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


//event_declaration 
//  : 
//  (at=attributes)? (em=event_modifiers)? EVENT t=type chld=event_declaration_Chld
//  ->eventDeclaration(attributes={at},evntModfs={em},type={t},child={chld})
//  ;
//  
//event_declaration_Chld
//  :
//  vd=variable_declarators SEMICOLON
//  ->eventDeclarationChld(varDecl={vd})
//  | mn=member_name OPEN_BRACE ead=event_accessor_declarations CLOSE_BRACE
//  ->eventDeclarationChld2(memNam={mn},evntAccDecl={ead})
//  ;
event_modifiers 
	: 
	(lst+=event_modifier)*
	->eventModifiers(list={$lst})
	;
event_modifier 
	: NEW                                ->text(value={$NEW.text})
   | PUBLIC                           ->text(value={$PUBLIC.text})
   | PROTECTED                        ->text(value={$PROTECTED.text})
   | INTERNAL                         ->text(value={"private"})
   | PRIVATE                          ->text(value={$PRIVATE.text})
   | STATIC                           ->text(value={$STATIC.text})
   | VIRTUAL                          ->text(value={$VIRTUAL.text})
   | SEALED                           ->text(value={$SEALED.text})
   | OVERRIDE                         ->text(value={"@Override\n"})
   | ABSTRACT                         ->text(value={$ABSTRACT.text})
   | EXTERN                           ->text(value={$EXTERN.text})
   | evntmod=event_modifier_unsafe    ->text(value={evntmod})
	;
event_accessor_declarations 
	: 
	(at=attributes)? chld=event_accessor_declarations_Chld
	->eventAccessorDeclarations(attributes={at},child={chld})
	;
	
event_accessor_declarations_Chld
  :
	ack=add_contextual_keyword blk1=block rad=remove_accessor_declaration
	->eventAccessorDeclarationsChld(kwd={ack},body={blk1},acssDecl={rad})
  | rck=remove_contextual_keyword blk2=block aad=add_accessor_declaration
  ->eventAccessorDeclarationsChld(kwd={rck},body={blk2},acssDecl={aad})
  ;
  
add_accessor_declaration 
	: 
	(at=attributes)? ack=add_contextual_keyword blk=block
	->addAccessorDeclaration(attributes={at},kwd={ack},body={blk})
	;
remove_accessor_declaration 
	: 
	(at=attributes)? rck=remove_contextual_keyword blk=block
	->removerAccessorDeclaration(attributes={at},kwd={rck},body={blk})
	;
indexer_declaration 
	: 
	(at=attributes)? (im=indexer_modifiers)? id=indexer_declarator OPEN_BRACE ad=accessor_declarations CLOSE_BRACE
	->indexerDeclaration(attributes={at},modfs={im},indexerDecl={id},accsrDecl={ad})
	;
indexer_modifiers 
	: 
	(lst+=indexer_modifier)+
	->indexerModifiers(list={$lst})
	;
indexer_modifier 
	:        
	NEW                                    ->text(value={$NEW.text})
	| PUBLIC                               ->text(value={$PUBLIC.text})
	| PROTECTED                            ->text(value={$PROTECTED.text})
	| INTERNAL                             ->text(value={"private"})
	| PRIVATE                              ->text(value={$PRIVATE.text})
	| VIRTUAL                              ->text(value={$VIRTUAL.text})
	| SEALED                               ->text(value={$SEALED.text})
	| OVERRIDE                             ->text(value={"@Override\n"})
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
  : 
  t=type (it=interface_type DOT)? THIS OPEN_BRACKET fpl=formal_parameter_list CLOSE_BRACKET
  ->indexerDeclarator(type={t},intfcTyp={it},formlParLst={fpl})
  ;
operator_declaration 
	: 
	(at=attributes)? om=operator_modifiers od=operator_declarator ob=operator_body
	->operatorDeclaration(attributes={at},optrModfs={om},optrDecl={od},optrBody={ob})
	;
operator_modifiers 
	: 
	(lst+=operator_modifier)+
	->operatorModifiers(list={$lst})
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
  : 
  (unary_operator_declarator) => uod=unary_operator_declarator
  ->operatorDeclarator(optrDecl={uod})
  | bod=binary_operator_declarator
  ->operatorDeclarator(optrDecl={bod})
  | cod=conversion_operator_declarator
  ->operatorDeclarator(optrDecl={cod})
  ;
unary_operator_declarator 
	: 
	t=type OPERATOR ouop=overloadable_unary_operator OPEN_PARENS t2=type IDENTIFIER CLOSE_PARENS
	->unaryOperatorDeclarator(type={t},overldbleUnryOptr={ouop},innerTyp={t2},name={$IDENTIFIER.text})
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
	: 
	t=type OPERATOR obo=overloadable_binary_operator OPEN_PARENS t2=type id1=IDENTIFIER COMMA t3=type id2=IDENTIFIER CLOSE_PARENS
	->binaryOperatorDeclarator(type={t},binryOptr={obo},innerTyp1={t2},innerTyp1Nam={$id1.text},innerTyp2={t3},innerTyp2Nam={$id2.text})
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
	: 
	kwd1=IMPLICIT OPERATOR t1=type OPEN_PARENS innerTyp1=type innerTyp1Nam=IDENTIFIER CLOSE_PARENS
	->conversionOperatorDeclarator(keyWrd={$kwd1.text},type1={t1},innerType1={innerTyp1},innerTyp1Name={$innerTyp1Nam.text})
	| kwd2=EXPLICIT OPERATOR t2=type OPEN_PARENS innerTyp2=type innerTyp2Nam=IDENTIFIER CLOSE_PARENS
	->conversionOperatorDeclarator(keyWrd={$kwd2.text},type1={t2},innerType1={innerTyp2},innerTyp1Name={$innerTyp2Nam.text})
	;
operator_body 
   : 
   blk=block       ->text(value={blk})
   | SEMICOLON     ->text(value={$SEMICOLON.text})
   ;

constructor_declaration 
	: 
	(at=attributes)? (cm=constructor_modifiers)? cd=constructor_declarator cb=constructor_body
	->constructorDeclaration(attributes={at},modfs={cm},decl={cd},body={cb})
	;
constructor_modifiers 
	: 
	(lst+=constructor_modifier)+
	->constructorModifiers(list={$lst})
	;
constructor_modifier 
  : 
  PUBLIC                                    ->text(value={$PUBLIC.text})
  | PROTECTED                               ->text(value={$PROTECTED.text})
  | INTERNAL                                ->text(value={"private"})
  | PRIVATE                                 ->text(value={$PRIVATE.text})
  | EXTERN                                  ->text(value={$EXTERN.text})
  | consmd=constructor_modifier_unsafe      ->text(value={consmd})
  ;
constructor_declarator 
	: 
	IDENTIFIER OPEN_PARENS (fpl=formal_parameter_list)? CLOSE_PARENS (ci=constructor_initializer)?
	->constructorDeclarator(declNam={$IDENTIFIER.text},formlParLst={fpl},constrInit={ci})
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
	: 
	(at=attributes)? scm=static_constructor_modifiers IDENTIFIER OPEN_PARENS CLOSE_PARENS scb=static_constructor_body
	->staticConstructorDeclaration(attributes={at},modfs={scm},conNam={$IDENTIFIER.text},conBody={scb})
	;
/*
static_constructor_modifiers 
	: EXTERN? STATIC
	| STATIC EXTERN?
	| static_constructor_modifiers_unsafe
	;
*/
static_constructor_modifiers 
  : 
  modfs=static_constructor_modifiers_unsafe
  ->staticConstructorModifiers(modifiers={modfs})
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
	: 
	ddu=destructor_declaration_unsafe
	->destructorDeclaration(decl={ddu})
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
	: 
	attributes? struct_modifiers? partial_contextual_keyword? STRUCT IDENTIFIER type_parameter_list? struct_interfaces? type_parameter_constraints_clauses? struct_body SEMICOLON?
	;
struct_modifiers 
	: 
	(lst+=struct_modifier)+
	->structModifiers(list={$lst})
	;
struct_modifier 
  : 
  NEW                                  ->text(value={$NEW.text})
  | PUBLIC                             ->text(value={$PUBLIC.text})
  | PROTECTED                          ->text(value={$PROTECTED.text})
  | INTERNAL                           ->text(value={"private"})
  | PRIVATE                            ->text(value={$PRIVATE.text})
  | strmod=struct_modifier_unsafe      ->text(value={strmod})
  ;

struct_interfaces 
	: 
	COLON interface_type_list
	;
struct_body 
	:
	 OPEN_BRACE struct_member_declarations? CLOSE_BRACE
	;
struct_member_declarations 
	: 
	struct_member_declaration ( struct_member_declaration )*
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
	->arrayTypeChld(symbolLst={"?"},rnkSpcr={rns})
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
	: 
	(at=attributes)? (im=interface_modifiers)? (pck=partial_contextual_keyword)? INTERFACE iName=IDENTIFIER (vtpl=variant_type_parameter_list)? (ib=interface_base)? (tpcc=type_parameter_constraints_clauses)? ibdy=interface_body (dlMtr=SEMICOLON)?
	->interfaceDeclaration(attributes={at},intFcModfs={im},partialKwd={pck},interfaceName={" interface "+$iName.text},varTypParLst={vtpl},intfcBas={ib},typParConstCls={tpcc},intfcBody={ibdy},delimiter={$dlMtr.text})
	;
interface_modifiers 
	: 
	(im+=interface_modifier)+
	->interfaceModifiers(list={$im})
	;
interface_modifier 
  : 
  NEW                                     ->text(value={$NEW.text})
  | PUBLIC                                ->text(value={$PUBLIC.text})
  | PROTECTED                             ->text(value={$PROTECTED.text})
  | INTERNAL                              ->text(value={"private"})
  | PRIVATE                               ->text(value={$PRIVATE.text})
  | intrmod=interface_modifier_unsafe     ->text(value={intrmod})
  ;

variant_type_parameter_list 
	: 
	LT vtp=variant_type_parameters GT
	->variantTypeParameterList(params={vtp})
	;
variant_type_parameters 
	: 
	attributes? variance_annotation? type_parameter ( COMMA  attributes?  variance_annotation?  type_parameter )*
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
	OPEN_BRACE (imd=interface_member_declarations)? CLOSE_BRACE
	->interfaceBody(members={imd})
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
  (at=attributes)? (n=NEW)? chld=interface_member_declaration_Chld
  ->interfaceMemberDeclaration(attributes={at},newKwd={$n.text},child={chld})
  ;
interface_member_declaration_Chld
  :
  t=type  subChld=interface_member_declaration_sub_Chld
  ->interfaceMemberDeclarationChld(type={CSharpHelper.replaceJavaType($t.text)},subChild={subChld})
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
	: 
	(at=attributes)? (n=NEW)? t=return_type IDENTIFIER (tpl=type_parameter_list)? OPEN_PARENS (fpl=formal_parameter_list)? CLOSE_PARENS (tpcc=type_parameter_constraints_clauses)? SEMICOLON
	->interfaceMethodDeclaration(attributes={at},newKwd={$n.text},type={t},methdNam={$IDENTIFIER.text},typParLst={tpl},fprmlParLst={fpl},typParConstCls={tpcc})
	;
interface_property_declaration 
	: 
	(at=attributes)? (n=NEW)? t=type IDENTIFIER OPEN_BRACE ia=interface_accessors CLOSE_BRACE
	->interfacePropertyDeclaration(attributes={at},newKwd={$n.text},type={t},propName={$IDENTIFIER.text},intfcAccrs={ia})
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
    ( get_contextual_keyword SEMICOLON (attributes? set_contextual_keyword SEMICOLON)?
    | set_contextual_keyword SEMICOLON (attributes? get_contextual_keyword SEMICOLON)?
    )
  ->interfaceAccessors(attributes={at})  
  ;
interface_event_declaration 
	: 
	(at=attributes)? (n=NEW)? EVENT t=type IDENTIFIER SEMICOLON
	->interfaceEventDeclaration(attributes={at},newKwd={$n.text},type={t},evntName={$IDENTIFIER.text})
	;
interface_indexer_declaration 
	: 
	(at=attributes)? (n=NEW)? t=type THIS OPEN_BRACKET fpl=formal_parameter_list CLOSE_BRACKET OPEN_BRACE ia=interface_accessors CLOSE_BRACE
	->interfaceIndexerDeclaration(attributes={at},newKwd={$n.text},type={t},formlParLst={fpl},accs={ia})
	;


//B.2.11 Enums
enum_declaration 
	: attr=attributes? enummod=enum_modifiers? ENUM IDENTIFIER enumbase=enum_base? enumbody=enum_body SEMICOLON?
	->enumdeclaration(attr={attr},enummod={enummod},enumbase={enumbase},enumbody={enumbody})
	;
enum_base 
	: COLON inttype=integral_type
	->enumbase(inttype={inttype})
	;
/*
enum_body 
	: OPEN_BRACE enum_member_declarations? CLOSE_BRACE
	| OPEN_BRACE enum_member_declarations COMMA CLOSE_BRACE
	;
*/
enum_body 
  : OPEN_BRACE CLOSE_BRACE
  | OPEN_BRACE enumdec=enum_member_declarations COMMA? CLOSE_BRACE
  ->enumbody(enumdec={enumdec})
  ;
enum_modifiers 
	: (enummodifier=enum_modifier)+
	->enummodifiers(enummodifier={enummodifier})
	;
enum_modifier 
  : 
  NEW               ->text(value={$NEW.text})
  | PUBLIC          ->text(value={$PUBLIC.text})
  | PROTECTED       ->text(value={$PROTECTED.text})
  | INTERNAL        ->text(value={"private"})
  | PRIVATE         ->text(value={$PRIVATE.text})
  ;

enum_member_declarations 
	: enumemdec=enum_member_declaration ( COMMA  enumemdec1=enum_member_declaration )*
	->enummemberdeclarations(enumemdec={enumemdec},enumemdec1={enumemdec1})
	;
/*
enum_member_declaration 
	: attributes? IDENTIFIER
	| attributes? IDENTIFIER ASSIGNMENT constant_expression
	;
*/
enum_member_declaration 
  : attrib=attributes? IDENTIFIER (ASSIGNMENT constexpres=constant_expression)?
  ->enummemberdeclaration(attrib={attrib},constexpres={constexpres})
  ;

//B.2.12 Delegates
delegate_declaration 
	: attributes? delegate_modifiers? DELEGATE return_type IDENTIFIER variant_type_parameter_list? 
	    OPEN_PARENS formal_parameter_list? CLOSE_PARENS type_parameter_constraints_clauses? SEMICOLON
	;
delegate_modifiers 
	: 
	delegate_modifier ( delegate_modifier )*
	;
delegate_modifier 
  : 
  NEW                                    ->text(value={$NEW.text})
  | PUBLIC                               ->text(value={$PUBLIC.text})
  | PROTECTED                            ->text(value={$PROTECTED.text})
  | INTERNAL                             ->text(value={"private"})
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
	attSec=attribute_sections        ->attributes(value={attSec})
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
  OPEN_BRACKET (attTarSpec=attribute_target_specifier)? attLst=attribute_list (septr=COMMA)? CLOSE_BRACKET
  ->attributeSection(attributeTargetSpecifier={attTarSpec},attributeList={attLst},separtr={$septr.text})
  ;
attribute_target_specifier 
	: 
	attTar=attribute_target COLON
	->text(value={$attTar.text+" : "})
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
	->attribute(attributeName={attNam},attributeArgs={attArgs})
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
  : 
  EXTERN?  STATIC
  ->staticConstructorModifiersUnsafe(fstKwd={$EXTERN.text},secndKwd={$STATIC.text})
  | UNSAFE? STATIC
  ->staticConstructorModifiersUnsafe(fstKwd={$UNSAFE.text},secndKwd={$STATIC.text})
  | EXTERN UNSAFE STATIC
  ->text(value={$EXTERN.text+" "+$UNSAFE.text+" "+$STATIC.text})
  | UNSAFE EXTERN STATIC
  ->text(value={$UNSAFE.text+" "+$EXTERN.text+" "+$STATIC.text})
  | EXTERN STATIC UNSAFE
  ->text(value={$EXTERN.text+" "+$STATIC.text+" "+$UNSAFE.text})
  | UNSAFE STATIC EXTERN
  ->text(value={$UNSAFE.text+" "+$STATIC.text+" "+$EXTERN.text})
  | STATIC EXTERN 
  ->text(value={$STATIC.text+" "+$EXTERN.text})
  | STATIC UNSAFE
  ->text(value={$STATIC.text+" "+$UNSAFE.text})
  | STATIC EXTERN UNSAFE
  ->text(value={$STATIC.text+" "+$EXTERN.text+" "+$UNSAFE.text})
  | STATIC UNSAFE EXTERN
  ->text(value={$STATIC.text+" "+$UNSAFE.text+" "+$EXTERN.text})
  ;
/** starts with UNSAFE or FIXED */
embedded_statement_unsafe 
	: 
	unsfStmt=unsafe_statement
	->embeddedStatementUnsafe(stmt={unsfStmt})
	| fxdStmt=fixed_statement
	->embeddedStatementUnsafe(stmt={fxdStmt})
	;
unsafe_statement 
	: 
	UNSAFE blk=block
	->unsafeStatement(block={blk})
	;
type_unsafe 
	: 
	pointer_type
	->text(value={""})  
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
  : 
  ( simple_type | class_type | VOID {allowAll = false;}) ( {allowAll}? => rank_specifier | {allowAll}? => INTERR | STAR {allowAll = true;})* STAR
  ->text(value={""})  
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
	: 
	piExpr=pointer_indirection_expression
	->unaryExpressionUnsafe(expression={piExpr})
	| aoExpr=addressof_expression
	->unaryExpressionUnsafe(expression={aoExpr})
	;
pointer_indirection_expression 
	: 
	STAR expr=unary_expression
	->pointerIndirectionExpression(expression={expr})
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
	: 
	AMP expr=unary_expression
	->addressofExpression(expression={expr})
	;
sizeof_expression 
	: 
	SIZEOF OPEN_PARENS ut=unmanaged_type CLOSE_PARENS
	->sizeofExpression(type={ut})
	;
fixed_statement 
	: 
	FIXED OPEN_PARENS pt=pointer_type fpd=fixed_pointer_declarators CLOSE_PARENS es=embedded_statement
	->fixedStatement(type={pt},ptrDecl={fpd},stmts={es})
	;
fixed_pointer_declarators 
	: 
	fstDecl=fixed_pointer_declarator (chld+=fixed_pointer_declarators_Chld)*
	->fixedPointerDeclarators(firstDecl={fstDecl},list={$chld})
	;
	
fixed_pointer_declarators_Chld
	:
	COMMA  fpd=fixed_pointer_declarator
	->fixedPointerDeclaratorsChld(decl={fpd})
	;
	
fixed_pointer_declarator 
	: 
	IDENTIFIER ASSIGNMENT fpi=fixed_pointer_initializer
	->fixedPointerDeclarator(lhs={$IDENTIFIER.text},rhs={fpi})
	;
/*
fixed_pointer_initializer 
	: AMP variable_reference
	| expression
	;
*/
fixed_pointer_initializer 
  : 
  (AMP) => AMP varInit=variable_reference
  ->fixedPointerInitializer(init={"&"+varInit})
  | expr=expression
  ->fixedPointerInitializer(init={expr})
  ;
struct_member_declaration_unsafe 
	: 
	fsbd=fixed_size_buffer_declaration
	->structMemberDeclarationUnsafe(decl={fsbd})
	;
fixed_size_buffer_declaration 
	: 
	(ats=attributes)? (fsbm=fixed_size_buffer_modifiers)? FIXED bet=buffer_element_type fsbd=fixed_size_buffer_declarators SEMICOLON
	->fixedSizeBufferDeclaration(attributes={ats},fxdSzBufModf={fsbm},bufElmntTyp={bet},fxdSzBufDcls={fsbd})
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
  | INTERNAL        ->text(value={"private"})
  | PRIVATE         ->text(value={$PRIVATE.text})
  | UNSAFE          ->text(value={$UNSAFE.text})
  ;

buffer_element_type 
	: 
	t=type
	->bufferElementType(type={t})
	;
fixed_size_buffer_declarators 
	: 
	(decls+=fixed_size_buffer_declarator)+
	->fixedSizeBufferDeclarators(declarators={$decls})
	;
fixed_size_buffer_declarator 
	: 
	IDENTIFIER OPEN_BRACKET expr=constant_expression CLOSE_BRACKET
	->fixedSizeBufferDeclarator(name={$IDENTIFIER.text},expression={expr})
	;
/** starts with STACKALLOC */
local_variable_initializer_unsafe 
	: 
	stkInit=stackalloc_initializer
	->localVariableInitializerUnsafe(init={stkInit})
	;
stackalloc_initializer 
	: 
	STACKALLOC t=unmanaged_type OPEN_BRACKET expr=expression CLOSE_BRACKET
	->stackallocInitializer(umManTyp={t},expression={expr})
	;

	
// ---------------------------------- rules not defined in the original parser ----------
// ---------------------------------- rules not defined in the original parser ----------
// ---------------------------------- rules not defined in the original parser ----------
// ---------------------------------- rules not defined in the original parser ----------


from_contextual_keyword
  : 
  {input.LT(1).getText().equals("from")}? IDENTIFIER
  ->text(value={"from "})
  ;
let_contextual_keyword
  : {input.LT(1).getText().equals("let")}? IDENTIFIER
   ->text(value={"let "})
  ;
where_contextual_keyword
  : {input.LT(1).getText().equals("where")}? IDENTIFIER
  ->text(value={"where "})
  ;
join_contextual_keyword
  : {input.LT(1).getText().equals("join")}? IDENTIFIER
   ->text(value={"join "})
  ;
on_contextual_keyword
  : {input.LT(1).getText().equals("on")}? IDENTIFIER
   ->text(value={"on "})
  ;
equals_contextual_keyword
  : 
  {input.LT(1).getText().equals("equals")}? IDENTIFIER
   ->text(value={"equals "})
  ;
into_contextual_keyword
  : {input.LT(1).getText().equals("into")}? IDENTIFIER
   ->text(value={"into "})
  ;
orderby_contextual_keyword
  : {input.LT(1).getText().equals("orderby")}? IDENTIFIER
    ->text(value={"orderby "})
  ;
ascending_contextual_keyword
  : {input.LT(1).getText().equals("ascending")}? IDENTIFIER
    ->text(value={"ascending "})
  ;
descending_contextual_keyword
  : {input.LT(1).getText().equals("descending")}? IDENTIFIER
    ->text(value={"descending "})
  ;
select_contextual_keyword
  : {input.LT(1).getText().equals("select")}? IDENTIFIER
    ->text(value={"select "})
  ;
group_contextual_keyword
  : 
  {input.LT(1).getText().equals("group")}? id=IDENTIFIER
  ->text(value={"group  "})
  ;
by_contextual_keyword
  : 
  {input.LT(1).getText().equals("by")}? id=IDENTIFIER
  ->text(value={"by "})
  ;
partial_contextual_keyword
  : 
  {input.LT(1).getText().equals("partial")}? id=IDENTIFIER
  ->text(value={"partial "})
  ;
alias_contextual_keyword
  : {input.LT(1).getText().equals("alias")}? IDENTIFIER
     ->text(value={"alias "})
  ;
yield_contextual_keyword
  : {input.LT(1).getText().equals("yield")}? IDENTIFIER
     ->text(value={"yield "+$IDENTIFIER.text})
  ;
get_contextual_keyword
  : 
  {input.LT(1).getText().equals("get")}? IDENTIFIER
  ->getContextualKeyword(value={"get "})
  ;
set_contextual_keyword
  : 
  {input.LT(1).getText().equals("set")}? IDENTIFIER
  ->setContextualKeyword(value={"set "})
  ;
add_contextual_keyword
  : {input.LT(1).getText().equals("add")}? IDENTIFIER
    ->text(value={"add "})
  ;
remove_contextual_keyword
  : 
  {input.LT(1).getText().equals("remove")}? id=IDENTIFIER
  ->text(value={"remove "})
  ;
dynamic_contextual_keyword
  : 
  {input.LT(1).getText().equals("dynamic")}? id=IDENTIFIER
  ->text(value={"dynamic "})
  ;
arglist
  : 
  {input.LT(1).getText().equals("__arglist")}? id=IDENTIFIER
  ->text(value={"__arglist "})
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
   | BOOL         ->text(value={"boolean"})
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
   | INTERNAL     ->text(value={"private"})
   | IS           ->text(value={$IS.text})
   | LOCK         ->text(value={$LOCK.text})
   | LONG         ->text(value={$LONG.text})
   | NAMESPACE    ->text(value={$NAMESPACE.text})
   | NEW          ->text(value={$NEW.text})
   | NULL         ->text(value={$NULL.text})
   | OBJECT       ->text(value={"Object"})
   | OPERATOR     ->text(value={$OPERATOR.text})
   | OUT          ->text(value={$OUT.text})
   | OVERRIDE     ->text(value={"@Override\n"})
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

class_definition
  : 
  CLASS clsNam=IDENTIFIER type_parameter_list? (basCls=class_base)? type_parameter_constraints_clauses?  (comts1=comments)?
      clsBdy=class_body (dl=SEMICOLON)? (comts=comments)?
  ->classDefinition(className={$clsNam.text},baseClass={basCls},comments1={comts1},classBody={clsBdy},delimiter={$dl.text},comments={comts})
  ;
struct_definition
  : 
  STRUCT nam=IDENTIFIER (tpl=type_parameter_list)? (si=struct_interfaces)? (tpcc=type_parameter_constraints_clauses)? (sb=struct_body) (dlMtr=SEMICOLON)?
  ->structDefinition(structName={nam},typParLst={tpl},strctIntfc={si},typParConstCls={tpcc},body={sb},delimiter={$dlMtr.text})
  ;
interface_definition
  : 
  INTERFACE nam=IDENTIFIER (vtpl=variant_type_parameter_list)? (ib=interface_base)? (tpcc=type_parameter_constraints_clauses)? bdy=interface_body (dlMtr=SEMICOLON)?
  ->interfaceDefinition(kwd={$INTERFACE.text+" "},interfaceName={$nam.text},varTypLst={vtpl},intfcBdy={ib},constrntCls={tpcc},body={bdy},delimiter={$dlMtr.text})
  ;
enum_definition
  : 
  ENUM IDENTIFIER (eb=enum_base)? bdy=enum_body dlMtr=SEMICOLON?
  ->enumDefinition(name={$IDENTIFIER.text},base={eb},body={bdy},delimiter={$dlMtr.text})
  ;
delegate_definition
  : 
  DELEGATE rt=return_type IDENTIFIER (vtpl=variant_type_parameter_list)? OPEN_PARENS (fpl=formal_parameter_list)? CLOSE_PARENS (tpcc=type_parameter_constraints_clauses)? SEMICOLON
  ->delegateDefinition(retType={rt},retVal={$IDENTIFIER.text},varTypeParLst={vtpl},formlParLst={fpl},constrntCls={tpcc})
  ;
event_declaration2
  : 
  EVENT t=type {$common_member_declaration::type = $type.tree;} chld=event_declaration2_Chld
  ->eventDeclaration2(type={t},evntDeclChld={chld}) 
  ;
  
event_declaration2_Chld
  :
  decl=variable_declarators SEMICOLON
  ->eventDeclaration2Chld(declaration={decl})
  |mName=member_name OPEN_BRACE ad=event_accessor_declarations CLOSE_BRACE
  ->eventDeclaration2Chld2(memberName={mName},accsDecl={ad})
  ;
  
field_declaration2
  : 
  varDec=variable_declarators SEMICOLON (comts=comments)?
  ->fieldDeclaration2(declaration={$varDec.st.toString().trim()},comments={comts})
  ;
property_declaration2
  : 
  mNam=member_name OPEN_BRACE ad=accessor_declarations CLOSE_BRACE
  ->propertyDeclaration2(mNm={mNam},ad1={ad})
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
  id=IDENTIFIER OPEN_PARENS (fpl=formal_parameter_list)? CLOSE_PARENS (cotrInit=constructor_initializer)? bdy=body
  ->constructorDeclaration2(constrName={$id.text},formalParamLst={fpl},constrInit={cotrInit},constrBdy={bdy})
  ;

comments  
  :
  (comLst+=comment)+
  ->comments(list={$comLst})
  ;

comment
  :
  SINGLE_LINE_COMMENT  
  ->comment(content={CSharpHelper.preProcessSingleLineComment($SINGLE_LINE_COMMENT.text)})
  |SINGLE_LINE_DOC_COMMENT
  ->comment(content={CSharpHelper.preProcessSingleLineComment($SINGLE_LINE_DOC_COMMENT.text)})
  ;
  
method_declaration2
  : 
  mthdNam=method_member_name (parLst=type_parameter_list)?  OPEN_PARENS (fpl=formal_parameter_list)? CLOSE_PARENS
      (cluses=type_parameter_constraints_clauses)? (comts=comments)? mBdy=method_body
  ->methodDeclaration2(methodName={NamingUtil.toCamelCase($mthdNam.text)},typeParamLst={parLst},formalParamLst={fpl},paramClauses={cluses},commnents={comts},methodBody={mBdy})
  ;
// added by chw to allow detection of type parameters for methods
method_member_name
  : 
  mName=method_member_name2
  ->methodMemberName(methodName={$mName.st.toString().trim()+""+assignMethodName($mName.st.toString().trim())})
  ;
method_member_name2
  : 
  strtId=IDENTIFIER (lst+=method_member_name2_chld)*
  ->methodMemberName2(startId={CSharpHelper.replaceJavaMethod(NamingUtil.toCamelCase($strtId.text))},list={$lst})
  | id1=IDENTIFIER DOUBLE_COLON id2=IDENTIFIER (lst+=method_member_name2_chld)*
  ->methodMemberName2(startId={$id1.text+" "+$id2.text},list={$lst})
  ;
  
method_member_name2_chld
  :
  tal=type_argument_list_opt DOT eId=IDENTIFIER
  ->methodMemberName2Chld(typArglst={tal},endId={CSharpHelper.replaceJavaMethod(NamingUtil.toCamelCase($eId.text))})
  ;
operator_declaration2
  : 
  OPERATOR ovlOptr=overloadable_operator OPEN_PARENS t=type id1=IDENTIFIER (COMMA t2=type id2=IDENTIFIER)? CLOSE_PARENS bdy=operator_body
  ->operatorDeclaration2(firstOptr={$OPERATOR.text},overloadableOptr={ovlOptr},type={t},typeNam={$id1.text},type2={t2},typeNam2={$id2.text},OptrBody={bdy})
  ;
interface_method_declaration2
  : 
  IDENTIFIER (parLst=type_parameter_list)? OPEN_PARENS fpl=formal_parameter_list? CLOSE_PARENS (clus=type_parameter_constraints_clauses)? SEMICOLON
  ->interfaceMethodDeclaration2(methodName={$IDENTIFIER.text},paramList={parLst},formlParLst={fpl},constraintCls={clus})
  ;
interface_property_declaration2
  : 
  IDENTIFIER OPEN_BRACE accrs=interface_accessors CLOSE_BRACE
  ->interfacePropertyDeclaration2(name={$IDENTIFIER.text},accessors={accrs})
  ;
interface_event_declaration2
  : EVENT t=type IDENTIFIER SEMICOLON
  ->interfaceEventDeclaration2(type={t},eventName={$IDENTIFIER.text})
  ;
interface_indexer_declaration2
  : 
  THIS OPEN_BRACKET fpl=formal_parameter_list CLOSE_BRACKET OPEN_BRACE intAccs=interface_accessors CLOSE_BRACE
  ->interfaceIndexerDeclaration2(frmlParLst={fpl},accessors={intAccs})
  ;
/** starts with DOT IDENTIFIER */
member_access2
  : 
  DOT id=IDENTIFIER tal=type_argument_list_opt
  ->memberAccess2(memName={CSharpHelper.replaceJavaMethod(NamingUtil.toCamelCase($id.text))},argLst={tal})
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
  
  