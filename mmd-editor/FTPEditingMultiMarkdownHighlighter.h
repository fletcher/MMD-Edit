//
//  FTPEditingMultiMarkdownHighlighter.h
//
//  Created by Fletcher T. Penney on 7/14/11.
//  Copyright 2011 Fletcher T. Penney. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "FTPMultiMarkdownHighlighter.h"

@interface FTPEditingMultiMarkdownHighlighter : FTPMultiMarkdownHighlighter {

}

- (void)insertNewlineAtRange:(NSRange) range;
- (BOOL)itemIsInsideElementType:(int)elementType range:(NSRange)range;

@end
