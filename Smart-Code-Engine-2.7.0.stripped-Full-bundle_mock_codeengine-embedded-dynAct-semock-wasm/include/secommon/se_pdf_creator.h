/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

#ifndef SECOMMONSE_PDF_CREATOR_H_INCLUDED
#define SECOMMONSE_PDF_CREATOR_H_INCLUDED

#include <secommon/se_string.h>
#include <secommon/se_geometry.h>
#include <secommon/se_image.h>

namespace se { namespace pdf {

class SE_DLL_EXPORT PhysicalString {
public:
  virtual ~PhysicalString() = default;
};

class SE_DLL_EXPORT PdfSourcesContainer {
public:
  static PdfSourcesContainer* Create();

  virtual int GetPhysicalStringsCount() const = 0;

  virtual const PhysicalString& GetPhysicalStringByIdx(int idx) const = 0;

  virtual const se::common::Image& GetPageImage() const = 0;
};

class SE_DLL_EXPORT PdfCreatorSettings {
public:
  virtual ~PdfCreatorSettings() = default;

  virtual bool HasOption(const char* option_name) const = 0;

  virtual const char* GetOption(const char* option_name) const = 0;

  virtual void SetOption(const char* option_name, const char* option_value) = 0;
};

class SE_DLL_EXPORT PdfResult {
public:
  static PdfResult* Create();

  virtual void GetPDFABuffer(unsigned char* output_buf, unsigned long long buf_size) const = 0;

  virtual int GetPDFABufferSize() const = 0;
};

class SE_DLL_EXPORT PdfCreator {
public:
  static PdfCreator* Create();

  virtual void Initialize() = 0;

  virtual void BuildPDFABuffer(
      const PdfSourcesContainer* src,
      const PdfCreatorSettings* settings,
      PdfResult* result) = 0;

  virtual PdfCreatorSettings* CreateSettings() const = 0;
};

} }

#endif //SECOMMONSE_PDF_CREATOR_H_INCLUDED
