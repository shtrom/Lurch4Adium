//
//  Carbons4Adium.m
//  Carbons4Adium
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

#import "Carbons4Adium.h"
#import "../vendor/carbons/src/carbons.h"

extern void purple_init_carbons_plugin();

@implementation Carbons4Adium

- (void) installPlugin
{
}

- (void) installLibpurplePlugin
{
    purple_init_carbons_plugin();
}

- (void) loadLibpurplePlugin
{
}

- (void) uninstallPlugin
{
}

- (NSString *)pluginAuthor
{
	return @"Olivier Mehani <shtrom+l4a@ssji.net>";
}

-(NSString *)pluginVersion
{
	return [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"];
}

-(NSString *)pluginDescription
{
	return @"Message carbons plugin\n"
		"Heavily reliant an the following libpurple plugin\n"
		"carbons " CARBONS_VERSION " by " CARBONS_AUTHOR "\n";
}

-(NSString *)pluginUrl
{
	return @"https://github.com/shtrom/Lurch4Adium";
}

@end
