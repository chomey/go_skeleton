#!/bin/bash

VERSION_TYPE=$1
LAST_MAJOR=`git tag -l *.*.* | grep -v "[A-Za-z]" | cut -d. -f1 | sort -rn | uniq | head -n 1`
LAST_MINOR=`git tag -l $LAST_MAJOR.*.* | grep -v "[A-Za-z]" | cut -d. -f2 | sort -rn | uniq | head -n 1`
LAST_PATCH=`git tag -l $LAST_MAJOR.$LAST_MINOR.* | grep -v "[A-Za-z]" | cut -d. -f3 | sort -rn | uniq | head -n 1`
LAST_VERSION=$LAST_MAJOR.$LAST_MINOR.$LAST_PATCH
if [[ 'major' == "$VERSION_TYPE" ]]
	then
		MAJOR=`echo $LAST_VERSION | cut -d. -f1`
		MAJOR=$(($MAJOR+1))
		MINOR=0
		PATCH=0
elif [[ 'minor' == "$VERSION_TYPE" ]]
	then
		MAJOR=`echo $LAST_VERSION | cut -d. -f1`
		MINOR=`echo $LAST_VERSION | cut -d. -f2`
		MINOR=$((MINOR+1))
		PATCH=0
elif [[ 'patch' == "$VERSION_TYPE" ]]
	then
		MAJOR=`echo $LAST_VERSION | cut -d. -f1`
		MINOR=`echo $LAST_VERSION | cut -d. -f2`
		PATCH=`echo $LAST_VERSION | cut -d. -f3`
		PATCH=$((PATCH+1))
fi

NEW_VERSION=$MAJOR.$MINOR.$PATCH
#
#GIT_TAG="git tag -a $NEW_VERSION -m '$VERSION_TYPE"
#GIT_PUSH="git push --tags"
#
#echo `$GIT_TAG`
#echo `$GIT_PUSH`

echo $NEW_VERSION > VERSION
