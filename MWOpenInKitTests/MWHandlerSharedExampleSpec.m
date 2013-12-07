//
//  MWHandlerSharedExampleSpec.m
//  MWOpenInKitTests
//
//  Created by Michael Walker on 11/26/13.
//  Copyright (c) 2013 Mike Walker. All rights reserved.
//

#define EXP_SHORTHAND
#define HC_SHORTHAND
#define MOCKITO_SHORTHAND

#import "Specta.h"
#import "Expecta.h"
#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>
#import "MWHandler.h"

@interface MWHandler (Spec)
@property UIApplication *application;
@end

@interface UIActivityViewController (Spec)
@property NSArray *activityItems;
@property NSArray *applicationActivities;
@end

SharedExamplesBegin(MWHandler)

sharedExamplesFor(@"a handler action", ^(NSDictionary *data) {
    __block MWHandler *handler;
    __block NSString *urlString;
    __block NSUInteger maxApps;
    __block UIActivityViewController *(^subjectAction)(void);

    beforeEach(^{
        handler.application = mock([UIApplication class]);

        handler = data[@"handler"];
        urlString = data[@"urlString"];
        maxApps = [data[@"maxApps"] intValue];
        subjectAction = data[@"subjectAction"];
    });

    context(@"when only one application is available", ^{
        it(@"should open in that application", ^{
            [given([handler.application canOpenURL:[NSURL URLWithString:urlString]]) willReturnBool:YES];

            subjectAction();

            [(UIApplication *)verify(handler.application) openURL:[NSURL URLWithString:urlString]];
        });
    });

    context(@"when multiple apps are installed", ^{
        beforeEach(^{
            [given([handler.application canOpenURL:anything()]) willReturnBool:YES];
        });

        context(@"when a default has not been set", ^{
            it(@"should prompt the user to pick", ^{
                UIActivityViewController *result = subjectAction();
                expect(result).will.beKindOf([UIActivityViewController class]);
            });

            it(@"should contain the correct activities", ^{
                UIActivityViewController *result = subjectAction();
                NSArray *items = [result applicationActivities];
                expect(items.count).to.equal(maxApps);
            });
        });
    });
});

sharedExamplesFor(@"an optional handler property", ^(NSDictionary *data) {
    __block MWHandler *handler;
    __block NSString *urlStringWithoutParam;
    __block NSString *urlStringWithParam;
    __block UIActivityViewController *(^subjectAction)(void);

    beforeEach(^{
        handler.application = mock([UIApplication class]);

        handler = data[@"handler"];
        urlStringWithoutParam = data[@"urlStringWithoutParam"];
        urlStringWithParam = data[@"urlStringWithParam"];
        subjectAction = data[@"subjectAction"];
    });

    it(@"should include the given param", ^{
        [given([handler.application canOpenURL:[NSURL URLWithString:urlStringWithoutParam]]) willReturnBool:YES];

        subjectAction();

        [(UIApplication *)verify(handler.application) openURL:[NSURL URLWithString:urlStringWithParam]];
    });
});

SharedExamplesEnd