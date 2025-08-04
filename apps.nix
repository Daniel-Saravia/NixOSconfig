{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    nodejs_22
    vscode-fhs
    google-chrome
    blender
    libsecret
    libgnome-keyring

    (writeScriptBin "disable-kwallet" ''
      #!${pkgs.bash}/bin/bash
      mkdir -p ~/.config
      cat > ~/.config/kwalletrc << EOF
      [Wallet]
      Enabled=false
      First Use=false
      EOF
      echo "KWallet has been disabled"
    '')
  ];
}
