//
//  GameScene.m
//  BONK
//
//  Created by Antti Mattila on 23.2.2014.
//  Copyright (c) 2014 Alupark. All rights reserved.
//

#import "GameScene.h"
#import "GameOverScene.h"
#import "NodeFactory.h"
#import "Common.h"
#import "SKSpriteNode+DebugDraw.h"
@import CoreMotion;
@import GLKit;

#define MAX_PLAYER_SPEED 600
#define GAME_TIME 45

@interface GameScene()<SKPhysicsContactDelegate>
@end

@implementation GameScene
{
    SKSpriteNode *_player;
    SKSpriteNode *_target;
    SKSpriteNode *_floor;
    SKSpriteNode *_background;
    SKLabelNode *_scoreLabel;
    SKLabelNode *_timeLabel;
    SKLabelNode *_getReadyLabel;
    SKSpriteNode *_getReadyOverlay;
    NSTimer *_timer;
    int _score;
    int _time;
    CMMotionManager *_motionManager;
    NSTimeInterval _dt;
    NSTimeInterval _lastUpdateTime;
    BOOL _gameStarted;
}

- (instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        [self setupUI];
        
        _motionManager = [CMMotionManager new];
        _motionManager.accelerometerUpdateInterval = 0.05;
        [_motionManager startAccelerometerUpdates];
    }
    return self;
}

- (void)dealloc
{
    [_motionManager stopAccelerometerUpdates];
    _motionManager = nil;
}

- (void)setupUI
{
    NodeFactory *factory = [[NodeFactory alloc] initWithSize:self.size];
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = PhysicsCategoryEdge;
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0, -5);
    
    [self addChild:_background = [factory getBackground]];
    [self addChild:_scoreLabel = [factory getScoreLabel]];
    [self addChild:_timeLabel = [factory getTimeLabel]];
    [self addChild:_player = [factory getPlayer]];
    [self addChild:_target = [factory getTarget]];
    [self addChild:_floor = [factory getFloor]];
    [self addChild:_getReadyLabel = [factory getReadyLabel]];
    [self addChild:_getReadyOverlay = [factory getReadyOverlay]];
}

#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_gameStarted) {
        [self startGame];
    } else {
        [self addBomb];
    }
}

#pragma mark - Accelerator moving

- (void)movePlayer
{
    GLKVector3 raw = GLKVector3Make(_motionManager.accelerometerData.acceleration.x,
                                    _motionManager.accelerometerData.acceleration.y,
                                    _motionManager.accelerometerData.acceleration.z);
    if (GLKVector3AllEqualToScalar(raw, 0)) return;
    
    static GLKVector3 ax, ay, az;
    ay = GLKVector3Make(0.63f, 0.0f, -0.92f);
    az = GLKVector3Make(0.0f, 1.0f, 0.0f);
    ax = GLKVector3Normalize(GLKVector3CrossProduct(az, ay));
    
    // Project accelerometer data to 2D
    CGPoint accel2D = CGPointZero;
    accel2D.x = GLKVector3DotProduct(raw, az);
    accel2D.y = GLKVector3DotProduct(raw, ax);
    accel2D = CGPointNormalize(accel2D);
    
    // Add deadzone
    static const float steerDeadZone = 0.15;
    if (fabsf(accel2D.x) < steerDeadZone) accel2D.x = 0;
    if (fabsf(accel2D.y) < steerDeadZone) accel2D.y = 0;
    
    CGPoint velocity = CGPointMake(accel2D.x * MAX_PLAYER_SPEED, 0);
    CGPoint bgVelocity = CGPointMake(accel2D.x * (MAX_PLAYER_SPEED / 4), 0);
    
    [self moveSprite:_player velocity:velocity];
    
    if (![self boundsCheckPlayer]) {
        [self moveSprite:_background velocity:bgVelocity];
    }
}

- (void)moveSprite:(SKSpriteNode *)sprite velocity:(CGPoint)velocity
{
    CGPoint amountToMove = CGPointMultiplyScalar(velocity, _dt);
    sprite.position = CGPointAdd(sprite.position, amountToMove);
}

- (BOOL)boundsCheckPlayer
{
    BOOL stopped = NO;
    
    CGPoint newPos = _player.position;
    CGFloat width = _player.size.width / 2;
    
    if (newPos.x - width <= 0) {
        newPos.x = width;
        stopped = YES;
    }
    if (newPos.x + width >= self.size.width) {
        newPos.x = self.size.width - width;
        stopped = YES;
    }
    
    _player.position = newPos;
    return stopped;
}

#pragma mark - Update

- (void)update:(CFTimeInterval)currentTime {
    if (!_gameStarted) return;
    
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    
    [self movePlayer];
}

#pragma mark - Physics Delegate

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if (!_gameStarted) return;
    
    uint32_t collision = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask);
    
    SKSpriteNode *a = (SKSpriteNode *)contact.bodyA.node;
    SKSpriteNode *b = (SKSpriteNode *)contact.bodyB.node;
    SKSpriteNode *bomb = [a.name isEqualToString:@"bomb"] ? a : b;
    
    if (collision == (PhysicsCategoryBomb | PhysicsCategoryGoal)) {
        [self addPoint:bomb];
    }
    if (collision == (PhysicsCategoryBomb | PhysicsCategoryFloor)) {
        [self lose:bomb];
    }
}

#pragma mark - Game methods

- (void)startGame
{
    SKAction *fadeOut = [SKAction sequence:@[[SKAction fadeOutWithDuration:0.5],
                                             [SKAction removeFromParent]]];
    [_getReadyLabel runAction:fadeOut];
    [_getReadyOverlay runAction:fadeOut];
    
    _gameStarted = YES;
    _time = GAME_TIME;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(updateTime)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)updateTime
{
    _time--;
    if (_time >= 0) {
        _timeLabel.text = [NSString stringWithFormat:@"Time left: 00:%02d", _time];
    } else {
        [self gameOver];
    }
}

- (void)updateScore
{
    _scoreLabel.text = [NSString stringWithFormat:@"Score: %i", _score];
}

- (void)gameOver
{
    [_timer invalidate];
    _gameStarted = NO;
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:2],
                                         [SKAction performSelector:@selector(presentGameOverScene) onTarget:self]]]];
}

- (void)presentGameOverScene
{
    SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size score:_score];
    SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.5];
    [self.view presentScene:gameOverScene transition:reveal];
}

- (void)addPoint:(SKSpriteNode *)bomb
{
    SKEmitterNode *explosion = [self newExplosion:[UIColor greenColor]];
    explosion.position = bomb.position;
    _score++;
    
    [bomb runAction:[SKAction sequence:@[[SKAction removeFromParent]]]];
    [self updateScore];
}

- (void)lose:(SKSpriteNode *)bomb
{
    SKEmitterNode *explosion = [self newExplosion:[UIColor brownColor]];
    explosion.position = bomb.position;

    _score -= 2;
    if (_score < 0) _score = 0;
    
    [bomb runAction:[SKAction sequence:@[[SKAction removeFromParent]]]];
    [self updateScore];
}

- (void)addBomb
{
    SKSpriteNode *bomb = [SKSpriteNode spriteNodeWithImageNamed:@"Bomb"];
    CGPoint startPos = CGPointMake(-bomb.size.width / 2, bomb.size.height / 2);
    startPos = CGPointMake(0, self.size.height - bomb.size.height / 2);
    bomb.position = startPos;
    bomb.name = @"bomb";
    bomb.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bomb.size.width / 2];
    bomb.physicsBody.restitution = 1.0;
    bomb.physicsBody.categoryBitMask = PhysicsCategoryBomb;
    bomb.physicsBody.collisionBitMask = PhysicsCategoryBomb | PhysicsCategoryPlayer | PhysicsCategoryEdge;
    bomb.physicsBody.contactTestBitMask = PhysicsCategoryGoal | PhysicsCategoryFloor;
    [self addChild:bomb];
    CGVector throwImpulse = CGVectorMake(ScalarRandomRange(5, 15), 0);
    [bomb.physicsBody applyImpulse:throwImpulse];
}

- (SKEmitterNode *)newExplosion:(UIColor *) color
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
    
    [self addChild:explosion];
    
    return explosion;
}

@end
