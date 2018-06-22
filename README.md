# MASM on Unix (OSX and Linux)

Write MASM code (and link to Irvine32) using native tools and assemble it into native ELF or Mach-O binaries. Additional support for graphical debugging in vscode using [CodeLLDB](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb)

Made possible thanks to [JWasm](https://github.com/JWasm/JWasm). Irvine32 library via [Along32](http://sourceforge.net/projects/along32).
OSX support thanks to [objconv](https://github.com/gitGNU/objconv)

An extension/reimplementation of [MASM_OSX](https://github.com/janka102/MASM_OSX) by [janka102](https://github.com/janka102)

# Background
If you're like me, you had to take a (terrible) x86 assembly class that uses Kip Irvine's book [Assembly Language for x86 Processors, 7th edition](http://kipirvine.com/asm/). The book uses MASM (Microsoft Macro Assembler) which is irrevocably tied to the Visual Studio toolchain on Windows. 

I hate spinning up an expensive Win10 VM every time I need to do homework for this class, but luckily there exist a couple neat FOSS implementations of the required tools! Namely, [JWasm](https://github.com/JWasm/JWasm) for assembling the MASM language, and [Along32](http://sourceforge.net/projects/along32) for the Irvine32 library written in nasm that can be compiled to a native static library.

Now you can use native tools to write code (your favorite text editor, IDE, whatever) and build native executables that can be passed to a native debuger (gdb, lldb). Graphical debugging is possible using vscode's [CodeLLDB](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb) extension, more info in `Instructions :: Optional ...`

# Instructions

### *Note: masm-unix does not include precompiled binaries, you **must** build them yourself. Don't worry, it's easy.*

## Prerequesites

Debian-based (Ubuntu, Debian, Linux Mint, ...)
```
sudo apt install build-essential cmake nasm perl
```
OSX (not tested)

Install xcode and [homebrew](https://brew.sh/), then:
```
xcode-select --install          # installs command line tools
brew install cmake nasm perl    # installs cmake, nasm and perl
```

### Building JWasm and Along32

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

### Building and running masm files

From the root directory, run `make bin/{your_filename}` to build an excutable 
- Example: `make bin/ch7-1` will look for a source file called `ch7-1.asm` 
and create an executable called `ch7-1` located in the `bin` folder

Run your file using `./ 

### Optional: vscode build and debug support
```
sudo apt install lldb-6.0   # or higher, if new versions are available on your distro
```
In vscode, press ctrl+p to open command pane, and run `ext install vadimcn.vscode-lldb`

I also recommend [MASM](https://marketplace.visualstudio.com/items?itemName=bltg-team.masm) syntax highlighting. 
Install using `ext install bltg-team.masm`

1. Open this folder in VS Code
2. Import or write some masm code
- Build current file using ctrl+shift+b
- Run current file using f5

## Known Issues (stolen from MASM_OSX)

* Can't have the first value in `.data` be uninitialized. See [here](https://github.com/janka102/MASM_OSX#known-issues) for more info