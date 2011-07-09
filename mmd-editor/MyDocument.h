//
//  MyDocument.h
//  mmd-editor
//
//  Created by Fletcher T. Penney on 6/29/11.
//  Copyright 2011 Fletcher T. Penney. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "FTPMultiMarkdownHighlighter.h"

@interface MyDocument: NSDocument
{
    IBOutlet NSTextView *textView;
    NSAttributedString *mString;

	FTPMultiMarkdownHighlighter *hl;
	
	BOOL isMMD;
	
	IBOutlet NSPanel *previewPanel;
	IBOutlet WebView *previewView;
}

- (NSAttributedString *) string;
- (void) setString: (NSAttributedString *) value;
- (NSString *)htmlForText;
- (IBAction)previewHTMLAction:(id)sender;

- (IBAction)tidyRulers:(id)sender;
- (IBAction)formatMetaData:(id)sender;
- (IBAction)formatTables:(id)sender;

- (void) handleStyleParsingErrors:(NSArray *)errorMessages;

@property BOOL isMMD;

@end