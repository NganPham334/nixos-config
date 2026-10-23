{ pkgs, ... }:
let
  # stock layout minus panel-2 and its plugins (11-18)
  panelDefault =
    pkgs.runCommand "xfce4-panel-default.xml" { nativeBuildInputs = [ pkgs.xmlstarlet ]; }
      ''
        xmlstarlet ed \
          -d '//property[@name="panels"]/value[@value="2"]' \
          -d '//property[@name="panels"]/property[@name="panel-2"]' \
          -d '//property[@name="plugins"]/property[number(substring-after(@name,"plugin-")) >= 11]' \
          \
          -a '//property[@name="panel-1"]/property[@name="plugin-ids"]/value[@value="7"]' \
             -t elem -n newvalue -v "" \
          -i '//newvalue' -t attr -n type  -v int \
          -i '//newvalue' -t attr -n value -v 11 \
          -r '//newvalue' -v value \
          \
          -s '//property[@name="plugins"]' -t elem -n newplugin -v "" \
          -i '//newplugin' -t attr -n name  -v plugin-11 \
          -i '//newplugin' -t attr -n type  -v string \
          -i '//newplugin' -t attr -n value -v pulseaudio \
          -r '//newplugin' -v property \
          ${pkgs.xfce4-panel}/etc/xdg/xfce4/panel/default.xml > $out

        # fail the build if the deletion didn't work
        if grep -q 'panel-2' $out; then echo "panel-2 still present" >&2; exit 1; fi
        grep -q 'value="pulseaudio"' $out || { echo "pulseaudio plugin missing" >&2; exit 1; }
      '';
in
{
  programs.firefox.enable = true;

  xfconf.settings = {

    displays = {
      "ActiveProfile" = "Default";
      "Default/HDMI-1" = "Acer 24\"";
      "Default/HDMI-1/Active" = true;
      "Default/HDMI-1/EDID" = "5980c187d56c2f8f8db565d9eab38aaef15d5bf5";
      "Default/HDMI-1/DuplicateEDID" = false;
      "Default/HDMI-1/Resolution" = "1920x1080";
      "Default/HDMI-1/RefreshRate" = 120.0;
      "Default/HDMI-1/ModeFlags" = 5;
      "Default/HDMI-1/Rotation" = 0;
      "Default/HDMI-1/Reflection" = "0";
      "Default/HDMI-1/Primary" = false;
      "Default/HDMI-1/Scale" = 1.0;
      "Default/HDMI-1/Position/X" = 0;
      "Default/HDMI-1/Position/Y" = 0;
    };

    xsettings = {
      "Net/ThemeName" = "Adwaita-dark";
      "Net/IconThemeName" = "Rodent"; # theme package must be installed
    };

    xfce4-power-manager = {
      "xfce4-power-manager/dpms-on-ac-sleep" = 0;
      "xfce4-power-manager/dpms-on-ac-off" = 4;
      "xfce4-power-manager/show-tray-icon" = true;
    };

    xfwm4 = {
      "general/wrap_windows" = false;
      "general/activate_action" = "switch";
    };

    # flat accel profile = no mouse acceleration (libinput takes [adaptive flat])
    pointers = {
      "Logitech_USB_Optical_Mouse/Properties/libinput_Accel_Profile_Enabled" = [
        0
        1
      ];
    };

    xfce4-desktop = {
      "desktop-icons/file-icons/show-removable" = false;
    };

    thunar = {
      "last-view" = "ThunarDetailsView";
      "last-icon-view-zoom-level" = "THUNAR_ZOOM_LEVEL_100_PERCENT";
      "last-details-view-zoom-level" = "THUNAR_ZOOM_LEVEL_38_PERCENT";
      "last-details-view-column-widths" = "50,50,277,50,50,50,50,50,333,50,50,72,50,141";
      "last-details-view-visible-columns" =
        "THUNAR_COLUMN_DATE_MODIFIED,THUNAR_COLUMN_NAME,THUNAR_COLUMN_SIZE";

      "last-window-width" = 853;
      "last-window-height" = 584;
      "last-window-maximized" = false;
      "last-separator-position" = 170;
    };

    xfce4-screensaver = {
      "saver/enabled" = false;
      "lock/saver-activation/enabled" = false;
    };
  };

  xdg.configFile."xfce4/panel/default.xml".source = panelDefault;

  xdg.configFile."autostart/fcitx5-toggle-shortcut.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=fcitx5 toggle shortcut
    Exec=sh -c "sleep 5 && xfconf-query -c xfce4-keyboard-shortcuts -n -t string -p '/commands/custom/<Primary>space' -s 'fcitx5-remote -t'"
  '';

  home.stateVersion = "26.05";
}
