{
  description = "Zack's nixCats config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    # Plugins missing from nixpkgs can be added as inputs named "plugins-<name>"
    # (with flake = false); they then appear as pkgs.neovimPlugins.<name>.
    # See :help nixCats.flake.inputs
    # "plugins-hlargs" = { url = "github:m-demare/hlargs.nvim"; flake = false; };
  };

  # see :help nixCats.flake.outputs
  outputs = { self, nixpkgs, ... }@inputs: let
    inherit (inputs.nixCats) utils;
    luaPath = "${./.}";
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;

    # Config passed to the nixpkgs used to build nvim (e.g. allowUnfree).
    extra_pkg_config = {
      # allowUnfree = true;
    };

    # Overlays applied to that nixpkgs. standardPluginOverlay exposes any
    # "plugins-<name>" inputs as pkgs.neovimPlugins.<name>.
    # see :help nixCats.flake.outputs.overlays
    dependencyOverlays = [
      (utils.standardPluginOverlay inputs)
    ];

    # Defines every category (plugins, deps, env) that packages can switch on.
    # see :help nixCats.flake.outputs.categoryDefinitions.scheme
    categoryDefinitions = { pkgs, settings, categories, extra, name, mkPlugin, ... }@packageDef: let
      # dudraw: a PyPI package (not in nixpkgs) for the `python` category.
      dudraw = pkgs.python3Packages.buildPythonPackage rec {
        pname = "dudraw";
        version = "1.10.1";
        pyproject = true;
        src = pkgs.fetchPypi {
          inherit pname version;
          sha256 = "sha256-NQCoqOBokjw30XVW2xoSynnTIpm+kifblXFatFhZ8V8=";
        };
        nativeBuildInputs = [ pkgs.python3Packages.hatchling ];
        propagatedBuildInputs = [ pkgs.python3Packages.pygame ];
      };
      python3WithDudraw = pkgs.python3.withPackages (ps: [ dudraw ps.pygame ]);
    in {
      # Each attribute below is a category. A category is "on" for a package
      # when that package's `categories` set marks it true (see packageDefinitions).
      # Category names are arbitrary; the lua side queries them via nixCats('name').
      # see :help nixCats.flake.outputs.categoryDefinitions.scheme

      # Binaries available on PATH at runtime (LSPs, linters, formatters, tools).
      lspsAndRuntimeDeps = {
        general = with pkgs; [
          universal-ctags
          ripgrep
          fd
        ];
        lint = with pkgs; [
          markdownlint-cli
          statix
        ];
        debug = with pkgs; {
          go = [ delve ];
        };
        go = with pkgs; [
          gopls
          gotools
          go-tools
          gccgo
        ];
        rust = with pkgs; [
          rust-analyzer
          cargo
          rustc
          rustfmt
          clippy
        ];
        python = with pkgs; [
          pyright
          ruff
        ];
        c = with pkgs; [
          clang-tools
        ];
        format = with pkgs; [
          stylua
          prettierd
        ];
        latex = with pkgs; [
          texlab
          zathura
        ];
        # inherit (pkgs) ... makes each name its own sub-category dependency.
        neonixdev = {
          inherit (pkgs) nix-doc lua-language-server nixd;
        };
      };

      # Plugins loaded at startup (no packadd). Categories may nest into
      # subcategories (e.g. general.always); the names are arbitrary.
      startupPlugins = {
        debug = with pkgs.vimPlugins; [
          nvim-nio
        ];
        general = with pkgs.vimPlugins; {
          always = [
            lze
            lzextras
            vim-repeat
            plenary-nvim
            nvim-notify
            direnv-vim
          ];
          extra = [
            oil-nvim
            harpoon2
            nvim-web-devicons
            alpha-nvim
          ];
        };
        # Picks the colorscheme plugin from the `colorscheme` setting in
        # packageDefinitions, without needing a dedicated category.
        themer = with pkgs.vimPlugins;
          (builtins.getAttr (categories.colorscheme or "onedark") {
              "onedark" = onedark-nvim;
              "catppuccin" = catppuccin-nvim;
              "catppuccin-mocha" = catppuccin-nvim;
              "tokyonight" = tokyonight-nvim;
              "tokyonight-day" = tokyonight-nvim;
              "tokyonight-night" = tokyonight-nvim;
              "kanagawa" = kanagawa-nvim;
            }
          );
      };

      # Lazy-loaded plugins (added via packadd by lze). Run `:NixCats pawsible`
      # to see the names packadd expects.
      optionalPlugins = {
        debug = with pkgs.vimPlugins; {
          # debug.default is auto-enabled with any debug.* via extraCats below.
          default = [
            nvim-dap
            nvim-dap-ui
            nvim-dap-virtual-text
          ];
          go = [ nvim-dap-go ];
        };
        lint = with pkgs.vimPlugins; [
          nvim-lint
        ];
        format = with pkgs.vimPlugins; [
          conform-nvim
        ];
        markdown = with pkgs.vimPlugins; [
          markdown-preview-nvim
        ];
        obsidian = with pkgs.vimPlugins; [
          obsidian-nvim
          render-markdown-nvim
        ];
        latex = with pkgs.vimPlugins; [
          vimtex
        ];
        neonixdev = with pkgs.vimPlugins; [
          lazydev-nvim
        ];
        general = {
          blink = with pkgs.vimPlugins; [
            luasnip
            cmp-cmdline
            blink-cmp
            blink-compat
            colorful-menu-nvim
          ];
          treesitter = with pkgs.vimPlugins; [
            nvim-treesitter-textobjects
            nvim-treesitter.withAllGrammars
            # This is for if you only want some of the grammars
            # (nvim-treesitter.withPlugins (
            #   plugins: with plugins; [
            #     nix
            #     lua
            #   ]
            # ))
          ];
          telescope = with pkgs.vimPlugins; [
            telescope-fzf-native-nvim
            telescope-ui-select-nvim
            telescope-nvim
          ];
          always = with pkgs.vimPlugins; [
            nvim-lspconfig
            lualine-nvim
            gitsigns-nvim
            vim-sleuth
            vim-fugitive
            vim-rhubarb
            nvim-surround
          ];
          extra = with pkgs.vimPlugins; [
            fidget-nvim
            which-key-nvim
            comment-nvim
            undotree
            indent-blankline-nvim
            vim-startuptime
          ];
        };
      };

      # Shared libraries added to LD_LIBRARY_PATH at runtime, by category.
      sharedLibraries = {
        general = with pkgs; [
          # libgit2
        ];
      };

      # Environment variables exported at runtime, by category.
      environmentVariables = {
        test = {
          default = {
            CATTESTVARDEFAULT = "It worked!";
          };
          subtest1 = {
            CATTESTVAR = "It worked!";
          };
          subtest2 = {
            CATTESTVAR3 = "It didn't work!";
          };
        };
      };

      # Extra args appended to the neovim wrapper (makeWrapper syntax), by category.
      extraWrapperArgs = {
        test = [
          '' --set CATTESTVAR2 "It worked again!"''
        ];
      };

      # python3.withPackages functions, by category. Needs hosts.python3.enable.
      # Reachable from lua via vim.g.python3_host_prog.
      python3.libraries = {
        test = (_:[]);
        python = (_: [ dudraw ]);
      };
      # lua.withPackages functions ($LUA_PATH / $LUA_CPATH), by category.
      extraLuaPackages = {
        general = [ (_:[]) ];
      };

      # Auto-enable a subcategory whenever any sibling subcategory is on, e.g.
      # any debug.* turns on debug.default. Each entry is a list of paths.
      # WARNING: do not read the `categories` arg here (infinite recursion).
      # see :help nixCats.flake.outputs.categoryDefinitions.default_values
      extraCats = {
        test = [
          [ "test" "default" ]
        ];
        debug = [
          [ "debug" "default" ]
        ];
        go = [
          [ "debug" "go" ] # must be a list of lists
        ];
      };
    };

    # A package = a set of categories turned on. The whole set is also handed to
    # the lua side for nixCats('...') queries.
    # see :help nixCats.flake.outputs.packageDefinitions
    packageDefinitions = {
      # Package name = default launch command.
      nvim = { pkgs, name, ... }@misc: {
        settings = {
          suffix-path = true;
          suffix-LD = true;
          # `aliases` must not collide with other binaries on PATH, or the
          # nixos/home-manager modules fail the build on the collision.
          aliases = [ "vim" "vimcat" ];

          # wrapRc = true bakes this config into the package (it ignores ~/.config).
          wrapRc = true;
          configDirName = "nixCats-nvim";
          hosts.python3.enable = true;
          hosts.node.enable = true;
        };
        # Categories enabled for this package (false ones may be omitted).
        categories = {
          markdown = true;
          obsidian = true;
          latex = true;
          general = true;
          lint = true;
          format = true;
          neonixdev = true;
          test = {
            subtest1 = true;
          };

          rust = true;
          python = true;
          c = true;

          # go is off here; enabling it would also pull in debug.go + debug.default.
          # go = true;

          # No plugins attached, but queryable from lua via nixCats('lspDebugMode').
          lspDebugMode = false;
          themer = true;
          colorscheme = "kanagawa";
        };
        # `extra` carries non-category values that lua can still read.
        extra = {
          nixdExtras = {
            nixpkgs = ''import ${pkgs.path} {}'';
          };
        };
      };
    };

    # Default package built by `nix build`, and the module namespace for the
    # exported nixos/home-manager modules.
    defaultPackageName = "nvim";
  in
  # Standard nixCats exports — rarely need to touch below here.
  # see :help nixCats.flake.outputs.exports
  forEachSystem (system: let
    # Builder: takes a packageDefinitions name and produces an nvim.
    nixCatsBuilder = utils.baseBuilder luaPath {
      inherit nixpkgs system dependencyOverlays extra_pkg_config;
    } categoryDefinitions packageDefinitions;
    defaultPackage = nixCatsBuilder defaultPackageName;

    # Only for utils like pkgs.mkShell here; nvim itself is built with the
    # pkgs resolved inside the builder.
    pkgs = import nixpkgs { inherit system; };
  in {
    # Outputs here are wrapped with ${system}.
    packages = utils.mkAllWithDefault defaultPackage;

    devShells = {
      default = pkgs.mkShell {
        name = defaultPackageName;
        packages = [ defaultPackage ];
        inputsFrom = [ ];
        shellHook = ''
        '';
      };
    };

  }) // (let
    # nixos + home-manager modules, for installing this nvim from a system config.
    nixosModule = utils.mkNixosModules {
      moduleNamespace = [ defaultPackageName ];
      inherit defaultPackageName dependencyOverlays luaPath
        categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
    };
    homeModule = utils.mkHomeModules {
      moduleNamespace = [ defaultPackageName ];
      inherit defaultPackageName dependencyOverlays luaPath
        categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
    };
  in {
    # Outputs here are NOT wrapped with ${system}.
    # One overlay per package; default is named by defaultPackageName.
    overlays = utils.makeOverlays luaPath {
      inherit nixpkgs dependencyOverlays extra_pkg_config;
    } categoryDefinitions packageDefinitions defaultPackageName;

    nixosModules.default = nixosModule;
    homeModules.default = homeModule;

    inherit utils nixosModule homeModule;
    inherit (utils) templates;
  });

}
