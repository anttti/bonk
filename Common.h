//
//  Typedefs.h
//  BONK
//
//  Created by Antti Mattila on 23.2.2014.
//  Copyright (c) 2014 Alupark. All rights reserved.
//

#ifndef BONK_Typedefs_h
#define BONK_Typedefs_h

typedef NS_OPTIONS(uint32_t, PhysicsCategory)
{
    PhysicsCategoryPlayer = 1 << 0,
    PhysicsCategoryBomb   = 1 << 1,
    PhysicsCategoryGoal   = 1 << 2,
    PhysicsCategoryEdge   = 1 << 3,
    PhysicsCategoryLabel  = 1 << 4,
    PhysicsCategoryFloor  = 1 << 5
};

#define ARC4RANDOM_MAX 0x100000000
#define UI_FONT @"ArialRoundedMTBold"
#define UI_PADDING 5

static inline CGFloat ScalarRandomRange(CGFloat min, CGFloat max)
{
    return floorf(((double)arc4random() / ARC4RANDOM_MAX) * (max - min) + min);
}

static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointSubtract(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

static inline CGFloat CGPointLength(const CGPoint a)
{
    return sqrtf(a.x * a.x + a.y * a.y);
}

static inline CGPoint CGPointNormalize(const CGPoint a)
{
    CGFloat length = CGPointLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

static inline CGFloat CGPointToAngle(const CGPoint a)
{
    return atan2f(a.y, a.x);
}

#endif
