#!/bin/sh
# 
# Combines the 'header' code and 'footer' code with the parser
# code generated by greg from the grammar description into
# one file.
# 

HEADER_ROW=$(grep -nF '/// header_code_here' markdown_parser_core.c | awk 'BEGIN{FS=":"};{print $1}')
HEADER_ROW_BEFORE=$(expr $HEADER_ROW - 1)
HEADER_ROW_AFTER=$(expr $HEADER_ROW + 1)

head -n ${HEADER_ROW_BEFORE} markdown_parser_core.c
cat markdown_parser_head.c
tail -n +${HEADER_ROW_AFTER} markdown_parser_core.c
cat markdown_parser_foot.c


