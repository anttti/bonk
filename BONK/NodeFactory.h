//
//  NodeFactory.h
//  BONK
//
//  Created by Antti Mattila on 23.2.2014.
//  Copyright (c) 2014 Alupark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface NodeFactory : NSObject

- (instancetype)initWithSize:(CGSize)s;

- (SKSpriteNode *)getPlayer;
- (SKSpriteNode *)getBackground;
- (SKLabelNode *)getScoreLabel;
- (SKLabelNode *)getTimeLabel;
- (SKSpriteNode *)getTarget;
- (SKSpriteNode *)getFloor;
- (SKSpriteNode *)getReadyOverlay;
- (SKLabelNode *)getReadyLabel;
- (SKSpriteNode *)getBomb;
- (SKEmitterNode *)getExplosionOfColor:(UIColor *)color;

@end
