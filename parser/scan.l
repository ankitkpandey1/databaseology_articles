%option noyywrap nodefault yylineno case-insensitive
%{
#include "parse.tab.h"
#include <stdarg.h>
#include <string.h>
void yyerror(char *s, ...);
int oldstate;
%}
%x COMMENT
%s BTWMODE
%%


 /* keywords */
CREATE { return CREATE; }
DATABASE { return DATABASE; }
DEFAULT { return DEFAULT; }
DISTINCT { return DISTINCT; }
EXISTS { yylval.subtok = 0; return EXISTS; }
NOT[ \t\n]+EXISTS { yylval.subtok = 1; return EXISTS; }
FROM { return FROM; }
IN { return IN; }
INSERT { return INSERT; }
INTO { return INTO; }
IS { return IS; }
BY { return BY; }

INDEX|KEY { return KEY; }
LIKE { return LIKE; }
LIMIT { return LIMIT; }
LONG { return LONG; }
LONGBLOB { return LONGBLOB; }
LONGTEXT { return LONGTEXT; }
NOT { return NOT; }
NULL { return NULLX; }
NUMBER { return NUMBER; }
ON { return ON; }
GROUP { return GROUP; }

OR { return OR; }
ORDER { return ORDER; }
REAL { return REAL; }
SCHEMA { return SCHEMA; }
SELECT { return SELECT; }
SET { return SET; }
INT2|SMALLINT { return SMALLINT; }
TABLE { return TABLE; }
TEXT { return TEXT; }
TIME { return TIME; }
TIMESTAMP { return TIMESTAMP; }
INT1|TINYINT { return TINYINT; }
TINYTEXT { return TINYTEXT; }
TO { return TO; }
TRAILING { return TRAILING; }
UPDATE { return UPDATE; }
UTC_DATE { return UTC_DATE; }
UTC_TIME { return UTC_TIME; }
UTC_TIMESTAMP { return UTC_TIMESTAMP; }
VALUES? { return VALUES; }
VARBINARY { return VARBINARY; }
VARCHAR(ACTER)? { return VARCHAR; }
VARYING { return VARYING; }
WHEN { return WHEN; }
WHERE { return WHERE; }

 /* numbers */
-?[0-9]+ { yylval.intval = atoi(yytext); return INTNUM; }
-?[0-9]+"."[0-9]* |
-?"."[0-9]+ |
-?[0-9]+E[-+]?[0-9]+ |
-?[0-9]+"."[0-9]*E[-+]?[0-9]+ |
-?"."[0-9]+E[-+]?[0-9]+ { yylval.floatval = atof(yytext);return APPROXNUM; }

 /* booleans */
TRUE { yylval.intval = 1; return BOOL; }
UNKNOWN { yylval.intval = -1; return BOOL; }
FALSE { yylval.intval = 0; return BOOL; }

 /* strings */
'(\\.|''|[^'\n])*' |
\"(\\.|\"\"|[^"\n])*\" { yylval.strval = strdup(yytext); return STRING; }
'(\\.|[^'\n])*$ { yyerror("Unterminated string %s", yytext); }
\"(\\.|[^"\n])*$ { yyerror("Unterminated string %s", yytext); }

 /* hex strings */
X'[0-9A-F]+' |
0X[0-9A-F]+ { yylval.strval = strdup(yytext); return STRING; }

 /* bit strings */
0B[01]+ |
B'[01]+' { yylval.strval = strdup(yytext); return STRING; }

 /* operators */
[-+&~|^/%*(),.;!] { return yytext[0]; }
"&&" { return ANDOP; }
"||" { return OR; }
"=" { yylval.subtok = 4; return COMPARISON; }
"<=>" { yylval.subtok = 12; return COMPARISON; }
">=" { yylval.subtok = 6; return COMPARISON; }
">" { yylval.subtok = 2; return COMPARISON; }
"<=" { yylval.subtok = 5; return COMPARISON; }
"<" { yylval.subtok = 1; return COMPARISON; }
"!=" |
"<>" { yylval.subtok = 3; return COMPARISON; }
"<<" { yylval.subtok = 1; return SHIFT; }
">>" { yylval.subtok = 2; return SHIFT; }
":=" { return ASSIGN; }

 /* functions */
SUBSTR(ING)?/"(" { return FSUBSTRING; }
TRIM/"(" { return FTRIM; }
DATE_ADD/"(" { return FDATE_ADD; }
DATE_SUB/"(" { return FDATE_SUB; }
 /* check trailing context manually */
COUNT { int c = input(); unput(c);
 if(c == '(') return FCOUNT;
 yylval.strval = strdup(yytext);
 return NAME; }
 /* names */
[A-Za-z][A-Za-z0-9_]* { yylval.strval = strdup(yytext);
 return NAME; }
`[^`/\\.\n]+` { yylval.strval = strdup(yytext+1);
 yylval.strval[yyleng-2] = 0;
 return NAME; }
`[^`\n]*$ { yyerror("unterminated quoted name %s", yytext); }

 /* everything else */
[ \t\n] /* whitespace */
. { yyerror("mystery character '%c'", *yytext); }