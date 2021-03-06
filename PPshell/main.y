%code requires
{
	#include <stdio.h>
	#include "main.h"
}

%define api.value.type union

%parse-param {int* return_value}

%token SEMIC
%token<string_t> IDF
%token REDIRI
%token REDIROT
%token REDIROA
%token PIPE
%token EOL

%type<pipelines_t> pipelines_pure 
%type<pipeline_t> pipeline
%type<command_t> command command_arguments_redirections
%type<redirections_t> redirections
%type<redirection_t> redirection
%type<redirection_type_t> redirection_type
%type<string_t> argument command_path

%start script

%%

script:
	pipelines
|	script EOL pipelines;

pipelines:
	%empty
|	pipelines_pure semic_opt { /*pipelines_debug(&$1);*/ pipelines_execute_and_destroy(&$1, return_value); };

pipelines_pure:
	pipeline
	{
		if (pipelines_construct_pipeline_move(&$$, &$1) != 0)
			YYERROR;
	}
|	pipelines_pure SEMIC pipeline
	{
		if (pipelines_append_move(&$1, &$3) != 0)
			YYERROR;
		pipelines_construct_move(&$$, &$1);
	};

semic_opt:
	%empty
|	SEMIC;

pipeline:
	command
	{
		if (pipeline_construct_move_command(&$$, &$1) != 0)
			YYERROR;
	}
|	pipeline PIPE command
	{
		if (pipeline_append_move_command(&$1, &$3) != 0)
			YYERROR;
		pipeline_construct_move(&$$, &$1);
	};

command:
	redirections command_arguments_redirections { command_combine_redirections_move(&$2, &$1); command_construct_move(&$$, &$2); };

redirections:
	%empty { redirections_construct(&$$); }
|	redirections redirection { redirections_register_move(&$1, &$2); redirections_construct_move(&$$, &$1); };

command_arguments_redirections:
	command_path
	{
		if (command_construct_move_cmd_path(&$$, &$1) != 0)
			YYERROR;
	}
|	command_arguments_redirections argument
	{
		if (command_register_argument_move(&$1, &$2) != 0)
			YYERROR;
		command_construct_move(&$$, &$1);
	}
|	command_arguments_redirections redirection { command_register_redirection_move(&$1, &$2); command_construct_move(&$$, &$1); };

argument:
	IDF { string_construct_move(&$$, &$1); };

redirection:
	redirection_type IDF { redirection_construct_path_move(&$$, &$2, $1); };

redirection_type:
	REDIRI  { $$ = RT_INPUT; }
|	REDIROT { $$ = RT_OUTPUT_TRUNCATE; }
|	REDIROA { $$ = RT_OUTPUT_APPEND; };

command_path:
	IDF { string_construct_move(&$$, &$1); };

%%
