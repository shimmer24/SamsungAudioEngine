##########################################################################################
#
# Magisk Module Installer Script
# by shimmer @ 4pda(xda)
#
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

SKIPMOUNT=false

PROPFILE=false

POSTFSDATA=false

LATESTARTSERVICE=false

AUTOWIPE=true

##########################################################################################
# Replace list
##########################################################################################

REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

REPLACE="
"

[ ! -f $TMPDIR/util_functions.sh ] && abort "! Unable to extract zip file!" || load() {
[ -f $TMPDIR/util_functions.sh ] && . $TMPDIR/util_functions.sh ;}; load && sa_conf

##########################################################################################
# Function Callbacks
##########################################################################################

block_engine() {
  ui_print "- Installing..."; $(usleep 100000);
  [ -f $LIB/libfloatingfeature.so ] || abort "Error: Unable to extract files!"
  DOLBY_SYSTEM=`grep "libswdap.so" $ETC/audio_effects.conf > /dev/null 2>/dev/null`
  DOLBY_VENDOR=`grep "libswdap.so" $ETC_VE/audio_effects.conf > /dev/null 2>/dev/null`
  DOLBY_VENDOR_XML=`grep "libswdap.so" $ETC_VE/audio_effects.xml > /dev/null 2>/dev/null`
  if [ -f $ECFG ]; then
    if grep "DOLBY_DEFAULT=true" $ECFG > /dev/null; then
      . $ECFG
      if $DOLBY_DEFAULT; then
        mkdir -p $TMPDIR/dolby
        mkdir -p $TMPDIR/dolby/lib
        mkdir -p $TMPDIR/dolby/ve_lib
        if $IS64BIT; then
          mkdir -p $TMPDIR/dolby64
          mkdir -p $TMPDIR/dolby64/lib64
          mkdir -p $TMPDIR/dolby64/ve_lib64
        fi
        if $DOLBY_SYSTEM; then
          cp -rfp $SYS/lib/soundfx/libswdap.so $TMPDIR/dolby 2>/dev/null
          cp -rfp $SYS/lib/libprofileparamstorage.so $TMPDIR/dolby/lib 2>/dev/null
          cp -rfp $VENDOR/lib/soundfx/libswdap.so $TMPDIR/dolby 2>/dev/null
          cp -rfp $VENDOR/lib/libprofileparamstorage.so $TMPDIR/dolby/ve_lib 2>/dev/null
          if $IS64BIT; then
            cp -rfp $SYS/lib64/soundfx/libswdap.so $TMPDIR/dolby64 2>/dev/null
            cp -rfp $SYS/lib64/libprofileparamstorage.so $TMPDIR/dolby/lib64 2>/dev/null
            cp -rfp $VENDOR/lib64/soundfx/libswdap.so $TMPDIR/dolby64 2>/dev/null
            cp -rfp $VENDOR/lib64/libprofileparamstorage.so $TMPDIR/dolby64/ve_lib64 2>/dev/null
          fi
        elif $DOLBY_VENDOR; then
          cp -rfp $SYS/lib/soundfx/libswdap.so $TMPDIR/dolby 2>/dev/null
          cp -rfp $SYS/lib/libprofileparamstorage.so $TMPDIR/dolby/lib 2>/dev/null
          cp -rfp $VENDOR/lib/soundfx/libswdap.so $TMPDIR/dolby 2>/dev/null
          cp -rfp $VENDOR/lib/libprofileparamstorage.so $TMPDIR/dolby/ve_lib 2>/dev/null
          if $IS64BIT; then
            cp -rfp $SYS/lib64/soundfx/libswdap.so $TMPDIR/dolby64 2>/dev/null
            cp -rfp $SYS/lib64/libprofileparamstorage.so $TMPDIR/dolby/lib64 2>/dev/null
            cp -rfp $VENDOR/lib64/soundfx/libswdap.so $TMPDIR/dolby64 2>/dev/null
            cp -rfp $VENDOR/lib64/libprofileparamstorage.so $TMPDIR/dolby64/ve_lib64 2>/dev/null
          fi
        elif $DOLBY_VENDOR_XML; then
          cp -rfp $VENDOR/lib/soundfx/libswdap.so $TMPDIR/dolby 2>/dev/null
          cp -rfp $SYS/lib/libprofileparamstorage.so $TMPDIR/dolby/lib 2>/dev/null
          cp -rfp $VENDOR/lib/libprofileparamstorage.so $TMPDIR/dolby/ve_lib 2>/dev/null
          if $IS64BIT; then
            cp -rfp $VENDOR/lib64/soundfx/libswdap.so $TMPDIR/dolby64 2>/dev/null
            cp -rfp $SYS/lib64/libprofileparamstorage.so $TMPDIR/dolby/lib64 2>/dev/null
            cp -rfp $VENDOR/lib64/libprofileparamstorage.so $TMPDIR/dolby64/ve_lib64 2>/dev/null
          fi
        fi
      fi
    elif grep "DOLBY_DEFAULT=false" $ECFG > /dev/null; then
      DOLBY_DEFAULT=false
    fi
  fi
  for F_CONFLICT in $conflict; do rm -rf $F_CONFLICT; done
  rm -rf $DATA_M/jack $DATA_M/profman 2>/dev/null
  mkdir -m0770 $DATA_M/jack
  mkdir -m0770 $DATA_M/profman
  chcon "u:object_r:profman_dump_data_file:s0" $DATA_M/profman
  rwxrxrx $BIN/apaservice
  rwxrxrx $BIN/jackd
  rwxrxrx $BIN/jackservice
  rwxrxrx $BIN/profman
  chcon "u:object_r:profman_exec:s0" $BIN/profman
  rwxrxrx $ETC/permissions && rwrr $ETC/permissions/*.xml
  rwrr $ETC/apa_settings.cfg
  rwrr $ETC/feature_default.xml
  rwrr $ETC/floating_feature.xml
  rwrr $ETC/sapa_feature.xml
  rwrr $ETC/stage_policy.conf
  rwrr $ETC/jack_alsa_mixer.json
  rwrr $ETC/security/cacerts/*.0
  rwrr $FRAME/*.jar 2>/dev/null
  rwxrxrx $LIB/hw && rwrr $LIB/hw/*.so
  rwxrxrx $LIB/jack && rwrr $LIB/jack/*.so
  rwrr $LIB/*.so
  rwxrxrx $ETC_VE
  rwrr $ETC_VE/SoundBoosterParam.txt
  rwrr $ETC_VE/abox_debug.xml
  rwrr $ETC_VE/mixer_gains.xml
  rwxrxrx $VENDOR/firmware && rwrr $VENDOR/firmware/*.bin
  rwxrxrx $VENDOR/lib
  rwxrxrx $LIB_VE/hw && rwrr $LIB_VE/hw/*.so
  rwrr $LIB_VE/*.so
  rwxrxrx $XBIN/jack*
  if $IS64BIT; then
    [ -d $TMPDIR/is64bit ] && cp -rf $TMPDIR/is64bit/lib64 $SYS
    [ -d $TMPDIR/is64bit ] && cp -rf $TMPDIR/is64bit/vendor/lib64 $VENDOR
    [ -f $LIB64/libfloatingfeature.so ] || abort "Error: Unable to extract files 64bit!"
	rwxrxrx $LIB64 && rwrr $LIB64/*.so
	rwxrxrx $LIB64/hw && rwrr $LIB64/hw/*.so
	rwxrxrx $VENDOR/lib64 && rwrr $LIB64_VE/*.so
	rwxrxrx $LIB64_VE/hw && rwrr $LIB64_VE/hw/*.so
  fi
  # hw patch
  
  $(rm -rf $DATA/system/package-cstats.list \
           $DATA/system/package-usage.list 2>/dev/null
    echo "" > $DATA/system/packages.list);
  echo "$(echo "" && cat $FEATURE/device.prop)" >> $BUILD
  echo "$(echo "" && cat $FEATURE/build_sys.prop)" >> $BUILD
  if [ "$API" -ge 28 ]; then echo "$(echo "" && cat $FEATURE/build_vendor.prop)" >> $BUILD_VE;
    else echo "$(echo "" && cat $FEATURE/build_sys_api.prop)" >> $BUILD; fi
  if getprop | grep "ro.boot.hardware" | grep "qcom"  > /dev/null; then
    echo "$(echo "" && cat $FEATURE/qcom.prop)" >> $BUILD
    if [ "$API" -ge 28 ]; then echo "$(echo "" && cat $FEATURE/qcom_vendor.prop)" >> $BUILD_VE; fi
  fi
  block_specific
  if [ -f $TMPDIR/dolby/libswdap.so ]; then
    if [ "$API" -ge 28 ]; then
      sed -i 's/libswdap_legacy.so/libswdap.so/' $ETC_VE/audio_effects.xml
      cp -rfp $TMPDIR/dolby/libswdap.so $VENDOR/lib/soundfx
      cp -rfp $TMPDIR/dolby/lib/libprofileparamstorage.so $SYS/lib
      cp -rfp $TMPDIR/dolby/ve_lib/libprofileparamstorage.so $VENDOR/lib
      if $IS64BIT; then
        cp -rfp $TMPDIR/dolby64/libswdap.so $VENDOR/lib64/soundfx
        cp -rfp $TMPDIR/dolby64/lib64/libprofileparamstorage.so $SYS/lib64
        cp -rfp $TMPDIR/dolby64/ve_lib64/libprofileparamstorage.so $VENDOR/lib64
      fi
    else
      sed -i 's/libswdap_legacy.so/soundfx\/libswdap.so/' $ETC_VE/audio_effects.conf
      cp -rfp $TMPDIR/dolby/libswdap.so $SYS/lib/soundfx
      cp -rfp $TMPDIR/dolby/lib/libprofileparamstorage.so $SYS/lib
      cp -rfp $TMPDIR/dolby/ve_lib/libprofileparamstorage.so $VENDOR/lib
      if $IS64BIT; then
        cp -rfp $TMPDIR/dolby64/libswdap.so $SYS/lib64/soundfx
        cp -rfp $TMPDIR/dolby64/lib64/libprofileparamstorage.so $SYS/lib64
        cp -rfp $TMPDIR/dolby64/ve_lib64/libprofileparamstorage.so $VENDOR/lib64
      fi
    fi
  fi
}

block_specific() {
  cd $SPECIFIC
  rwrr apa_settings.cfg
  rwrr lib/*.*
  rwrr lib64/*.*
  rwxrxrx bin/*
  cp -rfp apa_settings.cfg $DATA_M/jack
# Samsung power sound play
  cp -rfp bin/samsungpowersoundplay $BIN
  cp -rfp lib/libsamsungpowersound.so $LIB
  [ ! -d $ETC/init ] && mkdir -m0755 $ETC/init 2>/dev/null
  cp -rf etc/init/powersnd.rc $ETC/init && rwrr $ETC/init/powersnd.rc
  cp -rf alsa/alsa $USR/share
  $(rwxrxrx $USR/share/alsa && rwrr $USR/share/alsa/alsa.conf);
  [ -f $BIN/alsa* ] || $(cp -rf alsa/asound/libasound.so $LIB && rwrr $LIB/libasound.so);

  for SUP in libsoundextractor.so libsoundspeed.so libaudioclient.so libaudiohal.so;
    do 
      [ -f $LIB/$SUP ] || cp -rfp lib/$SUP $LIB
    if $IS64BIT; then
      for SUP64 in libsoundextractor.so libaudioclient.so libaudiohal.so;
        do
          [ -f $LIB64/$SUP64 ] || cp -rfp lib64/$SUP64 $LIB64
      done
    fi
  done
  if board_platform; then
    cp -rfp lib/libsonic.so \
               libsonivox.so \
               libspeexresampler.so $LIB
    if $IS64BIT; then
      cp -rfp lib64/libsonic.so \
                    libsonivox.so \
                    libspeexresampler.so $LIB64
    fi
  fi

# Core
  rwrr $CORE/lib/*.*
  cp -rfp $CORE/lib/libprofileparamstorage.so \
          #$CORE/lib/libmultirecord.so \
          $CORE/lib/libsecaudiocoreutils.so \
          $CORE/lib/libsecaudioinfo.so \
          $CORE/lib/libsecnativefeature.so $LIB
  board_platform && cp -rfp $CORE/lib/libvorbisidec.so $LIB
  rwrr $CORE/vendor/lib/*.*
  cp -rfp $CORE/vendor/lib/libalsautils_sec.so \
          $CORE/vendor/lib/libaudioproxy.so \
          $CORE/vendor/lib/libHMT.so \
          $CORE/vendor/lib/libprofileparamstorage.so \
          $CORE/vendor/lib/libsecaudioinfo.so \
          $CORE/vendor/lib/libsecnativefeature.so $LIB_VE
  [ -f $TMPDIR/dolby/lib/libprofileparamstorage.so ] || cp -rfp $CORE/lib/libprofileparamstorage.so $LIB
  [ -f $TMPDIR/dolby/ve_lib/libprofileparamstorage.so ] || cp -rfp $CORE/vendor/lib/libprofileparamstorage.so $LIB_VE
  if $IS64BIT; then
    rwrr $CORE/lib64/*.*
    cp -rfp $CORE/lib64/libprofileparamstorage.so \
            #$CORE/lib64/libmultirecord.so \
            $CORE/lib64/libsecaudiocoreutils.so \
            $CORE/lib64/libsecaudioinfo.so \
            $CORE/lib64/libsecnativefeature.so $LIB64
    board_platform && cp -rfp $CORE/lib64/libvorbisidec.so $LIB64
    rwrr $CORE/vendor/lib64/*.*
    cp -rfp $CORE/vendor/lib64/libprofileparamstorage.so \
            $CORE/vendor/lib64/libsecnativefeature.so $LIB64_VE
    [ -f $TMPDIR/dolby/lib64/libprofileparamstorage.so ] || cp -rfp $CORE/lib64/libprofileparamstorage.so $LIB64
    [ -f $TMPDIR/dolby/ve_lib64/libprofileparamstorage.so ] || cp -rfp $CORE/vendor/lib64/libprofileparamstorage.so $LIB64_VE
  fi
  if board_platform; then
    local DEPENDENCE="$CORE/dependence"
    rwrr $DEPENDENCE/lib/*.*
    cp -rfp $DEPENDENCE/lib/libtinyalsa.so $DEPENDENCE/lib/libalsautils.so $LIB
    if $IS64BIT; then
      rwrr $DEPENDENCE/lib64/*.*
      cp -rfp $DEPENDENCE/lib64/libtinyalsa.so $DEPENDENCE/lib64/libalsautils.so $LIB64
    fi
  fi
  if [ "$API" -lt 28 ]; then
    cp -rfp $CORE/lib/libdexfile.so $LIB
    $IS64BIT && cp -rfp $CORE/lib64/libdexfile.so $LIB64
  fi
  prop_engine_edit=`
echo "1" > $PROPERTY/persist.audio.a2dp_avc
echo "0" > $PROPERTY/persist.audio.allsoundmute
echo "1" > $PROPERTY/persist.audio.corefx
echo "350000" > $PROPERTY/persist.audio.effectcpufreq
echo "1" > $PROPERTY/persist.audio.finemediavolume
echo "1" > $PROPERTY/persist.audio.globaleffect
echo "15" > $PROPERTY/persist.audio.headsetsysvolume
echo "15" > $PROPERTY/persist.audio.hphonesysvolume
echo "1" > $PROPERTY/persist.audio.k2hd
echo "0" > $PROPERTY/persist.audio.mpseek
echo "1" > $PROPERTY/persist.audio.mysound
echo "0" > $PROPERTY/persist.audio.nxp_lvvil
echo "0" > $PROPERTY/persist.audio.pcmdump
echo "1" > $PROPERTY/persist.audio.ringermode
echo "SKT" > $PROPERTY/persist.audio.sales_code
echo "1" > $PROPERTY/persist.audio.soundalivefxsec
echo "1" > $PROPERTY/persist.audio.stereospeaker
echo "15" > $PROPERTY/persist.audio.sysvolume
echo "1" > $PROPERTY/persist.audio.uhqa
echo "585600" > $PROPERTY/persist.audio.voipcpufreq`;
  if [ "$API" -ge 28 ]; then
    prop_vendor_edit=`
echo "true" > $PROPERTY/persist.vendor.audio.fluence.speaker
echo "true" > $PROPERTY/persist.vendor.audio.fluence.voicecall
echo "false" > $PROPERTY/persist.vendor.audio.fluence.voicerec
echo "false" > $PROPERTY/persist.vendor.audio.ras.enabled`
  else
    prop_vendor_edit=`
echo "true" > $PROPERTY/persist.audio.fluence.speaker
echo "true" > $PROPERTY/persist.audio.fluence.voicecall
echo "false" > $PROPERTY/persist.audio.fluence.voicerec
echo "false" > $PROPERTY/persist.audio.ras.enabled`
  fi
  for F_PROP_ENGINE_EDIT in $prop_engine_edit;
    do 
                            $F_PROP_ENGINE_EDIT;
  done
  for F_PROP_VENDOR_EDIT in $prop_vendor_edit;
    do
                            $F_PROP_VENDOR_EDIT;
  done
  chmod 0600 $PROPERTY/persist.*
  rwrr etc/audio_effects.conf
  rwrr vendor/etc/audio_effects.conf
  rwrr vendor/lib/soundfx/*.*
  rwrr vendor/lib64/soundfx/*.*
  cp -rfp etc/audio_effects.conf $ETC
  cp -rfp vendor/etc/audio_effects.conf $ETC_VE
  cp -rfp vendor/lib/soundfx $LIB_VE
  $IS64BIT && cp -rfp vendor/lib64/soundfx $LIB64_VE

  mkdir -m0755 $APP/SapaAudioConnectionService 2>/dev/null
  cp -rf app/SapaAudioConnectionService.* $APP/SapaAudioConnectionService
  $(rwxrxrx $APP/SapaAudioConnectionService && rwrr $APP/SapaAudioConnectionService/SapaAudioConnectionService.*);
  mkdir -m0755 $APP/SapaMonitor 2>/dev/null
  [ "$API" -le 23 ] && cp -rf app/api21/SapaMonitor.* $SYS/app/SapaMonitor || cp -rf app/SapaMonitor.* $APP/SapaMonitor
  $(rwxrxrx $APP/SapaMonitor && rwrr $APP/SapaMonitor/SapaMonitor.*);
  mkdir -m0755 $APP/SplitSoundService 2>/dev/null
  [ "$API" -lt 23 ] && cp -rf app/api21/SplitSoundService.* $APP/SplitSoundService || cp -rf app/SplitSoundService.* $APP/SplitSoundService
  $(rwxrxrx $APP/SplitSoundService && rwrr $APP/SplitSoundService/SplitSoundService.*);
  mkdir -m0755 $PRIV/SoundAlive_54 2>/dev/null
  [ "$API" -le 23 ] && cp -rf app/api21/SoundAlive_54.* $SYS/priv-app/SoundAlive_54 || cp -rf app/SoundAlive_54.* $PRIV/SoundAlive_54
  $(rwxrxrx $PRIV/SoundAlive_54 && rwrr $PRIV/SoundAlive_54/SoundAlive_54.*);

# Hardware audio api26
  if board_platform; then
    if [ "$API" -lt 28 ]; then
      if [ "$API" -gt 25 ]; then
        cp -rfp lib/android.hardware.*.so $LIB
        rwrr vendor/lib/hw/*.so
        cp -rfp vendor/lib/hw/android.hardware.*.so $LIB_VE/hw
        if $IS64BIT; then
          cp -rfp lib64/android.hardware.*.so $LIB64
          rwrr vendor/lib64/hw/*.so
          cp -rfp vendor/lib64/hw/android.hardware.*.so $LIB64_VE/hw
        fi
      fi
    fi
  fi

# Pie
  if [ "$API" -ge 28 ]; then
    if [ ! -d $LIB_VE/soundfx ]; then
      mkdir -m0755 $LIB_VE/soundfx
      if $IS64BIT; then
        if [ ! -d $LIB64_VE/soundfx ]; then
          mkdir -m0755 $LIB64_VE/soundfx
        fi
      fi
    fi
    mv $LIB/soundfx/*.so $LIB_VE/soundfx
    rwrr $LIB_VE/soundfx/*.so
    rm -rf $LIB_VE/libwebrtc_audio_preprocessing.so
    mv $LIB/libwebrtc_audio_preprocessing.so $LIB_VE/libwebrtc_audio_preprocessing.so
    rwrr $LIB_VE/libwebrtc_audio_preprocessing.so
    rwrr vendor/etc/audio_effects.xml
    cp -rfp vendor/etc/audio_effects.xml $ETC_VE
    if $IS64BIT; then
      mv $LIB64/soundfx/*.so $LIB64_VE/soundfx
      rwrr $LIB64_VE/soundfx/*.so
      rm -rf $LIB64_VE/libwebrtc_audio_preprocessing.so
      mv $LIB64/libwebrtc_audio_preprocessing.so $LIB64_VE/libwebrtc_audio_preprocessing.so
      rwrr $LIB64_VE/libwebrtc_audio_preprocessing.so
    fi
    rm -rf $LIB/soundfx \
           $LIB64/soundfx \
           $ETC_VE/audio_effects.conf 2>/dev/null
  fi
  
# Module path
  if $MAGISK; then
    if [ "$API" -ge 28 ]; then
      echo "$(cat vendor/etc/audio_effects.xml)" >  $ETC_VE/audio_effects.xml
    else
      echo "$(cat vendor/etc/audio_effects.conf)" >  $ETC_VE/audio_effects.conf
    fi
  fi
  
# Low latency and audio pro
  rwrr etc/permissions/*.xml
  if [ "$API" -ge 28 ]; then
    if [ ! -d $ETC_VE/permissions ]; then
      mkdir -m0755 $ETC_VE/permissions
    fi
    cp -rfp etc/permissions/android.hardware.audio.low_latency.xml $ETC_VE/permissions
    cp -rfp etc/permissions/android.hardware.audio.pro.xml $ETC_VE/permissions
    rm -rf $ETC/permissions/android.hardware.audio.low_latency.xml \
           $ETC/permissions/android.hardware.audio.pro.xml 2>/dev/null
  else
      cp -rfp etc/permissions/android.hardware.audio.low_latency.xml $ETC/permissions
      cp -rfp etc/permissions/android.hardware.audio.pro.xml $ETC/permissions
      rm -rf $ETC_VE/permissions/android.hardware.audio.low_latency.xml \
             $ETC_VE/permissions/android.hardware.audio.pro.xml 2>/dev/null
  fi
  
  PLATFORM=$ETC/permissions/platform.xml
  if ! grep "com.sec.android.splitsound" $PLATFORM; then
    sed -i '/\<\/permissions\>/d' $PLATFORM && echo '
    <!-- Split sound application -->
    <allow-in-power-save package="com.sec.android.splitsound"/>
</permissions>' >> $PLATFORM
  fi
  chcon "u:object_r:audio_data_file:s0" /data/snd
  chcon "u:object_r:audio_data_file:s0" /data/snd/*
  chcon "u:object_r:audio_device:s0" /dev/snd
  chcon "u:object_r:audio_device:s0" /dev/snd/*
  chown root:shell $BIN/apaservice
  chown root:shell $BIN/jackd
  chown root:shell $BIN/jackservice
  chown root:shell $BIN/samsungpowersoundplay
  chown root:shell $XBIN/jack*
  chown root:shell $BIN/profman
  chown system:shell $DATA_M/profman
  chown system:shell $DATA_M/jack
  chown system:shell $DATA_M/jack/apa_settings.cfg
  rwrr $FEATURE/*.xml
  cp -rfp $FEATURE/com.samsung.feature.device_category_phone_high_end.xml $ETC/permissions
  cp -rfp $FEATURE/com.samsung.feature.device_category_phone.xml $ETC/permissions
  if [ "$API" -ge 28 ]; then
    cp -rf $FEATURE/api28/media_cmd.jar $FRAME
    rwrr $FRAME/media_cmd.jar
    cp -rf $FEATURE/media $BIN
    rwxrxrx $BIN/media
  elif [ "$API" -ge 24 ]; then
    if [ "$API" -le 25 ]; then
      cp -rf $FEATURE/media_cmd.jar $FRAME
      rwrr $FRAME/media_cmd.jar
      cp -rf $FEATURE/media $BIN
      rwxrxrx $BIN/media
    fi
  fi
  chown root:shell $BIN/media
  rm -rf $FRAME/com.google.android.media.effects.jar \
         $ETC/permissions/com.google.android.media.effects.xml
} > /dev/null 2>/dev/null

block_backup() {
  ui_print "- Backup..."; $(usleep 100000);
  rm -rf $ENGINE_SV
  mkdir -m0755 $ENGINE_SV && cd $ENGINE_SV
  $(
    mkdir -m0755 app
    mkdir -m0755 bin
    mkdir -m0755 etc
    if [ -d $ETC/init ]; then
      mkdir -m0755 etc/init
    fi
    mkdir -m0755 etc/security
    mkdir -m0755 etc/security/cacerts
    mkdir -m0755 etc/permissions
    mkdir -m0755 framework
    mkdir -m0755 lib
    mkdir -m0755 lib/hw
    mkdir -m0755 priv-app
    if [ -d $USR/share/alsa ]; then
      mkdir -m0755 usr
      mkdir -m0755 usr/share
      mkdir -m0755 usr/share/alsa
    fi
    mkdir -m0755 vendor
    if [ -d $ETC_VE ]; then
      mkdir -m0755 vendor/etc
    fi
    if [ -d $VENDOR/firmware ]; then
      mkdir -m0755 vendor/firmware
    fi
    mkdir -m0755 vendor/lib
    mkdir -m0755 xbin
  )
  cp -rfp $BUILD $ENGINE_SV
  for F_APP in $app; do cp -rfp $APP/$F_APP $ENGINE_SV/app; done
  cp -rfp $APP/Viper4Android* $ENGINE_SV/app
  cp -rfp $APP/VIPER4Android* $ENGINE_SV/app
  for F_BIN in $bin; do cp -rfp $BIN/$F_BIN $ENGINE_SV/bin; done
  for F_ETC in $etc; do cp -rfp $ETC/$F_ETC $ENGINE_SV/etc; done
  cp -rfp $ETC/init/powersnd.rc $ENGINE_SV/etc/init
  for F_CACERTS in $etccacerts; do cp -rfp $ETC/security/cacerts/$F_CACERTS $ENGINE_SV/etc/security/cacerts; done
  for F_PERMISSIONS in $permissions; do cp -rfp $ETC/permissions/$F_PERMISSIONS $ENGINE_SV/etc/permissions; done
  for F_FRAMEWORK in $framework; do cp -rfp $FRAME/$F_FRAMEWORK $ENGINE_SV/framework; done
  for F_LIB in $lib; do cp -rfp $LIB/$F_LIB $ENGINE_SV/lib; done
  cp -rfp $LIB/hw/audio.playback_record.default.so $ENGINE_SV/lib/hw
  cp -rfp $LIB/hw/audio.tms.default.so $ENGINE_SV/lib/hw
  for F_PRIVAPP in $privapp; do cp -rfp $PRIV/$F_PRIVAPP $ENGINE_SV/priv-app; done
  cp -rfp $PRIV/Viper4Android* $ENGINE_SV/app
  cp -rfp $PRIV/VIPER4Android* $ENGINE_SV/app
  if [ -d $USR/share/alsa ]; then cp -rfp $USR/share/alsa $ENGINE_SV/usr/share; fi
  cp -rfp $BUILD_VE $ENGINE_SV/vendor
  if [ -f $ETC_VE/audio/audio_effects.xml ]; then
    mkdir -m0755 vendor/etc/audio
    cp -rfp $ETC_VE/audio/audio_effects.xml $ENGINE_SV/vendor/etc/audio
  fi
  for F_VENDORETC in $vendoretc; do cp -rfp $ETC_VE/$F_VENDORETC $ENGINE_SV/vendor/etc; done
  for F_VENDORFIRMWARE in $vendorfirmware; do cp -rfp $VENDOR/firmware/$F_VENDORFIRMWARE $ENGINE_SV/vendor/firmware; done
  for F_VENDORLIB in $vendorlib; do cp -rfp $LIB_VE/$F_VENDORLIB $ENGINE_SV/vendor/lib; done
  if [ -d $LIB_VE/hw ]; then
    mkdir -m0755 vendor/lib/hw
    cp -rfp $LIB_VE/hw/audio.* \
            $LIB_VE/hw/android.hardware.audio* \
            $LIB_VE/hw/sound_trigger.primary.* \
            $LIB_VE/hw/android.hardware.soundtrigger* $ENGINE_SV/vendor/lib/hw
  fi
  for F_XBIN in $xbin; do cp -rfp $XBIN/$F_XBIN $ENGINE_SV/xbin; done
  if $IS64BIT; then
    mkdir -m0755 lib64
    mkdir -m0755 lib64/hw
    mkdir -m0755 vendor/lib64
    for F_LIB64 in $lib64; do cp -rfp $LIB64/$F_LIB64 $ENGINE_SV/lib64; done
    cp -rfp $LIB64/hw/audio.* $ENGINE_SV/lib64/hw
    cp -rfp $LIB64/hw/sound_trigger.* $ENGINE_SV/lib64/hw
    for F_VENDORLIB64 in $vendorlib64; do cp -rfp $LIB64_VE/$F_VENDORLIB64 $ENGINE_SV/vendor/lib64; done
    if [ -d $LIB64_VE/hw ]; then
      mkdir -m0755 vendor/lib64/hw
	  cp -rfp $LIB64_VE/hw/audio* \
	          $LIB64_VE/hw/android.hardware.audio* \
	          $LIB64_VE/hw/android.hardware.soundtrigger* \
                  $LIB64_VE/hw/sound_trigger.* $ENGINE_SV/vendor/lib64/hw
    fi
  fi
  [ -d $ENGINE_SV ] && pack -czf $BK * ; rm -rf $ENGINE_SV; mv $TMPDIR/uninstall.sh $TMPDIR/restore.sh || abort "Error: Failed to create backup!"
  [ ! -f $BK ] && abort "Error: Failed to create backup!"
} 2>/dev/null

block_uninstall() {
  ui_print "- Uninstalling..."; $(usleep 200000);
  local UNSH="uninstall.sh"
  [ -f $TMPDIR/$UNSH ] && launch $TMPDIR/$UNSH > /dev/null 2>/dev/null; rm -rf $TMPDIR/$UNSH || abort "Error: Unable to uninstall!"
}

[ ! -f $BK ] && unzip -oq "$ZIPFILE" specific.txz system.txz -d $TMPDIR 2>/dev/null; $IS64BIT && unzip -oq "$ZIPFILE" is64bit.txz -d $TMPDIR 2>/dev/null

block_check() {
  ui_print "- System check..."; $(usleep 100000);
  if [ ! -f $BUILD ]; then
    ui_print "Error: Failed to mount partitions!"
    abort "Try to mount manually "/system", "/vendor" and repeat the installation."
  fi
  rw_system() { touch /system/rw 2>/dev/null && rm -rf /system/rw; }
  rw_system || abort "Error: Not possible to install. Read-only file system!"
  for BKP in $LOCAL/backup_s8.pack $LOCAL/aes_v4.dub \
             $LOCAL/engine_sv4_b41.dub $LOCAL/engine_sv4_b42.dub \
             $DATA/stock_system_v43.arch;
    do
      [ -f $BKP ] && abort "Error: Not possible to install. Remove the previous version!"
  done
  mkdir_check() { mkdir -m0755 $LOCAL/mkcheck 2>/dev/null && rm -rf $LOCAL/mkcheck; }
  if ! mkdir_check; then
    ui_print "Error: Error using binary files!"
    abort "Try to update busybox or failed to mount partition "/data""
  fi
  if [ "$API" -le 20 ]; then
    abort "Error: Unable to install, requires minimum version of Android 5.0!"
  fi
}

auto_wipe() {
  local DIR="$DATA"
  local DALVIK="dalvik-cache"
  if [ -f $BK ]; then
    ui_print "Clearing dalvik-cache and rebooting"; $(usleep 100000);
    rm -rf $DIR/$DALVIK/* && reboot
  fi
}

on_install() {
  [ ! -f $BK ] && proc_var -i || proc_var -u 2>/dev/null
}

print_modname() {
  ui_print "-----------------------------------------------"
  ui_print "Name: Samsung Audio Engine"
  ui_print "Version: 4.4"
  ui_print "Author: shimmer"
  ui_print "Thanks: Alexmak77, Erik Blvck, papadim1002"
  ui_print "        выбермудень, nonamer1990"
  ui_print "-----------------------------------------------"; $(usleep 200000);
  $MAGISK && pbm
}

pbm() {
  ui_print "*******************"
  ui_print " Powered by Magisk "
  ui_print "*******************"
}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
}

# You can add more functions to assist your custom script code
