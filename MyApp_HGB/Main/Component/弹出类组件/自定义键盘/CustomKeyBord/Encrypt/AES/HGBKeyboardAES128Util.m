//
//  HGBKeyboardAES128Util.m
//  CustomKeyboard
//
//  Created by huangguangbao on 2018/5/18.
//  Copyright © 2018年 com.agree. All rights reserved.
//

#import "HGBKeyboardAES128Util.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

static NSString *const kInitVector = @"0000000000000000";
static size_t const kKeySize = kCCKeySizeAES128;


@implementation HGBKeyboardAES128Util
#pragma mark 加密
/**
 加密方法

 @param string 原始字符串
 @param key key
 @return 加密字符串
 */
+ (NSString*)AES128EncryptString:(NSString*)string andWithKey:(NSString *)key{
    NSData *contentData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = contentData.length;
    // 为结束符'\\0' +1
    char keyPtr[kKeySize + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    // 密文长度 <= 明文长度 + BlockSize
    size_t encryptSize = dataLength + kCCBlockSizeAES128;
    void *encryptedBytes = malloc(encryptSize);
    size_t actualOutSize = 0;
    NSData *initVector = [kInitVector dataUsingEncoding:NSUTF8StringEncoding];
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,  // 系统默认使用 CBC，然后指明使用 PKCS7Padding
                                          keyPtr,
                                          kKeySize,
                                          initVector.bytes,
                                          contentData.bytes,
                                          dataLength,
                                          encryptedBytes,
                                          encryptSize,
                                          &actualOutSize);
    if (cryptStatus == kCCSuccess) {
        // 对加密后的数据进行 base64 编码
        return [[NSData dataWithBytesNoCopy:encryptedBytes length:actualOutSize] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    free(encryptedBytes);
    return nil;
}


/**
 解密方法

 @param string  加密字符串
 @param key key
 @return 解密字符串
 */
+ (NSString*)AES128DecryptString:(NSString*)string andWithKey:(NSString *)key{
    // 把 base64 String 转换成 Data
    NSData *contentData = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSUInteger dataLength = contentData.length;
    char keyPtr[kKeySize + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    size_t decryptSize = dataLength + kCCBlockSizeAES128;
    void *decryptedBytes = malloc(decryptSize);
    size_t actualOutSize = 0;
    NSData *initVector = [kInitVector dataUsingEncoding:NSUTF8StringEncoding];
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kKeySize,
                                          initVector.bytes,
                                          contentData.bytes,
                                          dataLength,
                                          decryptedBytes,
                                          decryptSize,
                                          &actualOutSize);
    if (cryptStatus == kCCSuccess) {
        return [[NSString alloc] initWithData:[NSData dataWithBytesNoCopy:decryptedBytes length:actualOutSize] encoding:NSUTF8StringEncoding];
    }
    free(decryptedBytes);
    return nil;
}
@end
