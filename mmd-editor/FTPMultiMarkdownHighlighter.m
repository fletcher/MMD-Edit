//
//  FTPMultiMarkdownHighlighter.m
//
//  Created by Fletcher T. Penney on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FTPMultiMarkdownHighlighter.h"

@implementation FTPMultiMarkdownHighlighter

- (id) init
{
	if (!(self = [super init]))
		return nil;
	
	self.extensions = self.extensions | EXT_MMD;

	return self;
}


@end
