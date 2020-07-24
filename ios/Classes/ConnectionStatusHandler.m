//
//  ConnectionStatusHandler.m
//  Pods
//
//  Created by Foti Dim on 24.07.20.
//

#import "ConnectionStatusHandler.h"

@implementation ConnectionStatusHandler {
  FlutterEventSink _eventSink;
}

#pragma mark FlutterStreamHandler impl

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  _eventSink = eventSink;
  // [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
  // [[NSNotificationCenter defaultCenter] addObserver:self
  //                                          selector:@selector(onBatteryStateDidChange:)
  //                                              name:UIDeviceBatteryStateDidChangeNotification
  //                                            object:nil];

//    events(true) // any generic type or more compex dictionary of [String:Any]
//    events(FlutterError(code: "ERROR_CODE",
//                         message: "Detailed message",
//                         details: nil)) // in case of errors
//    events(FlutterEndOfEventStream) // when stream is over
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  _eventSink = nil;
  return nil;
}


@end
