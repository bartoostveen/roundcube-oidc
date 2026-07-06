{
  lib,
  php,
}:

php.buildComposerProject2 (_finalAttrs: {
  pname = "roundcube-oidc";
  version = "unstable";

  src = ./.;

  vendorHash = "sha256-n6xV5LIAyquQr1HsPJa5j/Mb9OVUW+101+hvpFbffO8=";
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
