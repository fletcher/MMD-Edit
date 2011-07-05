//
//  MyDocument.m
//  mmd-editor
//
//  Created by Fletcher T. Penney on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyDocument.h"
#import "HGMarkdownHighlightingStyle.h"

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
		[textView setFont:[NSFont fontWithName:@"courier" size:13]];


		hl = [[HGMarkdownHighlighter alloc] init];
		hl.targetTextView = textView;
		hl.parseAndHighlightAutomatically = YES;
		hl.waitInterval = 0.3;
		hl.makeLinksClickable = YES;
		
		self.isMMD = YES;
		hl.extensions = hl.extensions | EXT_SMART | EXT_NOTES;
		
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

@end
