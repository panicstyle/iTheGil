//
//  MainData.m
//  iMoojigae
//
//  Created by dykim on 2016. 3. 16..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "MainData.h"
#import "env.h"

@interface MainData () {
	NSMutableData *m_receiveData;
	NSURLConnection *m_connection;
}
@end

@implementation MainData
@synthesize m_arrayItems;
@synthesize m_strRecent;
@synthesize target;
@synthesize selector;

- (void)fetchItems
{
	m_arrayItems = [[NSMutableArray alloc] init];
	
	NSMutableDictionary *currItem;
	
	currItem = [[NSMutableDictionary alloc] init];
	[currItem setValue:@"최근글보기" forKey:@"title"];
	[currItem setValue:@"recent" forKey:@"link"];
	[m_arrayItems addObject:currItem];
	
	currItem = [[NSMutableDictionary alloc] init];
	[currItem setValue:@"무지개교육마을" forKey:@"title"];
	[currItem setValue:@"maul" forKey:@"link"];
	[m_arrayItems addObject:currItem];
	
	currItem = [[NSMutableDictionary alloc] init];
	[currItem setValue:@"초등무지개학교" forKey:@"title"];
	[currItem setValue:@"school1" forKey:@"link"];
	[m_arrayItems addObject:currItem];
	
	currItem = [[NSMutableDictionary alloc] init];
	[currItem setValue:@"중등무지개학교" forKey:@"title"];
	[currItem setValue:@"school2" forKey:@"link"];
	[m_arrayItems addObject:currItem];
	
	[self fetchItems2];
}

- (void)fetchItems2
{
	NSLog(@"fetchItems2");
	m_receiveData = [[NSMutableData alloc] init];
	
	NSString *url = [NSString stringWithFormat:@"%@/board-api-menu.do?comm=0", MENU_SERVER];
	NSLog(@"query = [%@]", url);
	
	m_connection = [[NSURLConnection alloc]
					initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
	NSLog(@"fetchItems 3");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"didReceiveData");
	[m_receiveData appendData:data];
	NSLog(@"didReceiveData receiveData=[%lu], data=[%lu]", (unsigned long)[m_receiveData length], (unsigned long)[data length]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"ListView receiveData Size = [%lu]", (unsigned long)[m_receiveData length]);
	
	NSString *html = [[NSString alloc] initWithData:m_receiveData
										   encoding:NSUTF8StringEncoding];
	
	NSLog(@"html=[%@]", html);
	
	NSError *localError = nil;
	NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:m_receiveData options:0 error:&localError];
	
	if (localError != nil) {
		return;
	}
	
	m_strRecent = [parsedObject valueForKey:@"recent"];
	NSLog(@"m_strRecent %@", m_strRecent);
	
	[target performSelector:selector withObject:nil afterDelay:0];
}

@end
