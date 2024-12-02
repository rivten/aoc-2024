#!/usr/bin/env -S nix eval -f
let
  nixpkgs-tarball = rev:
    fetchTarball "https://github.com/NixOS/nixpkgs/tarball/${rev}";
  pkgs = import (nixpkgs-tarball "nixos-24.11") { };

  inherit (pkgs.lib) strings lists;
  inherit (builtins) readFile map filter length;

in let
  abs = x: if x > 0 then x else -x;

  listWithout = lst: n: (lists.take n lst) ++ (lists.drop (n + 1) lst);

  split = sep: lst: filter (e: e != "") (strings.splitString sep lst);

  zipSelf = func: lst: lists.zipListsWith func
    (lists.take (length lst - 1) lst) (lists.drop 1 lst);

in let
  lines = split "\n" (readFile ./input);
  values = map (line: map strings.toInt (strings.splitString " " line)) lines;

  inRange = x: x != 0 && (abs x) <= 3;
  hasSameSign = lst: (lists.all (x: x < 0) lst) || (lists.all (x: x > 0) lst);

  isSafe = vals: let
    diffs = zipSelf (a: b: b - a) vals;
  in (lists.all inRange diffs) && (hasSameSign diffs);

  isSafeWithTolerance = vals: let
    iterator = n:
      if n < 0 then false
      else (isSafe (listWithout vals n)) || (iterator (n - 1));
  in iterator (length vals - 1);

in {
  part1 = lists.count isSafe values;
  part2 = lists.count isSafeWithTolerance values;
}
