//
//  CCLandscapeTableLayer.m
//  CCTableLayerTest
//
//  Created by Steven on 3/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CCLandscapeTableLayer.h"



@interface CCLandscapeTableLayer (Provate)
- (void)addFromBelow;
- (void)addFromTop;
- (void)removeFromTop;
- (void)removeFromBelow;
@end

@implementation CCLandscapeTableLayer
@dynamic delegate;
@synthesize dataSource = _dataSource;


- (id)init
{
    //self = [super initWithColor:ccc4(255, 0, 0, 255)];
    self = [super init];
    if(self)
    {
        _widthAry = [[NSMutableArray alloc]init];
        _cellAry = [[NSMutableArray alloc]init];
        _positionAry = [[NSMutableArray alloc]init];
        _freeCells = [[NSMutableArray alloc]init];
        _nullCell = [[CCTableLayerCell alloc]init];
        _yEnable = NO;
        _endIndex = -1;
    }
    return self;
}

- (void)initialize
{
    [_positionAry removeAllObjects];
    [_cellAry removeAllObjects];
    [_widthAry removeAllObjects];
    int cellCount = [_dataSource landscapeTableLayer:self numberOfRowsInSection:0];
    CGFloat contentWidth = 0.f;
    for (int i = 0; i<cellCount; i++) //获取高度数组
    {
        CGFloat width = [self.delegate landscapeTableLayer:self widthForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [_widthAry addObject:[NSNumber numberWithFloat:width]];
        [_positionAry addObject:[NSNumber numberWithFloat:contentWidth]];
        [_cellAry addObject:_nullCell];
        
        contentWidth += width;
    }
    /*
    CGFloat tempWidth = 0;//MAX(contentWidth, self.contentSize.width);
    for(NSNumber *width in _widthAry)
    {
        tempWidth += [width floatValue];
        [_positionAry addObject:[NSNumber numberWithFloat:tempWidth]];
        [_cellAry addObject:_nullCell];
    }
     */
    _contentLayer.contentSize = CGSizeMake(MAX(contentWidth, self.contentSize.width), self.contentSize.height );
}

- (void)resetCellInfo
{
    [_positionAry removeAllObjects];
    [_widthAry removeAllObjects];
    int cellCount = [_dataSource landscapeTableLayer:self numberOfRowsInSection:0];
    CGFloat contentWidth = 0.f;
    for(int i = 0; i<cellCount; i++) //获取高度数组
    {
        CGFloat width = [self.delegate landscapeTableLayer:self widthForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [_widthAry addObject:[NSNumber numberWithFloat:width]];
        [_positionAry addObject:[NSNumber numberWithFloat:contentWidth]];
        [_cellAry addObject:_nullCell];
        
        contentWidth += width;
    }
    _contentLayer.contentSize = CGSizeMake(MAX(contentWidth, self.contentSize.width), self.contentSize.height);
}
- (void)setDataSource:(id<CCLandscapeTableLayerDataSource>)dataSource
{
    _dataSource = dataSource;
    if(self.delegate)
    {
        [self initialize];
        [self scrollToTop:NO];
    }
}

- (void)setDelegate:(id<CCLandscapeTableLayerDelegate>)delegate
{
    _delegate = delegate;
    if(_dataSource)
    {
        [self initialize];
        [self scrollToTop:NO];
    }
}


- (void)dealloc
{
    [_nullCell release];
    [_positionAry release];
    [_freeCells release];
    [_cellAry release];
    [_widthAry release];
    [super dealloc];
}
#pragma mark - 内部工具方法


- (CGFloat)getPositionWithIndex:(int)index
{
    return [[_positionAry objectAtIndex:index]floatValue] - [[_widthAry objectAtIndex:index]floatValue];
}

- (int)indexOfPosition:(CGPoint)position
{
    int index = 0;
    CGFloat width = 0;
    while (position.x>= width)
    {
        if(_widthAry.count <= index)
        {
            index = -1;
            break;
        }
        width += [[_widthAry objectAtIndex:index]floatValue];
        index++;
    }
    return index - 1;
}

- (int)indexOfTouchLocation:(CGPoint)position
{
    int index = 0;
    CGFloat width = 0;
    
    while ((self.contentSize.width -position.x) + _contentOffset.x >= width)
    {
        if(_widthAry.count <= index)
        {
            index = -1;
            break;
        }
        width += [[_widthAry objectAtIndex:index]floatValue];
        index++;
    }
    return index - 1;
}

- (void)insertEnd:(CCTableLayerCell *)cell
{
    [_contentLayer reorderChild:cell z:[_cellAry indexOfObject:cell]];
}

- (BOOL)hasEventSliderOccurred:(CGPoint)touchPoint
{
    if(abs(touchPoint.x - _beginPoint.x) > 50 && abs(touchPoint.y - _beginPoint.y) < 10)
    {
        return YES;
    }
    return NO;
}
#pragma mark - contentLayer delegate
- (void)contentLayerDidMove
{
    [super contentLayerDidMove];
    [self checkValidCell];
}
//添加cell

- (CCTableLayerCell *)addCellAtIndex:(int)index
{
    CCTableLayerCell *cell = [self.dataSource landscapeTableLayer:self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.index = index;
    CGFloat width = [[_widthAry objectAtIndex:index]floatValue];
    CGFloat xPosition = [[_positionAry objectAtIndex:index] floatValue];
    cell.position = ccp(xPosition, 0);
    cell.contentSize = CGSizeMake(width, self.contentSize.height);
    [_contentLayer addChild:cell z:index];
    [_cellAry replaceObjectAtIndex:index withObject:cell];
    return cell;
}
//释放cell
- (void)releaseCellAtIndex:(int)index
{
    CCTableLayerCell *cell = [_cellAry objectAtIndex:index];
    [cell removeFromParentAndCleanup:YES];
    cell.isSelected = NO;
    [cell resetCell];
    [_freeCells addObject:cell];
    [_cellAry replaceObjectAtIndex:index withObject:_nullCell];
}
//释放不显示的cell
- (void)releaseUnusedCell
{
    for(int index = 0; index < _cellAry.count; index++)
    {
        CCTableLayerCell *cell = [_cellAry objectAtIndex:index];
        CGFloat xPosition = [[_positionAry objectAtIndex:index]floatValue];
        CGFloat width = [[_widthAry objectAtIndex:index]floatValue];
        if((xPosition + width < _contentOffset.x || xPosition > _contentOffset.x +self.contentSize.width) && ![cell isEqual:_nullCell])
        {
            [self releaseCellAtIndex:index];
        }
    }
}
//添加新cell
- (void)addNewCell
{
    for(int index = 0; index < _cellAry.count; index++)
    {
        CCTableLayerCell *cell = [_cellAry objectAtIndex:index];
        CGFloat xPosition = [[_positionAry objectAtIndex:index]floatValue];
        CGFloat width = [[_widthAry objectAtIndex:index]floatValue];
        
        if(xPosition + width >= _contentOffset.x && xPosition <= _contentOffset.x +self.contentSize.width && [cell isEqual:_nullCell])
        {
            [self addCellAtIndex:index];
        }
        
        /*
        if(xPosition + width >= _contentLayer.contentSize.width - _contentOffset.x - self.contentSize.width && xPosition <= _contentLayer.contentSize.width - _contentOffset.x && [cell isEqual:_nullCell])
        {
            [self addCellAtIndex:index];
        }
         */
    }
}

- (void)checkValidCell
{
    if(_isReuse)//如果开启了cell的重用
    {
        [self releaseUnusedCell];   //释放不用的cell
    }
    [self addNewCell];          //添加需要显示的cell;
    
}


- (CGPoint)convertToVisableFrame:(CGPoint)point
{
    point = [[CCDirector sharedDirector] convertToGL:point];
    point = [self convertToNodeSpace:point];
    point.x = self.contentSize.width - point.x;
    return  point;
}

#pragma mark - 对外接口
- (void)scrollToIndex:(int)index animated:(BOOL)animated
{
    CGFloat indexPosition = 0;
    for(int i = 0;i < index;i++)
    {
        indexPosition += [[_widthAry objectAtIndex:i]floatValue];
    }
    
    if(indexPosition > _contentLayer.contentSize.width - self.contentSize.width)
    {
        indexPosition = _contentLayer.contentSize.width - self.contentSize.width;
    }
    [self setContentOffset:CGPointMake(indexPosition, self.contentOffset.y) animated:animated];
}

- (CCTableLayerCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    _isReuse = YES;
    for(CCTableLayerCell *cell in _freeCells)
    {
        if([cell.reuseIdentifier isEqualToString:identifier])
        {
            [cell retain];
            [_freeCells removeObject:cell];
            return [cell autorelease];
        }
    }
    return nil;
}

- (CCTableLayerCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_cellAry.count <= indexPath.row)
    {
        return nil;
    }
    return [_cellAry objectAtIndex:indexPath.row];
}

- (void)insertRowsInRange:(NSRange)range withRowAnimation:(CCLandscapeTableLayerRowAnimation)animation
{
    CGFloat width = _contentLayer.contentSize.width;
    [self resetCellInfo];
    [self setContentOffset:_contentOffset animated:NO];
    //填充空cell
    for(int index = range.location;index < range.location + range.length; index++)
    {
        [_cellAry insertObject:_nullCell atIndex:index];
    }
    for(int index = 0;index < range.location; index++)
    {
        CCTableLayerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.index = index;
        CGFloat xPosition = [[_positionAry objectAtIndex:index]floatValue];
        if(xPosition - cell.position.x != _contentLayer.contentSize.width - width)
        {
            [cell stopAllActions];
            CCMoveTo *move = [CCMoveTo actionWithDuration:0.2 position:ccp(xPosition, 0)];
            move.tag = 1;
            [cell runAction:move];
        }
        else {
            cell.position = ccp(xPosition, 0);
        }
        
    }
    for(int index = range.location;index < range.location + range.length; index++)
    {
        CCTableLayerCell *cell = [self addCellAtIndex:index];
        cell.index = index;
        [_contentLayer reorderChild:cell z:-1];
        if(range.location > 0)
        {
            cell.position = ccp(0, [[_positionAry objectAtIndex:range.location - 1]floatValue]);
        }
        else {
            cell.position = ccp(0, [[_positionAry objectAtIndex:range.location]floatValue]);
        }
        CGFloat xPosition = [[_positionAry objectAtIndex:index]floatValue];
        CCMoveTo *move = [CCMoveTo actionWithDuration:0.2 position:ccp(xPosition, 0)];
        CCCallFuncN *insertEnd = [CCCallFuncN actionWithTarget:self selector:@selector(insertEnd:)];
        CCSequence *sequence = [CCSequence actions:move, insertEnd, nil];
        [cell runAction:sequence];
    }
    for(int index = range.location + range.length; index<_cellAry.count; index++)
    {
        CCTableLayerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.index = index;
        CGPoint destination = CGPointZero;
        [cell stopAllActions];
        cell.position = ccp(cell.position.x - width + _contentLayer.contentSize.width, 0);
        destination.x = [[_positionAry objectAtIndex:index]floatValue];
        CCMoveTo *move = [CCMoveTo actionWithDuration:0.2 position:destination];
        move.tag = 1;
        [cell runAction:move];
    }
}



- (void)deleteRowsInRange:(NSRange)range withRowAnimation:(CCLandscapeTableLayerRowAnimation)animation
{
    CGFloat width = _contentLayer.contentSize.width;
    [self resetCellInfo];
    //填充空cell
    for(int index = range.location;index < range.location + range.length; index++)
    {
        [self releaseCellAtIndex:index];
    }
    //    [self setContentOffset:_contentOffset animated:NO];
    for(int index = 0;index < range.location; index++)
    {
        CCTableLayerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.index = index;
        CGFloat xPosition = [[_positionAry objectAtIndex:index]floatValue];
        
        cell.position = ccp(xPosition, 0);
    }
    [_cellAry removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    for(int index = range.location; index<_cellAry.count; index++)
    {
        CCTableLayerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.index = index;
        CGPoint destination = CGPointZero;
        cell.position = ccp(cell.position.x - width + _contentLayer.contentSize.width, 0);
        destination.x = [[_positionAry objectAtIndex:index]floatValue];
        CCMoveTo *move = [CCMoveTo actionWithDuration:0.2 position:destination];
        [cell runAction:move];
    }
    [self setContentOffset:_contentOffset animated:NO];
    
}

- (void)reloadRowsInRange:(NSRange)range withRowAnimation:(CCLandscapeTableLayerRowAnimation)animation
{
    CGFloat width = _contentLayer.contentSize.width;
    [self resetCellInfo];
    [self setContentOffset:_contentOffset animated:NO];
    for(int index = 0;index < range.location; index++)
    {
        CCTableLayerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.index = index;
        CGFloat xPosition = [[_positionAry objectAtIndex:index]floatValue];
        [cell stopAllActions];
        cell.position = ccp(xPosition, 0);
    }
    for(int index = range.location;index < range.location + range.length; index++)
    {
        CCTableLayerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.index = index;
        if(![cell isEqual:_nullCell])
        {
            [self releaseCellAtIndex:index];
            [self addCellAtIndex:index];
        }
    }
    for(int index = range.location + range.length; index<_cellAry.count; index++)
    {
        CCTableLayerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.index = index;
        CGPoint destination = CGPointZero;
        cell.position = ccp(cell.position.x - width + _contentLayer.contentSize.width, 0);
        destination.x = [[_positionAry objectAtIndex:index]floatValue];
        CCMoveTo *move = [CCMoveTo actionWithDuration:0.2 position:destination];
        [cell runAction:move];
    }
}

- (void)reloadData
{
    [_contentLayer removeAllChildrenWithCleanup:YES];
    [_contentLayer stopAllActions];
    [_cellAry removeAllObjects];
    [_freeCells removeAllObjects];
    [_widthAry removeAllObjects];
    [_positionAry removeAllObjects];
    _beginIndex = -1;
    _endIndex = -1;
    _contentOffset = CGPointZero;
    [self initialize];
    [self scrollToTop:NO];
}
#pragma mark -
#pragma mark - dynamic cell processing

#pragma mark - touch
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint point = [touch locationInView:touch.view];
    point = [self convertToVisableFrame:point];
    
    if([super ccTouchBegan:touch withEvent:event])
    {
        
        int index = [self indexOfTouchLocation:point];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        CCTableLayerCell *cell = [self cellForRowAtIndexPath:indexPath];
        
        if(!self.isDecelerating)
        {
            [cell touchDown];//播放按下动画
        }
        if([_delegate respondsToSelector:@selector(landscapeTableLayer:cellTouchDownAtIndexPath:)])
        {
            [_delegate performSelector:@selector(landscapeTableLayer:cellTouchDownAtIndexPath:) withObject:self withObject:indexPath];
        }
        return YES;
    }
    return NO;
}


- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    [_contentLayer stopAllActions];
    CGPoint point = [touch locationInView:touch.view];
    CGPoint oriPoint = point;
    [super ccTouchMoved:touch withEvent:event];
    if(![super isTouchInside:point])
    {
        return;
    }
    point = [self convertToVisableFrame:point];
    int index = [self indexOfTouchLocation:point];
    for(CCTableLayerCell *cell in _cellAry)//效率有待优化
    {
        if(cell.isTouchDown)
        {
            [cell touchUp];
        }
    }
    if(abs(oriPoint.x - _beginPoint.x) > 50 && abs(oriPoint.y - _beginPoint.y) < 10)
    {
        if(index >= 0 && [_delegate respondsToSelector:@selector(tableLayer:cellNeedDelete:)])
        {
            CCTableLayerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            [self.delegate landscapeTableLayer:self cellNeedDelete:cell];
        }
    }
}



- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL isDragging = _isDragging;
    [super ccTouchEnded:touch withEvent:event];
    CGPoint point = [touch locationInView:touch.view];
    if(![super isTouchInside:point])
    {
        //        [super ccTouchEnded:touch withEvent:event];
        return;
    }
    
    point = [self convertToVisableFrame:point];
    
    CCLOG(@"Touch end point x:%f, y:%f", point.x, point.y);
    
    int index = [self indexOfTouchLocation:point];
    if(index >= 0 && !isDragging && !self.isDecelerating)
    {
        if([self.delegate respondsToSelector:@selector(landscapeTableLayer:didSelectRowAtIndexPath:)] && index>=0 && index<_cellAry.count)
        {
            //设置是否点击
            for(CCTableLayerCell *cell in _cellAry)
            {
                cell.isSelected = NO;
            }
            CCTableLayerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            cell.isSelected = YES;
            [cell touchUp];
            [self.delegate landscapeTableLayer:self didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }
    
}
@end
