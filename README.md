<h1 align="center">Writeboard [WIP]</h1>
<div align="center">
  <img src="https://img.shields.io/github/actions/workflow/status/folfcoder/writeboard/build.yaml?style=for-the-badge" />
  <img src="https://img.shields.io/github/license/folfcoder/writeboard?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Qt-%3E=6.2.4-brightgreen?style=for-the-badge&logo=qt" />
</div>

## What is Writeboard?

Writeboard is a virtual handwriting keyboard designed specifically for Linux desktops with drawing tablets or styluses.
Powered by Qt 6 and Tesseract OCR, Writeboard offers easy-to-use UI and powerful handwriting recognition, thanks to the specifically trained custom model.

## Installation

Currently, Writeboard is not available in any package manager. 
Please download the binary from the Releases page (stable) or from artifacts in Actions (latest). 
Additionally, make sure to have Qt (>=6.2.4) and Tesseract installed on your system before using Writeboard.

## Development

Install dependencies:
```
cmake
gcc
make
tesseract
qt6-declarative (>=6.2.4)
qtcreator (optional)
```

Run CMake and compile:
```bash
cmake -S . -B build
cd build && make
```

## License

[GNU General Public License v3.0](https://github.com/folfcoder/writeboard/blob/main/LICENSE)
