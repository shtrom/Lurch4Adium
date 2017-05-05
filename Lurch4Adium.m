//
//  Lurch4Adium.m
//  Lurch4Adium
//
//  Created by Olivier Mehani on 5/5/17.
//  Copyright © 2017 Olivier Mehani. All rights reserved.
//

#import "Lurch4Adium.h"

extern void purple_init_carbons_plugin();
extern void purple_init_lurch_plugin();


@implementation Lurch4Adium

- (void) installPlugin
{
    purple_init_carbons_plugin();
    purple_init_lurch_plugin();
}

- (void) installLibpurplePlugin
{
}

- (void) loadLibpurplePlugin
{
}

- (void) uninstallPlugin
{
}

- (NSString *)pluginAuthor
{
	return @"Olivier Mehani";
}

-(NSString *)pluginDescription
{
	return @"OMEMO multi-client end-to-end encryption";
}

@end
