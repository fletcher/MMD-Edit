//
//  AppDelegate.m
//  mmd-editor
//
//  Created by Fletcher T. Penney on 7/10/11.
//  Copyright 2011 Fletcher T. Penney. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

- (void) populateStylesPopUpButton
{
	[stylesChooser removeAllItems];
//	[stylesChooser addItemWithTitle:@"Default"];	
	
	// Store the names here so we can sort them
	NSMutableArray *styleNames = [[NSMutableArray alloc] init];

	// Find styles included in our app
	NSArray *styleFiles = [[NSBundle mainBundle] pathsForResourcesOfType:@"style"
															 inDirectory:nil];
	for (NSString *file in styleFiles)
		[styleNames addObject:[[file lastPathComponent] stringByDeletingPathExtension]];

	// Check Application Support for style sheets added by user
	NSArray *appSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSAllDomainsMask, YES);
	
	NSEnumerator *enumerator = [appSupportPaths objectEnumerator];
	id aPath;
	
	while (aPath = [enumerator nextObject])
	{

		NSString *styleFolderPath = [aPath stringByAppendingPathComponent:@"MMD-Edit/Styles/"];
		
		styleFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:styleFolderPath error:nil];
		id aFile;
		enumerator = [styleFiles objectEnumerator];
		
		while (aFile = [enumerator nextObject]) {
			if ([[aFile pathExtension] isEqualToString:@"style"])
				[styleNames addObject:[aFile stringByDeletingPathExtension]];
		}
	}
	
	enumerator = [[styleNames sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectEnumerator];
	id aStyle;
	
	while (aStyle = [enumerator nextObject])
		[stylesChooser addItemWithTitle:aStyle];
		
	[stylesChooser selectItemWithTitle:[[NSUserDefaults standardUserDefaults] stringForKey:@"defaultStyleSheet"]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self populateStylesPopUpButton];
	
	// Allow MyDocument to intercept requests to change font styling
	[[NSFontManager sharedFontManager] setAction:@selector(myChangeFont:)];
}


@end
