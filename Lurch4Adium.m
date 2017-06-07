//
//  Lurch4Adium.m
//  Lurch4Adium
//
//  Copyright (C) 2017 Olivier Mehani.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "Lurch4Adium.h"

extern void purple_init_carbons_plugin();
extern void purple_init_lurch_plugin();

@implementation Lurch4Adium

- (void) installPlugin
{
}

- (void) installLibpurplePlugin
{
    purple_init_carbons_plugin();
    purple_init_lurch_plugin();
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
