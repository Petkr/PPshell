cmake_minimum_required(VERSION 3.8)

find_package(BISON)
find_package(FLEX)

bison_target(parser main.y ${CMAKE_CURRENT_SOURCE_DIR}/parser.c DEFINES_FILE ${CMAKE_CURRENT_SOURCE_DIR}/parser.h)

flex_target(lexer main.lex ${CMAKE_CURRENT_SOURCE_DIR}/lexer.c)
ADD_FLEX_BISON_DEPENDENCY(lexer parser)

add_compile_options(-Wall -Wextra -pedantic -Werror)

add_executable(PPshell ${BISON_parser_OUTPUTS} ${FLEX_lexer_OUTPUTS}
	"main.c"
	"string.c"
	"strings.c"
	"redirections.c"
	"redirection.c"
	"command.c"
	"pipeline.c"
	"pipelines.c"
	"internal_commands.c"
	"internal_exit.c"
	"internal_cd.c"
 	"pipes.h"
	"pipes.c"
	"file_descriptor.c")

target_link_libraries(PPshell readline)
target_link_libraries(PPshell ${FLEX_LIBRARIES})