//
//  MyDocument.m
//  mmd-editor
//
//  Created by Fletcher T. Penney on 6/29/11.
//  Copyright 2011 Fletcher T. Penney. All rights reserved.
//

#import "MyDocument.h"
#import "HGMarkdownHighlightingStyle.h"
#import "FTPMultiMarkdownHighlighter.h"

@implementation MyDocument

@synthesize isMMD;

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		if (mString == nil) {
			mString = [[NSAttributedString alloc] initWithString:@""];
		}
		
		
    }
    return self;
}

+ (void)initialize
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *appDefaults = [[NSMutableDictionary alloc] init];
	
	// Set default styleSheet
	[appDefaults setValue:@"default" forKey:@"defaultStyleSheet"];
	
	// Use MultiMarkdown by default
	[appDefaults setValue:[NSNumber numberWithBool:YES]
			   forKey:@"useMultiMarkdown"];
	
	// Preview with Marked?
	[appDefaults setValue:[NSNumber numberWithBool:YES]
				   forKey:@"previewWithMarked"];

	// Clickable Links?
	[appDefaults setValue:[NSNumber numberWithBool:YES]
				   forKey:@"makeLinksClickable"];
	
	[defaults registerDefaults:appDefaults];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void) handleStyleParsingErrors:(NSArray *)errorMessages
{
	NSMutableString *errorsInfo = [NSMutableString string];
	for (NSString *str in errorMessages)
	{
		[errorsInfo appendString:@"• "];
		[errorsInfo appendString:str];
		[errorsInfo appendString:@"\n"];
	}
	
	NSAlert *alert = [NSAlert alertWithMessageText:@"There were some errors when parsing the stylesheet:"
									 defaultButton:@"Ok"
								   alternateButton:nil
									   otherButton:nil
						 informativeTextWithFormat:errorsInfo];
	[alert runModal];
}


- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    //	Add any code here that needs to be executed once the windowController has loaded the document's window.
	if ([self string] != nil) {
		[textView setRulerVisible:TRUE];
		
		NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		[paraStyle setAlignment:NSJustifiedTextAlignment];
		[textView setDefaultParagraphStyle:paraStyle];
		[paraStyle release];

		[[textView textStorage] setAttributedString: [self string]];
		[textView setFont:[NSFont fontWithName:@"palatino" size:13]];
		
		hl = [[FTPMultiMarkdownHighlighter alloc] init];
		hl.targetTextView = textView;
		hl.parseAndHighlightAutomatically = YES;
		hl.waitInterval = 0.3;
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"makeLinksClickable"])
			hl.makeLinksClickable = YES;
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useMultiMarkdown"])
			hl.extensions = hl.extensions | EXT_MMD;
		
		hl.formatParagraphs = YES;
		
		
		// Load Style Sheet
		NSString *styleName = [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultStyleSheet"];
		
		// last resort will be checking inside the app bundle
		NSString *styleFilePath = [[NSBundle mainBundle] pathForResource:styleName
																  ofType:@"style"];
		
		// Check Application Support first
		NSArray *appSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSAllDomainsMask, YES);
		
		NSEnumerator *enumerator = [appSupportPaths objectEnumerator];
		id aPath;
		
		while (aPath = [enumerator nextObject])
		{
			NSString *filePath = [[[aPath stringByAppendingPathComponent:@"MMD-Edit/Styles/"]
								  stringByAppendingPathComponent:styleName]
								  stringByAppendingPathExtension:@"style"];
			if ([[NSFileManager defaultManager]
				 fileExistsAtPath:filePath] == YES ) {
				styleFilePath = filePath;
			}
		}
		
				 

		// And load the file contents (assuming it exists...)
		NSString *styleContents = [NSString stringWithContentsOfFile:styleFilePath
															encoding:NSUTF8StringEncoding
															   error:NULL];

		
		[hl applyStylesFromStylesheet:styleContents
					 withErrorDelegate:self
						 errorSelector:@selector(handleStyleParsingErrors:)];		
		[hl activate];
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useMultiMarkdown"]) {
			self.isMMD = YES;
		}
		
	}
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    BOOL readSuccess = NO;
    NSAttributedString *fileContents = [[NSAttributedString alloc]
										initWithData:data options:NULL documentAttributes:NULL
										error:outError];
    if (fileContents) {
        readSuccess = YES;
        [self setString:fileContents];
        [fileContents release];
    }
    return readSuccess;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSData *data;
    [self setString:[textView textStorage]];
    NSMutableDictionary *dict = [NSDictionary dictionaryWithObject:NSPlainTextDocumentType
															forKey:NSDocumentTypeDocumentAttribute];
    [textView breakUndoCoalescing];
    data = [[self string] dataFromRange:NSMakeRange(0, [[self string] length])
					 documentAttributes:dict error:outError];
    return data;
}

- (NSAttributedString *) string { return [[mString retain] autorelease]; }

- (void) setString: (NSAttributedString *) newValue {
    if (mString != newValue) {
        if (mString) [mString release];
        mString = [newValue copy];
    }
}



- (NSString *)htmlForText
{
	// Use an externally installed version of MMD 3 - eventually I would like to build this in
	
	NSString *path2MMD = @"/usr/local/bin/multimarkdown";

	NSTask* task = [[NSTask alloc] init];
	[task setLaunchPath: [path2MMD stringByExpandingTildeInPath]];
	
	// MMD or MD?
	if (self.isMMD) {
		[task setArguments: [NSArray arrayWithObjects: nil]];
	} else {
		[task setArguments: [NSArray arrayWithObjects: @"-c", nil]];
	}

	
	NSPipe *writePipe = [NSPipe pipe];
	NSFileHandle *writeHandle = [writePipe fileHandleForWriting];
	[task setStandardInput: writePipe];
	
	NSPipe *readPipe = [NSPipe pipe];
	[task setStandardOutput:readPipe];
	
	[task launch];
	
	[writeHandle writeData:[[textView string] dataUsingEncoding:NSUTF8StringEncoding]];
	[writeHandle closeFile];
	
	
	NSData *mdData = [[readPipe fileHandleForReading] readDataToEndOfFile];
	
	NSString* aStr;
	aStr = [[NSString alloc] initWithData:mdData encoding:NSASCIIStringEncoding];
	
	[[NSPasteboard generalPasteboard] setString:aStr forType:NSStringPboardType];

	return aStr;
}

- (IBAction)previewHTMLAction:(id)sender;
{	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"previewWithMarked"]) {
		// Open current document in Brett Terpstra's Marked application for previewing
		
		// If it's been saved to a file
		if ([self fileURL] != nil){
			// And if we can find Marked
			if ([[NSWorkspace sharedWorkspace] openFile:[[self fileURL] path] withApplication:@"Marked"])
			{
				// But we want to stay on top if possible
				[[NSApplication sharedApplication] activateIgnoringOtherApps: YES];
				[[self windowForSheet] becomeKeyWindow];
				return;
			}
		} 
	}

	// In all other cases, use built in preview
	[previewPanel makeKeyAndOrderFront:nil];
	[[previewView mainFrame] loadHTMLString:[self htmlForText] baseURL:[self fileURL]];
}

- (void) setIsMMD: (BOOL) newMMD {
	// Toggle between MMD and plain Markdown syntax-highlighting
    if (isMMD != newMMD) {
		isMMD = newMMD;
		if (isMMD) {
			hl.extensions = hl.extensions | EXT_MMD;
		} else {
			hl.extensions = hl.extensions & ~EXT_MMD;
		}
		
		hl.highlightingIsDirty = YES;

		[hl parseAndHighlightNow];
    }
		
	
}

- (IBAction)tidyRulers:(id)sender
{
	[hl resetParagraphs];
	[hl formatMetaData];
	[hl formatTables];
	[hl formatBlockQuotes];
}

- (IBAction)unWrapParagraphs:(id)sender
{
	NSRange selectionRange = [textView rangeForUserTextChange];
	
	if (selectionRange.length == 0)
	{
		// Unwrap all paragraphs
		[hl unWrapParagraphsWithRange:NSMakeRange(0, [[textView string] length])];
	} else {
		// Unwrap current paragraph
		[hl unWrapParagraphsWithRange:selectionRange];
	}
}

- (IBAction)reWrapMetaData:(id)sender
{
	[hl reFormatEachMetadataLine];
}

- (IBAction)reWrapTables:(id)sender
{
	[hl updateEntireTableWhitespaceWithRange:NSMakeRange(0, [[textView string] length])];
}

- (IBAction)totalReformat:(id)sender
{
	NSRange selectionRange = [textView rangeForUserTextChange];
	// TODO: Need a way to wait on reparsing to complete before moving on
	
	// Unwrap all paragraphs and tables
	if (selectionRange.length == 0)
	{
		// Nothing is selected so do everything
//		[hl updateEntireTableWhitespaceWithRange:NSMakeRange(0, [[textView string] length])];
		[hl unWrapParagraphsWithRange:NSMakeRange(0, [[textView string] length])];
	} else {
		// Only reformat the selection
//		[hl updateEntireTableWhitespaceWithRange:selectionRange];
		[hl unWrapParagraphsWithRange:selectionRange];
	}

	[hl reFormatEachMetadataLine];
}


- (void)myChangeFont:(id)sender
{
	BOOL fontDebug = NO;	// Enable debugging hints when something is awry
	
	// Override and customize requests to change font in order to apply MMD syntax
	if (fontDebug)
		NSLog(@"change font");
	
	// See what was requested by comparing old and new fonts
	NSFont *currentFont = [textView font];
 	NSFont *newFont = [sender convertFont:currentFont];

	NSFontTraitMask new = [[NSFontManager sharedFontManager] traitsOfFont:newFont];
	NSFontTraitMask old = [[NSFontManager sharedFontManager] traitsOfFont:currentFont];
	
	NSFontTraitMask changed = new ^ old;
	if (!changed)
	{
		// It's not a simple change, so need to figure out exactly font change was requested
		if (fontDebug)
			NSLog(@"complex request");
		
		currentFont = [[NSFontManager sharedFontManager] convertFont:currentFont toHaveTrait:NSBoldFontMask];
		currentFont = [[NSFontManager sharedFontManager] convertFont:currentFont toHaveTrait:NSItalicFontMask];
		
		newFont = [sender convertFont:currentFont];
		
		new = [[NSFontManager sharedFontManager] traitsOfFont:newFont];
		old = [[NSFontManager sharedFontManager] traitsOfFont:currentFont];
		
		changed = new ^ old;
		
	}
	
	if ( changed & NSBoldFontMask) {
		if (fontDebug)
			NSLog(@"change bold");
		if (new & NSBoldFontMask) {
			// TODO: Check for wrapping '**'and unbold instead if present
			if (fontDebug)
				NSLog(@"add bold");
			[self addBoldToRange:[textView rangeForUserTextChange]];
		} else {
			if (fontDebug)
				NSLog(@"remove bold");
			[self removeBoldFromRange:[textView rangeForUserTextChange]];
		}
	}

	if ( changed & NSItalicFontMask) {
		if (fontDebug)
			NSLog(@"change italics");
		if (new & NSItalicFontMask) {
			// TODO: Check for wrapping '*' and unitalicize instead if present
			if (fontDebug)
				NSLog(@"add italics");
			[self addItalicsToRange:[textView rangeForUserTextChange]];
		} else {
			if (fontDebug)
				NSLog(@"remove italics");
			[self removeItalicsFromRange:[textView rangeForUserTextChange]];
		}
	}
	
	if ( !(changed & ( NSItalicFontMask | NSBoldFontMask) )) {
		// doesn't look like a bold/italics request, so forward on
		NSLog(@"do something else");
		[textView changeFont:sender];
		return;
	}
	
	// Just pass on request for now
	//[textView changeFont:sender];

	return;
}

- (void)addItalicsToRange:(NSRange)range
{
	// Apply Italics to the current range
	if (range.length == 0){
		[[textView textStorage] replaceCharactersInRange:range
											  withString:@"**"];
		[textView setSelectedRange:NSMakeRange(range.location+1, 0)];
	} else {
		[self wrapRange:range prefix:@"*" suffix:@"*"];
	
		// Strip out prior italics inside the range
		NSRange trimmed = [textView selectedRange];
		
		NSMutableString *replacementString = [NSMutableString stringWithString:[[[textView textStorage] string] substringWithRange:trimmed]];

		// Preserve Bold
		[replacementString replaceOccurrencesOfString:@"**" 
										   withString:@"MMD-BOLD" 
											  options:0		
												range:NSMakeRange(0,[replacementString length])];

		// Strip italics
		[replacementString replaceOccurrencesOfString:@"*" 
										   withString:@"" 
											  options:0		
												range:NSMakeRange(0,[replacementString length])];

		// Replace Bold
		[replacementString replaceOccurrencesOfString:@"MMD-BOLD" 
										   withString:@"**" 
											  options:0		
												range:NSMakeRange(0,[replacementString length])];
		
		[[textView textStorage] replaceCharactersInRange:trimmed withString:replacementString];
		// Recalculate selected range and restore
		[textView setSelectedRange:NSMakeRange(trimmed.location, [replacementString length])];
	}
		 
	[hl parseAndHighlightNow];
}

- (void)addBoldToRange:(NSRange)range
{
	// Apply Bold to the current range
	if (range.length == 0){
		[[textView textStorage] replaceCharactersInRange:range
											  withString:@"****"];
		[textView setSelectedRange:NSMakeRange(range.location+2, 0)];
	} else {
		[self wrapRange:range prefix:@"**" suffix:@"**"];

		// Strip out prior bold inside the range
		NSRange trimmed = [textView selectedRange];
		
		NSMutableString *replacementString = [NSMutableString stringWithString:[[[textView textStorage] string] substringWithRange:trimmed]];
		[replacementString replaceOccurrencesOfString:@"**" 
										   withString:@"" 
											  options:0		
												range:NSMakeRange(0,[replacementString length])];
		
		[[textView textStorage] replaceCharactersInRange:trimmed withString:replacementString];

		// Recalculate selected range and restore
		[textView setSelectedRange:NSMakeRange(trimmed.location, [replacementString length])];
	}
	[hl parseAndHighlightNow];
}

- (void)removeBoldFromRange:(NSRange)range
{
	// Remove bold from the current range if possible
	if (range.length == 0){
		// nothing selected, not sure what to do here?
	} else {
		[self removeWrapFromRange:range prefix:@"**" suffix:@"**"];
	}
	[hl parseAndHighlightNow];

	return;
}

- (void)removeItalicsFromRange:(NSRange)range
{
	// Remove bold from the current range if possible
	if (range.length == 0){
		// nothing selected, not sure what to do here?
	} else {
		[self removeWrapFromRange:range prefix:@"*" suffix:@"*"];
	}
	[hl parseAndHighlightNow];
	
	return;
}

- (void)wrapRange:(NSRange)range prefix:(NSString *) prefix suffix:(NSString*) suffix
{
	// Trim leading and following whitespace from selection, then wrap in specified strings
	
	NSRange trimmed = [self trimSpaceOrFontMarkersFromRange:range];
	
	// Only select the part we're interested in
	[textView setSelectedRange:trimmed];
	
	
	[[textView textStorage] replaceCharactersInRange:NSMakeRange(trimmed.location+trimmed.length, 0)
										  withString:suffix];

	[[textView textStorage] replaceCharactersInRange:NSMakeRange(trimmed.location, 0)
										  withString:prefix];
	
}


- (void)removeWrapFromRange:(NSRange)range prefix:(NSString *) prefix suffix:(NSString*) suffix
{
	// Remove suffix
	if ( [suffix isEqualToString:[[[textView textStorage] string] 
								  substringWithRange:NSMakeRange(range.location+range.length, [suffix length])] ])
	{
		[[textView textStorage] replaceCharactersInRange:NSMakeRange(range.location+range.length, [suffix length])
											  withString:@""];
	}
	
	// Remove suffix
	if ( [prefix isEqualToString:[[[textView textStorage] string] 
								  substringWithRange:NSMakeRange(range.location-[prefix length], [prefix length])] ])
	{
		[[textView textStorage] replaceCharactersInRange:NSMakeRange(range.location-[prefix length], [prefix length])
											  withString:@""];
	}
	
}


- (NSRange)trimSpaceFromRange:(NSRange)range
{
	// given a range,return the range without any wrapping whitespace
	
	return [self trimCharactersInString:@" \t\r\n" FromRange:range];
}

- (NSRange)trimSpaceOrFontMarkersFromRange:(NSRange)range
{
	return [self trimCharactersInString:@"* \t\r\n" FromRange:range];
}

- (NSRange)trimFontMarkersFromRange:(NSRange)range
{
	return [self trimCharactersInString:@"*" FromRange:range];
}

- (NSRange)trimCharactersInString:(NSString *)characterString FromRange:(NSRange)range
{
	// given a range,return the range without any specified characters at begin/end
	
	NSRange start = [[[textView textStorage] string] rangeOfCharacterFromSet:[[NSCharacterSet characterSetWithCharactersInString:characterString] invertedSet] 
																	 options:0
																	   range:range];
	start.length = 0;
	
	NSRange end = [[[textView textStorage] string] rangeOfCharacterFromSet:[[NSCharacterSet characterSetWithCharactersInString:characterString] invertedSet]
																   options:NSBackwardsSearch
																	 range:range];
	end.length = 0;
	end.location += 1;
	
	NSRange result = NSMakeRange(start.location, end.location-start.location);
	return result;
}


@end
