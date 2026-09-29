#!/usr/bin/env bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount --flake .#omega
sudo nixos-install --flake .#omega
