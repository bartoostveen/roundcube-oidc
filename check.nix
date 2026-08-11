{ lib, ... }:

let
  hostName = "localhost";
in
{
  name = "roundcube-oidc";

  nodes.server = { pkgs, ... }: {
    services.roundcube = {
      enable = true;
      package = pkgs.roundcube.withPlugins (_: [ pkgs.roundcube-oidc ]);
      inherit hostName;
      plugins = [ "roundcube_oidc" ];
    };
    services.nginx.virtualHosts.${hostName} = {
      enableACME = false;
      forceSSL = false;
    };
    environment.systemPackages = [ pkgs.curl ];
  };

  testScript = ''
    start_all()
    with subtest("check if roundcube loads"):
        server.wait_for_unit("nginx.service")
        server.wait_for_unit("phpfpm-roundcube.service")
        server.wait_for_open_port(80)
        server.succeed("curl --fail http://${hostName}")
        server.succeed("curl --fail http://${hostName}?oidc=1")
  '';

  meta.maintainers = with lib.maintainers; [
    bartoostveen
  ];
}
