//
//  NodeFactory.m
//  BONK
//
//  Created by Antti Mattila on 23.2.2014.
//  Copyright (c) 2014 Alupark. All rights reserved.
//

#import "NodeFactory.h"
#import "Common.h"

@implementation NodeFactory
{
    CGSize _size;
}

- (instancetype)initWithSize:(CGSize)s
{
    if (self = [super init]) {
        _size = s;
    }
    return self;
}

- (SKSpriteNode *)getPlayer
{
    SKSpriteNode *player = [SKSpriteNode spriteNodeWithImageNamed:@"Paddle"];
    player.position = CGPointMake(_size.width / 2, 20);
    
    // physicsBody created with http://dazchong.com/spritekit/
    CGFloat offsetX = player.frame.size.width * player.anchorPoint.x;
    CGFloat offsetY = player.frame.size.height * player.anchorPoint.y;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0 - offsetX, 5 - offsetY);
    CGPathAddLineToPoint(path, NULL, 0 - offsetX, 9 - offsetY);
    CGPathAddLineToPoint(path, NULL, 4 - offsetX, 14 - offsetY);
    CGPathAddLineToPoint(path, NULL, 15 - offsetX, 18 - offsetY);
    CGPathAddLineToPoint(path, NULL, 27 - offsetX, 21 - offsetY);
    CGPathAddLineToPoint(path, NULL, 34 - offsetX, 22 - offsetY);
    CGPathAddLineToPoint(path, NULL, 46 - offsetX, 21 - offsetY);
    CGPathAddLineToPoint(path, NULL, 57 - offsetX, 19 - offsetY);
    CGPathAddLineToPoint(path, NULL, 66 - offsetX, 15 - offsetY);
    CGPathAddLineToPoint(path, NULL, 71 - offsetX, 12 - offsetY);
    CGPathAddLineToPoint(path, NULL, 74 - offsetX, 8 - offsetY);
    CGPathAddLineToPoint(path, NULL, 74 - offsetX, 4 - offsetY);
    CGPathCloseSubpath(path);
    player.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    
    player.physicsBody.categoryBitMask = PhysicsCategoryPlayer;
	player.physicsBody.contactTestBitMask = PhysicsCategoryBomb;
    player.physicsBody.dynamic = NO;
    
    return player;
}

- (SKSpriteNode *)getBackground
{
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
    background.position = CGPointMake(_size.width / 2, _size.height / 2);
    
    return background;
}

- (SKLabelNode *)getScoreLabel
{
    SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:UI_FONT];
    scoreLabel.text = @"Score: 0";
    scoreLabel.color = [SKColor whiteColor];
    scoreLabel.position = CGPointMake(UI_PADDING, _size.height - scoreLabel.frame.size.height - UI_PADDING);
    scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    
    return scoreLabel;
}

- (SKLabelNode *)getTimeLabel
{
    SKLabelNode *timeLabel = [SKLabelNode labelNodeWithFontNamed:UI_FONT];
    timeLabel.text = @"Time left: 00:45";
    timeLabel.color = [SKColor whiteColor];
    timeLabel.position = CGPointMake(_size.width - UI_PADDING, _size.height - timeLabel.frame.size.height - UI_PADDING);
    timeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    
    return timeLabel;
}

- (SKSpriteNode *)getTarget
{
    CGSize targetSize = CGSizeMake(1, _size.height);
    SKSpriteNode *target = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:targetSize];
    target.position = CGPointMake(_size.width - targetSize.width, _size.height / 2);
    target.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:targetSize];
    target.physicsBody.dynamic = NO;
    target.physicsBody.categoryBitMask = PhysicsCategoryGoal;
    
    return target;
}

- (SKSpriteNode *)getFloor
{
    CGSize floorSize = CGSizeMake(_size.width, 1);
    SKSpriteNode *floor = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:floorSize];
    floor.position = CGPointMake(_size.width / 2, 1);
    floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:floorSize];
    floor.physicsBody.dynamic = NO;
    floor.physicsBody.categoryBitMask = PhysicsCategoryFloor;
    
    return floor;
}

- (SKSpriteNode *)getReadyOverlay
{
    SKSpriteNode *getReadyOverlay = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:0 green:0 blue:0 alpha:0.6] size:_size];
    getReadyOverlay.position = CGPointMake(_size.width / 2, _size.height / 2);
    
    return getReadyOverlay;
}

- (SKLabelNode *)getReadyLabel
{
    SKLabelNode *getReadyLabel = [SKLabelNode labelNodeWithFontNamed:UI_FONT];
    getReadyLabel.text = @"tapwhenready";
    getReadyLabel.fontSize = 42;
    getReadyLabel.color = [SKColor whiteColor];
    getReadyLabel.position = CGPointMake(_size.width / 2, _size.height / 2);
    SKAction *scaleUp = [SKAction scaleBy:1.1 duration:1];
    SKAction *blink = [SKAction sequence:@[scaleUp, [scaleUp reversedAction]]];
    [getReadyLabel runAction:[SKAction repeatActionForever:blink]];
    
    return getReadyLabel;
}

- (SKSpriteNode *)getBomb
{
	SKSpriteNode *bomb = [SKSpriteNode spriteNodeWithImageNamed:@"Bomb"];
    CGPoint startPos = CGPointMake(-bomb.size.width / 2, bomb.size.height / 2);
    startPos = CGPointMake(0, _size.height - bomb.size.height / 2);
    bomb.position = startPos;
    bomb.name = @"bomb";
    bomb.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bomb.size.width / 2];
    bomb.physicsBody.restitution = 1.0;
    bomb.physicsBody.categoryBitMask = PhysicsCategoryBomb;
    bomb.physicsBody.collisionBitMask = PhysicsCategoryBomb | PhysicsCategoryPlayer | PhysicsCategoryEdge;
    bomb.physicsBody.contactTestBitMask = PhysicsCategoryGoal | PhysicsCategoryFloor;
	
	return bomb;
}

- (SKEmitterNode *)getExplosionOfColor:(UIColor *) color
{
    SKEmitterNode *explosion = [[SKEmitterNode alloc] init];
    [explosion setParticleTexture:[SKTexture textureWithImageNamed:@"spark.png"]];
    [explosion setParticleColor:color];
    [explosion setNumParticlesToEmit:100];
    [explosion setParticleBirthRate:450];
    [explosion setParticleLifetime:2];
    [explosion setEmissionAngleRange:360];
    [explosion setParticleSpeed:100];
    [explosion setParticleSpeedRange:50];
    [explosion setXAcceleration:0];
    [explosion setYAcceleration:0];
    [explosion setParticleAlpha:0.8];
    [explosion setParticleAlphaRange:0.2];
    [explosion setParticleAlphaSpeed:-0.5];
    [explosion setParticleScale:0.75];
    [explosion setParticleScaleRange:0.4];
    [explosion setParticleScaleSpeed:-0.5];
    [explosion setParticleRotation:0];
    [explosion setParticleRotationRange:0];
    [explosion setParticleRotationSpeed:0];
    
    [explosion setParticleColorBlendFactor:1];
    [explosion setParticleColorBlendFactorRange:0];
    [explosion setParticleColorBlendFactorSpeed:0];
    [explosion setParticleBlendMode:SKBlendModeAdd];
    
    return explosion;
}

@end
