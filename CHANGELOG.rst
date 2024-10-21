lib_src change log
==================

2.7.0
-----

  * CHANGED: Documentation updates
  * CHANGED: Build examples and tests using XCommon CMake instead of XCommon
  * FIXED: Warning about "ASRC_TASK using defaults" if using lib_src without
    using asrc_task

  * Changes to dependencies:

    - lib_logging: 3.2.0 -> 3.3.1

2.6.0
-----

  * ADDED: Documentation characterising latency for ASRC and associated
    subsystems
  * ADDED: Return code on asynchronous_fifo_consumer_get() to indicate if
    samples are valid or not
  * CHANGED: ASRC task zeros pulled samples if FIFO get is not valid

2.5.0
-----

  * FIXED: Double buffer asrc_io.input_timestamp to prevent producer timestamp
    getting overwritten during asrc processing
  * REMOVED: xscope_used argument from the asynchronous_fifo_producer_put() API
  * ADDED: VPU enabled ASRC and SSRC providing a 2x speed improvement
  * ADDED: Asynchronous FIFO with phase detector and PID rate controller for
    ASRC usage
  * ADDED: Support for XCommon CMake build system
  * FIXED: Function pointer annotation avoid stack corruption when using
    multiple instances of SSRC or ASRC.
  * ADDED: ASRC task wrapper to simplify integration of ASRC blocks

  * Changes to dependencies:

    - lib_logging: 3.1.1 -> 3.2.0

    - lib_xassert: Removed dependency

2.4.0
-----

  * ADDED: Support for building the core ASRC code in the C emulator as a
    library
  * ADDED: Auto-generated ASRC and SSRC performance plots in documentation
  * ADDED: Documentation warning about overflow in XS3 optimized SRC components
  * CHANGED: Documents built under Jenkins instead of Github Actions
  * CHANGED: Tested against fwk_core v1.0.2 updated from v1.0.0

2.3.0
-----

  * ADDED: XS3 VPU optimised voice fixed factor of 3 upsampling/downsampling
  * ADDED: XS3 VPU optimised voice fixed factor of 3/2 upsampling/downsampling
  * CHANGED: OS3 uses firos3_144.dat coefficients by default inline with model
  * CHANGED: Replaced xmostest with pytest for all SRC automated tests
  * CHANGED: Used XMOS doc builder for documentation
  * CHANGED: Golden reference test signals now generated automatically by CI
  * RESOLVED: Linker warning on channel ends
  * REMOVED: AN00231 ASRC App Note. See github.com/xmos/sln_voice/examples
  * CHANGED: Increased precision of the fFsRatioDeviation used in the C emulator
    from float to double
  * CHANGED: Allow for 64 bits in the rate ratio passed to asrc_process() for
    extra precision

  * Changes to dependencies:

    - lib_logging: 2.0.1 -> 3.1.1

    - lib_xassert: 2.0.1 -> 4.1.0

2.2.0
-----

  * CHANGED: Made the FIR coefficient array that is used with the voice fixed
    factor of 3 up and down sampling functions usable from within C files as
    well as XC files.
  * CHANGED: Aligned the FIR coefficient array to an 8-byte boundary. This
    ensures that the voice fixed factor of 3 up and down sampling functions do
    not crash with a LOAD_STORE exception.
  * ADDED: Missing device attributes to the .xn file of the AN00231 app note.
  * ADDED: Minimal cmake support.

2.1.0
-----

  * CHANGED: Use XMOS Public License Version 1

2.0.1
-----

  * CHANGED: Pin Python package versions
  * REMOVED: not necessary cpanfile

2.0.0
-----

  * CHANGED: Build files updated to support new "xcommon" behavior in xwaf.

1.1.2
-----

  * CHANGED: initialisation lists to avoid warnings when building

1.1.1
-----

  * RESOLVED: correct compensation factor for voice upsampling
  * ADDED: test of voice unity gain

1.1.0
-----

  * ADDED: Fixed factor of 3 conversion functions for downsampling and
    oversampling
  * ADDED: Fixed factor of 3 downsampling function optimised for use with voice
    (reduced memory and compute footprint)
  * ADDED: Fixed factor of 3 upsampling function optimised for use with voice
    (reduced memory and compute footprint)

1.0.0
-----

  * Initial version

  * Changes to dependencies:

    - lib_logging: Added dependency 2.0.1

    - lib_xassert: Added dependency 2.0.1

