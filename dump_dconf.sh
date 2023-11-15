#!/bin/sh
# dump dconf settings and persist with nix

dconf dump / | dconf2nix > dconf.nix
