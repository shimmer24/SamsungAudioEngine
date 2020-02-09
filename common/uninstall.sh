#!/sbin/sh
app="SapaAudioConnectionService
SapaMonitor
SplitSoundService";
bin="apaservice
jackd
jackservice
profman
samsungpowersoundplay
media
sae";
etc="apa_settings.cfg
audio_effects.conf
floating_feature.xml
jack_alsa_mixer.json
sapa_feature.xml
SoundAlive_Settings.xml
stage_policy.conf
feature_default.xml
soundalive";
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
privapp="SoundAlive_54";
vendoretc="abox_debug.xml
mixer_gains.xml
SoundBoosterParam.txt
audio_effects.conf
audio_effects.xml
permissions";
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
property="persist.audio.a2dp_avc
persist.audio.allsoundmute
persist.audio.corefx
persist.audio.effectcpufreq
persist.audio.finemediavolume
persist.audio.globaleffect
persist.audio.headsetsysvolume
persist.audio.hphonesysvolume
persist.audio.k2hd
persist.audio.mpseek
persist.audio.mysound
persist.audio.nxp_lvvil
persist.audio.pcmdump
persist.audio.ringermode
persist.audio.sales_code
persist.audio.soundalivefxsec
persist.audio.stereospeaker
persist.audio.sysvolume
persist.audio.uhqa
persist.audio.voipcpufreq
persist.bluetooth.enableinbandringing
persist.audio.fluence.speaker
persist.audio.fluence.voicecall
persist.audio.fluence.voicerec
persist.audio.fluence.speaker
persist.audio.fluence.voicecall
persist.audio.fluence.voicerec
persist.audio.ras.enabled
persist.vendor.audio.fluence.speaker
persist.vendor.audio.fluence.voicecall
persist.vendor.audio.fluence.voicerec
persist.vendor.audio.ras.enabled";
code_u() {
  for F_APP in $app; do rm -rf $APP/$F_APP; done
  for F_BIN in $bin; do rm -rf $BIN/$F_BIN; done
  for F_ETC in $etc; do rm -rf $ETC/$F_ETC; done
  rm -rf $ETC/init/powersnd.rc $ETC/SoundAlive_Settings.xml $ETC/soundalive 2>/dev/null
  for F_CACERTS in $etccacerts; do rm -rf $ETC/security/cacerts/$F_CACERTS; done
  for F_PERMISSIONS in $permissions; do rm -rf $ETC/permissions/$F_PERMISSIONS; done
  rm -rf $ETC/init/powersnd.rc
  for F_FRAMEWORK in $framework; do rm -rf $FRAME/$F_FRAMEWORK; done
  for F_LIB in $lib; do rm -rf $LIB/$F_LIB; done
  rm -rf $LIB/hw/audio.playback_record.default.so \
         $LIB/hw/audio.tms.default.so 2>/dev/null
  for F_PRIVAPP in $privapp; do rm -rf $PRIV/$F_PRIVAPP; done
  for F_XBIN in $xbin; do rm -rf $XBIN/$F_XBIN; done
  rm -rf $ETC_VE/audio/audio_effects.xml
  for F_VENDORETC in $vendoretc; do rm -rf $ETC_VE/$F_VENDORETC; done
  for F_VENDORFIRMWARE in $vendorfirmware; do rm -rf $VENDOR/firmware/$F_VENDORFIRMWARE; done
  for F_VENDORLIB in $vendorlib; do rm -rf $LIB_VE/$F_VENDORLIB; done
  rm -rf $LIB_VE/hw/audio.* \
         $LIB_VE/hw/android.hardware.audio* \
         $LIB_VE/hw/android.hardware.soundtrigger* \
         $LIB_VE/hw/sound_trigger.* 2>/dev/null
  if find $LIB_VE/hw/* ; then echo "" > /dev/null; else rm -rf $LIB_VE/hw; fi
  if $IS64BIT; then
    for F_LIB64 in $lib64; do rm -rf $LIB64/$F_LIB64; done
    rm -rf $LIB64/hw/audio* \
           $LIB64/hw/sound_trigger* 2>/dev/null
    for F_VENDORLIB64 in $vendorlib64; do rm -rf $LIB64_VE/$F_VENDORLIB64; done
    rm -rf $LIB64_VE/hw/audio* \
           $LIB64_VE/hw/android.hardware.audio* \
           $LIB64_VE/hw/android.hardware.soundtrigger* \
           $LIB64_VE/hw/sound_trigger.* 2>/dev/null
    if find $LIB64_VE/hw/* ; then echo "" > /dev/null; else rm -rf $LIB64_VE/hw; fi
  fi
  rm -rf $USR/share/alsa $DATA_M/jack $DATA_M/profman 2>/dev/null
  for F_PROPERTY in $property; do rm -rf $PROPERTY/$F_PROPERTY; done
  rm -rf $DATA/data/com.samsung.android.sdk.professionalaudio.app.audioconnectionservice $DATA/dalvik-cache/arm*/*SapaAudioConnectionService*
  sed -i '/com.samsung.android.sdk.professionalaudio.app.audioconnectionservice/d' $DATA/system/package-cstats.list
  sed -i '/SapaAudioConnectionService/d' $DATA/system/package-cstats.list
  sed -i '/com.samsung.android.sdk.professionalaudio.app.audioconnectionservice/d' $DATA/system/package-usage.list
  sed -i '/com.samsung.android.sdk.professionalaudio.app.audioconnectionservice/d' $DATA/system/packages.list
  rm -rf $DATA/data/com.samsung.android.sdk.professionalaudio.utility.jammonitor $DATA/dalvik-cache/arm*/*SapaMonitor*
  sed -i '/com.samsung.android.sdk.professionalaudio.utility.jammonitor/d' $DATA/system/package-cstats.list
  sed -i '/SapaMonitor/d' $DATA/system/package-cstats.list
  sed -i '/com.samsung.android.sdk.professionalaudio.utility.jammonitor/d' $DATA/system/package-usage.list
  sed -i '/com.samsung.android.sdk.professionalaudio.utility.jammonitor/d' $DATA/system/packages.list
  rm -rf $DATA/data/com.sec.android.splitsound $DATA/dalvik-cache/arm*/*SplitSoundService*
  sed -i '/com.sec.android.splitsound/d' $DATA/system/package-cstats.list
  sed -i '/SplitSoundService/d' $DATA/system/package-cstats.list
  sed -i '/com.sec.android.splitsound/d' $DATA/system/package-usage.list
  sed -i '/com.sec.android.splitsound/d' $DATA/system/packages.list
  rm -rf $DATA/data/com.sec.android.app.soundalive $DATA/dalvik-cache/arm*/*SoundAlive_54*
  sed -i '/com.sec.android.app.soundalive/d' $DATA/system/package-cstats.list
  sed -i '/SoundAlive_/d' $DATA/system/package-cstats.list
  sed -i '/com.sec.android.app.soundalive/d' $DATA/system/package-usage.list
  sed -i '/com.sec.android.app.soundalive/d' $DATA/system/packages.list
}
code_u
pack -xf $BK -C $SYS
rm -rf $BK
