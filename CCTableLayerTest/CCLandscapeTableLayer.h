//
//  CCLandscapeTableLayer.h
//  CCTableLayerTest
//
//  Created by Steven on 3/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCScrollLayer.h"
#import "CCTableLayerCell.h"

@class CCLandscapeTableLayer;

@protocol CCLandscapeTableLayerDelegate <CCScrollLayerDelegate>
- (CGFloat)landscapeTableLayer:(CCLandscapeTableLayer *)tableLayer widthForRowAtIndexPath:(NSIndexPath *)indexPath;
//配置单元格的高度
@optional
- (void)landscapeTableLayer:(CCLandscapeTableLayer *)tableLayer didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)landscapeTableLayer:(CCLandscapeTableLayer *)tableLayer cellNeedDelete:(CCTableLayerCell *)cell;
- (void)landscapeTableLayer:(CCLandscapeTableLayer *)tableLayer cellTouchDownAtIndexPath:(NSIndexPath *)indexPath;
//单元格响应到用户点击时的事件回调
@end


@protocol CCLandscapeTableLayerDataSource
- (NSInteger)landscapeTableLayer:(CCLandscapeTableLayer *)tableLayer numberOfRowsInSection:(NSInteger)section;
//配置单元格的行数
- (CCTableLayerCell *)landscapeTableLayer:(CCLandscapeTableLayer *)tableLayer cellForRowAtIndexPath:(NSIndexPath *)indexPath;
//配置具体的单元格，返回一个CCTableLayerCell类型的对象
@end


typedef enum
{
    CCLandscapeTableLayerRowAnimationDefault,
}CCLandscapeTableLayerRowAnimation;

@interface CCLandscapeTableLayer : CCScrollLayer
{
    id <CCLandscapeTableLayerDataSource> _dataSource;
    NSMutableArray *_widthAry;                 //存储单元格宽度
    NSMutableArray *_cellAry;                   //存储单元格
    NSMutableArray *_positionAry;               //存储单元格位置坐标
    NSMutableArray *_freeCells;                 //存储可重用的空闲单元格
    int _beginIndex;                            //目前显示的单元格的起始坐标
    int _endIndex;                              //目前显示的单元格的结束坐标
    BOOL _isReuse;                              //是否开启了重用
    CCTableLayerCell *_nullCell;
}

@property (nonatomic,assign) id <CCLandscapeTableLayerDataSource> dataSource;
@property (nonatomic,assign) id <CCLandscapeTableLayerDelegate> delegate;
- (CCTableLayerCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
//根据index值获取单元格cell

- (CCTableLayerCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
//通过id获取可重用的cell，返回为空时需要自己创建cell

- (void)insertRowsInRange:(NSRange)range withRowAnimation:(CCLandscapeTableLayerRowAnimation)animation;
//批量插入单元格，在插入之前需要修改数据源中单元格的总数量，否则会crash，和UITableView使用时一样。其中rang的location代表插入的地点，range的length代表插入的数量

- (void)deleteRowsInRange:(NSRange)range withRowAnimation:(CCLandscapeTableLayerRowAnimation)animation;
//批量删除，具体使用规则和插入一样

- (void)reloadRowsInRange:(NSRange)range withRowAnimation:(CCLandscapeTableLayerRowAnimation)animation;
//批量刷新单元格，具体使用规则和插入一样

- (void)scrollToIndex:(int)index animated:(BOOL)animated;
//使得列表滚动到指定的单元格索引

- (void)reloadData;
//重新刷新列表的所有数据

@end
