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
	
	[self fetchItems2];
}

- (void)fetchItems2
{
	NSLog(@"fetchItems2");
	m_receiveData = [[NSMutableData alloc] init];
	
	NSString *url;
	url = [NSString stringWithFormat:@"%@/board-api-menu.do?comm=4", MENU_SERVER];
	
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
	
	NSArray *jsonItems = [parsedObject valueForKey:@"menu"];
	
	NSMutableDictionary *currItem;
	
	for (int i = 0; i < [jsonItems count]; i++) {
		NSDictionary *jsonItem = [jsonItems objectAtIndex:i];
		
		currItem = [[NSMutableDictionary alloc] init];
		
		// title
		NSString *strTitle = [jsonItem valueForKey:@"title"];
		[currItem setValue:strTitle forKey:@"title"];
		
		// type
		NSString *strType = [jsonItem valueForKey:@"type"];
		[currItem setValue:strType forKey:@"type"];
		
		// boardId
		NSString *strBoardId = [jsonItem valueForKey:@"boardId"];
		[currItem setValue:strBoardId forKey:@"boardId"];
		
		[m_arrayItems addObject:currItem];
	}
	
	[target performSelector:selector withObject:nil afterDelay:0];
}

@end
