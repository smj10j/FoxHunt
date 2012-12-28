//
//  ConfigManager.h
//  Outlaw
//
//  Created by Stephen Johnson on 12/23/12.
//  Copyright (c) 2012 Conquer LLC. All rights reserved.
//


#ifndef Outlaw_ConfigManager_h
#define Outlaw_ConfigManager_h

@interface ConfigManager : NSObject

+(void)init;

+(bool)boolForKey:(NSString*)key;
+(NSString*)stringForKey:(NSString*)key;
+(int)intForKey:(NSString*)key;
+(double)doubleForKey:(NSString*)key;


@end



#define CONFIG_SIMULATION_STEP_SIZE @"SIMULATION_STEP_SIZE"
#define CONFIG_SIMULATION_MAX_STEPS @"SIMULATION_MAX_STEPS"

#define CONFIG_PLAYER_DASH_IMPULSE @"PLAYER_DASH_IMPULSE"

#define CONFIG_PARALLAX_SPEED @"PARALLAX_SPEED"
#define CONFIG_PARALLAX_SPEED_ADJUSTMENT_FACTOR @"PARALLAX_SPEED_ADJUSTMENT_FACTOR"
#endif