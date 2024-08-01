# shell.nix
let
  nixpkgs-src = builtins.fetchTarball {
    # unstable
    url = "https://github.com/NixOS/nixpkgs/archive/master.tar.gz";
  };

  pkgs = import nixpkgs-src {
    config = {
      # allowUnfree may be necessary for some packages, but in general you should not need it.
      allowUnfree = false;
    };
  };

  inherit (pkgs.stdenv) isDarwin isLinux;
  
  linuxDeps = [
      pkgs.libnotify # For ExUnit Notifier on Linux.
      pkgs.inotify-tools # For file_system on Linux.
    ];
  
  darwinDeps = [ pkgs.terminal-notifier ] # For ExUnit Notifier on macOS.
               ++ (with pkgs.darwin.apple_sdk.frameworks; [
                 # For file_system on macOS.
                 CoreFoundation
                 CoreServices
               ]);

  shell = pkgs.mkShell {
    
    buildInputs = with pkgs; [
      git
      elixir
    ] ++ (lib.optionals isLinux linuxDeps) ++ (lib.optionals isDarwin darwinDeps);
    
    shellHook = ''
      echo "installing pocproxy deps"
      mix deps.get
      mix compile
    '';
  };
in shell
