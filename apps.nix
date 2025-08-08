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
  ];
}
