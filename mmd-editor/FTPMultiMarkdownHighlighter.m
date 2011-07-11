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
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useMultiMarkdown"]) {
		self.extensions = self.extensions | EXT_MMD;
	}

	return self;
}


- (void) textViewTextDidChange:(NSNotification *)notification
{
	[super textViewTextDidChange:notification];

	NSRect visibleRect = [[[self.targetTextView enclosingScrollView] contentView] documentVisibleRect];
	NSRange visibleRange = [[self.targetTextView layoutManager] glyphRangeForBoundingRect:visibleRect inTextContainer:[self.targetTextView textContainer]];
	[self reformatParagraphsWithRange:visibleRange];
}

- (void) reformatParagraphsWithRange:(NSRange) range
{
	//	[self resetParagraphsWithRange:[self.targetTextView rangeForUserParagraphAttributeChange]];
	[self resetParagraphsWithRange:range];
	
	[self formatMetaDataWithRange:range];
	[self formatTablesWithRange:range];
	[self formatBlockQuotesWithRange:range];
	
}


- (void) applyHighlighting:(element **)elements withRange:(NSRange)range
{
	[self reformatParagraphsWithRange:range];
	[super applyHighlighting:elements withRange:range];
}


- (void)resetParagraphs
{
	[self resetParagraphsWithRange:NSMakeRange(0, [[self.targetTextView string] length])];
}

- (void)resetParagraphsWithRange:(NSRange)range
{
	NSParagraphStyle *paraStyle = [self.targetTextView defaultParagraphStyle];
	
	[[self.targetTextView textStorage] addAttribute:NSParagraphStyleAttributeName
								   value:paraStyle
								   range:range];
	
}


- (void)formatMetaData
{
	[self formatMetaDataWithRange:NSMakeRange(0, [[self.targetTextView string] length])];
}

- (void)formatMetaDataWithRange:(NSRange)range
{
	// find range for MetaData and do something
	int maxWidth = 0;
	
	NSArray *metaDataRanges = [self rangesForElementType:METADATA];
	
	// End if no metadata
	if ([metaDataRanges count] == 0)
	{
		return;
	}
	
	
	NSString *metaDataRangeString = [metaDataRanges objectAtIndex:0];
	NSRange metaDataRange = NSRangeFromString(metaDataRangeString);
	
	// End if metadata not in specified range
	NSRange intersection = NSIntersectionRange(range, metaDataRange);
	if (intersection.length == 0) {
		return;
	}
	

	//	NSLog(@"Found range %@",metaDataRangeString);
	//	[hl clearHighlightingForRange:metaDataRange];
	
	NSArray *metaKeyArray = [self rangesForElementType:METAKEY inRange:metaDataRange];
	
	NSEnumerator *enumerator = [metaKeyArray objectEnumerator];
	id aMetaKeyString;
	
	while (aMetaKeyString = [enumerator nextObject]) {
		NSRange theRange = NSRangeFromString(aMetaKeyString);
		//		NSLog(@"Metakey range %@",aMetaKeyString);
		
		if (theRange.length > maxWidth)
		{
			maxWidth = theRange.length;
		}
	}
	
	
	NSMutableParagraphStyle *paraStyle = [[self.targetTextView defaultParagraphStyle] mutableCopy];
	if (paraStyle == nil) {
		paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	}
	
	NSFont *myFont = [[self.targetTextView textStorage] font];
	
	float charWidth = [[myFont screenFontWithRenderingMode:NSFontDefaultRenderingMode] advancementForGlyph:(NSGlyph) 'T'].width;
	//	[paraStyle setDefaultTabInterval:(charWidth * (maxWidth +4))];
	[paraStyle setTabStops:[NSArray array]];
	
	[paraStyle addTabStop:[[[NSTextTab alloc] initWithType:NSLeftTabStopType location:(charWidth * (maxWidth +2))] autorelease]];
	
	
	//	[textView setDefaultParagraphStyle:paragraphStyle];
	
	NSMutableDictionary* typingAttributes = [[self.targetTextView typingAttributes] mutableCopy];
	[typingAttributes setObject:paraStyle forKey:NSParagraphStyleAttributeName];
	[typingAttributes setObject:myFont forKey:NSFontAttributeName];
	//	[textView setTypingAttributes:typingAttributes];
	
	/** ADDED CODE BELOW **/
	//	[textView shouldChangeTextInRange:metaDataRange replacementString:nil];
	[[self.targetTextView textStorage] setAttributes:typingAttributes range:metaDataRange];
	
	[paraStyle release];
	[typingAttributes release];
}


- (void)formatTables
{
	[self formatTablesWithRange:NSMakeRange(0, [[self.targetTextView string] length])];
}

- (void)formatTablesWithRange:(NSRange) range
{
	// find range for Tables and do something
	NSArray *tableRanges = [self rangesForElementType:TABLE];
	
	// No tables present
	if ([tableRanges count] == 0)
		return;
	
	NSEnumerator *enumerator = [tableRanges objectEnumerator];
	id aTableRangeString;
	NSRange intersection;
	
	while (aTableRangeString = [enumerator nextObject]) {
		// Iterate through each table
		NSRange tableRange = NSRangeFromString(aTableRangeString);
		
		// skip if table not in specified range
		intersection = NSIntersectionRange(tableRange, range);
		if (intersection.length == 0)
			continue;
		
		int cols;
		
		
		// Find and count separator cells to determine # columns
		NSArray *separatorCells = [self rangesForElementType:SEPARATORCELL inRange:tableRange];
		cols = [separatorCells count];
		
		// Create array to store max width for each column
		int colWidth[cols];
		memset(colWidth, 0, sizeof colWidth);
		
		
		// Find and count table rows to determine # rows
		NSArray *tableRows = [self rangesForElementType:TABLEROW inRange:tableRange];
		
		
		// Iterate through rows, and check cells for max width
		// TODO: Need to fix this to account for cells that span more than one column
		NSEnumerator *rowEnumerator = [tableRows objectEnumerator];
		id aTableRowRangeString;
		int counter;
		
		while (aTableRowRangeString = [rowEnumerator nextObject])
		{
			NSRange rowRange = NSRangeFromString(aTableRowRangeString);
			
			// iterate through cells in this row
			NSArray *rowCells = [self rangesForElementType:CELLCONTENTS inRange:rowRange];
			NSEnumerator *cellEnumerator = [rowCells objectEnumerator];
			id aTableCell;
			counter = 0;
			
			while (aTableCell = [cellEnumerator nextObject]) {
				// Compare width of contents to the previous maximum
				
				NSRange cellRange = NSRangeFromString(aTableCell);
				
				if (cellRange.length > colWidth[counter]) {
					colWidth[counter] = cellRange.length;
				}
				
				counter++;
			}
		}
		
		
		// Get avg character width
		NSFont *myFont = [[self.targetTextView textStorage] font];
		float charWidth = [[myFont screenFontWithRenderingMode:NSFontDefaultRenderingMode] advancementForGlyph:(NSGlyph) 'T'].width;
		
		float tabTotal = 0;
		
		NSMutableParagraphStyle *paraStyle = [[self.targetTextView defaultParagraphStyle] mutableCopy];
		if (paraStyle == nil) {
			paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		}
		
		[paraStyle setTabStops:[NSArray array]]; // delete default tabs
		
		for (int i=0; i<cols; i++)
		{
			tabTotal += (charWidth * (colWidth[i] + 3));
			
			[paraStyle addTabStop:[[[NSTextTab alloc] initWithType:NSLeftTabStopType location:tabTotal] autorelease]];
			
			//			NSLog(@"Max width for column %d is %d",i,colWidth[i]);
		}
		
		[[self.targetTextView textStorage] addAttribute:NSParagraphStyleAttributeName
									   value:paraStyle
									   range:tableRange];
		
		[paraStyle release];
	}
	
}



- (void)formatBlockQuotes
{
	[self formatBlockQuotesWithRange:NSMakeRange(0, [[self.targetTextView string] length])];
}

- (void)formatBlockQuotesWithRange:(NSRange)range
{
	NSArray *quoteRanges = [self rangesForElementType:BLOCKQUOTE];
	
	if ([quoteRanges count] == 0)
		return;
	
	NSEnumerator *enumerator = [quoteRanges objectEnumerator];
	id aQuoteRangeString;
	
	NSRange intersection;
	
	while (aQuoteRangeString = [enumerator nextObject]) {
		NSRange quoteRange = NSRangeFromString(aQuoteRangeString);
		
		// skip if not in specified range
		intersection = NSIntersectionRange(range, quoteRange);
		if (intersection.length == 0)
			continue;
		
		NSMutableParagraphStyle *paraStyle = [[self.targetTextView defaultParagraphStyle] mutableCopy];
		
		// Get avg character width
		NSFont *myFont = [[self.targetTextView textStorage] font];
		float charWidth = [[myFont screenFontWithRenderingMode:NSFontDefaultRenderingMode] advancementForGlyph:(NSGlyph) 'T'].width;
		
		[paraStyle setHeadIndent:charWidth*8];
		[paraStyle setFirstLineHeadIndent:charWidth*8];
		[paraStyle setTailIndent:-charWidth*8];
		
		[[self.targetTextView textStorage] addAttribute:NSParagraphStyleAttributeName
									   value:paraStyle
									   range:quoteRange];
		[paraStyle release];
	}
}


@end
