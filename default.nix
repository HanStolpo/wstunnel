{ mkDerivation, async, base, base64-bytestring, binary, bytestring
, classy-prelude, cmdargs, connection, hslogger, mtl, network
, network-conduit-tls, stdenv, streaming-commons, text
, unordered-containers, websockets
}:
mkDerivation {
  pname = "wstunnel";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    async base base64-bytestring binary bytestring classy-prelude
    connection hslogger mtl network network-conduit-tls
    streaming-commons text unordered-containers websockets
  ];
  executableHaskellDepends = [
    base bytestring classy-prelude cmdargs hslogger text
  ];
  testHaskellDepends = [ base text ];
  homepage = "https://github.com/githubuser/wstunnel#readme";
  description = "Initial project template from stack";
  license = stdenv.lib.licenses.bsd3;
}
