proj_print_current_conf() {
  echo "####### projdir: $projdir"
  echo "####### host_plat: $host_plat"
  echo "####### target_plat: $target_plat ($target_label)"
  echo "####### confscript: $cmake"
  echo "####### buildconf: $buildconf"
  echo "####### builddir: $builddir"
  echo "####### deploydir: $deploydir"
}

_qt_config_target() {
  type qt_config &>/dev/null && qt_config --target $1
}

proj_set_target() {
  unset -v target_conf_flags target_plat_prefix
  if [ -z $1 ]; then
    # check global env var
    if [ -z $curr_proj_target ]; then
      target=$host_plat
      target_label="default"
    else
      target=$curr_proj_target
      target_label="global env [\$curr_proj_target]"
    fi
  else
    target=$1
    target_label="set by user"
  fi

  if [[ "x$host_plat" == "x$target" ]]; then
    target=$host_plat
    cmake=cmake
    run=''
    _qt_config_target gcc_64 # FIXME improve
  else
    case $target in
      Msys-x86_64)
        target_plat_prefix='x86_64-w64-mingw32'
        cmake=${target_plat_prefix}-cmake
        run=${target_plat_prefix}-wine
        ;;
      *android*)
        cmake=cmake
        run=''
        _qt_config_target $target
        target_conf_flags=(
          "-DCMAKE_TOOLCHAIN_FILE=${android_toolchain_file}"
        )
        ;;
      *)
        echo "Only supports x86_64 host/target!"
        return 1
        ;;
    esac
  fi

  target_plat=$target
  unset target
}

ensure_dir() {
  test -d $1 || mkdir -pv $1 || return 1
}

push_dir() {
  for arg in $@; do
    case $arg in
      '-p') local f='yes';;
      '-c') local c='yes';;
      *) local d=$arg;;
    esac
  done
  [ -z $f ] || ensure_dir $d || return 1
  #[ -z $c ] || rm $d/* -rf || return 1
  pushd $d > /dev/null
}

pop_dir() { popd $1 > /dev/null; }

push_buildir() {
  [ -z $deploydir ] && return 1
  test -d $builddir || mkdir -pv $builddir || return 1
  push_dir $builddir $@ || return 1
}

push_deploydir() {
  [ -z $deploydir ] && return 1
  test -d $builddir || mkdir -pv $deploydir || return 1
  push_dir $deploydir $@ || return 1
}

proj_config() {
  [ -z $1 ] || proj_set_buildconf $1 || return 1
  push_buildir
  local config_cmd="$cmake ${conf_flags[@]} ${projdir}"
  echo "Config command: [$config_cmd]" && $config_cmd

  # FIXME temp (report mingw-x86-64-qt5-base-dynamic
  # bug for this)
  #buildfile="${builddir}/CMakeFiles/hellomingw.dir/build.make"
  #perl -pi -e 's/Qt5::rcc//' $buildfile
  pop_dir
}

proj_build() {
    push_buildir
    cmake --build .
    pop_dir
}

proj_deploy() {
  case $target_plat in
    android*)
      local android_apk="${builddir}/bin/QtApp-${buildconf}.apk"
      adb install -r $android_apk
      ;;
    *)
      push_buildir
      make install
      pop_dir
      ;;
  esac
}

proj_run() {
  case $target_plat in
    android*)
      local android_activity="org.qtproject.drunk_waiter/org.qtproject.qt5.android.bindings.QtActivity"
      local logfile="${builddir}/app.log"
      touch $logfile
      adb shell am start -n $android_activity &&
      adb logcat "${android_activity}:I" > $logfile & tail -n0 -f $logfile
      ;;
    *)
      push_buildir
      $run $exe $@
      pop_dir
      ;;
  esac
}

proj_set_buildconf() {
  local conf=$1
  local qt_cmake_prefix="${QT_ROOT}/${target_plat}/lib/cmake"
  unset -v conf_flags
  case $conf in
    debug)
      builddir=$builddir_debug
      deploydir=$deploydir_debug
      exe=$exe_debug
      conf_flags=(
        '-DCMAKE_BUILD_TYPE=Debug'
        "-DCMAKE_INSTALL_PREFIX:PATH=${deploydir}"
      )
      ;;
    release)
      conf_flags=(
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_INSTALL_PREFIX:PATH=${deploydir}"
      )
      builddir=$builddir_release
      deploydir=$deploydir_release
      exe=$exe_release
      ;;
    *)
      echo "Unrecognized buildconf: '$conf'"
      return 1
  esac
  conf_flags+=(
    "${target_conf_flags[@]}"
  )
  buildconf=$conf
}

proj_build_dir() {
  echo "$projdir/.build/${target_plat}-$1"
}

proj_deploy_dir() {
  echo "$projdir/.deploy/${target_plat}-$1"
}

proj_exe_name() {
  case $target_plat in
    *Linux*) echo $exebasename;;
    *Msys*) echo "$exebasename.exe";;
  esac
}

#### Let'go!

scriptdir=$(dirname $BASH_SOURCE)
projdir=$(readlink -f $scriptdir)

host_plat="$(uname -s)-$(uname -m)"
#default_plat='android_armv7'
default_plat=$host_plat
android_toolchain_file="${projdir}/cmake/android/toolchain/android.toolchain.cmake"

proj_set_target ${1:-$default_plat} || return 1

builddir_debug=$(proj_build_dir 'debug')
builddir_release=$(proj_build_dir 'release')
deploydir_debug=$(proj_deploy_dir 'debug')
deploydir_release=$(proj_deploy_dir 'release')

exebasename='qtzxing_live'
exename=$(proj_exe_name)
exe_debug=$builddir_debug/$exename
exe_release=$builddir_release/$exename
# TODO get this from command line option
proj_set_buildconf 'debug'

proj_print_current_conf
