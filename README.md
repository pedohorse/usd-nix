A little flake for building pixar's USD library.

Some options are exposed, such as:

* `python` provides version of python you want
* `doUsdView` (defaults true) build usd view tool ?
* `doGl` (defaults true) build openGL related components ?
* `doPtex` (defaults false) build Ptex support (NOT TESTED, probably ptex library required)

Much more options are not yet exposed

## Building

just `nix build`

## TODO

[ ] expose more options
[ ] move <22.08 && glibc>3.34 patch into the flake
