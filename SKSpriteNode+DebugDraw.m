//
//  SKSpriteNode+DebugDraw.m
//  KittenPhysics
//
//  Created by Antti Mattila on 22.2.2014.
//  Copyright (c) 2014 Alupark. All rights reserved.
//

#import "SKSpriteNode+DebugDraw.h"

static BOOL kDebugDraw = YES;

@implementation SKSpriteNode (DebugDraw)

- (void)attachDebugRectWithSize:(CGSize)size
{
    CGPathRef bodyPath = CGPathCreateWithRect(CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), nil);
    [self attachDebugFrameFromPath:bodyPath];
    CGPathRelease(bodyPath);
}

- (void)attachDebugFrameFromPath:(CGPathRef)bodyPath
{
    if (!kDebugDraw) return;
    
    SKShapeNode *shape = [SKShapeNode node];
    shape.path = bodyPath;
    shape.strokeColor = [SKColor colorWithRed:1 green:0 blue:0 alpha:0.5];
    shape.lineWidth = 1.0;
    [self addChild:shape];
}

@end
