{ lib, stdenv, fetchurl
, cmake
, boost
, tbb
, libGLU
, python ? null
, opensubdiv 
, xorg
, libsForQt5
, doUsdView ? true
, doGl ? true
, doPtex ? false
}:

assert doUsdView -> doGl;

assert doUsdView -> (! isNull python);

stdenv.mkDerivation rec {
  pname = "Pixar-USD";
  version = "23.05";
  
  src = fetchurl {
    url = "https://github.com/PixarAnimationStudios/OpenUSD/archive/refs/tags/v${version}.tar.gz";
    sha256 = "sha256-9cPnLNWEurODqAVGKLbtmKoXscu+iW65glesGWQdEMc=";
  };

  nativeBuildInputs = 
  [ cmake ] ++ 
  (if doUsdView then [ libsForQt5.wrapQtAppsHook ] else []) ++
  (if ! isNull python then [ python.pkgs.wrapPython ] else []);

  buildInputs = [
    boost
    tbb
    opensubdiv
  ] ++ (if ! isNull python then [
    python
    python.pkgs.boost
  ] else []
  ) ++ (if doUsdView then [
    python.pkgs.pyside2-tools
  ] else []
  ) ++ (if doGl then [
    xorg.libX11
    libGLU
  ] else []
  );

  propagatedBuildInputs = if ! isNull python then (
    (if doGl then [ python.pkgs.pyopengl] else []) ++
    (if doUsdView then [ python.pkgs.pyside2 ] else []) ++
    [ python.pkgs.jinja2 ]
  ) else [];

  cmakeFlags = [
    # "-DPXR_ENABLE_GL_SUPPORT=FALSE"
    "-DPXR_BUILD_EXAMPLES=FALSE"
    "-DPXR_BUILD_TUTORIALS=FALSE"
    # "-DPXR_BUILD_IMAGING=FALSE"
    # "-DPXR_BUILD_USD_IMAGING=FALSE"
  ] ++ 
  (if isNull python then [
    "-DPXR_ENABLE_PYTHON_SUPPORT=FALSE"
  ] else []) ++
  (if ! doUsdView then [
    "-DPXR_BUILD_USDVIEW=FALSE"
  ] else []) ++
  (if ! doGl then [
    "-DPXR_ENABLE_GL_SUPPORT=FALSE"
    "-DPXR_BUILD_TESTS=FALSE"
    "-DPXR_BUILD_USD_IMAGING=FALSE"  # depends on GL
  ] else []) ++
  (if doPtex then [
    "-DPXR_ENABLE_PTEX_SUPPORT=TRUE"
  ] else [
    "-DPXR_ENABLE_PTEX_SUPPORT=FALSE"
  ]);

  postInstall = if ! isNull python then ''
    mkdir -p $(dirname $out/${python.sitePackages})
    mv $out/lib/python $out/${python.sitePackages}
  '' else "";

  dontWrapQtApps = true;

  postFixup = if ! isNull python then (''
    wrapPythonProgramsIn "$out/bin" "$out $pythonPath"
    ${if doUsdView then ''wrapQtApp "$out/bin/usdview"'' else ""}
  '') else "";
}
