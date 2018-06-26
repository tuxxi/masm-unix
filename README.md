# MASM on Unix (OSX and Linux)

Write MASM code (and link to Irvine32) using native tools, assemble it into native ELF or Mach-O binaries. Graphical debugging is possible using your favorite gdb/lldb wrapper, however instructions for vscode are included.

This is a fork of https://github.com/janka102/MASM_OSX that also supports Linux.

Made possible thanks to [JWasm](https://github.com/JWasm/JWasm). Irvine32 library via [Along32](https://github.com/janka102/Along32).
OSX support thanks to [objconv](https://github.com/gitGNU/objconv)


# Background
If you're like me, you had to take a x86 assembly class in college that uses Kip Irvine's book [Assembly Language for x86 Processors, 7th edition](http://kipirvine.com/asm/). The book uses MASM (Microsoft Macro Assembler) which is irrevocably tied to the Visual Studio toolchain on Windows. 

I hate spinning up an expensive Win10 VM every time I need to do homework for this class, but luckily there exist a couple free, open source implementations of the required tools! Namely, [JWasm](https://github.com/JWasm/JWasm) for assembling the MASM language into x86 bytecode, and [Along32](http://sourceforge.net/projects/along32) for the Irvine32 library written in nasm that can be compiled to a native static library. Because JWasm does not support Mach-O, on OSX we use [objconv](https://github.com/gitGNU/objconv) to convert the jwasm elf output to Mach-O.

Now you can use native tools to write assembly code (your favorite text editor, IDE, whatever) and build native executables that can be passed to a native debuger (gdb, lldb). Graphical debugging is possible with a gdb wrapper such as `kdbg` or by using vscode's [CodeLLDB](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb) extension,  more info in `Instructions :: Optional ...`

# Building


## Prerequesites
Requires `yasm`, `perl` and `cmake`
### Debian-based (Ubuntu, Debian, Linux Mint, ...)
```
sudo apt install build-essential cmake yasm perl
```
### OSX (not tested)

Install xcode, then
```
xcode-select --install          # installs command line tools
```
Then install homebrew [homebrew](https://brew.sh/), and: 

```
brew install cmake yasm perl
```

## Building JWasm, Along32, and objconv

1. First, clone this repo
    ```
    git clone http://github.com/tuxxi/masm-unix
    ```
2. Then, build the libraries
    ```
    cd masm_unix
    mkdir build             # make a directory for build products
    cmake -H. -Bbuild       # tell cmake to init in our build directory
    cmake --build build     # tell cmake to build everything
    ```

That's it! Now you can build masm into native binaries!

# Usage

From the root directory, run `make {your_base_filename}` to build an excutable 
- Example: `make ch7-1` will look for a source file called `ch7-1.asm` in the current directory, and create an executable called `ch7-1` located in the `bin` folder

Run your file using `./bin/{your_base_filename}`
- Example: `./bin/ch7-2`

### Optional: VSCode support
The [CodeLLDB](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb) extension is great for native debugging in VSCode, and it works very well here because of the disassembly view. 

#### Setup Instructions:
OSX comes with lldb and clang, on Linux, we need to install lldb. For Debian-based Linux:

```
sudo apt install lldb-6.0   # or higher, if new versions are available on your distro
```

In vscode, press ctrl+p to open command pane, and run `ext install vadimcn.vscode-lldb`

I also recommend [MASM](https://marketplace.visualstudio.com/items?itemName=bltg-team.masm) syntax highlighting. 
Install using `ext install bltg-team.masm`

#### Usage:

1. Open the `masm-unix` root folder in VS Code
2. Import or write some masm code
    - Build current file using ctrl+shift+b
    - Run current file using f5
3. Set a breakpoint
    - Click on 'debug' tab, then in the lower left pane, select breakpoints and add `main` as a breakpoint. You can break wherever you wish, but `main` is a good place to start

# Known Issues (stolen from MASM_OSX)

* Can't have the first value in `.data` be uninitialized. See [here](https://github.com/janka102/MASM_OSX#known-issues) for more info