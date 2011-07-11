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
	[stylesChooser addItemWithTitle:@"Default"];	

	NSArray *styleFiles = [[NSBundle mainBundle] pathsForResourcesOfType:@"style"
															 inDirectory:nil];
	for (NSString *file in styleFiles)
		[stylesChooser addItemWithTitle:[[file lastPathComponent] stringByDeletingPathExtension]];
	
	[stylesChooser selectItemWithTitle:[[NSUserDefaults standardUserDefaults] stringForKey:@"defaultStyleSheet"]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self populateStylesPopUpButton];
}


@end
