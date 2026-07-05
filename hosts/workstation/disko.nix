{
  diskDevice,
  hostName,
  ...
}:

let
  btrfsMountOptions = [
    "compress=zstd"
    "noatime"
    "ssd"
    "discard=async"
  ];
in
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = diskDevice;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0077"
                "dmask=0077"
              ];
            };
          };

          cryptroot = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true;
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "-L"
                  hostName
                ];
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = btrfsMountOptions;
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = btrfsMountOptions;
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = btrfsMountOptions;
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
