# Development machines: the toolchain on top of modules/common.nix.
{ pkgs, llm-agents, ... }:

{
  environment.systemPackages = with pkgs; [
    fastfetch
    gh

    # Editors
    neovim

    # C/C++ toolchain
    gcc
    clang-tools
    cmake
    gnumake
    ninja
    gdb

    postgresql

    # Neovim tools
    ripgrep
    fd
    nodejs
    unzip
    tree-sitter

    claude-code

    #llm-agents.packages.x86_64-linux.herdr
  ];
}
