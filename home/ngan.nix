{
  osConfig,
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  syncthing = lib.getExe config.services.syncthing.package;
  folderId = "6nhkt-m4tcn";
  idFile = osConfig.sops.secrets.central_syncthing_id.path;

  setupIntroducer = pkgs.writeShellScript "syncthing-introducer-setup" ''
    set -eu
    export PATH=${
      lib.makeBinPath [
        pkgs.coreutils
        pkgs.gnugrep
      ]
    }:$PATH

    ID="$(cat ${idFile})"

    # wait for the Syncthing API to come up
    for _ in $(seq 1 30); do
      ${syncthing} cli show system >/dev/null 2>&1 && break
      sleep 2
    done

    # add the introducer device if it isn't there yet
    if ! ${syncthing} cli config devices list | grep -qx "$ID"; then
      ${syncthing} cli config devices add --device-id "$ID" --name central --introducer
    fi

    # share the folder with it if it isn't already
    if ! ${syncthing} cli config folders ${folderId} devices list | grep -qx "$ID"; then
      ${syncthing} cli config folders ${folderId} devices add --device-id "$ID"
    fi
  '';

  opencode-wrapped = pkgs.writeShellScriptBin "opencode" ''
    if ! XPROX_KEY="$(sudo cat "${osConfig.sops.secrets.xprox_key.path}")"; then
      echo "Error: Failed to read xprox_key" >&2
      exit 1
    fi

    export XPROX_KEY
    exec ${pkgs.opencode}/bin/opencode "$@"
  '';
in
{
  imports = [ inputs.nixcord.homeModules.nixcord ];

  home.packages = with pkgs; [
    nixd
    keepassxc
    fastfetch
    btop
    gcr_3
    protontricks
  ];

  programs.nixcord = {
    enable = true;
    discord.enable = false;

    vesktop = {
      enable = true;

      settings = {
        hardwareVideoAcceleration = true;
        staticTitle = true;
        customTitleBar = true;
        tray = false;
        minimizeToTray = false;
      };

      state = {
        firstLaunch = false;

        windowBounds = {
          x = 310;
          y = 214;
          width = 1325;
          height = 621;
        };

        maximized = false;
        minimized = false;
      };
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "NganPham334";
      user.email = "189833900+NganPham334@users.noreply.github.com";
      init.defaultBranch = "main";
      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };

  services.syncthing = {
    enable = true;
    cert = osConfig.sops.secrets.syncthing_cert.path;
    key = osConfig.sops.secrets.syncthing_key.path;

    overrideFolders = true;
    overrideDevices = false; # keep devices the introducer adds

    settings = {
      folders.${folderId} = {
        id = folderId;
        label = "Sink";
        path = "/home/ngan/Storage/Sink";
        devices = [ ]; # added by autostart after login
      };

      options = {
        urAccepted = 3;
        urSeen = 3;
      };
    };
  };

  systemd.user.services.syncthing-introducer-setup = {
    Unit = {
      Description = "Add Syncthing introducer";
      Wants = [ "syncthing.service" ];
      After = [
        "syncthing.service"
        "syncthing-init.service"
      ];
      PartOf = [ "syncthing.service" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true; # PartOf only restarts units that are active
      ExecStart = "${setupIntroducer}";
    };
    Install.WantedBy = [ "default.target" ];
  };

  services.ssh-agent.enable = true;

  systemd.user.services.ssh-agent.Service.Environment = [
    "SSH_ASKPASS=${pkgs.gcr_3}/libexec/gcr-ssh-askpass"
    "SSH_ASKPASS_REQUIRE=force"
  ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        identityFile = osConfig.sops.secrets.ngan_ssh_key.path;
        identitiesOnly = true;
        addKeysToAgent = "confirm";
      };
    };
  };

  programs.opencode = {
    enable = true;
    package = opencode-wrapped;

    settings = {
      model = "xprox/mimo-v2.6-pro";
      default_agent = "plan";

      agents = {
        plan.model = "xprox/mimo-v2.6-pro";
        build.model = "xprox/mimo-v2.6-pro";
      };

      providers.xprox = {
        name = "xprox";
        env = [ "XPROX_KEY" ];
        package = "aisdk:@ai-sdk/openai-compatible";
        settings = {
          baseURL = "http://openai-proxy.ddns.net:8080";
          apiKey = "{env:XPROX_KEY}";
        };
        models = {
          "mimo-v2.6-pro" = {
            name = "MiMo v2.6 Pro";
            capabilities = {
              tools = true;
              input = [
                "text"
                "image"
                "video"
                "audio"
              ];
              output = [ "text" ];
              reasoning = {
                supported = true;
                toggle = true;
                effort = [
                  "minimal"
                  "high"
                ];
              };
            };
            limit = {
              context = 1000000;
              output = 128000;
            };
          };

          "mimo-v2.6-flash" = {
            name = "MiMo v2.6 Flash";
            capabilities = {
              tools = true;
              input = [
                "text"
                "image"
                "video"
                "audio"
              ];
              output = [ "text" ];
              reasoning = {
                supported = true;
                toggle = true;
                effort = [
                  "minimal"
                  "high"
                ];
              };
            };
            limit = {
              context = 1000000;
              output = 128000;
            };
          };
        };
      };
    };
  };
}
