/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#import <objcsecommon_impl/se_strings_set_impl.h>
#import <objcsecommon_impl/se_strings_iterator_impl.h>

@implementation SECommonStringsSetRef {
  se::common::StringsSet* ptr;
  bool is_mutable;
}

- (instancetype) initFromInternalStringsSetPointer:(se::common::StringsSet *)set
                                withMutabilityFlag:(BOOL)mutabilityFlag {
  if (self = [super init]) {
    ptr = set;
    is_mutable = (YES == mutabilityFlag);
  }
  return self;
}

- (se::common::StringsSet *) getInternalStringsSetPointer {
  return ptr;
}

- (BOOL) isMutable {
  return is_mutable? YES : NO;
}

- (int) getStringsCount {
  return ptr->GetStringsCount();
}

- (BOOL) hasString:(NSString *)string {
  return ptr->HasString([string UTF8String])? YES : NO;
}

- (SECommonStringsSetIterator *) stringsBegin {
  return [[SECommonStringsSetIterator alloc] initFromInternalStringsSetIterator:ptr->StringsBegin()];
}

- (SECommonStringsSetIterator *) stringsEnd {
  return [[SECommonStringsSetIterator alloc] initFromInternalStringsSetIterator:ptr->StringsEnd()];
}

@end
