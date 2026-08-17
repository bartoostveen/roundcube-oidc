{
  lib,
  php,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "roundcube-oidc";
  version = "unstable";

  src = lib.cleanSourceWith {
    src = ./.;
    name = "source";
    filter =
      path: type: type == "regular" && builtins.match ".*(\\.php.*|composer\\.(json|lock))" path != null;
  };

  vendorHash = "sha256-3f+atrbA2ZEo4Qupg6f0On5YREqiplSMmYhOBI/2sZA=";
  composerStrictValidation = false;

  installPhase = ''
    mkdir -p $out/plugins/roundcube_oidc
    cp -R * $out/plugins/roundcube_oidc/
  '';

  meta = {
    description = "OpenID Connect authentication plugin for Roundcube";
    homepage = "https://git.bartoostveen.nl/bart/roundcube-oidc";
    changelog = "https://git.bartoostveen.nl/bart/roundcube-oidc/src/tag/v${finalAttrs.version}/CHANGELOG.md";
    maintainers = with lib.maintainers; [ bartoostveen ];
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
