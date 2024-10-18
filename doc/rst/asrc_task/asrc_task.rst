|newpage|

.. _asrc_task_header:

*********
ASRC Task
*********

The ASRC library provides a function call that operates on blocks of samples whereas typical `XMOS`
audio IO libraries provide streaming audio one sample at a time. The ASRC task wraps up the core ASRC function with all of the other lower level APIs (eg. FIFO) and required sample change and initialisation logic. It provides a simple-to-use and generic ASRC conversion block suitable for integration into practical designs. It is fully re-entrant permitting multiple instances within a project supporting multiple (or bi-directional) sample rates and audio clock domain bridges.

.. figure:: images/asrc_task_layers.drawio.png
   :scale: 50 %
   :alt: ASRC Thread Usage

Operation
==========

The ASRC task handles bridging between two asynchronous audio sources. It has an input side and output side. The input samples are provided over a channel allowing the source to be placed on a different `xcore` tile if needed. The output side sample interface is via an asynchronous FIFO meaning the consumer must reside on the same `xcore` tile as the ASRC. The ASRC task uses a minimum of one thread but may be configured to use many depending on processing requirements.

.. figure:: images/ASRC_block_threads.png
   :scale: 80 %
   :alt: ASRC Thread Usage


Both input and output interfaces must specify the nominal sample rate required and additionally the input must specify a channel count. The output channel count will be set to the same as the input channel count automatically once the ASRC has automatically configured itself. A timestamp indicating the time of the production of the last input sample and the consumption of the first output sample must also be supplied which allows the ASRC FIFO to calculate the rate and phase difference. Each time either the input or output nominal sample rate or the channel count changes the ASRC subsystem automatically re-configures itself and restarts with the new settings.

The ASRC Task supports the following nominal sample rates for input and output:

    - 44.1 kHz
    - 48 kHz
    - 88.2 kHz
    - 96 kHz
    - 176.4 kHz
    - 192 kHz

Because the required compute for multi-channel systems may exceed the performance limit of a single thread, the ASRC subsystem is able to make use of multiple threads in parallel to achieve the required conversion within the sample time period. It uses a dynamic fork and join architecture to share the ASRC workload across multiple threads each time a batch of samples is processed. The threads must all reside on the same tile as the ASRC task due to them sharing input and output buffers. The workload and buffer partitioning is dynamically computed by the ASRC task at stream startup and is constrained by the user at compile time to set maximum limits of both channel count and worker threads.

The number of threads that are required depends on the required channel count and sample rates required. Higher sample rates require more MIPS. The amount of thread MHz (and consequently how many threads) required can be *roughly* calculated using the following formulae:

    - Total thread MHz required for `xcore.ai` systems = 0.15 * Max channel count * (Max SR input kHz + Max SR output kHz)
    - Total thread MHz required for `xcore-200` systems = 0.3 * Max channel count * (Max SR input kHz + Max SR output kHz)

The difference between the performance requirement between the two architectures is due to xcore.ai supporting a Vector Processing Unit (VPU) which allows acceleration of the internal filters used by the ASRC. For example:

    - A two channel system supporting up to 192kHz input and output will require about (0.15 * (192 + 192) * 2) ~= 115 thread MHz. This means a single thread (assuming no more than 5 active threads on an `xcore.ai` device with a 600MHz clock) will likely be capable of handling this stream.

    - An eight channel system consisting of either 44.1kHz or 48kHz input with maximum output rate of 192kHz will require about (0.15 * (48 + 192) * 8) ~= 288 thread MHz. This can adequately be provided by four threads (assuming up to 8 active threads on an `xcore.ai` device with a 600MHz clock).

In reality the amount of thread MHz needed will be lower than the above formulae suggest since subsequent ASRC channels after the first can share some of the calculations. This results in about at 10% performance requirement reduction per additional channel per worker thread. Increasing the input frame size in the ASRC task may also reduce the MHz requirement a few % at the cost of larger buffers and a slight latency increase.

.. warning::
    Exceeding the processing time available by specifying a channel count, input/output rates, number of worker threads or device clock speed may result in at best choppy audio or a blocked ASRC task if the overrun is persistent.

It is strongly recommended that you test the system for your desired channel count and input and output sample rates. An optional timing calculation and check is provided in the ASRC to allow characterisation at run-time which can be found in the `asrc_task.c` source code.

The low level ASRC processing function call API accepts a minimum input frame size of four whereas most XMOS audio interfaces provide a single sample period frame. The ASRC subsystem integrates a serial to block back to serial conversion to support this. The input side works by stealing cycles from the ASRC using an interrupt and notifies the main ASRC loop using a single channel end when a complete frame of double buffered is available to process. The ASRC output side is handled by the asynchronous FIFO which supports a block `put` with single sample `get` and thus provides de-serialisation intrinsically.


Latency characterisation
========================

The latency shown by ASRC Task depends on many factors:

    - Input sample rate (dynamically variable)
    - Output sample rate (dynamically variable)
    - ASRC filter stages latency (fixed based on input and output sample rates)
    - FIFO sizing (statically or dynamically variable by user)
    - ASRC sample processing block size (default of 4 which is the minimum for the ASRC and recommended for most applications)

The input and output sample rate are defined by the application and are not negotiable. The ASRC filters have fixed group delay according to the input and output rates. The underlying filter delay can be found in :ref:`ASRC latency characterisation section <asrc_latency_header>` and typically dominates the total delay.

The ASRC sample block processing size is nominally 4 but can be increased to 8, 16 or 32 to slightly reduce the MIPS required to run the processing but will incur extra delay. The case for the block size of 4 is already accounted for in the ASRC filter stage figures.

FIFO sizing is the major variable which the user has control over. The FIFO size is configurable and is a trade-off between PPM lock range required, output sample rate and desired latency. It is also partly governed by the maximum upsample ratio since, when upsampling, multiple samples are produced for a single input sample and hence the FIFO needs to be larger to accommodate a whole block.

See the :ref:`Practical FIFO sizing <asynchronous_FIFO_practical_sizing>` section for more details.

The total delay can be calculated as follows::

    GROUP_DELAY = ((INPUT_BLOCK_SIZE - 4) / INPUT_SAMPLE_RATE) + ASRC_FILTER_DELAY + (OUTPUT_FIFO_LENGTH / OUTPUT_SAMPLE_RATE / 2)


API & usage
===========

The ASRC Task consists of a task to which various data structures must be declared and passed:

    - A pointer to instance of the `asrc_in_out_t` structure which contains buffers, stream information and ASRC task state.
    - A pointer to the FIFO used at the output side of the ASRC task.
    - The length of the FIFO passed in above.

In addition the following two functions may be declared in a user `C` file (note that `XC` does not handle function pointers):

    - The callback function from ASRC task which receives samples over a channel from the producer.
    - A callback initialisation function which registers the callback function into the `asrc_in_out_t` struct

If these are not defined, then a default receive implementation will be used which is matched with the
``send_asrc_input_samples_default()`` function on the user's producer side. This should be sufficient for typical usage.

.. note:: ``ASRC task`` must have ``asrc_task_config.h`` defined in the user application which sets various static settings for the ASRC. See :ref:`ASRC task API <asrc_task_api>` for details or reference `AN02003: SPDIF/ADAT/I2S Receive to I2S Slave Bridge with ASRC <https://www.xmos.com/file/an02003>`_ as an example.

An example of calling the ASRC task form and ``XC`` main function is provided below. Note use of `unsafe` permitting the compiler to allow shared memory structures to be accessed by more than one thread::

    chan c_producer;

    // FIFO and ASRC I/O declaration. Unsafe to allow producer and consumer to access it from XC
    #define FIFO_LENGTH     40 // Example only. Depends on rates and PPM - see docs
    int64_t array[ASYNCHRONOUS_FIFO_INT64_ELEMENTS(FIFO_LENGTH, MAX_ASRC_CHANNELS_TOTAL)];

    unsafe{
        // IO struct for ASRC must be passed to both asrc_proc and consumer
        asrc_in_out_t asrc_io = {{{0}}};
        asrc_in_out_t * unsafe asrc_io_ptr = &asrc_io;
        asynchronous_fifo_t * unsafe fifo = (asynchronous_fifo_t *)array;
        setup_asrc_io_custom_callback(asrc_io_ptr); // Optional user rx function

        par
        {
            producer(c_producer);
            asrc_task(c_producer, asrc_io_ptr, fifo, FIFO_LENGTH);
            consumer(asrc_io_ptr, fifo);

        }
    } // unsafe region


An example of the user-defined `C` function for receiving the input samples is shown below along with the user callback registration function. The `receive_asrc_input_samples()` function must be as short as possible because it steals cycles from the ASRC task operation. Because this function is not called until the first channel word is received from the producer, the `chanend_in_word()` operations will happen straight away and not block as long as the producer immediately produces all required samples.

.. literalinclude:: ../../../lib_src/src/asrc_task/asrc_task.c
   :start-at: Default implementation of receive
   :end-at: END ASRC_TASK_ISR_CALLBACK_ATTR


Note that the producing side of the above transaction must match the channel protocol. For this example, the producer must send the following items across the channel in order:

    - The nominal input sample rate.
    - The input time stamp of the last sample received.
    - The input channel count of the current frame.
    - The samples from 0..n.

Because a `streaming` channel is used the back-pressure on the producer side will be very low because the channel outputs will be buffered and the receive callback will always respond to the received words.

This callback function helps bridge between `sample based` systems and the block-based nature of the underlying ASRC functions without consuming an extra thread.

.. _asrc_task_api:

The API for ASRC task is shown below:

.. doxygengroup:: src_asrc_task
   :content-only:

