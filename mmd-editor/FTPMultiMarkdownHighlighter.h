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

	BOOL formatParagraphs;
	
@private

}

- (void)reformatParagraphsWithRange:(NSRange) range;

- (void)resetParagraphs;
- (void)resetParagraphsWithRange:(NSRange) range;

- (void)formatMetaData;
- (void)formatMetaDataWithRange:(NSRange)range;

- (void)formatTables;
- (void)formatTablesWithRange:(NSRange)range;

- (void)formatBlockQuotes;
- (void)formatBlockQuotesWithRange:(NSRange)range;

- (void)updateWhitespaceWithRange:(NSRange) range;
- (void)updateMetadataWhitespaceWithRange:(NSRange)range;
- (void)updateTableWhitespaceWithRange:(NSRange)range;
- (void) updateFutureTableWithRange:(NSRange)range;

- (void)updateTableRowSpacingWithRange:(NSRange)lineRange;

- (void)unWrapParagraphsWithRange:(NSRange)range;

@property BOOL formatParagraphs;

@end
