#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}
EFFECTS_XML=/system/vendor/audio_effects.xml
EFFECTS=/system/vendor/audio_effects.conf
POSTPROCESS=false
ENFORCE=false

[ -d /sdcard/Android ] && CFGDIR=/sdcard
[ -d /storage/emulated/0/Android ] && CFGDIR=/storage/emulated/0
CFGNAME=engine_s.conf
ECFG=$CFGDIR/$CFGNAME
[ -f $ECFG ] && . $ECFG

if $POSTPROCESS; then
  if [ -f $EFFECTS_XML ]; then
    sed -i '/\<\/audio_effects_conf\>/d' $EFFECTS_XML && echo '
    <postprocess>
        <stream type="music">
            <apply effect="soundalive"/>
        </stream>
        <stream type="ring">
            <apply effect="soundalive"/>
        </stream>
        <stream type="alarm">
            <apply effect="soundalive"/>
        </stream>
    </postprocess>
</audio_effects_conf>' >> $EFFECTS_XML
  elif [ -f $EFFECTS ]; then
    echo "
output_session_processing {
    music {
        soundalive {}
    }
    ring {
        soundalive {}
    }
    alarm {
        soundalive {}
    }
}" >> $EFFECTS
  fi
fi

usleep 10000000
if $ENFORCE; then
  for MODECHANGE in /sys/fs/selinux/enforce;
    do ls $MODECHANGE > /dev/null && MCH=true || MCH=false
    && $MCH && echo "0" > $MODECHANGE || ${ grep "0" $MODECHANGE || setenforce 0 } 2>/dev/null
  done
fi

# This script will be executed in post-fs-data mode