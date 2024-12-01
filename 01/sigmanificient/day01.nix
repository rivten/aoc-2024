let
  nixpkgs-tarball = rev:
    fetchTarball "https://github.com/NixOS/nixpkgs/tarball/${rev}";
  pkgs = import (nixpkgs-tarball  "nixos-24.11") { };

  inherit (pkgs.lib) strings lists trivial attrsets;
  inherit (builtins) readFile map mapAttrs filter length;

in let
  # split, without the empty string at the end
  split = sep: lst: filter (e: e != "") (strings.splitString sep lst);

  # accumulate the result of a function on every element on a list
  accMap = op: lst: lists.foldl (x: y: x + (op y)) 0 lst;

  # merge a list of attrset:
  # [ {a = 1; b = 1; } { b = 1; } ] => { a = [ 1 2 ]; b = [ 1 ]}
  mergeAttrs = attrs: lists.foldl (a: b: trivial.mergeAttrs a b) {} attrs;

in let
  lines = strings.splitString "\n" (readFile ./input);

 # Identify column with their id: [{ col_1: val } { col_2: val } ... ]
 identifyColumns = line:
    lists.imap1
      (i: v: {"col_${toString i}" = strings.toInt v; })
      (split " " line);

  cols = mapAttrs
    (k: v: lists.sort (a: b: a < b) v)
    (attrsets.zipAttrs (map mergeAttrs (map identifyColumns lines)));

in {
  part1 = accMap
    (x: if x > 0 then x else -x)
    (lists.zipListsWith (x: y: y - x) cols.col_1 cols.col_2);

  part2 = accMap
    (e: e * length (filter (x: x == e) cols.col_2))
    cols.col_1;
}
