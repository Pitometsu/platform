{ pkgs ? (
    let
      inherit (builtins) fetchTree fromJSON readFile;
      inherit ((fromJSON (readFile ./flake.lock)).nodes) nixpkgs gomod2nix;
    in
    import (fetchTree nixpkgs.locked) {
      overlays = [
        (import "${fetchTree gomod2nix.locked}/overlay.nix")
      ];
    }
  )
, buildGoApplication ? pkgs.buildGoApplication
}:

buildGoApplication {
  pname = "platform";
  version = "0.1";
  pwd = ./.;
  src = pkgs.lib.cleanSourceWith {
      filter = p: t:
        let n = builtins.baseNameOf p;
        in n != ".db"
        && n != "result"
        && n != "scripts";
      src = ./.;
    };
  modules = ./gomod2nix.toml;
}
