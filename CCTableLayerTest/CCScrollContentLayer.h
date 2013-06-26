//
//  PAScrollContentLayer.h
//  EOW
//
//  Created by apple on 12-7-17.
//  Copyright (c) 2012年 Jason Zhang. All rights reserved.
//

#import "CCLayer.h"
@protocol CCScrollContentLayerDelegate <NSObject>
- (void)contentLayerDidMove;
@end

@interface CCScrollContentLayer : CCLayerColor
{
    id <CCScrollContentLayerDelegate> _delegate;
}
@property (nonatomic,assign) id <CCScrollContentLayerDelegate> delegate;
@end
