//
//  main.m
//  Episodes
//
//  Created by Ryan Keefe on 4/27/16.
//  Copyright © 2016 Ryan Keefe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, const char * argv[]) {
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    return NSApplicationMain(argc, argv);
}
