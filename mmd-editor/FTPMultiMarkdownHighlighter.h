//
//  FTPMultiMarkdownHighlighter.h
//
//  Created by Fletcher T. Penney on 7/9/11.
//  Copyright 2011 Fletcher T. Penney. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "HGMarkdownHighlighter.h"

/*
	Subclass the highlighter to enable the MultiMarkdown extensions and apply proper styling.
	Requires that the PEG include the MMD syntax.
*/

@interface FTPMultiMarkdownHighlighter : HGMarkdownHighlighter {

	NSDictionary *currentLineAttributes;
	
@private

}

@property(retain) NSDictionary *currentLineAttributes;

@end
