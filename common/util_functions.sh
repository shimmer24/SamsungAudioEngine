#########################################
#
# Magisk General Utility Functions
# by topjohnwu
#
#########################################

#MAGISK_VERSION_STUB

###################
# Helper Functions
###################

ui_print() {
  $BOOTMODE && echo "$1" || echo -e "ui_print $1\nui_print" >> /proc/self/fd/$OUTFD
}

toupper() {
  echo "$@" | tr '[:lower:]' '[:upper:]'
}

grep_cmdline() {
  local REGEX="s/^$1=//p"
  cat /proc/cmdline | tr '[:space:]' '\n' | sed -n "$REGEX" 2>/dev/null
}

grep_prop() {
  local REGEX="s/^$1=//p"
  shift
  local FILES=$@
  [ -z "$FILES" ] && FILES='/system/build.prop'
  sed -n "$REGEX" $FILES 2>/dev/null | head -n 1
}

getvar() {
  local VARNAME=$1
  local VALUE=
  VALUE=`grep_prop $VARNAME /sbin/.magisk/config /data/.magisk /cache/.magisk`
  [ ! -z $VALUE ] && eval $VARNAME=\$VALUE
}

is_mounted() {
  grep -q " `readlink -f $1` " /proc/mounts 2>/dev/null
  return $?
}

abort() {
  ui_print "$1"
  $BOOTMODE || recovery_cleanup
  exit 1
}

resolve_vars() {
  MAGISKBIN=$NVBASE/magisk
  POSTFSDATAD=$NVBASE/post-fs-data.d
  SERVICED=$NVBASE/service.d
}

######################
# Environment Related
######################

setup_flashable() {
  # Preserve environment varibles
  OLD_PATH=$PATH
  ensure_bb
  $BOOTMODE && return
  if [ -z $OUTFD ] || readlink /proc/$$/fd/$OUTFD | grep -q /tmp; then
    # We will have to manually find out OUTFD
    for FD in `ls /proc/$$/fd`; do
      if readlink /proc/$$/fd/$FD | grep -q pipe; then
        if ps | grep -v grep | grep -q " 3 $FD "; then
          OUTFD=$FD
          break
        fi
      fi
    done
  fi
}

ensure_bb() {
  if [ -x $MAGISKTMP/busybox/busybox ]; then
    [ -z $BBDIR ] && BBDIR=$MAGISKTMP/busybox
  elif [ -x $TMPDIR/bin/busybox ]; then
    [ -z $BBDIR ] && BBDIR=$TMPDIR/bin
  else
    # Construct the PATH
    [ -z $BBDIR ] && BBDIR=$TMPDIR/bin
    mkdir -p $BBDIR
    BBFILE=$TMPDIR/common/bin
    api_level_arch_detect
    if [ "$ARCH" = "arm" ]; then unzip -oq "$ZIPFILE" 'common/bin/busybox-arm' -d $TMPDIR >&2
      mv $BBFILE/busybox-arm $BBDIR/busybox; fi
    if [ "$ARCH" = "arm64" ]; then unzip -oq "$ZIPFILE" 'common/bin/busybox-arm' -d $TMPDIR >&2
      mv $BBFILE/busybox-arm $BBDIR/busybox; fi
    if [ "$ABI" = "x86" ]; then unzip -oq "$ZIPFILE" 'common/bin/busybox-x86' -d $TMPDIR >&2
      mv $BBFILE/busybox-$ABI $BBDIR/busybox; fi
    chmod 0755 $BBDIR/busybox
    $BBDIR/busybox --install -s $BBDIR
  fi
  echo $PATH | grep -q "^$BBDIR" || export PATH=$BBDIR:$PATH
}

recovery_actions() {
  # Make sure random don't get blocked
  mount -o bind /dev/urandom /dev/random
  # Unset library paths
  OLD_LD_LIB=$LD_LIBRARY_PATH
  OLD_LD_PRE=$LD_PRELOAD
  OLD_LD_CFG=$LD_CONFIG_FILE
  unset LD_LIBRARY_PATH
  unset LD_PRELOAD
  unset LD_CONFIG_FILE
  # Force our own busybox path to be in the front
  # and do not use anything in recovery's sbin
  export PATH=$BBDIR:/system/bin:/vendor/bin
}

recovery_cleanup() {
  ui_print "- Unmounting partitions"
  umount -l /system 2>/dev/null
  umount -l /system_root 2>/dev/null
  umount -l /vendor 2>/dev/null
  umount -l /dev/random 2>/dev/null
  export PATH=$OLD_PATH
  [ -z $OLD_LD_LIB ] || export LD_LIBRARY_PATH=$OLD_LD_LIB
  [ -z $OLD_LD_PRE ] || export LD_PRELOAD=$OLD_LD_PRE
  [ -z $OLD_LD_CFG ] || export LD_CONFIG_FILE=$OLD_LD_CFG
}

#######################
# Installation Related
#######################

find_block() {
  for BLOCK in "$@"; do
    DEVICE=`find /dev/block -type l -iname $BLOCK | head -n 1` 2>/dev/null
    if [ ! -z $DEVICE ]; then
      readlink -f $DEVICE
      return 0
    fi
  done
  # Fallback by parsing sysfs uevents
  for uevent in /sys/dev/block/*/uevent; do
    local DEVNAME=`grep_prop DEVNAME $uevent`
    local PARTNAME=`grep_prop PARTNAME $uevent`
    for BLOCK in "$@"; do
      if [ "`toupper $BLOCK`" = "`toupper $PARTNAME`" ]; then
        echo /dev/block/$DEVNAME
        return 0
      fi
    done
  done
  return 1
}

# mount_name <partname> <mountpoint> <flag>
mount_name() {
  local PART=$1
  local POINT=$2
  local FLAG=$3
  [ -L $POINT ] && rm -f $POINT
  mkdir -p $POINT 2>/dev/null
  is_mounted $POINT && return
  ui_print "- Mounting $POINT"
  # First try mounting with fstab
  mount $FLAG $POINT 2>/dev/null
  if ! is_mounted $POINT; then
    local BLOCK=`find_block $PART`
    mount $FLAG $BLOCK $POINT
  fi
}

mount_ro_ensure() {
  # We handle ro partitions only in recovery
  $BOOTMODE && return
  local PART=$1$SLOT
  local POINT=/$1
  mount_name $PART $POINT '-o rw'
  is_mounted $POINT || abort "! Cannot mount $POINT"
}

mount_partitions() {
  # Check A/B slot
  SLOT=`grep_cmdline androidboot.slot_suffix`
  if [ -z $SLOT ]; then
    SLOT=`grep_cmdline androidboot.slot`
    [ -z $SLOT ] || SLOT=_${SLOT}
  fi
  [ -z $SLOT ] || ui_print "- Current boot slot: $SLOT"

  # Mount ro partitions
  mount_ro_ensure system
  if [ -f /system/init.rc ]; then
    SYSTEM_ROOT=true
    [ -L /system_root ] && rm -f /system_root
    mkdir /system_root 2>/dev/null
    mount --move /system /system_root
    mount -o bind /system_root/system /system
  else
    grep ' / ' /proc/mounts | grep -qv 'rootfs' || grep -q ' /system_root ' /proc/mounts \
    && SYSTEM_ROOT=true || SYSTEM_ROOT=false
  fi
  [ -L /system/vendor ] && mount_ro_ensure vendor
  $SYSTEM_ROOT && ui_print "- Device is system-as-root"

  # Mount persist partition in recovery
  if ! $BOOTMODE && [ ! -z $PERSISTDIR ]; then
    # Try to mount persist
    PERSISTDIR=/persist
    mount_name persist /persist
    if ! is_mounted /persist; then
      # Fallback to cache
      mount_name cache /cache
      is_mounted /cache && PERSISTDIR=/cache || PERSISTDIR=
    fi
  fi
}

get_flags() {
  # override variables
  getvar KEEPVERITY
  getvar KEEPFORCEENCRYPT
  getvar RECOVERYMODE
  if [ -z $KEEPVERITY ]; then
    if $SYSTEM_ROOT; then
      KEEPVERITY=true
      ui_print "- System-as-root, keep dm/avb-verity"
    else
      KEEPVERITY=false
    fi
  fi
  if [ -z $KEEPFORCEENCRYPT ]; then
    grep ' /data ' /proc/mounts | grep -q 'dm-' && FDE=true || FDE=false
    [ -d /data/unencrypted ] && FBE=true || FBE=false
    # No data access means unable to decrypt in recovery
    if $FDE || $FBE || ! $DATA; then
      KEEPFORCEENCRYPT=true
      ui_print "- Encrypted data, keep forceencrypt"
    else
      KEEPFORCEENCRYPT=false
    fi
  fi
  [ -z $RECOVERYMODE ] && RECOVERYMODE=false
}

find_boot_image() {
  BOOTIMAGE=
  if $RECOVERYMODE; then
    BOOTIMAGE=`find_block recovery_ramdisk$SLOT recovery`
  elif [ ! -z $SLOT ]; then
    BOOTIMAGE=`find_block ramdisk$SLOT recovery_ramdisk$SLOT boot$SLOT`
  else
    BOOTIMAGE=`find_block ramdisk recovery_ramdisk kern-a android_boot kernel boot lnx bootimg boot_a`
  fi
  if [ -z $BOOTIMAGE ]; then
    # Lets see what fstabs tells me
    BOOTIMAGE=`grep -v '#' /etc/*fstab* | grep -E '/boot[^a-zA-Z]' | grep -oE '/dev/[a-zA-Z0-9_./-]*' | head -n 1`
  fi
}

flash_image() {
  # Make sure all blocks are writable
  $MAGISKBIN/magisk --unlock-blocks 2>/dev/null
  case "$1" in
    *.gz) CMD1="$MAGISKBIN/magiskboot decompress '$1' - 2>/dev/null";;
    *)    CMD1="cat '$1'";;
  esac
  if $BOOTSIGNED; then
    CMD2="$BOOTSIGNER -sign"
    ui_print "- Sign image with verity keys"
  else
    CMD2="cat -"
  fi
  if [ -b "$2" ]; then
    local img_sz=`stat -c '%s' "$1"`
    local blk_sz=`blockdev --getsize64 "$2"`
    [ $img_sz -gt $blk_sz ] && return 1
    eval $CMD1 | eval $CMD2 | cat - /dev/zero > "$2" 2>/dev/null
  else
    ui_print "- Not block device, storing image"
    eval $CMD1 | eval $CMD2 > "$2" 2>/dev/null
  fi
  return 0
}

patch_dtb_partitions() {
  local result=1
  cd $MAGISKBIN
  for name in dtb dtbo; do
    local IMAGE=`find_block $name$SLOT`
    if [ ! -z $IMAGE ]; then
      ui_print "- $name image: $IMAGE"
      if ./magiskboot dtb $IMAGE patch dt.patched; then
        result=0
        ui_print "- Backing up stock $name image"
        cat $IMAGE > stock_${name}.img
        ui_print "- Flashing patched $name"
        cat dt.patched /dev/zero > $IMAGE
        rm -f dt.patched
      fi
    fi
  done
  cd /
  return $result
}

# Common installation script for flash_script.sh and addon.d.sh
install_magisk() {
  cd $MAGISKBIN

  eval $BOOTSIGNER -verify < $BOOTIMAGE && BOOTSIGNED=true
  $BOOTSIGNED && ui_print "- Boot image is signed with AVB 1.0"

  $IS64BIT && mv -f magiskinit64 magiskinit 2>/dev/null || rm -f magiskinit64

  # Source the boot patcher
  SOURCEDMODE=true
  . ./boot_patch.sh "$BOOTIMAGE"

  ui_print "- Flashing new boot image"

  if ! flash_image new-boot.img "$BOOTIMAGE"; then
    ui_print "- Compressing ramdisk to fit in partition"
    ./magiskboot cpio ramdisk.cpio compress
    ./magiskboot repack "$BOOTIMAGE"
    flash_image new-boot.img "$BOOTIMAGE" || abort "! Insufficient partition size"
  fi

  ./magiskboot cleanup
  rm -f new-boot.img

  patch_dtb_partitions
  run_migrations
}

sign_chromeos() {
  ui_print "- Signing ChromeOS boot image"

  echo > empty
  ./chromeos/futility vbutil_kernel --pack new-boot.img.signed \
  --keyblock ./chromeos/kernel.keyblock --signprivate ./chromeos/kernel_data_key.vbprivk \
  --version 1 --vmlinuz new-boot.img --config empty --arch arm --bootloader empty --flags 0x1

  rm -f empty new-boot.img
  mv new-boot.img.signed new-boot.img
}

remove_system_su() {
  if [ -f /system/bin/su -o -f /system/xbin/su ] && [ ! -f /su/bin/su ]; then
    ui_print "- Removing system installed root"
    mount -o rw,remount /system
    # SuperSU
    if [ -e /system/bin/.ext/.su ]; then
      mv -f /system/bin/app_process32_original /system/bin/app_process32 2>/dev/null
      mv -f /system/bin/app_process64_original /system/bin/app_process64 2>/dev/null
      mv -f /system/bin/install-recovery_original.sh /system/bin/install-recovery.sh 2>/dev/null
      cd /system/bin
      if [ -e app_process64 ]; then
        ln -sf app_process64 app_process
      elif [ -e app_process32 ]; then
        ln -sf app_process32 app_process
      fi
    fi
    rm -rf /system/.pin /system/bin/.ext /system/etc/.installed_su_daemon /system/etc/.has_su_daemon \
    /system/xbin/daemonsu /system/xbin/su /system/xbin/sugote /system/xbin/sugote-mksh /system/xbin/supolicy \
    /system/bin/app_process_init /system/bin/su /cache/su /system/lib/libsupol.so /system/lib64/libsupol.so \
    /system/su.d /system/etc/install-recovery.sh /system/etc/init.d/99SuperSUDaemon /cache/install-recovery.sh \
    /system/.supersu /cache/.supersu /data/.supersu \
    /system/app/Superuser.apk /system/app/SuperSU /cache/Superuser.apk  2>/dev/null
  fi
}

api_level_arch_detect() {
  API=`grep_prop ro.build.version.sdk`
  ABI=`grep_prop ro.product.cpu.abi | cut -c-3`
  ABI2=`grep_prop ro.product.cpu.abi2 | cut -c-3`
  ABILONG=`grep_prop ro.product.cpu.abi`

  ARCH=arm
  ARCH32=arm
  IS64BIT=false
  if [ "$ABI" = "x86" ]; then ARCH=x86; ARCH32=x86; fi;
  if [ "$ABI2" = "x86" ]; then ARCH=x86; ARCH32=x86; fi;
  if [ "$ABILONG" = "arm64-v8a" ]; then ARCH=arm64; ARCH32=arm; IS64BIT=true; fi;
  if [ "$ABILONG" = "x86_64" ]; then ARCH=x64; ARCH32=x86; IS64BIT=true; fi;
}

check_data() {
  DATA=false
  DATA_DE=false
  if grep ' /data ' /proc/mounts | grep -vq 'tmpfs'; then
    # Test if data is writable
    touch /data/.rw && rm /data/.rw && DATA=true
    # Test if DE storage is writable
    $DATA && [ -d /data/adb ] && touch /data/adb/.rw && rm /data/adb/.rw && DATA_DE=true
  fi
  $DATA && NVBASE=/data || NVBASE=/cache/data_adb
  $DATA_DE && NVBASE=/data/adb
  resolve_vars
}

find_manager_apk() {
  [ -z $APK ] && APK=/data/adb/magisk.apk
  [ -f $APK ] || APK=/data/magisk/magisk.apk
  [ -f $APK ] || APK=/data/app/com.topjohnwu.magisk*/*.apk
  if [ ! -f $APK ]; then
    DBAPK=`magisk --sqlite "SELECT value FROM strings WHERE key='requester'" 2>/dev/null | cut -d= -f2`
    [ -z $DBAPK ] && DBAPK=`strings /data/adb/magisk.db | grep 5requester | cut -c11-`
    [ -z $DBAPK ] || APK=/data/user_de/*/$DBAPK/dyn/*.apk
    [ -f $APK ] || [ -z $DBAPK ] || APK=/data/app/$DBAPK*/*.apk
  fi
  [ -f $APK ] || ui_print "! Unable to detect Magisk Manager APK for BootSigner"
}

run_migrations() {
  local LOCSHA1
  local TARGET
  # Legacy app installation
  local BACKUP=/data/adb/magisk/stock_boot*.gz
  if [ -f $BACKUP ]; then
    cp $BACKUP /data
    rm -f $BACKUP
  fi

  # Legacy backup
  for gz in /data/stock_boot*.gz; do
    [ -f $gz ] || break
    LOCSHA1=`basename $gz | sed -e 's/stock_boot_//' -e 's/.img.gz//'`
    [ -z $LOCSHA1 ] && break
    mkdir /data/magisk_backup_${LOCSHA1} 2>/dev/null
    mv $gz /data/magisk_backup_${LOCSHA1}/boot.img.gz
  done

  # Stock backups
  LOCSHA1=$SHA1
  for name in boot dtb dtbo; do
    BACKUP=/data/adb/magisk/stock_${name}.img
    [ -f $BACKUP ] || continue
    if [ $name = 'boot' ]; then
      LOCSHA1=`$MAGISKBIN/magiskboot sha1 $BACKUP`
      mkdir /data/magisk_backup_${LOCSHA1} 2>/dev/null
    fi
    TARGET=/data/magisk_backup_${LOCSHA1}/${name}.img
    cp $BACKUP $TARGET
    rm -f $BACKUP
    gzip -9f $TARGET
  done
}

#################
# Module Related
#################

set_perm() {
  chown $2:$3 $1 || return 1
  chmod $4 $1 || return 1
  CON=$5
  [ -z $CON ] && CON=u:object_r:system_file:s0
  chcon $CON $1 || return 1
}

set_perm_recursive() {
  find $1 -type d 2>/dev/null | while read dir; do
    set_perm $dir $2 $3 $4 $6
  done
  find $1 -type f -o -type l 2>/dev/null | while read file; do
    set_perm $file $2 $3 $5 $6
  done
}

mktouch() {
  mkdir -p ${1%/*} 2>/dev/null
  [ -z $2 ] && touch $1 || echo $2 > $1
  chmod 644 $1
}

request_size_check() {
  reqSizeM=`du -ms "$1" | cut -f1`
}

request_zip_size_check() {
  reqSizeM=`unzip -l "$1" | tail -n 1 | awk '{ print int(($1 - 1) / 1048576 + 1) }'`
}

boot_actions() { return; }

##########
# Presets
##########

# Detect whether in boot mode
[ -z $BOOTMODE ] && ps | grep zygote | grep -qv grep && BOOTMODE=true
[ -z $BOOTMODE ] && ps -A 2>/dev/null | grep zygote | grep -qv grep && BOOTMODE=true
[ -z $BOOTMODE ] && BOOTMODE=false

MAGISKTMP=/sbin/.magisk
NVBASE=/data/adb
[ -z $TMPDIR ] && TMPDIR=/dev/tmp

# Bootsigner related stuff
BOOTSIGNERCLASS=a.a
BOOTSIGNER="/system/bin/dalvikvm -Xnodex2oat -Xnoimage-dex2oat -cp \$APK \$BOOTSIGNERCLASS"
BOOTSIGNED=false

SYS=/system; APP=$SYS/app; BIN=$SYS/bin; ETC=$SYS/etc; FRAME=$SYS/framework; MEDIA=$SYS/media; LIB=$SYS/lib; LIB64=$SYS/lib64; PRIV=$SYS/priv-app; USR=$SYS/usr; XBIN=$SYS/xbin; BUILD=$SYS/build.prop
VENDOR=$SYS/vendor; ETC_VE=$VENDOR/etc; LIB_VE=$VENDOR/lib; LIB64_VE=$VENDOR/lib64; BUILD_VE=$VENDOR/build.prop; EFFECTS_XML=$ETC_VE/audio_effects.xml; EFFECTS=$ETC_VE/audio_effects.conf
DATA=/data; DATA_M=$DATA/misc; LOCAL=$DATA/local; PROPERTY=$DATA/property; SPECIFIC=$TMPDIR/specific; CORE=$SPECIFIC/core; FEATURE=$SPECIFIC/feature
NAMEBK=stock_system_v44.arch; ENGINE_SV=$SYS/engine_sv; BK=$DATA/$NAMEBK; CFGNAME=sa.conf

conflict="$APP/AudioFX
$APP/MusicFX
$PRIV/AudioFX
$PRIV/MusicFX
$PRIV/SoundAlive_54
$PRIV/SoundAlive_53
$PRIV/SoundAlive_52
$PRIV/SoundAlive_51
$PRIV/SoundAlive_50
$ETC/audio_effects.conf
$ETC_VE/audio_effects.conf
$LIB/soundfx
$LIB64/soundfx
$LIB_VE/soundfx
$LIB64_VE/soundfx
$ETC/dolby
$LIB/libdlbdapstorage.so
$PRIV/Ax
$PRIV/AxUI
$APP/Viper4Android*
$APP/VIPER4Android*
$PRIV/Viper4Android*
$PRIV/VIPER4Android*
$LIB/libV4AJniUtils.so
$ETC_VE/audio_effects.xml
$ETC/audio_effects_sec.conf
$ETC_VE/audio_effects_sec.xml
$ETC_VE/audio_effects_common.conf
$PRIV/DiracAudioControlService
$ETC_VE/audio/audio_effects.xml";
app="SapaAudioConnectionService
SapaMonitor
SplitSoundService
MusicFX
AudioFX";
bin="apaservice
jackd
jackservice
profman
samsungpowersoundplay
media";
etc="apa_settings.cfg
audio_effects.conf
floating_feature.xml
jack_alsa_mixer.json
sapa_feature.xml
stage_policy.conf
feature_default.xml
audio_effects_sec.conf
dolby";
etccacerts="262ba90f.0
b936d1c6.0
31188b5e.0
c2c1704e.0
33ee480d.0
c907e29b.0
583d0756.0
cb1c3204.0
7892ad52.0
d0cddf45.0
7a7c655d.0
d41b5e2a.0
7c302982.0
d5727d6a.0
88950faa.0
dfc0fe80.0
a81e292b.0
fb5fa911.0
ab59055e.0
fd08c599.0";
permissions="com.google.android.media.effects.xml
com.samsung.device.xml
SemAudioThumbnail_library.xml
privapp-permissions-com.sec.android.app.soundalive.xml
platform.xml
com.samsung.feature.device_category_phone_high_end.xml
com.samsung.feature.device_category_phone.xml
android.hardware.audio.pro.xml
android.hardware.audio.low_latency.xml";
framework="SemAudioThumbnail.jar
com.google.android.media.effects.jar
com.samsung.device.jar
media_cmd.jar";
lib="jack
libapa_client.so
libapa_control.so
libapaproxy.so
libapa.so
libaudiosaplus_sec_legacy.so
libcorefx.so
lib_DNSe_EP_ver216c.so
libfloatingfeature.so
libhiddensound.so
libjackserver.so
libjackservice.so
libjackshm.so
liblegacyeffects.so
libmediacapture_jni.so
libmediacaptureservice.so
libmediacapture.so
libmysound_legacy.so
libsamsungearcare.so
libsamsungSoundbooster_plus_legacy.so
libsamsungvad.so
lib_SamsungVAD_v01009.so
libsavsac.so
libsavscmn_jni.media.samsung.so
libsavscmn.so
libsavsff.so
libsavsmeta.so
libsavsvc.so
lib_SoundAlive_AlbumArt_ver105.so
lib_SoundAlive_play_plus_ver210.so
lib_soundaliveresampler.so
lib_SoundAlive_SRC384_ver320.so
libSoundAlive_VSP_ver315b_arm.so
lib_SoundBooster_ver950.so
libsvoicedll.so
libswdap_legacy.so
libwebrtc_audio_preprocessing.so
libdexfile.so
libmultirecord.so
libprofileparamstorage.so
libsecaudiocoreutils.so
libsecaudioinfo.so
libsecnativefeature.so
libutilscallstack.so
libvorbisidec.so
libalsautils.so
libtinyalsa.so
android.hardware.audio@2.0.so
android.hardware.audio.common@2.0.so
android.hardware.audio.common@2.0-util.so
android.hardware.audio.effect@2.0.so
android.hardware.soundtrigger@2.0.so
libaudioclient.so
libaudiohal.so
libsamsungpowersound.so
libsonic.so
libsonivox.so
libsoundextractor.so
libsoundspeed.so
libspeexresampler.so
soundfx
libV4AJniUtils.so
libdlbdapstorage.so
libasound.so";
lib64="libapa_client.so
libapa_control.so
libapaproxy.so
libapa.so
libcorefx.so
lib_DNSe_EP_ver216c.so
libfloatingfeature.so
libhiddensound.so
libjackshm.so
liblegacyeffects.so
libmediacapture_jni.so
libmediacapture.so
libSamsungAPVoiceEngine.so
libsamsungearcare.so
libsavsac.so
libsavscmn_jni.media.samsung.so
libsavscmn.so
libsavsff.so
libsavsmeta.so
libsavsvc.so
lib_soundaliveresampler.so
libSoundAlive_SRC192_ver205a.so
lib_SoundAlive_SRC384_ver320.so
libSoundAlive_VSP_ver316a_ARMCpp_64bit.so
libswdap_legacy.so
libwebrtc_audio_preprocessing.so
libdexfile.so
libmultirecord.so
libprofileparamstorage.so
libsecaudiocoreutils.so
libsecaudioinfo.so
libsecnativefeature.so
libutilscallstack.so
libvorbisidec.so
libalsautils.so
libtinyalsa.so
android.hardware.audio@2.0.so
android.hardware.audio.common@2.0.so
android.hardware.audio.common@2.0-util.so
android.hardware.audio.effect@2.0.so
android.hardware.soundtrigger@2.0.so
libaudioclient.so
libaudiohal.so
libsonic.so
libsonivox.so
libsoundextractor.so
libspeexresampler.so
soundfx";
privapp="SoundAlive_54
SoundAlive_53
SoundAlive_52
SoundAlive_51
SoundAlive_50
AudioFX
MusicFX
DiracAudioControlService
Ax
AxUI";
vendoretc="abox_debug.xml
mixer_gains.xml
SoundBoosterParam.txt
audio_effects.conf
audio_effects.xml
permissions
audio_effects_common.conf
audio_effects_sec.xml";
vendorfirmware="cs47l92-dsp1-trace.wmfw
dsm.bin
dsm_tune.bin
SoundBoosterParam.bin";
vendorlib="libaboxpcmdump.so
libapa_jni.so
libcodecdspdump.so
libfloatingfeature.so
libjack.so
librecordalive.so
libSamsungPostProcessConvertor.so
lib_SamsungRec_06006.so
libsavsac.so
libsavscmn.so
libsavsvc.so
lib_SoundAlive_3DPosition_ver202.so
lib_SoundAlive_AlbumArt_ver105.so
lib_SoundAlive_play_plus_ver210.so
lib_soundaliveresampler.so
lib_SoundAlive_SRC384_ver320.so
lib_SoundBooster_ver950.so
libalsautils_sec.so
libaudioproxy.so
libHMT.so
libprofileparamstorage.so
libsecaudioinfo.so
libsecnativefeature.so
soundfx";
vendorlib64="libapa_jni.so
libfloatingfeature.so
libjack.so
libsavsac.so
libsavscmn.so
libsavsvc.so
libprofileparamstorage.so
libsecnativefeature.so
soundfx";
xbin="jack_connect
jack_disconnect
jack_lsp
jack_showtime
jack_simple_client
jack_transport";

if [ -d /sdcard/Android ]; then
  CFGDIR=/sdcard
elif [ -d /storage/emulated/0/Android ]; then
  CFGDIR=/storage/emulated/0
fi
ECFG=$CFGDIR/$CFGNAME

pack() {
  local UT='tar '
  local DC=$@
  $UT${DC}
}

sa_conf() {
  if [ -f $ECFG ]; then
    ui_print "- Found $ECFG"
    value_magisk() { grep "MAGISK=" $ECFG; }
    value_dolby() { grep "DOLBY_DEFAULT=" $ECFG; }
    if value_magisk > /dev/null; then
      ui_print "- Value: $(value_magisk)"
    fi
    if value_dolby > /dev/null; then
      ui_print "- Value: $(value_dolby)"
    fi
  fi
}

remount_partitions() {
  remount_part() {
    local PART=$@
    local POINT=/${PART}
    mount -o rw,remount $POINT 2>/dev/null
  }
  for BLOCK in system system_root vendor;
    do remount_part $BLOCK
  done
  recovery_remount() {
    umount -l /system_root 2>/dev/null
    umount -l /system 2>/dev/null
    umount -l /vendor 2>/dev/null
    mount_partitions > /dev/null
  }
  rw_system() { touch /system/rw 2>/dev/null && rm -rf /system/rw; }
  rw_vendor() { touch /system/vendor/rw 2>/dev/null && rm -rf /system/vendor/rw; }
  rw_system || recovery_remount
  rw_vendor || recovery_remount
}

unpack() {
  local FORMAT="txz"
  case $1 in
    -e)ui_print "- Extract files..."
        [ -f $TMPDIR/specific.$FORMAT ] && pack -xf $TMPDIR/specific.$FORMAT -C $TMPDIR 2>/dev/null
        [ -f $TMPDIR/system.$FORMAT ] && pack -xf $TMPDIR/system.$FORMAT -C / 2>/dev/null
        [ -f $TMPDIR/is64bit.$FORMAT ] && $IS64BIT && pack -xf $TMPDIR/is64bit.$FORMAT -C $TMPDIR 2>/dev/null
    ;;
  esac
}

proc_var() {
  local I=$@
  case ${I} in
    -i)
        remount_partitions; block_check; block_backup; unpack -e; block_engine
        ;;
    -u)
        remount_partitions; block_check; block_uninstall
        ;;
  esac
}

rwxrxrx() {
  local FD=$@
  chmod 0755 ${FD}
}

rwrr() {
  local F=$@
  chmod 0644 ${F}
}

rwrw() {
  local F=$@
  chmod 0660 ${F}
}

board_platform() {
  local FILE="/system/build.prop"
  PLATFORM=`grep_prop ro.board.platform | sed -r 's/(.+[^0-9]).+/\1/' | head -n 1` 2>/dev/null
  for SUPPORT in sdm msm exynos;
    do $(grep "ro.board.platform=$SUPPORT" $FILE > /dev/null) && if [ "$PLATFORM" = "$SUPPORT" ]; then BOARD=true && break; fi || BOARD=false
  done; $BOARD
}

launch() {
  local FEATURE=$1
  chmod 0755 $FEATURE
  . $FEATURE
}

abort() {
  ui_print "$1"
  [ -f $BK ] && ui_print "Restore system... $(launch $TMPDIR/restore.sh > /dev/null 2>/dev/null; ui_print "Done")"
  magisk_unid
  $BOOTMODE || recovery_cleanup
  exit 1
}

magisk_unid() {
  if [ -d $MAGISKBIN ]; then
    if [ -f $BK ]; then
      UNID=false; else UNID=true
      if $UNID; then
        for ID in sae aliveset aes;
          do rm -rf $MAGISKTMP/img/$ID $NVBASE/modules/$ID  $MODULEROOT/$ID
        done
      fi
    fi
  fi
}

magisk() {
  [ -d $MAGISKBIN ] && MAGISK=true || MAGISK=false
  if [ -f $ECFG ]; then
    if grep "MAGISK=true" $ECFG > /dev/null; then
      . $ECFG
      if $MAGISK; then
        MAGISK=true
      fi
    elif grep "MAGISK=false" $ECFG > /dev/null; then
      . $ECFG
      if ! $MAGISK; then
        MAGISK=false
      fi
    fi
  fi
}

resolve_vars
