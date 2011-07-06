//
//  MyDocument.m
//  mmd-editor
//
//  Created by Fletcher T. Penney on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyDocument.h"
#import "HGMarkdownHighlightingStyle.h"
#import "HGMarkdownHighlighter.h"

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

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    //	Add any code here that needs to be executed once the windowController has loaded the document's window.
	if ([self string] != nil) {
	//	[textView setRulerVisible:TRUE];
		[[textView textStorage] setAttributedString: [self string]];
		
		[textView setAlignment:NSJustifiedTextAlignment range:NSMakeRange(0, [[self string] length])];
		[textView setFont:[NSFont fontWithName:@"palatino" size:13]];


		hl = [[HGMarkdownHighlighter alloc] init];
		hl.targetTextView = textView;
		hl.parseAndHighlightAutomatically = YES;
		hl.waitInterval = 0.3;
		hl.makeLinksClickable = YES;
		
		self.isMMD = YES;
		
		[hl activate];
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

- (void) textDidChange: (NSNotification *) notification
{
    [self setString: [textView textStorage]];
}

- (NSString *)htmlForText
{
	// Use an externally installed version of MMD 3 - eventually I would like to build this in
	
	NSString *path2MMD = @"/usr/local/bin/multimarkdown";

//	NSLog(@"launching %@", [path2MMD stringByExpandingTildeInPath]);
	NSTask* task = [[NSTask alloc] init];
	[task setLaunchPath: [path2MMD stringByExpandingTildeInPath]];
	[task setArguments: [NSArray arrayWithObjects: nil]];
	
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
//	NSLog(@"creating preview");
	
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
		
		[hl clearHighlighting];
		[hl parseAndHighlightNow];
    }
}

- (IBAction)formatMetaData:(id)sender
{
	// find range for MetaData and do something
	int maxWidth = 0;
	
	NSArray *metaDataRanges = [hl rangesForElementType:METADATA];
	
	if ([metaDataRanges count] == 0)
		return;
	
	NSString *metaDataRangeString = [metaDataRanges objectAtIndex:0];
	NSRange metaDataRange = NSRangeFromString(metaDataRangeString);
	
	//	NSLog(@"Found range %@",metaDataRangeString);
	//	[hl clearHighlightingForRange:metaDataRange];
	
	NSArray *metaKeyArray = [hl rangesForElementType:METAKEY inRange:metaDataRange];
	
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

	
	NSMutableParagraphStyle *paraStyle; // = [[textView defaultParagraphStyle] mutableCopy];
	
		
//	if (paraStyle == nil) {
		paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//	}
	
	NSFont *myFont = [[textView textStorage] font];
	
	float charWidth = [[myFont screenFontWithRenderingMode:NSFontDefaultRenderingMode] advancementForGlyph:(NSGlyph) 'T'].width;
	[paraStyle setDefaultTabInterval:(charWidth * (maxWidth +4))];
	[paraStyle setTabStops:[NSArray array]];
	
//	[textView setDefaultParagraphStyle:paragraphStyle];
	
	NSMutableDictionary* typingAttributes = [[textView typingAttributes] mutableCopy];
	[typingAttributes setObject:paraStyle forKey:NSParagraphStyleAttributeName];
	[typingAttributes setObject:myFont forKey:NSFontAttributeName];
//	[textView setTypingAttributes:typingAttributes];
	
	/** ADDED CODE BELOW **/
	[textView shouldChangeTextInRange:metaDataRange replacementString:nil];
	[[textView textStorage] setAttributes:typingAttributes range:metaDataRange];
	[textView didChangeText];
	
	[paraStyle release];
	[typingAttributes release];
	
	[self formatTables:nil];
}

- (IBAction)formatTables:(id)sender
{
	// find range for Tables and do something
	NSArray *tableRanges = [hl rangesForElementType:TABLE];
	
	if ([tableRanges count] == 0)
		return;
	
	NSEnumerator *enumerator = [tableRanges objectEnumerator];
	id aTableRangeString;
	
	//NSFont *myFont = [[textView textStorage] font];
	
	NSMutableDictionary* typingAttributes = [[textView typingAttributes] mutableCopy];
	[typingAttributes setObject:[NSFont fontWithName:@"courier" size:13] forKey:NSFontAttributeName];

	while (aTableRangeString = [enumerator nextObject]) {
		NSRange theRange = NSRangeFromString(aTableRangeString);
		

		[[textView textStorage] setAttributes:typingAttributes range:theRange];
	}
	
	//[textView setFont:myFont];
	[textView didChangeText];
}


@end
