//
//  MyDocument.h
//  mmd-editor
//
//  Created by Fletcher T. Penney on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "HGMarkdownHighlighter.h"

@interface MyDocument: NSDocument
{
    IBOutlet NSTextView *textView;
    NSAttributedString *mString;

	HGMarkdownHighlighter *hl;
	
	BOOL isMMD;
	
	IBOutlet NSPanel *previewPanel;
	IBOutlet WebView *previewView;
}

- (NSAttributedString *) string;
- (void) setString: (NSAttributedString *) value;
- (NSString *)htmlForText;
- (IBAction)previewHTMLAction:(id)sender;

@property BOOL isMMD;

@end