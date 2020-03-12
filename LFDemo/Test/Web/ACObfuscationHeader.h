
#ifndef ACObfuscation_h
#define ACObfuscation_h

//待混淆标识
#define __Obfuscation_Todo

//已混淆标识
#define __Obfuscation_Done

//使用说明
/*
 混淆前
 #import "ACObfuscationHeader.h"
 __Obfuscation_Todo const NSString *str = @"00000222";
 
 混淆后
 //[Orginial]---->00000222
 __Obfuscation_Done const NSString *str = @"[Obfu]->MDAwMDAyMjI=";
 
 运行时取值
 #import "NSString+ACObfuscation.h"
 NSString *idealString = [str ac_bian];
 
 */


#endif /* ACObfuscation_h */

