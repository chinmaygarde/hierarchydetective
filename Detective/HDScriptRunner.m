#import "HDScriptRunner.h"
#import "wax.h"
#import "wax_stdlib.h"
#import "lauxlib.h"

@implementation HDScriptRunner

+(HDScriptRunner *) sharedScriptRunner {
  static HDScriptRunner *runner = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    runner = [[HDScriptRunner alloc] init];
  });
  return runner;
}

-(void) runScript:(NSString *) script {
  [self runScript:script withCompletionHandler:nil];
}

-(void) runScript:(NSString *) script withCompletionHandler:(HDScriptExecutionCompletionHandler) handler {
  NSError *error = nil;
  
  // Setup global state
  wax_setup();
	
	lua_State *L = wax_currentLuaState();
	 
	// Load stdlib
  char stdlib[] = WAX_STDLIB;
  size_t stdlibSize = sizeof(stdlib);
  
	if (luaL_loadbuffer(L, stdlib, stdlibSize, "loading wax stdlib") || lua_pcall(L, 0, LUA_MULTRET, 0)) {
    error = [NSError errorWithDomain:[NSString stringWithFormat:@"Error executing lua script: %s", lua_tostring(L,-1)] code:0 userInfo:nil];
	}

  // Load script
  if (luaL_dostring(L, script.UTF8String) != 0) {
    error = [NSError errorWithDomain:[NSString stringWithFormat:@"Error executing lua script: %s", lua_tostring(L,-1)] code:0 userInfo:nil];
  }

  // Teardown
  wax_end();
  
  if(handler) {
    handler(error);
  }
}

@end
