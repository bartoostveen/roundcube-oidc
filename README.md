# Roundcube OIDC

This plugin allows you to authenticate users to roundcube using an OpenID Connect 1.0 provider. There are three modes to run the plugin in:

1. **Cleartext Password**: The OIDC provider must supply the user's password in cleartext, which is then used to login to the IMAP server
2. **Master Password**: In this mode (also falls back to this), a master password is used to login to the IMAP server with the username obtained from OIDC
3. **Master User**: IMAP authentication is done using a master user ([Dovecot](https://doc.dovecot.org/configuration_manual/authentication/master_users/)) with a provided separator

Check [config.inc.php](./config.inc.php.dist) for more details on configuration.

## SMTP

Note that unless cleartext passwords are provided, SMTP must necessarily be configured to use no authentication or a master password.

## Installation

To install, get the plugin with Composer in your Roundcube directory.

```bash
composer require radialapps/roundcube-oidc
```

Alternatively, some releases may be available as [zipped packages](https://git.bartoostveen.nl/bart/roundcube-oidc/releases) on Forgejo. You need to unzip the package in your plugins directory and activate the plugin in the configuration.

On NixOS, you may install the plugin like this:

```nix
# flake.nix
{
  inputs.bart-packages = {
    url = "git+https://git.bartoostveen.nl/bart/nix-packages.git";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}

# configuration.nix
{
  services.roundcube = {
    enable = true;
    package = pkgs.roundcube.withPlugins (_: [ inputs.bart-packages.packages.${pkgs.stdenv.hostPlatform.system}.roundcube-oidc ]);
    plugins = [ "roundcube_oidc" ];
  };
}

# alternatively, including custom configuration:
{
  services.roundcube = {
    enable = true;
    package = pkgs.roundcube.withPlugins (_: [
      (
        inputs.bart-packages.packages.${pkgs.stdenv.hostPlatform.system}.roundcube-oidc.override {
          configText = ''
            <?php

            $config['oidc_imap_master_password'] =
            $config['oidc_master_user_separator'] =
            $config['oidc_config_master_user'] =
            $config['oidc_url'] =
            $config['oidc_logout_url'] =
            $config['oidc_client'] =
            $config['oidc_secret'] =
            $config['oidc_scope'] =
            $config['oidc_field_uid'] =
            $config['oidc_force'] =
          '';
        }
      )
    ]);
    plugins = [ "roundcube_oidc" ];
  };
}
```

## License

Permissively licensed under the [MIT license](./LICENSE).
