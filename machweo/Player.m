//
//  Player.m
//  tgrrn
//
//  Created by Feldcamp, Zachary Satoshi on 10/23/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "Player.h"
@implementation Player

//-(void)initAtPoint:(CGPoint)point{
//    self.physicsBody = [SKPhysicsBody body]
//    self.position = point;
//    self.minYPosition = -9999;
//}

+(instancetype)playerAtPoint:(CGPoint)point{
    Constants* constants = [Constants sharedInstance];
    Player *player = [Player spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(constants.PLAYER_SIZE * constants.SCALE_COEFFICIENT.dy, constants.PLAYER_SIZE * constants.SCALE_COEFFICIENT.dy * 2)];
    player.zPosition = constants.PLAYER_Z_POSITION;
    player.velocity = CGVectorMake(constants.MAX_PLAYER_VELOCITY_DX / 4, 0);
    player.position = point;
    
    player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(player.size.width * 1/4, player.size.height * 1/4 * 2)];
    player.physicsBody.categoryBitMask = [Constants sharedInstance].PLAYER_HIT_CATEGORY;
    player.physicsBody.contactTestBitMask = [Constants sharedInstance].OBSTACLE_HIT_CATEGORY;
    //player.physicsBody.collisionBitMask = 3;

   // NSLog(@"player.physicsBody.categoryBitMask: %d", player.physicsBody.categoryBitMask);
    //NSLog(@"player.physicsBody.contactTestBitMask: %d", player.physicsBody.contactTestBitMask);

    
    //player.physicsBody.dynamic = false;
    player.physicsBody.affectedByGravity = false;
    player.physicsBody.allowsRotation = false;

    
    return player;
}

-(void)updateEdges{
    _yCoordinateOfBottomSide = self.position.y - (self.size.height / 2);
    _yCoordinateOfTopSide = self.position.y + (self.size.height / 2);
    _xCoordinateOfLeftSide = self.position.x - (self.size.width / 2);
    _xCoordinateOfRightSide = self.position.x + (self.size.width / 2);
}

-(void)resetMinsAndMaxs{
    self.minYPosition = -9999;
}

@end
