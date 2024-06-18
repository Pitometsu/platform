# Platform

Platform API implementation as a test challenge.

## Usage:

``` sh
# Get Nix, see: https://nixos.org/download/
curl https://nixos.org/nix/install | sh
. ~/.nix-profile/etc/profile.d/nix.sh
# Enable flakes, see: https://nixos.wiki/wiki/Flakes
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
# Open development environment
nice nix-shell --pure -Q
```

In case of troubles with local DB creating, try

``` sh
rm -Rf .db ; pkill postgres
```

and restart the `nix-shell`.


## Build:

```sh
nix run
```

## Run:

```sh
nix run
```

****

## Test example:

```sh
curl -sw '%{http_code}\n' -X POST -s http://localhost:8080/open-api-games/v1/games-processor -H "Content-Type: application/json" -d '{ "api":"balance", "data": {} }'

{"api":"balance","data":{"userNick":"userNick","amount":0,"denomination":0,"maxWin":0,"currency":"currency","userId":"userId","jpKey":"jpKey"}}
200
```
