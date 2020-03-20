//
//  CGHContactsUtil.m
//  LFDemo
//
//  Created by wulinfeng on 2020/3/19.
//  Copyright © 2020 lio. All rights reserved.
//

#import "CGHContactsUtil.h"
#import <YYKit.h>
#import <ContactsUI/ContactsUI.h>
@interface CGHChooseContactAdapter : NSObject<CNContactPickerDelegate, CNContactViewControllerDelegate>
@property (nonatomic, copy) void(^cancelHandler)(void);
@property (nonatomic, copy) void(^didComplete)(NSDictionary *contact);
@end

@implementation CGHChooseContactAdapter
- (void)chooseContact:(UIViewController *)presentingVC {
    CNContactPickerViewController *picker =[[CNContactPickerViewController alloc] init];
    picker.delegate = self;
    [presentingVC presentViewController:picker animated:YES completion:nil];
}

#pragma mark - CNContactPickerDelegate
- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    @weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        !self.cancelHandler ?: self.cancelHandler();
    }];
}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(nonnull CNContactProperty *)contactProperty {
    CNContact *contact = contactProperty.contact;
    NSString *lastname = contact.familyName;
    NSString *firstname = contact.givenName;
    NSString *organizationName = contact.organizationName;
    NSString *name = [NSString stringWithFormat:@"%@%@", lastname, firstname];
    if (name.length == 0) name = [NSString stringWithFormat:@"%@", organizationName];
    NSArray<CNLabeledValue<CNPhoneNumber*>*> *phoneNumbers = contactProperty.contact.phoneNumbers; //crash when no granted
    NSString *num = @"";
    if ([phoneNumbers containsObject:contactProperty.value]) {
        num = ((CNPhoneNumber*)contactProperty.value).stringValue;
    } else {
        num = phoneNumbers.firstObject.value.stringValue ?: @"";
    }
    NSCharacterSet *setToRemove = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    NSString *phoneStr = [[num componentsSeparatedByCharactersInSet:setToRemove] componentsJoinedByString:@""];
    NSDictionary *dict = @{@"phoneNumber":phoneStr,@"displayName":name};
    
    @weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        !self.didComplete ?: self.didComplete(dict);
    }];
}

#pragma mark - CNContactViewControllerDelegate
- (BOOL)contactViewController:(CNContactViewController *)viewController shouldPerformDefaultActionForContactProperty:(CNContactProperty *)property {
    return YES;
}

- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact {
    @weakify(self);
    [viewController dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        !self.didComplete ?: self.didComplete(nil);
    }];
}
@end



@interface CGHAddContactAdapter : CGHChooseContactAdapter
@end

@implementation CGHAddContactAdapter
- (void)addNewContact:(NSDictionary *)dict presentingVC:(UIViewController *)presentingVC {
    CNMutableContact *contact = [self contactWithDict:dict];
    CNContactViewController *vc = [CNContactViewController viewControllerForNewContact:contact];
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [presentingVC presentViewController:nav animated:YES completion:nil];
}

- (void)editContact:(UIViewController *)presentingVC {
    [self chooseContact:presentingVC];
}

#pragma mark - private
/**
 *  设置联系人的基本属性
 firstName    string        是    名字
 photoFilePath    string        否    头像本地文件路径
 nickName    string        否    昵称
 lastName    string        否    姓氏
 middleName    string        否    中间名
 remark    string        否    备注
 mobilePhoneNumber    string        否    手机号
 weChatNumber    string        否    微信号
 addressCountry    string        否    联系地址国家
 addressState    string        否    联系地址省份
 addressCity    string        否    联系地址城市
 addressStreet    string        否    联系地址街道
 addressPostalCode    string        否    联系地址邮政编码
 organization    string        否    公司
 title    string        否    职位
 workFaxNumber    string        否    工作传真
 workPhoneNumber    string        否    工作电话
 hostNumber    string        否    公司电话
 email    string        否    电子邮件
 url    string        否    网站
 workAddressCountry    string        否    工作地址国家
 workAddressState    string        否    工作地址省份
 workAddressCity    string        否    工作地址城市
 workAddressStreet    string        否    工作地址街道
 workAddressPostalCode    string        否    工作地址邮政编码
 homeFaxNumber    string        否    住宅传真
 homePhoneNumber    string        否    住宅电话
 homeAddressCountry    string        否    住宅地址国家
 homeAddressState    string        否    住宅地址省份
 homeAddressCity    string        否    住宅地址城市
 homeAddressStreet    string        否    住宅地址街道
 homeAddressPostalCode    string        否    住宅地址邮政编码
 */

- (CNMutableContact *)contactWithDict:(NSDictionary *)info {
    CNMutableContact *contact = [[CNMutableContact alloc] init];
    [self phoneNumber:contact info:info];
    [self address:contact info:info];
    
    NSArray *matchedProperties = @[@"familyName", @"middleName", @"givenName", @"nickname"];
    for (NSString *property in matchedProperties) {
        NSString *propertyValue = info[property];
        if (![self _checkIsString:propertyValue]) continue;
        [contact setValue:propertyValue forKey:property];
    }
    
    NSDictionary *unmatchedProperties =
  @{@"organizationName":@"organization",
    @"jobTitle":@"title",
    @"note":@"remark"};
    for (NSString *property in unmatchedProperties.allKeys) {
        NSString *value = unmatchedProperties[property];
        NSString *propertyValue = info[value];
        if (![self _checkIsString:propertyValue]) continue;
        [contact setValue:propertyValue forKey:property];
    }
    
    NSData *data = [NSData dataWithContentsOfFile:@"photoFilePath"];
    contact.imageData = data;
    
    NSString *email = [self _checkIsString:info[@"email"]];
    if (email) {
        CNLabeledValue *value = [CNLabeledValue labeledValueWithLabel:CNLabelWork value:email];
        contact.emailAddresses = @[value];
    }
    
    NSString *url = [self _checkIsString:info[@"url"]];
    if (url) {
        CNLabeledValue *value = [CNLabeledValue labeledValueWithLabel:CNLabelURLAddressHomePage value:url];
        contact.urlAddresses = @[value];
    }
    
    return contact;
}

- (void)phoneNumber:(CNMutableContact *)contact info:(NSDictionary *)info {
    NSArray *phoneArr =
  @[@{CNLabelPhoneNumberiPhone: @"homePhoneNumber"},
    @{CNLabelPhoneNumberMobile: @"mobilePhoneNumber"},
    @{CNLabelWork: @"workPhoneNumber"},
    @{CNLabelPhoneNumberHomeFax: @"homeFaxNumber"},
    @{CNLabelPhoneNumberWorkFax: @"workFaxNumber"},
//    @{CNLabelPhoneNumberOtherFax: @""},
//    @{CNLabelPhoneNumberPager: @""}
  ];
    NSMutableArray *mPhoneArr = @[].mutableCopy;
    for (NSDictionary *dict in phoneArr) {
        NSString *label = dict.allKeys.firstObject;
        NSString *value = info[dict[label]];
        if (![self _checkIsString:value]) continue;
        value = [NSString stringWithFormat:@"%@", value];
        CNPhoneNumber *mobileNumber = [[CNPhoneNumber alloc] initWithStringValue:value];
        CNLabeledValue *mobilePhone = [[CNLabeledValue alloc] initWithLabel:label value:mobileNumber];
        [mPhoneArr addObject:mobilePhone];
    }
    if (mPhoneArr.count > 0) contact.phoneNumbers = mPhoneArr;
}

- (void)address:(CNMutableContact *)contact info:(NSDictionary *)info {
    NSArray *addressProperties = @[@"street", @"city", @"state", @"postalCode", @"country"];
    NSArray *scenes =
  @[@{CNLabelHome:@[@"homeAddressStreet", @"homeAddressCity", @"homeAddressState", @"homeAddressPostalCode", @"homeAddressCountry"]},
  @{CNLabelWork:@[@"workAddressStreet", @"workAddressCity", @"workAddressState", @"workAddressPostalCode", @"workAddressCountry"]},
  @{CNLabelOther:@[@"addressStreet", @"addressCity", @"addressState", @"addressPostalCode", @"addressCountry"]}];
    
    NSMutableArray *mArr = @[].mutableCopy;
    NSUInteger pCount = addressProperties.count;
    for (NSDictionary *scene in scenes) {
        NSString *sceneKey = scene.allKeys.firstObject;
        NSArray *sceneAddressProperties = scene[sceneKey];
        BOOL add = NO;
        CNMutablePostalAddress *address = CNMutablePostalAddress.new;
        for (NSUInteger i = 0; i < pCount; i++) {
            NSString *senceProperty = sceneAddressProperties[i];
            NSString *sencePropertyValue = info[senceProperty];
            if (![self _checkIsString:sencePropertyValue]) continue;
            add = YES;
            NSString *addressProperty = addressProperties[i];
            [address setValue:sencePropertyValue forKey:addressProperty];
        }
        if (add) {
            CNLabeledValue *label = [[CNLabeledValue alloc] initWithLabel:sceneKey value:address];
            [mArr addObject:label];
        }
    }
    if (mArr.count > 0) contact.postalAddresses = mArr;
}

- (NSString *)_checkIsString:(NSString *)str {
    if (!str || ![str isKindOfClass:NSString.class] || str.length == 0) return nil;
    return str;
}

#pragma mark - CNContactPickerDelegate
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(nonnull CNContact *)contact {
    UIViewController *presentingVC = picker.presentingViewController;
    [picker dismissViewControllerAnimated:NO completion:^{
        CNContactViewController *vc = [CNContactViewController viewControllerForContact:contact];
        vc.delegate = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [presentingVC presentViewController:nav animated:YES completion:^{
            [vc performSelector:vc.navigationItem.rightBarButtonItem.action];
        }];
    }];
}
@end



@interface CGHContactsUtil () <CNContactPickerDelegate, CNContactViewControllerDelegate>
@property (nonatomic, strong) CGHChooseContactAdapter *adapter;
@end
 
@implementation CGHContactsUtil
- (void)chooseContact:(UIViewController *)presentingVC noGrantedHandler:(void (^)(void))noGrantedHandler cancelHandler:(nonnull void (^)(void))cancelHandler completeHandler:(nonnull void (^)(NSDictionary * _Nonnull))completeHandler {
    if (@available(iOS 9.0, *)) {} else {
        !cancelHandler ?: cancelHandler();
        return;
    }
    
    self.adapter = CGHChooseContactAdapter.new;
    self.adapter.cancelHandler = ^{
        !cancelHandler ?: cancelHandler();
    };
    
    self.adapter.didComplete = ^(NSDictionary *contact) {
        !completeHandler ?: completeHandler(contact);
    };
    
    @weakify(self);
    [self grantChooseContact:^(BOOL granted) {
        @strongify(self);
        if (granted) {
            [self.adapter chooseContact:presentingVC];
        } else {
            !noGrantedHandler ?: noGrantedHandler();
            !cancelHandler ?: cancelHandler();
        }
    }];
}

- (void)addNewContact:(NSDictionary *)contact presentingVC:(UIViewController *)presentingVC noGrantedHandler:(void (^)(void))noGrantedHandler cancelHandler:(void (^)(void))cancelHandler completeHandler:(void (^)(void))completeHandler {
    if (@available(iOS 9.0, *)) {} else {
        !cancelHandler ?: cancelHandler();
        return;
    }
    
    self.adapter = CGHAddContactAdapter.new;
    self.adapter.cancelHandler = ^{
        !cancelHandler ?: cancelHandler();
    };
    
    self.adapter.didComplete = ^(NSDictionary *contact) {
        !completeHandler ?: completeHandler();
    };
    
    @weakify(self);
    [self grantChooseContact:^(BOOL granted) {
        @strongify(self);
        if (granted) {
            [(CGHAddContactAdapter*)self.adapter addNewContact:contact presentingVC:presentingVC];
        } else {
            !noGrantedHandler ?: noGrantedHandler();
            !cancelHandler ?: cancelHandler();
        }
    }];
}
 
- (void)editContact:(UIViewController *)presentingVC noGrantedHandler:(void (^)(void))noGrantedHandler cancelHandler:(nonnull void (^)(void))cancelHandler completeHandler:(nonnull void (^)(void))completeHandler {
    if (@available(iOS 9.0, *)) {} else {
        !cancelHandler ?: cancelHandler();
        return;
    }
    
    self.adapter = CGHAddContactAdapter.new;
    self.adapter.cancelHandler = ^{
        !cancelHandler ?: cancelHandler();
    };
    
    self.adapter.didComplete = ^(NSDictionary *contact) {
        !completeHandler ?: completeHandler();
    };
    
    @weakify(self);
    [self grantChooseContact:^(BOOL granted) {
        @strongify(self);
        if (granted) {
            [(CGHAddContactAdapter*)self.adapter editContact:presentingVC];
        } else {
            !noGrantedHandler ?: noGrantedHandler();
            !cancelHandler ?: cancelHandler();
        }
    }];
}

- (void)grantChooseContact:(void(^)(BOOL granted))completionHandler {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    CNContactStore *store = [[CNContactStore alloc] init];
    if (status == CNAuthorizationStatusNotDetermined) {
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            completionHandler(granted);
        }];
    } else if (status == CNAuthorizationStatusAuthorized) {
        completionHandler(YES);
    } else {
        completionHandler(NO);
    }
}

@end
