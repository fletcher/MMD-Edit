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
		hl.makeLinksClickable = YES;

		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useMultiMarkdown"]) {
			hl.extensions = hl.extensions | EXT_MMD;
		}
		
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

//	NSLog(@"launching %@", [path2MMD stringByExpandingTildeInPath]);
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
//	NSLog(@"creating preview");
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"previewWithMarked"]) {
		// Open current document in Brett Terpstra's Marked application for previewing
		if ([self fileURL] != nil){
			[[NSWorkspace sharedWorkspace] openFile:[[self fileURL] path] withApplication:@"Marked"];
			
			// But we want to stay on top
			[[NSApplication sharedApplication] activateIgnoringOtherApps : YES];
			[[self windowForSheet] becomeKeyWindow];
		}
	}else {
		[previewPanel makeKeyAndOrderFront:nil];
		[[previewView mainFrame] loadHTMLString:[self htmlForText] baseURL:[self fileURL]];
	}
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

- (IBAction)openDocumentInMarked:(id)sender
{
}

@end
