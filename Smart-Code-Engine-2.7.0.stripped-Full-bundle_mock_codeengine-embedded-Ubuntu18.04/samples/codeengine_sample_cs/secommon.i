//  Copyright (c) 2016-2025, Smart Engines Service LLC
//  All rights reserved.

%module cssecommon

%include secommon_defs.i

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

%pragma(csharp) imclassimports=%{
using System.Runtime.InteropServices;
using System;
using System.Text;
%}

%pragma(csharp) imclasscode=%{
public class SimpleMarshaler : ICustomMarshaler {
    static SimpleMarshaler myself = new SimpleMarshaler();

    public object MarshalNativeToManaged(IntPtr pNativeData) {
        int size_buffer = 0;
        while (Marshal.ReadByte(pNativeData, size_buffer) != 0) {
            ++size_buffer;
        }
        byte[] byte_buffer = new byte[size_buffer];
        Marshal.Copy((IntPtr)pNativeData, byte_buffer, 0, size_buffer);
        return Encoding.UTF8.GetString(byte_buffer);
    }

    public IntPtr MarshalManagedToNative( Object ManagedObj ) => throw new NotImplementedException();

    public void CleanUpNativeData( IntPtr nativeData ) {
        Marshal.FreeHGlobal(nativeData);
    }

    public void CleanUpManagedData( Object ManagedObj ) => throw new NotImplementedException();
    public int GetNativeDataSize() => throw new NotImplementedException();

    public static ICustomMarshaler GetInstance(string cookie) {
        return myself;
    }
}
%}

SWIG_CSBODY_PROXY(public, public, SWIGTYPE)
SWIG_CSBODY_TYPEWRAPPER(public, public, public, SWIGTYPE)

%exception {
  try {
    $action
  } catch (const se::common::BaseException& e) {
        SWIG_CSharpSetPendingException(static_cast<SWIG_CSharpExceptionCodes>(SWIG_RuntimeError), (std::string("Base secommon exception caught: ") + e.what()).c_str());
        return $null;
  } catch (const std::exception& e) {
        SWIG_CSharpSetPendingException(static_cast<SWIG_CSharpExceptionCodes>(SWIG_RuntimeError), (std::string("CRITICAL!: STL exception caught: ") + e.what()).c_str());
        return $null;
  } catch (...) {
        SWIG_CSharpSetPendingException(static_cast<SWIG_CSharpExceptionCodes>(SWIG_RuntimeError), "CRITICAL!: Unknown exception caught");
        return $null;
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

%ignore se::common::OcrString::GetOcrStringImplPtr;
%ignore se::common::ImagesMapIterator::GetValuePtr;

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

%typemap(imtype,
         outattributes="\n  [return: global::System.Runtime.InteropServices.MarshalAs(global::System.Runtime.InteropServices.UnmanagedType.CustomMarshaler, MarshalTypeRef = typeof(SimpleMarshaler))] \n ") const char * "string";
%include "secommon/se_string.h"
%include "secommon/se_images_iterator.h"
%include "secommon/se_image.h"

%typemap(imtype) const char *;
%include "secommon/se_strings_iterator.h"
%include "secommon/se_strings_set.h"
%include "secommon/se_common.h"
