with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    imagemagick
    libwebp
  ];
}
