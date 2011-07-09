//
//  FTPMultiMarkdownHighlighter.m
//
//  Created by Fletcher T. Penney on 7/9/11.
//  Copyright 2011 Fletcher T. Penney. All rights reserved.
//

#import "FTPMultiMarkdownHighlighter.h"
#import "HGMarkdownHighlightingStyle.h"

@implementation FTPMultiMarkdownHighlighter

- (id) init
{
	if (!(self = [super init]))
		return nil;
	
	self.extensions = self.extensions | EXT_MMD;

	return self;
}

- (NSArray *) getDefaultStyles
{
	static NSArray *defaultStyles = nil;
	if (defaultStyles != nil)
		return defaultStyles;
	
	defaultStyles = [[NSArray arrayWithObjects:
					  HG_MKSTYLE(H1, HG_D(HG_COLOR_HEX(0x222222),HG_FORE, HG_COLOR_HEX(0xCCCCCC),HG_BACK), nil, NSBoldFontMask),
					  HG_MKSTYLE(H2, HG_D(HG_COLOR_HEX(0x222222),HG_FORE, HG_COLOR_HEX(0xCCCCCC),HG_BACK), nil, NSBoldFontMask),
					  HG_MKSTYLE(H3, HG_D(HG_COLOR_HEX(0x222222),HG_FORE, HG_COLOR_HEX(0xCCCCCC),HG_BACK), nil, NSBoldFontMask),
					  HG_MKSTYLE(H4, HG_D(HG_COLOR_HEX(0x222222),HG_FORE, HG_COLOR_HEX(0xCCCCCC),HG_BACK), nil, NSBoldFontMask),
					  HG_MKSTYLE(H5, HG_D(HG_COLOR_HEX(0x222222),HG_FORE, HG_COLOR_HEX(0xCCCCCC),HG_BACK), nil, NSBoldFontMask),
					  HG_MKSTYLE(H6, HG_D(HG_COLOR_HEX(0x222222),HG_FORE, HG_COLOR_HEX(0xCCCCCC),HG_BACK), nil, NSBoldFontMask),
					  HG_MKSTYLE(HRULE, HG_D(HG_DARK_GRAY,HG_FORE, HG_LIGHT_GRAY,HG_BACK), nil, 0),
					  HG_MKSTYLE(LIST_BULLET, HG_D(HG_DARK(HG_MAGENTA),HG_FORE), nil, 0),
					  HG_MKSTYLE(LIST_ENUMERATOR, HG_D(HG_DARK(HG_MAGENTA),HG_FORE), nil, 0),
					  HG_MKSTYLE(LINK, HG_D(HG_DARK(HG_CYAN),HG_FORE, HG_LIGHT(HG_CYAN),HG_BACK), nil, 0),
					  HG_MKSTYLE(AUTO_LINK_URL, HG_D(HG_DARK(HG_CYAN),HG_FORE, HG_LIGHT(HG_CYAN),HG_BACK), nil, 0),
					  HG_MKSTYLE(AUTO_LINK_EMAIL, HG_D(HG_DARK(HG_CYAN),HG_FORE, HG_LIGHT(HG_CYAN),HG_BACK), nil, 0),
					  HG_MKSTYLE(IMAGE, HG_D(HG_DARK(HG_MAGENTA),HG_FORE, HG_LIGHT(HG_MAGENTA),HG_BACK), nil, 0),
					  HG_MKSTYLE(REFERENCE, HG_D(HG_DIM(HG_RED),HG_FORE), nil, 0),
					  HG_MKSTYLE(CODE, HG_D(HG_DARK(HG_GREEN),HG_FORE, HG_LIGHT(HG_GREEN),HG_BACK), nil, 0),
					  HG_MKSTYLE(EMPH, HG_D(HG_DARK(HG_YELLOW),HG_FORE), nil, NSItalicFontMask),
					  HG_MKSTYLE(STRONG, HG_D(HG_DARK(HG_MAGENTA),HG_FORE), nil, NSBoldFontMask),
					  HG_MKSTYLE(HTML_ENTITY, HG_D(HG_MED_GRAY,HG_FORE), nil, 0),
					  HG_MKSTYLE(COMMENT, HG_D(HG_MED_GRAY,HG_FORE), nil, 0),
					  HG_MKSTYLE(VERBATIM, HG_D(HG_DARK(HG_GREEN),HG_FORE, HG_LIGHT(HG_GREEN),HG_BACK), nil, 0),
					  HG_MKSTYLE(BLOCKQUOTE, HG_D(HG_DARK(HG_MAGENTA),HG_FORE), HG_A(HG_BACK), NSUnboldFontMask),
					  HG_MKSTYLE(METADATA, HG_D(HG_COLOR_HEX(0x222222),HG_FORE, HG_COLOR_HEX(0xE8E8E8),HG_BACK), nil, 0),
					  HG_MKSTYLE(METAKEY, HG_D(HG_COLOR_HEX(0x777777),HG_FORE), HG_A(HG_FORE), 0),
					  HG_MKSTYLE(CITATION, HG_D(HG_DIM(HG_RED),HG_FORE), nil, 0),
					  HG_MKSTYLE(MATHSPAN, HG_D(HG_DARK(HG_GREEN),HG_FORE, HG_LIGHT(HG_GREEN),HG_BACK), nil, 0),
					  HG_MKSTYLE(TABLE, HG_D(HG_COLOR_HEX(0x777777),HG_FORE, HG_COLOR_HEX(0xE8E8E8),HG_BACK), nil, 0),
					  //		HG_MKSTYLE(TABLEROW, HG_D(HG_DARK(HG_GREEN),HG_FORE, HG_LIGHT(HG_RED),HG_BACK), nil, 0),
					  //		HG_MKSTYLE(CELLCONTENTS, HG_D(HG_DARK(HG_BLUE),HG_FORE, HG_LIGHT(HG_BLUE),HG_BACK), nil, 0),
					  HG_MKSTYLE(DEFTERM, HG_D(HG_DARK(HG_BLUE),HG_FORE), nil, NSItalicFontMask),
					  HG_MKSTYLE(DEFINITION, HG_D(HG_DARK(HG_RED),HG_FORE), nil, 0),
					  nil] retain];
	
	return defaultStyles;
}


@end
