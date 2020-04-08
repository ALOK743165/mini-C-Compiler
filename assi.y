%{
	int yylineno;
	char data_type[200];
%}
%expect 8
%nonassoc NO_ELSE
%nonassoc  ELSE 
%left '<' '>' '=' GE_OP LE_OP EQ_OP NE_OP 
%left  '+'  '-'
%left  '*'  '/' '%'
%left  '|'
%left  '&'
%token IDENTIFIER CONSTANT STRING_LITERAL REPETITION
%token INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN
%token CHAR INT LONG FLOAT DOUBLE VOID 
%token IF ELSE WHILE DO FOR GOTO BREAK RETURN
%union{
	char str[1000];
}
%%
start : external_declaration | start external_declaration | repetition start ;

primary_expression
	: IDENTIFIER { insertToHash($<str>1, data_type , yylineno); }
	| CONSTANT | STRING_LITERAL | '(' expression ')' ;

repetition : REPETITION ;

postfix_expression : primary_expression | postfix_expression '[' expression ']'
	| postfix_expression '(' ')' | postfix_expression '(' argument_expression_list ')'
	| postfix_expression INC_OP | postfix_expression DEC_OP ;

argument_expression_list : assignment_expression
	| argument_expression_list ',' assignment_expression ;

unary_expression : postfix_expression | INC_OP unary_expression | DEC_OP unary_expression
	| unary_operator cast_expression ;

unary_operator : '&' | '*' | '+' | '-' | '~' | '!' ;

cast_expression : unary_expression | '(' type_name ')' cast_expression ;

multiplicative_expression : cast_expression
	| multiplicative_expression '*' cast_expression
	| multiplicative_expression '/' cast_expression
	| multiplicative_expression '%' cast_expression ;

additive_expression : multiplicative_expression
	| additive_expression '+' multiplicative_expression
	| additive_expression '-' multiplicative_expression
	;

shift_expression : additive_expression
	| shift_expression LEFT_OP additive_expression
	| shift_expression RIGHT_OP additive_expression ;

relational_expression : shift_expression
	| relational_expression '<' shift_expression
	| relational_expression '>' shift_expression
	| relational_expression LE_OP shift_expression
	| relational_expression GE_OP shift_expression ;

equality_expression : relational_expression
	| equality_expression EQ_OP relational_expression
	| equality_expression NE_OP relational_expression ;

and_expression : equality_expression | and_expression '&' equality_expression ;

exclusive_or_expression : and_expression | exclusive_or_expression '^' and_expression ;

inclusive_or_expression : exclusive_or_expression
	| inclusive_or_expression '|' exclusive_or_expression ;

logical_and_expression : inclusive_or_expression
	| logical_and_expression AND_OP inclusive_or_expression ;

logical_or_expression : logical_and_expression
	| logical_or_expression OR_OP logical_and_expression ;

conditional_expression : logical_or_expression
	| logical_or_expression '?' expression ':' conditional_expression ;

assignment_expression : conditional_expression
	| unary_expression assignment_operator assignment_expression ;

assignment_operator : '=' | MUL_ASSIGN | DIV_ASSIGN | MOD_ASSIGN | ADD_ASSIGN
				| SUB_ASSIGN ;

expression : assignment_expression | expression ',' assignment_expression;

constant_expression : conditional_expression ;

declaration : declaration_specifiers ';'
	| declaration_specifiers init_declarator_list ';' ;

declaration_specifiers : type_specifier	{ strcpy(data_type, $<str>1); }
	| type_specifier declaration_specifiers ;

init_declarator_list : init_declarator | init_declarator_list ',' init_declarator ;

init_declarator : declarator | declarator '=' initializer ;

type_specifier : VOID | CHAR | INT | LONG | FLOAT | DOUBLE ;

specifier_qualifier_list : type_specifier specifier_qualifier_list | type_specifier ;

declarator : direct_declarator ;

direct_declarator : IDENTIFIER | '(' declarator ')'
	| direct_declarator '[' constant_expression ']' | direct_declarator '[' ']'
	| direct_declarator '(' parameter_list ')'
	| direct_declarator '(' identifier_list ')' | direct_declarator '(' ')' ;

parameter_list : parameter_declaration | parameter_list ',' parameter_declaration ;

parameter_declaration : declaration_specifiers declarator
	| declaration_specifiers ;

identifier_list : IDENTIFIER | identifier_list ',' IDENTIFIER ;

type_name : specifier_qualifier_list | specifier_qualifier_list declarator ;

initializer : assignment_expression | '{' initializer_list '}'
	| '{' initializer_list ',' '}' ;

initializer_list : initializer | initializer_list ',' initializer ;

statement : compound_statement | expression_statement | selection_statement
	| iteration_statement | jump_statement ;

compound_statement : '{' '}' | '{' statement_list '}' | '{' declaration_list '}'
	| '{' declaration_list statement_list '}' ;

declaration_list : declaration | declaration_list declaration ;

statement_list : statement | statement_list statement ;

expression_statement : ';' | expression ';' ;

selection_statement : IF '(' expression ')' statement    %prec NO_ELSE
	| IF '(' expression ')' statement ELSE statement | GOTO IDENTIFIER ';'
	| IDENTIFIER ':' ;

iteration_statement : WHILE '(' expression ')' statement
	| DO statement WHILE '(' expression ')' ';'
	| FOR '(' expression_statement expression_statement ')' statement
	| FOR '(' expression_statement expression_statement expression ')' statement ;

jump_statement : BREAK ';' | RETURN ';' | RETURN expression ';' ;

external_declaration : function_definition | declaration ;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement
	| declaration_specifiers declarator compound_statement
	| declarator declaration_list compound_statement
	| declarator compound_statement ;
%%
#include "lex.yy.c"
#include <stdio.h>
#include <string.h>
int main(int argc, char *argv[]){
	yyin = fopen(argv[1], "r");
	if(!yyparse())
		printf("\nVALID\n");
	else
		printf("\nINVALID\n");

	fclose(yyin);
	display();
	disp();
	return 0;
}
extern char *yytext;
yyerror(char *s) {
	printf("\nLine %d : %s\n", (yylineno), s);
}         