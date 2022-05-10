with (import <nixpkgs> {});
let
  waifu2x = stdenv.mkDerivation rec {
    name = "waifu2x-${version}";
    version = "20220419";
    src = fetchurl {
      url = "https://github.com/nihui/waifu2x-ncnn-vulkan/releases/download/${version}/waifu2x-ncnn-vulkan-${version}-macos.zip";
      sha256 = "sha256-wzv7D4DKI3k2HC+hUB/I678kMNVFW5WMpY8Uw3bSLn8=";
    };
    buildInputs = [ unzip ];
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      unzip $src 
      cp -R waifu2x-ncnn-vulkan-${version}-macos/* $out/bin
    '';
  };
in
mkShell {
  buildInputs = [
    imagemagick
    libwebp
    waifu2x
  ];
}
