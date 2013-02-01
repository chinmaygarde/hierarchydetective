@protocol HDProperties <NSObject>

@required
-(NSArray *) serializableProperties;

@optional
-(void) setNonKVCCompliantValue:(id) value forKey:(NSString *) string;

@end
