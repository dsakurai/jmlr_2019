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
        python312
        # python312Packages.pytorch-bin # for pytorch from nixpkgs, tested with WSL2 (with CUDA) and podman, where the podman machine has NVIDIA's nvidia's container toolkit installed.
        
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

          poetry config virtualenvs.in-project true
          poetry install --no-root

          export JUPYTER_CONFIG_DIR="$(pwd)/.jupyter"

          eval $(poetry env activate)
        '';

    };
  };
  
}

