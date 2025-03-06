//  Copyright (c) 2016-2024, Smart Engines Service LLC
//  All rights reserved.

%include typemaps.i
%include pybuffer.i

%typemap(typecheck) unsigned char* { }
%pybuffer_binary(unsigned char* raw_data, int raw_data_length);
%pybuffer_binary(unsigned char* config_data, int config_data_length);
%pybuffer_binary(unsigned char* yuv_data, int yuv_data_length);
%pybuffer_binary(unsigned char* data, int data_length);
%pybuffer_binary(unsigned char* buffer, int buffer_length);
%pybuffer_binary(unsigned char* y_plane, int y_plane_length);
%pybuffer_binary(unsigned char* u_plane, int u_plane_length);
%pybuffer_binary(unsigned char* v_plane, int v_plane_length);
%pybuffer_binary(const unsigned char *bytes, size_t n);
%pybuffer_binary(const char* out_buffer, int buffer_length);



%include "secommon/se_export_defs.h"
