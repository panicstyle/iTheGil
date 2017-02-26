//
//  MainData.h
//  iMoojigae
//
//  Created by dykim on 2016. 3. 16..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainData : NSObject
@property (strong, nonatomic) NSMutableArray *m_arrayItems;
@property (strong, nonatomic) NSString *m_strRecent;
@property id target;
@property SEL selector;

- (void)fetchItems;
@end
