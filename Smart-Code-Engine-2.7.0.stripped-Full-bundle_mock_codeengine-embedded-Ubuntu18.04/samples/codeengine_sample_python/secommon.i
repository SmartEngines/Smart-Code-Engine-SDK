//  Copyright (c) 2016-2025, Smart Engines Service LLC
//  All rights reserved.

%module pysecommon

%include secommon_defs.i
%include exception.i

%{
#include "secommon/se_export_defs.h"
#include "secommon/se_geometry.h"
#include "secommon/se_string.h"
#include "secommon/se_image.h"
#include "secommon/se_images_iterator.h"
#include "secommon/se_strings_iterator.h"
#include "secommon/se_strings_set.h"
#include "secommon/se_exception.h"
#include "secommon/se_serialization.h"
#include "secommon/se_common.h"
%}

%rename("%(lowercamelcase)s", %$isvariable) "";

%exception { 
    try {
        $action
    } catch (const se::common::BaseException& e) {
        SWIG_exception(SWIG_RuntimeError, (std::string(e.ExceptionName()) + ": " + e.what()).c_str());
    } catch (const std::exception& e) {
        SWIG_exception(SWIG_RuntimeError, (std::string("CRITICAL!: STL exception caught: ") + e.what()).c_str());
    } catch (...) {
        SWIG_exception(SWIG_RuntimeError, "CRITICAL!: Unknown exception caught");
    }
}

%ignore se::common::StringsSetIteratorImpl;
%ignore se::common::StringsMapIteratorImpl;
%ignore se::common::StringsVectorIteratorImpl;
%ignore se::common::SerializerImplBase;
%ignore se::common::QuadranglesMapIteratorImpl;
%ignore se::common::SerializationParametersImpl;
%ignore se::common::OcrStringImpl;

%ignore SerializerImplBase;
%ignore GetImpl;

%ignore SerializeImpl;
%ignore se::common::SerializerImplBase;

%ignore ConstructFromImpl;

%ignore Construct;

%ignore se::common::StringsVectorIterator::Construct;
%ignore se::common::StringsSetIterator::Construct;
%ignore se::common::StringsMapIterator::Construct;
%ignore se::common::StringsVectorIterator::Construct;
%ignore se::common::QuadranglesMapIterator::Construct;

%ignore se::common::Image::GetUnsafeBufferPtr;
%ignore se::common::ImagesMapIterator::GetValuePtr;

%ignore se::common::OcrString::GetOcrStringImplPtr;

%ignore se::common::ProjectiveTransform::GetRawCoeffs;
%ignore se::common::ProjectiveTransform::GetMutableRawCoeffs;
%ignore se::common::ProjectiveTransform::Raw2dArrayType;
%ignore se::common::ProjectiveTransform::Create( double[3][3]);
%ignore se::common::ProjectiveTransform::Create( Raw2dArrayType&);
%ignore se::common::ProjectiveTransform::Create(const double[3][3]);
%ignore se::common::ProjectiveTransform::Create(const Raw2dArrayType&);
%ignore se::common::ProjectiveTransform::Create( Raw2dArrayType&);


%newobject se::common::Image::CreateEmpty;
%newobject se::common::Image::FromFile;
%newobject se::common::Image::FromFileBuffer;
%newobject se::common::Image::FromBuffer;
%newobject se::common::Image::FromBufferExtended;
%newobject se::common::Image::FromYUVBuffer;
%newobject se::common::Image::FromYUV;
%newobject se::common::Image::FromBase64Buffer;
%newobject se::common::Image::CloneDeep;
%newobject se::common::Image::CloneShallow;
%newobject se::common::Image::CloneResized;
%newobject se::common::Image::CloneCropped;
%newobject se::common::Image::CloneCroppedShallow;
%newobject se::common::Image::CloneMasked;
%newobject se::common::Image::CloneFlippedVertical;
%newobject se::common::Image::CloneFlippedHorizontal;
%newobject se::common::Image::CloneRotated90;
%newobject se::common::Image::CloneAveragedChannels;
%newobject se::common::Image::CloneInverted;

%newobject se::common::ProjectiveTransform::Create;
%newobject se::common::ProjectiveTransform::Clone;
%newobject se::common::ProjectiveTransform::CloneInverted;

%include "secommon/se_serialization.h"
%include "secommon/se_geometry.h"
%include "secommon/se_string.h"
%include "secommon/se_images_iterator.h"
%include "secommon/se_image.h"
%include "secommon/se_strings_iterator.h"
%include "secommon/se_strings_set.h"
%include "secommon/se_common.h"
