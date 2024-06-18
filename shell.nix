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
, mkGoEnv ? pkgs.mkGoEnv
, gomod2nix ? pkgs.gomod2nix
, setupDB ? true
}:

let
  src = builtins.toString ./.;
  goEnv = mkGoEnv { pwd = ./.; };
in
pkgs.mkShell rec {
  packages = [
    goEnv
    gomod2nix
  ] ++ (with pkgs; [
    postgresql
    gopls gosec delve go-tools gotests gomodifytags
    wget gnupg coreutils
    which less curl ripgrep
    gitMinimal openssh man-db
  ]);

  PGHOST = "${src}/.db";
  PGPORT = "5432";
  PGDATA = "${PGHOST}/pgdata";
  LOG_PATH = "${PGHOST}/log";
  PGDATABASE = "platform";
  PGUSER = "platform_user";
  PGADMIN = builtins.getEnv "USER";
  DATABASE_URL = "postgresql:///postgres?host=${PGHOST}";

  LANG = "C.UTF-8";
  LC_ALL = "C.UTF-8";

  DB_HOST = PGHOST;
  DB_PORT = PGPORT;
  DB_PASSWORD = "";
  DB_USER = PGUSER;
  DB_NAME = PGDATABASE;

  NIX_PATH = builtins.getEnv "NIX_PATH";
  NIX_PROFILES = builtins.getEnv "NIX_PROFILES";
  NIX_SSL_CERT_FILE = builtins.getEnv "NIX_SSL_CERT_FILE";

  GIT_SSL_CAINFO = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

  shellHook = ''
    ulimit -Sv 52428800
    ulimit -v 104857600

    export PAGER='less -R'

    # PostrgeSQL
    psql () { command psql -h "${PGHOST}" -p "${PGPORT}" "$@"; }
    createdb () { command createdb -h "${PGHOST}" -p "${PGPORT}" "$@"; }
    dropdb () { command dropdb -h "${PGHOST}" -p "${PGPORT}" "$@"; }
    createuser () { command createuser -h "${PGHOST}" -p "${PGPORT}" "$@"; }
    pg_ctl () { command pg_ctl -l "${LOG_PATH}/postgres.log" "$@"; }

    # Interactive shell case
    if [ "$PWD" != "$NIX_BUILD_TOP" ] && [ "${builtins.toString setupDB}" ]
    then
      "${src}"/scripts/setup_pg.sh "${PGADMIN}" "${PGHOST}" "${PGPORT}" \
        "${PGDATA}" "${LOG_PATH}" && \
      "${src}"/scripts/create_db.sh "${PGADMIN}" "${PGUSER}" \
        "${PGDATABASE}" && \
      "${src}"/scripts/migrate_schema.sh "${PGADMIN}" || true
    fi
  '';
}
