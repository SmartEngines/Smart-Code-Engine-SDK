/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines;

import com.smartengines.code.CodeEngineResult;

public interface CodeCallback {
  void initialized(boolean engine_initialized);
  void recognized(CodeEngineResult result);
  void started();
  void stopped();
  void error(String message);
}
