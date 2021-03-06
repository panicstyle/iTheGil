//
//  ArticleData.h
//  iGongdong
//
//  Created by dykim on 2016. 3. 13..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArticleData : NSObject

@property (strong, nonatomic) NSString *m_strHtml;
@property (strong, nonatomic) NSString *m_strTitle;
@property (strong, nonatomic) NSString *m_strName;
@property (strong, nonatomic) NSString *m_strDate;
@property (strong, nonatomic) NSString *m_strHit;
@property (strong, nonatomic) NSString *m_strContent;
@property (strong, nonatomic) NSString *m_strEditableContent;

@property (strong, nonatomic) NSString *m_strBoardId;
@property (strong, nonatomic) NSString *m_strBoardNo;
@property (strong, nonatomic) NSMutableArray *m_arrayItems;
@property (strong, nonatomic) NSDictionary *m_attachItems;
@property id target;
@property SEL selector;

- (void)fetchItems;
- (bool)DeleteArticle:(NSString *)strBoardId boardNo:(NSString *)strBoardNo;
- (bool)DeleteComment:(NSString *)strBoardId boardNo:(NSString *)strBoardNo commentNo:(NSString *)strCommentNo;

@end
