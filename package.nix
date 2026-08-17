{
  lib,
  php,
}:

php.buildComposerProject2 (_finalAttrs: {
  pname = "roundcube-oidc";
  version = "unstable";

  src = lib.cleanSourceWith {
    src = ./.;
    name = "source";
    filter =
      path: type: type == "regular" && builtins.match ".*(\\.php.*|composer\\.(json|lock))" path != null;
  };

  vendorHash = "sha256-AaR8qSRGPOeAqrrhqLlFGKKCYn0U9kpRX5rsYTSmxWo=";
  composerStrictValidation = false;

  installPhase = ''
    mkdir -p $out/plugins/roundcube_oidc
    cp -R * $out/plugins/roundcube_oidc/
  '';

  meta = {
    description = "OpenID Connect authentication plugin for Roundcube";
    homepage = "https://git.bartoostveen.nl/bart/roundcube-oidc";
    license = lib.licenses.mit;
    mainProgram = "roundcube-oidc";
    platforms = lib.platforms.all;
  };
})
