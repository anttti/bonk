//
//  GameOverScene.m
//  BONK
//
//  Created by Antti Mattila on 23.2.2014.
//  Copyright (c) 2014 Alupark. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"
@import AVFoundation;

@implementation GameOverScene
{
	AVAudioPlayer *_backgroundMusicPlayer;
}

- (instancetype)initWithSize:(CGSize)size score:(int)score
{
    if (self = [super initWithSize:size]) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"GameOver"];
        bg.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        [self addChild:bg];
        
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"ArialRoundedMTBold"];
        label.fontSize = 64;
        label.color = [SKColor whiteColor];
        label.text = [NSString stringWithFormat:@"score: %d", score];
        label.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        SKAction *scaleUp = [SKAction scaleBy:1.1 duration:1];
        SKAction *blink = [SKAction sequence:@[scaleUp, [scaleUp reversedAction]]];
        [label runAction:[SKAction repeatActionForever:blink]];
        [self addChild:label];
		
		[self playBackgroundMusic];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    SKScene *gameScene = [[GameScene alloc] initWithSize:self.size];
    SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionRight duration:0.5];
    [self.view presentScene:gameScene transition:reveal];
}

- (void)playBackgroundMusic
{
	NSError *error;
	NSURL *musicUrl = [[NSBundle mainBundle] URLForResource:@"Intro-Song.mp3" withExtension:nil];
	_backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicUrl error:&error];
	_backgroundMusicPlayer.numberOfLoops = -1;
	[_backgroundMusicPlayer prepareToPlay];
	[_backgroundMusicPlayer play];
}

@end
