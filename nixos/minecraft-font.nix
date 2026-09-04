{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation {
  pname = "minecraft-font";
  version = "2026-09-04";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/IdreesInc/Minecraft-Font/main/Minecraft.otf";
    hash = "sha256-68envp9pR58Ch1rx/nmiuTzIaLg75PY2nszrRfq+XuY=";
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm644 "$src" "$out/share/fonts/opentype/Minecraft.otf"
  '';

  meta = {
    description = "Open-source Minecraft-inspired display font";
    homepage = "https://github.com/IdreesInc/Minecraft-Font";
    license = stdenvNoCC.lib.licenses.ofl;
  };
}
