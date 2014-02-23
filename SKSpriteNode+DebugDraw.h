//
//  SKSpriteNode+DebugDraw.h
//  KittenPhysics
//
//  Created by Antti Mattila on 22.2.2014.
//  Copyright (c) 2014 Alupark. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKSpriteNode (DebugDraw)

- (void)attachDebugRectWithSize:(CGSize)size;
- (void)attachDebugFrameFromPath:(CGPathRef)bodyPath;

@end
