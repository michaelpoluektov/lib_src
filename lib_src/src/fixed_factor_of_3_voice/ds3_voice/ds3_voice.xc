// Copyright (c) 2016, XMOS Ltd, All rights reserved
#include <stdint.h>

/** Used for FIR compensation.
 *
 *  Generated using ds3_voice.py
 */
const unsigned src_ds3_voice_fir_comp_q = 30;

/** Used for FIR compensation.
 *
 *  Generated using ds3_voice.py
 */
const int32_t src_ds3_voice_fir_comp =2225098336;

/** Used for self testing src_ds3_voice functionality
 *
 *  Generated using ds3_voice.py
 */
int32_t src_ds3_voice_coefs_debug[72] = {
    1005142, 1367390, 29412, -4146838, -10154637,
    -14619962, -13776186, -6744830, 2692812, 8121360, 5508436, -2814524,
    -9285443, -7351357, 2193307, 10930750, 9953155, -1338213, -13227624,
    -13683020, -123797, 16201217, 19008511, 2582573, -20205295, -27041699,
    -6837031, 26249516, 40760231, 15085431, -37763299, -71330011, -37235961,
    74585089, 219245690, 320542055, 320542055, 219245690, 74585089,
    -37235961, -71330011, -37763299, 15085431, 40760231, 26249516, -6837031,
    -27041699, -20205295, 2582573, 19008511, 16201217, -123797, -13683020,
    -13227624, -1338213, 9953155, 10930750, 2193307, -7351357, -9285443,
    -2814524, 5508436, 8121360, 2692812, -6744830, -13776186, -14619962,
    -10154637, -4146838, 29412, 1367390, 1005142, };

/** Coefficients for use with src_ds3_voice functions
 *
 *  Generated using ds3_voice.py
 */
const int32_t src_ds3_voice_coefs[3][24] = { {
    29412, -14619962, 2692812, -2814524, 2193307,
    -1338213, -123797, 2582573, -6837031, 15085431, -37235961, 320542055,
    74585089, -37763299, 26249516, -20205295, 16201217, -13227624, 10930750,
    -9285443, 8121360, -13776186, -4146838, 1005142, }, { 1367390,
    -10154637, -6744830, 5508436, -7351357, 9953155, -13683020, 19008511,
    -27041699, 40760231, -71330011, 219245690, 219245690, -71330011,
    40760231, -27041699, 19008511, -13683020, 9953155, -7351357, 5508436,
    -6744830, -10154637, 1367390, }, { 1005142, -4146838, -13776186,
    8121360, -9285443, 10930750, -13227624, 16201217, -20205295, 26249516,
    -37763299, 74585089, 320542055, -37235961, 15085431, -6837031, 2582573,
    -123797, -1338213, 2193307, -2814524, 2692812, -14619962, 29412, }, };
