{ config, lib, pkgs, ... }:

let
  mt7630eBt = config.boot.kernelPackages.callPackage ./mt7630e.nix { };

  coldbootScript = pkgs.writeShellScript "mt7630e-coldboot" ''
    set -eu

    # Wait for the PCI Wi-Fi driver.  The Bluetooth loader must not
    # be allowed to race the MT7630E Wi-Fi initialization.
    i=0
    while [ "$i" -lt 30 ]; do
      if ls /sys/bus/pci/drivers/mt76x0e/* >/dev/null 2>&1; then
        break
      fi
      i=$((i + 1))
      sleep 1
    done

    # 0489:e080 is the pre-firmware USB state.  Do NOT bind it to
    # btusb: mt76xx has to load firmware and let the device re-enumerate.
    ${pkgs.kmod}/bin/modprobe mt76xx

    sleep 2

    ${pkgs.util-linux}/bin/rfkill unblock bluetooth 2>/dev/null || true
  '';
in
{
  # The out-of-tree loader must match the active kernel package set.
  boot.extraModulePackages = [ mt7630eBt ];

  # Do not put mt76xx in boot.kernelModules: it must start after mt76x0e.
  boot.kernelModules = lib.mkForce [
    "bluetooth"
    "btusb"
  ];

  hardware.firmware = [ mt7630eBt ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.AutoEnable = true;
  };

  services.blueman.enable = true;

  # The old workaround service from the previous configuration is disabled.
  systemd.services.fix-mt7630e-coldboot.enable = lib.mkForce false;

  systemd.services.mt7630e-coldboot = {
    description = "Initialize MT7630E Bluetooth after Wi-Fi";
    wantedBy = [ "multi-user.target" ];
    after = [
      "systemd-modules-load.service"
      "NetworkManager.service"
    ];
    wants = [ "NetworkManager.service" ];
    before = [ "bluetooth.service" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = coldbootScript;
      RemainAfterExit = true;
    };
  };

  # Keep the Intel HD 5500 configuration that was already working,
  # but remove the unrelated global PCIe/ACPI/USB workarounds.
  boot.initrd.kernelModules = lib.mkForce [ "i915" ];

  boot.kernelParams = lib.mkForce [
    "i915.enable_dc=0"
    "i915.enable_fbc=0"
    "quiet"
    "splash"
    "loglevel=3"
  ];

  boot.extraModprobeConfig = lib.mkForce "";

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
    ];
  };

  # The previous configuration forced 0489:e080 directly to btusb.
  # Remove that rule so mt76xx can perform firmware initialization.
  services.udev.extraRules = lib.mkForce "";
}
