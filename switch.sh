#!/bin/sh
echo 'installing latest configuration.txt...'

sudo nixos-rebuild switch -I nixos-config=configuration.nix

