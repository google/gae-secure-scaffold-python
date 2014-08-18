#!/bin/bash
# Utility script for the secure GAE application scaffold.

die() {
  echo "FATAL: $@" 1>&2
  exit 1
}

warn() {
  echo -n -e "\a" 1>&2
  echo "WARN: $@" 1>&2
}

get_or_die() {
  local x=`which $1`
  if [[ -z "$x" ]] ; then
    die "could not find $1"
  fi
  eval "$2=$x"
}

get_or_die "awk" "AWK"
get_or_die "cat" "CAT"
get_or_die "cp" "CP"
get_or_die "cut" "CUT"
get_or_die "dirname" "DIRNAME"
get_or_die "find" "FIND"
get_or_die "git" "GIT"
get_or_die "java" "JAVA"
get_or_die "mkdir" "MKDIR"
get_or_die "python" "PYTHON"
get_or_die "rm" "RM"
get_or_die "sed" "SED"
get_or_die "tr" "TR"
get_or_die "wc" "WC"

UTIL_SH_RELATIVE_DIR=`$DIRNAME ${0}`

if [[ "$UTIL_SH_RELATIVE_DIR" != "." ]] ; then
  die "util.sh must be run from $PWD/$UTIL_SH_RELATIVE_DIR"
fi

APPENGINE_BASE_DIR=$HOME/bin/google_appengine
APPCFG=$APPENGINE_BASE_DIR/appcfg.py
DEV_APPSERVER=$APPENGINE_BASE_DIR/dev_appserver.py
CLOSURE_COMPILER_JAR=$HOME/bin/google_closure/compiler.jar
CLOSURE_TEMPLATES_BASE_DIR=$HOME/bin/google_closure_templates/
CLOSUREBUILDER=$PWD/closure-library/closure/bin/build/closurebuilder.py
OUTPUT_DIR=$PWD/out

usage() {
  echo "Usage: util.sh " 1>&2
  echo "    -h           Display this help" 1>&2
  echo "    -d           Run this in dev_appserver" 1>&2
  echo "    -p <appid>   Push to appengine with specified application id" 1>&2
}

compute_version_string() {
  $GIT status 2>&1 >/dev/null
  if [[ $? -ne 0 ]] ; then
    die "not inside a git repository"
  fi
  local commit=`$GIT log --format=oneline -n 1 | $AWK '{ print $1 }' | $CUT -c1-16`
  local uncommitted=`$GIT status | $WC -l`
  local suffix=''
  if [[ $uncommitted -ne '0' ]] ; then
    local suffix='dev'
  fi
  echo $commit-$suffix
}


gen_soy() {
  local soy_template_count=`$FIND $PWD/templates/soy -iname "*.soy" | $WC -l`
  local template_files=`$FIND $PWD/templates/soy -iname "*.soy" | \
    $TR -s '\n' ',' | $SED 's/,$//'`
  if [[ $soy_template_count -ne '0' ]] ; then
    if [[ -e $CLOSURE_TEMPLATES_BASE_DIR/SoyToJsSrcCompiler.jar ]] ; then
      $JAVA -jar $CLOSURE_TEMPLATES_BASE_DIR/SoyToJsSrcCompiler.jar \
        --allowExternalCalls false --outputPathFormat \
        $OUTPUT_DIR/static/app.soy.js --srcs $template_files
    else
      warn "Soy templates found, but no compiler available."
    fi
    if [[ -e $CLOSURE_TEMPLATES_BASE_DIR/soyutils.js ]] ; then
      $CP $CLOSURE_TEMPLATES_BASE_DIR/soyutils.js $OUTPUT_DIR/static/soyutils.js
    else
      warn "Soy templates found, but soyutils.js not found."
    fi
  fi
}

gen_dev_js() {
  if [[ -e $CLOSUREBUILDER ]] ; then
    $PYTHON $CLOSUREBUILDER --root=$PWD/closure-library --root=$PWD/js \
      --namespace="app" --compiler_jar=$CLOSURE_COMPILER_JAR \
      --output_mode="compiled" \
      --compiler_flags="--compilation_level=SIMPLE_OPTIMIZATIONS" \
      > $OUTPUT_DIR/static/app.js
  else
    warn "$CLOSUREBUILDER not found, skipping compilation in js/"
  fi
  gen_soy
}

gen_prod_js() {
  if [[ -e $CLOSUREBUILDER ]] ; then
    $PYTHON $CLOSUREBUILDER --root=$PWD/closure-library --root=$PWD/js \
      --namespace="app" --compiler_jar=$CLOSURE_COMPILER_JAR \
      --output_mode="compiled" \
      --compiler_flags="--compilation_level=ADVANCED_OPTIMIZATIONS" \
      > $OUTPUT_DIR/static/app.js
  else
    warn "$CLOSUREBUILDER not found, skipping compilation in js/"
  fi
  gen_soy
}

gen_app_yaml() {
  if [[ ! -e "$PWD/app.yaml.base" ]] ; then
    die "no app.yaml.base in current directory"
  fi
  $CAT $PWD/app.yaml.base | $SED -e "s/__APPLICATION__/$1/" \
    -e "s/__VERSION__/$2/" > $OUTPUT_DIR/app.yaml
}

reset_output_dir() {
  if [[ -e $OUTPUT_DIR ]] ; then
    $RM -rf $OUTPUT_DIR
  fi
  $MKDIR $OUTPUT_DIR
  $CP -R $PWD/third_party/py/* $OUTPUT_DIR
  $CP -R $PWD/src/* $OUTPUT_DIR
  $CP -R $PWD/static $OUTPUT_DIR
  mkdir $OUTPUT_DIR/static/third_party
  $CP -R $PWD/third_party/js/* $OUTPUT_DIR/static/third_party
  $CP -R $PWD/templates $OUTPUT_DIR
}

dev() {
  if [[ ! -e $DEV_APPSERVER ]] ; then
    die "dev_appserver.py not found at $DEV_APPSERVER"
  fi
  reset_output_dir
  local version=$(compute_version_string)
  gen_app_yaml "dev" "$version"
  gen_dev_js
  $DEV_APPSERVER --skip_sdk_update_check true $OUTPUT_DIR
}

deploy() {
  if [[ ! -e $APPCFG ]] ; then
    die "appcfg.py not found at $APPCFG"
  fi
  if [[ $1 =~ ^[a-zA-Z0-9-]+$ ]] ; then
    reset_output_dir
    local version=$(compute_version_string)
    gen_app_yaml $1 $version
    gen_prod_js
    $APPCFG --no_cookies --skip_sdk_update_check update $OUTPUT_DIR
  else
    die "invalid application name $1"
  fi
}

args=`getopt hdp: $*`

if [[ $? -ne 0 ]] ; then
  usage
  exit 1
fi

set -- $args
while [[ $# -ne 0 ]] ; do
  case "$1" in
    -h) usage; exit 0;;
    -d) dev; shift;;
    -p) deploy $2; shift; shift ;;
    --) shift; break;;
    *) die "unknown option \"$1\""; usage;;
  esac
done
