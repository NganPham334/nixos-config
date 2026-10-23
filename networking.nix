{ ... }:

{
  networking.hostName = "nixos";

  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [
        "1.1.1.1#cloudflare-dns.com"
        "1.0.0.1#cloudflare-dns.com"
      ];
      Domains = [ "~." ];
      DNSOverTLS = "true";
      DNSSEC = "allow-downgrade";
    };
  };

  services.zapret2 = {
    enable = true;

    profiles = {
      http = {
        parameters = [
          "--filter-tcp=80"
          "--payload=http_req"
          "--lua-desync=multidisorder:pos=1"
        ];
      };

      https = {
        parameters = [
          "--filter-tcp=443"
          "--payload=tls_client_hello"
          "--lua-desync=multidisorder:pos=1"
        ];
      };

      quic = {
        parameters = [
          "--filter-udp=443"
          "--payload=quic_initial"
          "--lua-desync=fake"
        ];
      };
    };
  };
}
