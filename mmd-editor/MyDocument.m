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

	// Set default styleSheet
	[defaults setValue:@"fletcher" forKey:@"defaultStyleSheet"];
	
	// Use MultiMarkdown by default
	[defaults setBool:YES
			   forKey:@"useMultiMarkdown"];
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
		hl.makeLinksClickable = YES;

		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useMultiMarkdown"]) {
			hl.extensions = hl.extensions | EXT_MMD;
		}
		
		hl.formatParagraphs = YES;
		
		NSString *styleName = [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultStyleSheet"];
		
		NSString *styleFilePath = [[NSBundle mainBundle] pathForResource:styleName
																  ofType:@"style"];
		NSString *styleContents = [NSString stringWithContentsOfFile:styleFilePath
															encoding:NSUTF8StringEncoding
															   error:NULL];

		
		[hl applyStylesFromStylesheet:styleContents
					 withErrorDelegate:self
						 errorSelector:@selector(handleStyleParsingErrors:)];		
		[hl activate];
		
		self.isMMD = YES;
		
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
		[hl readClearTextStylesFromTextView];
    }
		
	
}

- (IBAction)tidyRulers:(id)sender
{
	[hl resetParagraphs];
	[hl formatMetaData];
	[hl formatTables];
	[hl formatBlockQuotes];
}



@end
