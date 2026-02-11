//  Copyright (c) 2016-2025, Smart Engines Service LLC
//  All rights reserved.

%include std_map.i
%include std_string.i
%include std_vector.i
%include stdint.i
%include typemaps.i
%include exception.i
%include "arrays_csharp.i"

%apply unsigned char INPUT[] { unsigned char* data };
%apply unsigned char INPUT[] { unsigned char* yuv_data };
%apply unsigned char INPUT[] { unsigned char* config_data };
%apply unsigned char INPUT[] { unsigned char* raw_data };
%apply unsigned char INPUT[] { unsigned char* buffer };
%apply unsigned char INPUT[] { unsigned char* y_plane };
%apply unsigned char INPUT[] { unsigned char* u_plane };
%apply unsigned char INPUT[] { unsigned char* v_plane };

%apply unsigned char INPUT[] { unsigned char* bytes };
%apply char OUTPUT[] { char* out_buffer };


CSHARP_ARRAYS(char, byte)

%include "secommon/se_export_defs.h"
