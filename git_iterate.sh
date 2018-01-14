#!/bin/bash

PRERUNSCRIPT=""
TESTSCRIPTS=()
declare -i NUMBER_OF_TESTS=0
BUILDSCRIPT=""
STARTCOMMIT=""
ENDCOMMIT=""
SOURCEPATH=""
OUTPUTFILE="Git_iterate_result.txt"
LOGFILE="LOG.txt"
for i in "$@"
do
case $i in
	-o=*|--output=*)
	OUTPUTFILE="${i#*=}"
	shift # past argument=value
	;;
	--logfile=*)
	LOGFILE="${i#*=}"
	shift # past argument=value
	;;
	-sp=*|--sourcepath=*)
	SRCPATH="${i#*=}"
	shift # past argument=value
	;;
	-bs=*|--buildscript=*)
	BUILDSCRIPT="${i#*=}"
	shift # past argument=value
	;;
	-is=*|--initscript=*)
	PRERUNSCRIPT="${i#*=}"
	shift # past argument=value
	;;
	-ts=*|--testscript=*)
	TESTSCRIPTS+=("${i#*=}")
	NUMBER_OF_TESTS=$NUMBER_OF_TESTS+1
	shift # past argument=value
	;;
	-s=*|--startcommit=*)
	STARTCOMMIT="${i#*=}"
	shift # past argument=value
	;;
	-e=*|--endcommit=*)
	ENDCOMMIT="${i#*=}"
	shift # past argument=value
	;;
	*)
	# unknown option
	;;
	esac
done

declare -i SHOULD_EXIT=0
if [ "$NUMBER_OF_TESTS" == "0" ]; then
	echo " => No testscripts specified. Give at least one test with --testscript=<script> or -ts=<script>"
	SHOULD_EXIT=1
fi
if [ "$BUILDSCRIPT" == "" ]; then
	echo " => No buildscript specified. Give exactly one test with --buildscript=<script> or -bs=<script>"
	SHOULD_EXIT=1
fi
if [ "$SRCPATH" == "" ]; then
	echo " => No sourcepath specified. Set with --sourcepath=</path/to/repo> or -sp=</path/to/repo>"
	SHOULD_EXIT=1
	
fi
if [ "$STARTCOMMIT" == "" ]; then
	echo " => No starting commit specified. Set with --startcommit=<integer> or -s=<integer>. Will be used for git checkout HEAD~integer"
	SHOULD_EXIT=1
fi
if [ "$ENDCOMMIT" == "" ]; then
	echo " => No end commit specified. Set with --endcommit=<integer> or -e=<integer>. Will be used for git checkout HEAD~integer"
	SHOULD_EXIT=1
fi
if [ $SHOULD_EXIT -eq 1 ]; then 
	exit 128
fi

# Get base dir
BASEDIR=`pwd`
# Get current date
TODAY=`date +%Y-%m-%d_%H:%M`
# Get initial commit
cd "$SRCDIR"
INITIAL_COMMIT=`git rev-parse HEAD`
INITIAL_COMMIT_MESSAGE=`git log --oneline -n 1`
cd "$BASEDIR"

echo "#Git-iterate testrun - ${TODAY}" | tee -a "$OUTPUTFILE"
echo "#Sourcepath  = ${SRCPATH}" | tee -a "$OUTPUTFILE"
echo "#Source inital commit: ${INITIAL_COMMIT_MESSAGE}" | tee -a "$OUTPUTFILE"
echo "#Source inital commit: ${INITIAL_COMMIT}" | tee -a "$OUTPUTFILE"
echo "#Init script = ${PRERUNSCRIPT}" | tee -a "$OUTPUTFILE"
echo "#buildscript = ${BUILDSCRIPT}" | tee -a "$OUTPUTFILE"
echo "#From HEAD~${STARTCOMMIT} to HEAD~${ENDCOMMIT} testing following scrips:" | tee -a "$OUTPUTFILE"
#echo ${TESTSCRIPTS[*]}
declare -i COUNTER=2
for script_it in "${TESTSCRIPTS[@]}";do
	echo "#-->Column $COUNTER: $script_it" | tee -a "$OUTPUTFILE"	
	COUNTER=$COUNTER+1
done

echo # newline
read -p "Continue? (y/n)" -n 1 -r
echo # newline
if [[ $REPLY =~ ^[Yy]$ ]]; then

	if [ "$PRERUNSCRIPT" != "" ]; then
		echo "Running init script..." | tee -a "$LOGFILE"
		echo "Script: $PRERUNSCRIPT" | tee -a "$LOGFILE"
		./${PRERUNSCRIPT}
		echo "Init script finished" | tee -a "$LOGFILE"
	else
		echo "No init script specified!" | tee -a "$LOGFILE"
	fi

	echo "Start iterating git repo..." | tee -a "$LOGFILE"
	for x in seq `$ENDCOMMIT 1 $STARTCOMMIT`; do
		cd $SOURCEDIR
		git checkout ${INITIAL_COMMIT}
		git checkout HEAD~$x
		CURRENT_COMMIT_MESSAGE=`git log --oneline -n 1`
		cd $BASEDIR
		echo "--------------------------------" | tee -a "$LOGFILE"
		echo "Now at:  $CURRENT_COMMIT_MESSAGE" | tee -a "$LOGFILE"
		echo "Starting building..." | tee -a "$LOGFILE"
		echo "Buildscript: $BUILDSCRIPT" | tee -a "$LOGFILE"
		./${BUILDSCRIPT}
		echo "Build finished" | tee -a "$LOGFILE"
		echo "--------------------------------" | tee -a "$LOGFILE"
	
		TESTRESULTS=()
		RESULTSTRING="$x, "
		for i in "${TESTSCRIPTS[@]}";do
			echo "Starting test..." | tee -a "$LOGFILE"
			echo "Testscript: $i" | tee -a "$LOGFILE"
			retn_value=$("./${i}")
			echo "Test finished!" | tee -a "$LOGFILE"
			echo "--------------------------------" | tee -a "$LOGFILE"
			TESTRESULTS+=("$retn_value")
			RESULTSTRING+="$retn_value"
		done
		RESULTSTRING+="$CURRENT_COMMIT_MESSAGE"
		echo "$RESULTSTRING" >> "$OUTPUTFILE"
	done
fi # exit yes/no dialog
echo "exiting..."
exit 0
