//
//  HelloWorldLayer.m
//  CCTableLayerTest
//
//  Created by Joe on 13-2-27.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		//_tableLayer = [[CCTableLayer alloc]init];
        _tableLayer = [[CCLandscapeTableLayer alloc] init];
        _tableLayer.delegate = self;
        _tableLayer.dataSource = self;
        _tableLayer.contentSize = CGSizeMake(self.contentSize.width, 200);
        
        [_tableLayer setPosition:ccp(0, 100)];
        
        [self addChild:_tableLayer];
        
        
        [_tableLayer scrollToIndex:10 animated:YES];
	}
	return self;
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}


- (CGFloat)landscapeTableLayer:(CCLandscapeTableLayer *)tableLayer widthForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (int)landscapeTableLayer:(CCLandscapeTableLayer *)tableLayer numberOfRowsInSection:(NSInteger)section
{
    return 15;
}

- (CCTableLayerCell *)landscapeTableLayer:(CCLandscapeTableLayer *)tableLayer cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCTableLayerCell *cell = [tableLayer dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[CCTableLayerCell alloc]initWithReuseIdentifier:@"cell"];
        
    }
    [cell removeAllChildrenWithCleanup:YES];
    CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",indexPath.row] fontName:@"GillSans" fontSize:20];
    label.anchorPoint = CGPointZero;
    label.color = ccWHITE;
    [cell addChild:label];
    
    CCMenuItemFont *item = [CCMenuItemFont itemFromString:@"Button" target:self selector:@selector(buttonAction:)];
    
    item.tag = indexPath.row;
    CCMenu *menu = [CCMenu menuWithItems:item, nil];
    [menu setPosition:CGPointZero];
    [cell addChild:menu];
    [item setPosition:ccp(0, 150)];
    
    return cell;
}


- (void)landscapeTableLayer:(CCLandscapeTableLayer *)tableLayer didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCLOG(@"Sel index %d", indexPath.row);
}

- (void)landscapeTableLayer:(CCLandscapeTableLayer *)tableLayer cellNeedDelete:(CCTableLayerCell *)cell
{
    
}

/*
- (CGFloat)tableLayer:(CCTableLayer *)tableLayer heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (int)tableLayer:(CCTableLayer *)tableLayer numberOfRowsInSection:(NSInteger)section
{
    return 15;
}

- (CCTableLayerCell *)tableLayer:(CCTableLayer *)tableLayer cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCTableLayerCell *cell = [tableLayer dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[CCTableLayerCell alloc]initWithReuseIdentifier:@"cell"];
        
    }
    [cell removeAllChildrenWithCleanup:YES];
    CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",indexPath.row] fontName:@"GillSans" fontSize:10];
    label.anchorPoint = CGPointZero;
    label.color = ccWHITE;
    [cell addChild:label];
    
    CCMenuItemFont *item = [CCMenuItemFont itemFromString:@"Button" target:self selector:@selector(buttonAction:)];
    
    item.tag = indexPath.row;
    CCMenu *menu = [CCMenu menuWithItems:item, nil];
    [menu setPosition:CGPointZero];
    [cell addChild:menu];
    [item setPosition:ccp(250, 10)];
    
    return cell;
}

- (void)tableLayer:(CCTableLayer *)tableLayer cellNeedDelete:(CCTableLayerCell *)cell
{
    
}
 */

- (void)buttonAction:(id)sender
{
    CCMenuItem *item = (CCMenuItem *)sender;
    CCLOG(@"Button action %d", item.tag);
}

@end
