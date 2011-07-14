//
//  FTPEditingMultiMarkdownHighlighter.m
//
//  Created by Fletcher T. Penney on 7/14/11.
//  Copyright 2011 Fletcher T. Penney. All rights reserved.
//
//	Adds features for interactive editing of MultiMarkdown documents

#import "FTPEditingMultiMarkdownHighlighter.h"
#import "HGMarkdownHighlightingStyle.h"

@implementation FTPEditingMultiMarkdownHighlighter

- (BOOL)textView:(NSTextView *)view shouldChangeTextInRange:(NSRange)range replacementString:(NSString *)replacementString
{
	// We're about to add a string, so let's see if we need to intervene
	
	
	// Handle newlines separately
	if ([replacementString isEqualToString:@"\n"])
	{
		[self insertNewlineAtRange:range];
		return YES;
	}

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
		}
		return YES;
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
		}
		return YES;
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
		}
		return YES;
	}
	
	
	return YES;
}

- (void)insertNewlineAtRange:(NSRange)range
{
	if ([self itemIsInsideElementType:H1 range:range])
		NSLog(@"H1");
}

- (BOOL)itemIsInsideElementType:(int)elementType range:(NSRange)range
{
	NSArray *anArray = [self rangesForElementType:elementType];
	id anItem;
	NSRange itemRange;
	
	NSEnumerator *enumerator = [anArray objectEnumerator];
		
		while (anItem = [enumerator nextObject]) {
			itemRange = NSRangeFromString(anItem);
			NSLog(@"compare %d:%d",range.location,itemRange.location);
			if ((range.location-1 >= itemRange.location) &&
				(range.location-1 <= itemRange.location+itemRange.length)){
				NSLog(@"yep");
				return YES;
			}
		}
	
	NSLog(@"nope");
	return NO;
}

@end
