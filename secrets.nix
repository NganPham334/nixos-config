{ ... }:

{
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      hashed_ngan = {
        neededForUsers = true;
      };

      ngan_ssh_key = {
        owner = "ngan";
        mode = "0400";
      };

      syncthing_cert.owner = "ngan";
      syncthing_key.owner = "ngan";
      central_syncthing_id.owner = "ngan";

      xprox_key = { };
    };
  };

  environment.shellAliases.sops-host = "SOPS_AGE_KEY=$(sudo cat /etc/ssh/ssh_host_ed25519_key | ssh-to-age -private-key) sops";
}
