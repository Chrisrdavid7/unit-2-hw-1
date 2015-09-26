//
//  APIManager.h
//  LearnAPI
//
//  Created by Chris David on 9/20/15.
//  Copyright © 2015 Chris David. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIManager : NSObject

+ (void)GETRequestWithURL:(NSURL *)URL
        completionHandler:(void(^)(NSData *, NSURLResponse *, NSError *))
completionHandler; 

@end
