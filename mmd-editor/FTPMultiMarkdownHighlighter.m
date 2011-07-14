//
//  FTPMultiMarkdownHighlighter.m
//
//  Created by Fletcher T. Penney on 7/9/11.
//  Copyright 2011 Fletcher T. Penney. All rights reserved.
//

#import "FTPMultiMarkdownHighlighter.h"
#import "HGMarkdownHighlightingStyle.h"

@implementation FTPMultiMarkdownHighlighter

@synthesize formatParagraphs;

- (id) init
{
	if (!(self = [super init]))
		return nil;
	
	self.formatParagraphs = NO;
	return self;
}


- (void) textViewTextDidChange:(NSNotification *)notification
{
	[super textViewTextDidChange:notification];

	// Do we need to clean up whitespace on the current paragraph?
	[self updateWhitespaceWithRange:[self.targetTextView rangeForUserParagraphAttributeChange]];
	
	// Update paragraph layout for current paragraph
	if (self.formatParagraphs)
		[self reformatParagraphsWithRange:[self.targetTextView rangeForUserParagraphAttributeChange]];
}

- (void) reformatParagraphsWithRange:(NSRange) range
{
	[[self.targetTextView textStorage] beginEditing];

	[self resetParagraphsWithRange:range];	
	[self formatMetaDataWithRange:range];
	[self formatTablesWithRange:range];
	[self formatBlockQuotesWithRange:range];
	
	[[self.targetTextView textStorage] endEditing];

}


- (void) applyHighlighting:(element **)elements withRange:(NSRange)range
{
	if (self.formatParagraphs)
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
		return;
	
	
	// End if metadata not in specified range
	NSString *metaDataRangeString = [metaDataRanges objectAtIndex:0];
	NSRange metaDataRange = NSRangeFromString(metaDataRangeString);

	NSRange intersection = NSIntersectionRange(range, metaDataRange);
	if (intersection.length == 0)
		return;
	
	
	NSArray *metaKeyArray = [self rangesForElementType:METAKEY inRange:metaDataRange];
	
	NSEnumerator *enumerator = [metaKeyArray objectEnumerator];
	id aMetaKeyString;
	
	while (aMetaKeyString = [enumerator nextObject]) {
		NSRange theRange = NSRangeFromString(aMetaKeyString);
		
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


- (void) updateWhitespaceWithRange:(NSRange)range
{
	[self updateMetadataWhitespaceWithRange:range];
	[self updateTableWhitespaceWithRange:range];
	[self updateFutureTableWithRange:range];
}

- (void) updateMetadataWhitespaceWithRange:(NSRange)range
{
	NSArray *metaDataRanges = [self rangesForElementType:METADATA];
	
	// End if no metadata
	if ([metaDataRanges count] == 0)
		return;
	
	
	// End if metadata not in specified range
	NSString *metaDataRangeString = [metaDataRanges objectAtIndex:0];
	NSRange metaDataRange = NSRangeFromString(metaDataRangeString);

	NSRange intersection = NSIntersectionRange(range, metaDataRange);
	if (intersection.length == 0)
		return;
	
	
	// So, we're in metadata, and now just need to tweak white space
	NSArray *metaKeysRanges = [self rangesForElementType:METAKEY];
	id aKeyRange;
	NSRange metaKeyRange;
	NSEnumerator *enumerator = [metaKeysRanges objectEnumerator];
	
	// Set up scanner
	NSCharacterSet *spaceSet = [NSCharacterSet characterSetWithCharactersInString:@" \t"];
	NSScanner *metaScanner = [NSScanner scannerWithString:[[self.targetTextView textStorage] string]];
		
	while (aKeyRange = [enumerator nextObject])
	{
		metaKeyRange = NSRangeFromString(aKeyRange);
		if (NSIntersectionRange(metaKeyRange, range).length == 0)
		{
			continue;
		} else {
			// We found the right line
			//int startValue = metaKeyRange.location+metaKeyRange.length;
			int startValue = metaKeyRange.location;

			// find the ':'
			[metaScanner setScanLocation:startValue];
			[metaScanner scanUpToString:@":" intoString:NULL];
			startValue = [metaScanner scanLocation]+1;
			
			// now we need to worry about whitespace
			[metaScanner setCharactersToBeSkipped:nil];
			[metaScanner setScanLocation:startValue];
			
			// Go until we find non whitespace character
			[metaScanner scanCharactersFromSet:spaceSet intoString:NULL];
			
			// replace whitespace after ':' with a single tab character
			[[self.targetTextView textStorage]
			 replaceCharactersInRange:NSMakeRange(startValue, [metaScanner scanLocation]-startValue)
			 withString:@"\t"];
			
			break;
		}
	}
	
}

- (void)reFormatEachMetadataLine
{
	NSArray *metaDataRanges = [self rangesForElementType:METADATA];
	
	// End if no metadata
	if ([metaDataRanges count] == 0)
		return;
	
	// Cycle through keys and reformat each, working backwards
	NSArray *metaKeyRanges = [self rangesForElementType:METAKEY];
	NSEnumerator *enumerator = [metaKeyRanges reverseObjectEnumerator];
	id metaKeyRange;
	NSRange aRange;
	
	while (metaKeyRange = [enumerator nextObject]) {
		aRange = NSRangeFromString(metaKeyRange);
		
		[self updateMetadataWhitespaceWithRange:aRange];
	}
	
	// And remove duplicate tabs
	[self stripSerialTabsFromRange:NSRangeFromString([metaDataRanges objectAtIndex:0])];
	self.highlightingIsDirty = YES;
	[self parseAndHighlightNow];
}


- (void) updateTableWhitespaceWithRange:(NSRange)range
{
	NSArray *tableRanges = [self rangesForElementType: TABLE];
	
	// End if no tables
	if ([tableRanges count] ==0)
		return;
	
	
	// Check tables to see if one is in range
	NSEnumerator *enumerator = [tableRanges objectEnumerator];
	id aTableRange;
	NSRange tableRange;
	NSRange intersection;
	
	while (aTableRange = [enumerator nextObject]) {
		tableRange = NSRangeFromString(aTableRange);
		intersection = NSIntersectionRange(tableRange, range);
		
		// Skip if we're not in this table
		if (intersection.length == 0)
			continue;
		
		NSRange lineRange = [self.targetTextView rangeForUserParagraphAttributeChange];
		
		// Tweak this line
		[self updateTableRowSpacingWithRange:lineRange];
		
		break;
	}
}


- (void) updateFutureTableWithRange:(NSRange)range
{
	NSArray *tableRanges = [self rangesForElementType: FUTURETABLE];
	
	// End if no futuretables
	if ([tableRanges count] ==0)
		return;
		
	// Check future tables to see if one is in range
	NSEnumerator *enumerator = [tableRanges objectEnumerator];
	id aTableRange;
	NSRange tableRange;
	NSRange intersection;
	
	while (aTableRange = [enumerator nextObject]) {
		tableRange = NSRangeFromString(aTableRange);
		intersection = NSIntersectionRange(tableRange, range);
		
		// Skip if we're not in this table
		if (intersection.length == 0)
		{
			if (range.length >1)
				continue;
			
			if (tableRange.location+tableRange.length+1> range.location) {
				// We're not in the future table, but we are on next line which is basically empty

				// So now we want to copy the header line and make a separator line out of it
				NSString *headerLine = [[[self.targetTextView textStorage] string] substringWithRange:tableRange];
				NSMutableString *separatorLine = [NSMutableString stringWithString:headerLine];
				
				NSScanner *tabScanner = [NSScanner scannerWithString:headerLine];
				[tabScanner setCharactersToBeSkipped:nil];

				NSCharacterSet *dontChange = [NSCharacterSet characterSetWithCharactersInString:@"|\t\n\r"];
				NSRange replaceRange;
				int curPos = 0;
				
				// TODO: need to trap error when this template string isn't long enough
				NSString *template = [NSString stringWithString:@"----------------------------------------------------------------------------------------------------------------------------"];
				
				
				while ([tabScanner isAtEnd] == NO) {
					[tabScanner scanCharactersFromSet:[dontChange invertedSet] intoString:NULL];
					replaceRange = NSMakeRange(curPos, [tabScanner scanLocation]-curPos);
					curPos = [tabScanner scanLocation]+1;
					[separatorLine replaceCharactersInRange:replaceRange withString:[template
																					 substringWithRange:replaceRange]];
					[tabScanner setScanLocation:curPos];
				}
				
				// Insert the separator line
				[[self.targetTextView textStorage] replaceCharactersInRange:
				 range withString:separatorLine];
				
				
			}
			continue;
		}
		
		// Update spacing to include tabs
		NSRange lineRange = [self.targetTextView rangeForUserParagraphAttributeChange];
		[self updateTableRowSpacingWithRange:lineRange];
		
		
	}
}

-(void)updateTableRowSpacingWithRange:(NSRange)lineRange
{
	
	// Don't mess with newline
	int start = lineRange.location;
	int len = lineRange.length-1;
	
	NSRange dividerRange = [[[self.targetTextView textStorage] string] rangeOfString:@"|"
																			 options:NSBackwardsSearch 
																			   range:NSMakeRange(start, len)];
	
	NSCharacterSet *trailingValidSet = [NSCharacterSet characterSetWithCharactersInString:@"| \t\n\r"];
	NSCharacterSet *leadingValidSet = [NSCharacterSet characterSetWithCharactersInString:@"|\t\n"];
	
	// Need to work from end of line to avoid tripping over ourselves
	while (dividerRange.length != 0)
	{
		// found '|'
		
		// '|' should be followed by '|', or whitespace
		if (![trailingValidSet characterIsMember:[[[self.targetTextView textStorage] string]
												  characterAtIndex:dividerRange.location+dividerRange.length]])
			[[self.targetTextView textStorage] replaceCharactersInRange:
			 NSMakeRange(dividerRange.location+dividerRange.length, 0) withString:@" "];
		
		// '|' should be preceded by '|' or tab
		if (![leadingValidSet characterIsMember:[[[self.targetTextView textStorage] string]
												 characterAtIndex:dividerRange.location-1]])
			[[self.targetTextView textStorage] replaceCharactersInRange:
			 NSMakeRange(dividerRange.location, 0) withString:@"\t"];
		
		
		len = dividerRange.location-start;
		if (len < 0) {
			break;
		}
		
		// Find next '|'
		dividerRange = [[[self.targetTextView textStorage] string] rangeOfString:@"|"
																		 options:NSBackwardsSearch 
																		   range:NSMakeRange(start, len)];			
	}
}


- (void)unWrapParagraphsWithRange:(NSRange)range
{
	// iterate through paragraphs and remove newlines

	NSArray *paraRanges = [self rangesForElementType: PARA];
	
	// End if no paragraphs
	if ([paraRanges count] ==0)
		return;
	
	// Check PARAs to see if one is in range
	// Check backwards so we don't screw things up
	NSEnumerator *enumerator = [paraRanges reverseObjectEnumerator];
	id aParaRange;
	NSRange paraRange;
	NSRange intersection;
	
	while (aParaRange = [enumerator nextObject]) {
		paraRange = NSRangeFromString(aParaRange);
		intersection = NSIntersectionRange(paraRange, range);
		
		// Skip if we're not in this paragraph
		if (intersection.length == 0)
			continue;
				
		// get substring for paragraph
		NSMutableString *paragraphString = [NSMutableString stringWithString:[[[self.targetTextView textStorage] string]
											substringWithRange:paraRange]];
		// preserve intentional breaks
		[paragraphString replaceOccurrencesOfString:@"  \n"
										withString:@"MMD-MARKER"
											options:NSCaseInsensitiveSearch
											  range:NSMakeRange(0, [paragraphString length])];
		
		// remove newlines
		[paragraphString replaceOccurrencesOfString:@"\n" 
										 withString:@" "
											options:NSCaseInsensitiveSearch 
											  range:NSMakeRange(0, [paragraphString length])];
		
		// replace repeated spaces with single space
		id parts = [NSMutableArray arrayWithArray:[paragraphString componentsSeparatedByString:@" "]];
		[parts removeObject:@""];
		
		// TODO: Fix this - it's a crutch to work around the fact that blockquotes and PARA don't work together
		// properly in Ali's parser and I haven't fixed it yet.
		[parts addObject:@""];
		
		// And restore to a string
		NSMutableString *newParagraph = [NSMutableString stringWithString:[parts componentsJoinedByString:@" "]];

		// restore intentional breaks
		[newParagraph replaceOccurrencesOfString:@"MMD-MARKER"
										 withString:@"  \n"
											options:NSCaseInsensitiveSearch
											  range:NSMakeRange(0, [newParagraph length])];
		
		
		[[self.targetTextView textStorage] replaceCharactersInRange:paraRange withString:newParagraph];
		
		[[self.targetTextView textStorage] endEditing];
	}
	self.highlightingIsDirty = YES;
	[self parseAndHighlightNow];
}

- (void) stripSerialTabsFromRange:(NSRange)range
{
	// Break range into an array divided by '\t' and remove duplicates
	
	id parts = [NSMutableArray arrayWithArray:[[[[self.targetTextView textStorage] string] 
												substringWithRange:range] 
											   componentsSeparatedByString:@"\t"]];
	
	[parts removeObject:@""]; // that's the empty string
	NSString *newString = [parts componentsJoinedByString:@"\t"];
	
	[[self.targetTextView textStorage] replaceCharactersInRange:range withString:newString];
	
}

- (void) updateEntireTableWhitespaceWithRange:(NSRange)range
{
	NSArray *tableRanges = [self rangesForElementType: TABLE];
	
	// End if no tables
	if ([tableRanges count] ==0)
		return;
	
	
	// Check tables to see if one is in range
	NSEnumerator *enumerator = [tableRanges reverseObjectEnumerator];
	id aTableRange;
	NSRange tableRange;
	NSRange intersection;
	
	while (aTableRange = [enumerator nextObject]) {
		tableRange = NSRangeFromString(aTableRange);
		intersection = NSIntersectionRange(tableRange, range);
		
		// Skip if we're not in this table
		if (intersection.length == 0)
			continue;
				
		// Tweak this line
		[self updateTableRowSpacingWithRange:tableRange];
		
	}
	self.highlightingIsDirty = YES;
	[self parseAndHighlightNow];
}


- (BOOL)textView:(NSTextView *)view shouldChangeTextInRange:(NSRange)range replacementString:(NSString *)replacementString
{
	// We're about to add a string, so let's see if we need to intervene

	if ([replacementString isEqualToString:@"`"]) {
		if ( ( [[[view textStorage] string] length] > range.location)
			&& [[[[view textStorage] string]substringWithRange:NSMakeRange(range.location, 1)] isEqualToString:@"`"]) {
			// the next character is also `, so replace instead
			[[view textStorage] replaceCharactersInRange:NSMakeRange(range.location, 1) withString:@""];
			return YES;
		}
		if (range.length == 0) {
			// Close after cursor
			[[view textStorage] replaceCharactersInRange:NSMakeRange(range.location, 0) withString:@"`"];
			[view setSelectedRange:range];
			  return YES;
		} else {
			return YES;
		}
	}

	if ([replacementString isEqualToString:@"\""]) {
		if ( ( [[[view textStorage] string] length] > range.location)
			&& [[[[view textStorage] string]substringWithRange:NSMakeRange(range.location, 1)] isEqualToString:@"\""]) {
			// the next character is also ", so replace instead
			[[view textStorage] replaceCharactersInRange:NSMakeRange(range.location, 1) withString:@""];
			return YES;
		}
		if (range.length == 0) {
			// Close after cursor
			[[view textStorage] replaceCharactersInRange:NSMakeRange(range.location, 0) withString:@"\""];
			[view setSelectedRange:range];
			return YES;
		} else {
			return YES;
		}
	}
	
	if ([replacementString isEqualToString:@"["]) {
		if (range.length == 0) {
			// Close after cursor
			[[view textStorage] replaceCharactersInRange:NSMakeRange(range.location, 0) withString:@"]"];
			[view setSelectedRange:range];
			return YES;
		} else {
			return NO;
		}
	}

	if ([replacementString isEqualToString:@"]"]) {
		if ( ( [[[view textStorage] string] length] > range.location)
			&& [[[[view textStorage] string]substringWithRange:NSMakeRange(range.location, 1)] isEqualToString:@"]"]) {
			// the next character is also ], so replace instead
			[[view textStorage] replaceCharactersInRange:NSMakeRange(range.location, 1) withString:@""];
		}
		return YES;
	}
	
	
	if ([replacementString isEqualToString:@"("]) {
		if (range.length == 0) {
			// Close after cursor
			[[view textStorage] replaceCharactersInRange:NSMakeRange(range.location, 0) withString:@")"];
			[view setSelectedRange:range];
			return YES;
		} else {
			return NO;
		}
	}

	if ([replacementString isEqualToString:@")"]) {
		if ( ( [[[view textStorage] string] length] > range.location)
			&& [[[[view textStorage] string]substringWithRange:NSMakeRange(range.location, 1)] isEqualToString:@")"]) {
			// the next character is also ), so replace instead
			[[view textStorage] replaceCharactersInRange:NSMakeRange(range.location, 1) withString:@""];
		}
		return YES;
	}
	
	if ([replacementString isEqualToString:@"*"]) {
		if ( ( [[[view textStorage] string] length] > range.location)
			&& [[[[view textStorage] string]substringWithRange:NSMakeRange(range.location, 1)] isEqualToString:@"*"]) {
			// the next character is also *, so replace instead
			[[view textStorage] replaceCharactersInRange:NSMakeRange(range.location, 1) withString:@""];
			return YES;
		}
	}
	
	
	return YES;
}

@end
