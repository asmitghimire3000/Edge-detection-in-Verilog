# Edge-detection-in-Verilog

This project implements a hardware-accelerated edge detection system in Verilog, suitable for FPGA deployment. It processes grayscale images using convolution-based techniques, including Gaussian blur and edge detection filters, and is designed for efficient streaming and DMA integration.

## Features

- **Line Buffering**: Efficiently manages image rows for convolution operations ([linebuffer.v](linebuffer.v)).
- **Control Logic**: Handles data flow, line buffer management, and interrupt signaling ([control_logic.v](control_logic.v)).
- **Convolution Modules**:
  - Gaussian blur ([convolution.v](convolution.v))
  - Edge detection (Sobel-like, [convolution_edge.v](convolution_edge.v))
- **AXI-like Streaming Interface**: For easy integration with DMA controllers ([top_view.v](top_view.v)).
- **Testbench**: Simulates image input/output and verifies functionality ([tb.v](tb.v)).

## File Overview

- [`top_view.v`](top_view.v): Top-level module connecting all submodules and interfacing with external systems.
- [`control_logic.v`](control_logic.v): Manages line buffers and orchestrates data movement.
- [`linebuffer.v`](linebuffer.v): Implements a parameterized line buffer for image rows.
- [`convolution.v`](convolution.v): Performs 3x3 Gaussian blur convolution.
- [`convolution_edge.v`](convolution_edge.v): Performs 3x3 edge detection convolution.
- [`tb.v`](tb.v): Testbench for simulation, reads BMP images and writes processed output.
- [`README.md`](README.md): Project documentation.

## How It Works

1. **Image Input**: The testbench reads a BMP image and streams pixel data into the design.
2. **Line Buffering**: Four line buffers store rows of the image, enabling 3x3 window extraction for convolution.
3. **Convolution**: The selected convolution module processes the 3x3 window to produce blurred or edge-detected output.
4. **Output Buffering**: Results are streamed out, ready for DMA or further processing.
5. **Interrupts**: The design signals when a frame or line is processed.

## Convolution

- Gaussian Blur for blurring.
     | 1 | 2 | 1 |
     |---|---|---|
     | 2 | 4 | 2 |
     | 1 | 2 | 1 |

- Sobel for Edge Detection.
  
  **G<sub>x</sub> =**  
    | -1 |  0 | +1 |
    |----|----|----|
    | -2 |  0 | +2 |
    | -1 |  0 | +1 |
    
    **G<sub>y</sub> =**  
    | -1 | -2 | -1 |
    |----|----|----|
    |  0 |  0 |  0 |
    | +1 | +2 | +1 |
  



  $G = \sqrt{Gx^2 + Gy^2}$.
  

## Simulation

To simulate the design:

1. Place a grayscale BMP image named `lena_gray.bmp` in the simulation directory.
2. Run the testbench ([tb.v](tb.v)) using your preferred Verilog simulator (e.g., Icarus Verilog, ModelSim).
3. The processed image will be written as `blurred_lena.bmp`.

## Customization

- To switch between Gaussian blur and edge detection, instantiate the desired convolution module in [`top_view.v`](top_view.v).
- Adjust image width or kernel as needed in the line buffer and convolution modules.

## Requirements

- Verilog 2001 compatible simulator
- BMP image for testing (grayscale, 512x512 pixels)

## License

This project is provided for educational and research purposes.

---
                
