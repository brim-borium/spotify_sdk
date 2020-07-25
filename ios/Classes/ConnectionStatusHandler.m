#import "ConnectionStatusHandler.h"

@implementation ConnectionStatusHandler {
  FlutterEventSink _eventSink;
}

#pragma mark FlutterStreamHandler implementation

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  _eventSink = eventSink;
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  _eventSink = nil;
  return nil;
}


@end
