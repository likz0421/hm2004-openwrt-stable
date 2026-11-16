RAMFS_COPY_BIN='fitblk fit_check_sign'
REQUIRE_IMAGE_METADATA=1
platform_check_image() {
 [ "$#" -eq 1 ] || return 1
 case "$(board_name)" in h3c,hm2004-du) fit_check_image "$1" ;; *) return 0 ;; esac
}
platform_do_upgrade() {
 local ubidev volume fip_volume
 case "$(board_name)" in
 h3c,hm2004-du)
  ubidev="$(nand_find_ubi ubi)"
  [ -n "$ubidev" ] || { echo 'UBI layout is missing; repair from recovery.'; return 1; }
  for volume in fip ubootenv ubootenv2 factory; do
   nand_find_volume "$ubidev" "$volume" >/dev/null || { echo "UBI base volume $volume is missing."; return 1; }
  done
  fip_volume="$(nand_find_volume "$ubidev" fip)"
  [ "$(cat "/sys/class/ubi/$fip_volume/data_bytes")" -gt 0 ] || { echo 'Boot chain is empty.'; return 1; }
  fit_do_upgrade "$1"
  ;;
 *) nand_do_upgrade "$1" ;;
 esac
}
