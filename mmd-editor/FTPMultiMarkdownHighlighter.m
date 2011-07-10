//
//  FTPMultiMarkdownHighlighter.m
//
//  Created by Fletcher T. Penney on 7/9/11.
//  Copyright 2011 Fletcher T. Penney. All rights reserved.
//

#import "FTPMultiMarkdownHighlighter.h"
#import "HGMarkdownHighlightingStyle.h"

@implementation FTPMultiMarkdownHighlighter

@synthesize currentLineAttributes;

- (id) init
{
	if (!(self = [super init]))
		return nil;
	
	self.extensions = self.extensions | EXT_MMD;
	self.currentLineAttributes = nil;

	return self;
}



// - (NSRange)textView:(NSTextView *)theTextView
// willChangeSelectionFromCharacterRange:(NSRange)oldSelectedCharRange
 //  toCharacterRange:(NSRange)newSelectedCharRange;

- (void) textViewDidChangeSelection:(NSNotification *)notification
{
	id editor;
	editor = [notification object];
	
	if((editor != nil) && ([editor isKindOfClass:[NSTextView class]]
						   == YES))
	{

		// Highlight current line/paragraph?
		
		NSMutableAttributedString *attrStr = [editor textStorage];
		NSRange currentPara = [editor rangeForUserParagraphAttributeChange];
		
		NSLog(@"range length: %d", currentPara.length);
	//	[attrStr addAttributes:[[editor delegate] currentLineAttributes] range:currentPara];

		
		NSFont *myFont = [NSFont fontWithName:@"courier" size:13];
		NSMutableDictionary* typingAttributes = [[editor typingAttributes] mutableCopy];
		[typingAttributes setObject:myFont forKey:NSFontAttributeName];
		
		
		
		[editor setTypingAttributes:[[editor delegate]
									 defaultTypingAttributes]];
		[attrStr addAttributes:typingAttributes range:currentPara];
		
		[[editor delegate] applyVisibleRangeHighlighting];
	//	[self.targetTextView didChangeText];

	}
}

- (void) applyStylesFromStylesheet:(NSString *)stylesheet
				 withErrorDelegate:(id)errorDelegate
					 errorSelector:(SEL)errorSelector
{
	[super applyStylesFromStylesheet:stylesheet
					   withErrorDelegate:errorDelegate
						   errorSelector:errorSelector];
	
	for (HGMarkdownHighlightingStyle *style in self.styles)
	{
		if (style.elementType == CURRENT) {
			NSLog(@"loaded current");
			self.currentLineAttributes = style.attributesToAdd;
		}
	}
}

@end
