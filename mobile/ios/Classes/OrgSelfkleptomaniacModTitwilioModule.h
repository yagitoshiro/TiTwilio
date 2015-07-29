/**
 * TiTwilio
 *
 * Created by Your Name
 * Copyright (c) 2015 Your Company. All rights reserved.
 */

#import "TiModule.h"
#import "TwilioClient.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface OrgSelfkleptomaniacModTitwilioModule : TiModule
{
    @private
        TCDevice* _device;
        TCConnection* _connection;
        TCConnection* _pendingIncomingConnection;
        BOOL _speakerEnabled;
}
@property (nonatomic,retain) TCDevice* device;
@property (nonatomic,retain) TCConnection* connection;
@property (nonatomic,retain) TCConnection* pendingIncomingConnection;

@end
