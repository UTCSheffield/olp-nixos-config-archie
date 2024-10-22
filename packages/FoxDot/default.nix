{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  tkinter,
  supercollider,
}:

buildPythonPackage rec {
  pname = "foxdot";
  version = "v0.8.12";

  src = fetchFromGitHub {
    owner = "UTCSheffield";
    repo = "FoxDot";
    rev = "v0.8.12";
    sha256 = "sha256-WgbmablVUPSp/1h1E1A56kfV1CwWsS5cPzzUp/HZHjU=";
  };

  propagatedBuildInputs =
    [ tkinter ]
    # we currently build SuperCollider only on Linux
    # but FoxDot is totally usable on macOS with the official SuperCollider binary
    ++ lib.optionals stdenv.hostPlatform.isLinux [ supercollider ];

  # Requires a running SuperCollider instance
  doCheck = false;

  meta = with lib; {
    description = "Live coding music with SuperCollider";
    mainProgram = "FoxDot";
    homepage = "https://foxdot.org/";
    license = licenses.cc-by-sa-40;
    maintainers = with maintainers; [ mrmebelman ];
  };
}