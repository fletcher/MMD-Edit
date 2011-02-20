
#include <stdbool.h>
#include <stdlib.h>


enum markdown_extensions {
    EXT_SMART            = 0x01,
    EXT_NOTES            = 0x02,
    EXT_FILTER_HTML      = 0x04,
    EXT_FILTER_STYLES    = 0x08
};

/* Types of semantic values returned by parsers. */ 
enum types
{
	NO_TYPE,
	LIST,   /* A generic list of values.  For ordered and bullet lists, see below. */
	RAW,    /* Raw markdown to be processed further */
	SPACE,
	LINEBREAK,
	ELLIPSIS,
	EMDASH,
	ENDASH,
	APOSTROPHE,
	SINGLEQUOTED,
	DOUBLEQUOTED,
	STR,
	LINK,
	IMAGE,
	CODE,
	HTML,
	EMPH,
	STRONG,
	PLAIN,
	PARA,
	LISTITEM,
	BULLETLIST,
	ORDEREDLIST,
	H1, H2, H3, H4, H5, H6,  /* Code assumes that these are in order. */
	BLOCKQUOTE,
	VERBATIM,
	HTMLBLOCK,
	HRULE,
	REFERENCE,
	NOTE
};

#define MAX_TYPE 33;


/* Semantic value of a parsing action. */
struct Element
{
    int               type;
    long              pos;
    long              end;
    struct Element    *next;
};
typedef struct Element element;


element ** parse_markdown(char *string, int extensions);
