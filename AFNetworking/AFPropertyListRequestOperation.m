// AFPropertyListRequestOperation.m
//
// Copyright (c) 2011 Gowalla (http://gowalla.com/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFPropertyListRequestOperation.h"

@interface AFPropertyListRequestOperation ()
@property (readwrite, nonatomic, retain) id responsePropertyList;
@property (readwrite, nonatomic, assign) NSPropertyListFormat propertyListFormat;
@property (readwrite, nonatomic, retain) NSError *propertyListError;
@end

@implementation AFPropertyListRequestOperation
@synthesize responsePropertyList = _responsePropertyList;
@synthesize propertyListReadOptions = _propertyListReadOptions;
@synthesize propertyListFormat = _propertyListFormat;
@synthesize propertyListError = _propertyListError;

+ (AFPropertyListRequestOperation *)propertyListRequestOperationWithRequest:(NSURLRequest *)request
                                                                    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id propertyList))success
                                                                    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id propertyList))failure
{
    AFPropertyListRequestOperation *requestOperation = [[[self alloc] initWithRequest:request] autorelease];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation.request, operation.response, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation.request, operation.response, error, [(AFPropertyListRequestOperation *)operation responsePropertyList]);
        }
    }];
    
    return requestOperation;
}

- (id)initWithRequest:(NSURLRequest *)urlRequest {
    self = [super initWithRequest:urlRequest];
    if (!self) {
        return nil;
    }
        
    self.propertyListReadOptions = NSPropertyListImmutable;
    
    return self;
}

- (void)dealloc {
    [_responsePropertyList release];
    [_propertyListError release];
    [super dealloc];
}

- (id)responsePropertyList {
    if (!_responsePropertyList && [self.responseData length] > 0 && [self isFinished]) {
        NSPropertyListFormat format;
        NSError *error = nil;
        self.responsePropertyList = [NSPropertyListSerialization propertyListWithData:self.responseData options:self.propertyListReadOptions format:&format error:&error];
        self.propertyListFormat = format;
        self.propertyListError = error;
    }
    
    return _responsePropertyList;
}

- (NSError *)error {
    if (_propertyListError) {
        return _propertyListError;
    } else {
        return [super error];
    }
}

#pragma mark - AFHTTPRequestOperation

+ (NSSet *)acceptableContentTypes {
    return [NSSet setWithObjects:@"application/x-plist", nil];
}

+ (BOOL)canProcessRequest:(NSURLRequest *)request {
    return [[[request URL] pathExtension] isEqualToString:@"plist"] || [super canProcessRequest:request];
}

- (id)responseObject {
    return self.responsePropertyList;
}

@end
