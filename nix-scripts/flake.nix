{
  description = "A Nix flake to use poetry";


  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }: {
    defaultPackage.x86_64-linux = let
      pkgs = import nixpkgs {
         system = "x86_64-linux";
         config = {
           allowUnfree = true;
           # cudaSupport = true;
           # cudaVersion = "12.6"; # Some packages like nix's torch respect this, others not... I'm not sure about the version number format.
         };
      };
    in pkgs.mkShell {
      buildInputs = with pkgs; [
        # python39
        # python312Packages.pytorch-bin # for pytorch from nixpkgs, tested with WSL2 (with CUDA) and podman, where the podman machine has NVIDIA's nvidia's container toolkit installed.
        
        python3Packages.pip # Needed for installing python with pyenv
        zlib libffi readline bzip2 openssl ncurses sqlite
        # tk xorg.libX11 xorg.libXft # tkinter for Python
        xz
        # glibcLocales
        pyenv

        # Use CUDA like below in shellHook:
        # export LD_LIBRARY_PATH="${pkgs.cudaPackages_12_6.cudatoolkit.lib}/lib:${pkgs.cudaPackages_12_6.libcublas.lib}/lib:$LD_LIBRARY_PATH"
        # cudaPackages_12_6.cuda_nvcc # You can check the CUDA version with `nvcc --version`, for example.

        poetry # <- Uses Nix's system default python by default
      ];

      shellHook = ''
          # Pass the libraries (to poetry's virtual environment for using Python packages)
          export "LD_LIBRARY_PATH=${pkgs.gcc.cc.lib}/lib:$LD_LIBRARY_PATH" # Used by torch
          
          # Find libcuda for WSL
          CUDA_PATH=$(find /usr/lib/wsl/drivers -name 'libcuda.so.*' | head -n1)
          if [ -n "$CUDA_PATH" ]; then
            export LD_LIBRARY_PATH="$(dirname "$CUDA_PATH"):$LD_LIBRARY_PATH"
            export LD_LIBRARY_PATH="/usr/lib/wsl/lib:$LD_LIBRARY_PATH"
            echo "[INFO] Found libcuda at $CUDA_PATH"
          else
            echo "[WARN] libcuda.so not found"
          fi

          # For installing Python with pyenv
          # export CPPFLAGS="-I${pkgs.zlib.dev}/include -I${pkgs.libffi.dev}/include -I${pkgs.readline.dev}/include -I${pkgs.bzip2.dev}/include -I${pkgs.openssl.dev}/include -I${pkgs.xz.dev}/include -I${pkgs.sqlite.dev}/include";
          # export CXXFLAGS="-I${pkgs.zlib.dev}/include -I${pkgs.libffi.dev}/include -I${pkgs.readline.dev}/include -I${pkgs.bzip2.dev}/include -I${pkgs.openssl.dev}/include -I${pkgs.xz.dev}/include -I${pkgs.sqlite.dev}/include";
          # export CFLAGS="-I${pkgs.openssl.dev}/include";
          # export LDFLAGS="-L${pkgs.zlib.out}/lib -L${pkgs.libffi.out}/lib -L${pkgs.readline.out}/lib -L${pkgs.bzip2.out}/lib -L${pkgs.openssl.out}/lib  -I${pkgs.xz.out}/lib -L${pkgs.sqlite.out}/lib";
          # export CONFIGURE_OPTS="--with-openssl=${pkgs.openssl.dev}";

          #echo lz:
          #ls ${pkgs.xz.dev}/include/lzma.h
          #ls ${pkgs.xz.out}/lib/liblzma.so

  export LANG="C"
  export LC_ALL="C"
  # export LC_CTYPE="en_US.UTF-8"
  # export LOCALE_ARCHIVE="${pkgs.glibcLocales}/lib/locale/locale-archive"

  export CPPFLAGS="-I${pkgs.zlib.dev}/include \
                   -I${pkgs.libffi.dev}/include \
                   -I${pkgs.readline.dev}/include \
                   -I${pkgs.bzip2.dev}/include \
                   -I${pkgs.openssl.dev}/include \
                   -I${pkgs.sqlite.dev}/include \
                   -I${pkgs.xz.dev}/include \
                   -I${pkgs.tk.dev}/include \
                   "

  export LDFLAGS="-L${pkgs.zlib.out}/lib \
                  -L${pkgs.libffi.out}/lib \
                  -L${pkgs.readline.out}/lib \
                  -L${pkgs.bzip2.out}/lib \
                  -L${pkgs.openssl.out}/lib \
                  -L${pkgs.sqlite.out}/lib \
                  -L${pkgs.xz.out}/lib \
                  -L${pkgs.tk.out}/lib \
                  "

  export CONFIGURE_OPTS="--with-openssl=${pkgs.openssl.dev}"

          pyenv install --skip-existing 3.8.20

          export PYENV_ROOT="$HOME/.pyenv"
          [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
          eval "$(pyenv init - /nix/store/xg75pc4yyfd5n2fimhb98ps910q5lm5n-bash-5.2p37/bin/bash)"

          pyenv shell 3.8.20

          poetry env use $(pyenv which python)

          poetry config virtualenvs.in-project true
          poetry install --no-root

          export JUPYTER_CONFIG_DIR="$(pwd)/.jupyter"

          eval $(poetry env activate)
        '';

    };
  };
  
}

