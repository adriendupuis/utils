#!/usr/bin/env bash

# https://doc.ibexa.co/en/latest/getting_started/install_ez_platform/
# https://docs.platform.sh/integrations/source/github.html

set -e;
set -x;

IBEXA_DXP_VERSION=$1; # content, experience, commerce, experience:v3.3.2, commerce:^3.3@rc, …
IBEXA_REPO_USER=$2; # a.k.a <installation-key>
IBEXA_REPO_PASS=$3; # a.k.a <token-password>
LOCAL_REPO_DIR=$4; # Path to not-existing-yet local directory
GITHUB_REPO=$5; # owner/name
GITHUB_TOKEN=$6;
PLATFORM_PROJECT_ID=$7; # Platform.sh project ID
PLATFORM_PROJECT_NAME=$8;
PLATFORM_TOKEN=$9;
DEFAULT_BRANCH=${10:-'master'}; # production, main, staging, …

platform integration:add --yes --project=$PLATFORM_PROJECT_ID --type=github --token=$GITHUB_TOKEN --repository=$GITHUB_REPO --build-pull-requests=false --fetch-branches=true --prune-branches=true ;
integration=`platform integration:list --project=$PLATFORM_PROJECT_ID --format=csv | grep $GITHUB_REPO;`;
platform integration:validate --project=$PLATFORM_PROJECT_ID ${integration%%,*};

if [ 1 -eq 1 ]; then
  cd && rm -rf $LOCAL_REPO_DIR;
fi;
if [ -e $LOCAL_REPO_DIR ]; then
  echo "Error: $LOCAL_REPO_DIR already exists.";
  exit 1;
fi;
mkdir -v -p $LOCAL_REPO_DIR && cd $LOCAL_REPO_DIR;

if [ "${IBEXA_DXP_VERSION#*:}" == "${IBEXA_DXP_VERSION}" ]; then
  skeleton="${IBEXA_DXP_VERSION}-skeleton";
else
  skeleton="${IBEXA_DXP_VERSION%:*}-skeleton:${IBEXA_DXP_VERSION#*:}";
fi;
composer create-project ibexa/$skeleton ./ --no-install;
rm -v composer.lock;
composer config platform.php 7.3.23;
composer config http-basic.updates.ibexa.co $IBEXA_REPO_USER $IBEXA_REPO_PASS;
composer config repositories.ibexa composer https://updates.ibexa.co;
composer install --no-scripts;

composer ibexa:setup --platformsh;

cp .gitignore.dist .gitignore;
git init;
# git remote add origin git@github.com:$GITHUB_REPO; # `platform` remote added by next step is enough
platform project:set-remote $PLATFORM_PROJECT_ID; #
git remote -v;

git add ./ 2>/dev/null;
git commit -m "create-project ibexa/$skeleton ./";
git branch -M $DEFAULT_BRANCH;
#git push -u origin $DEFAULT_BRANCH;
git push -u platform $DEFAULT_BRANCH;

sleep 60;
if [ 'master' != "$DEFAULT_BRANCH" ]; then
  platform project:info default_branch $DEFAULT_BRANCH --project=$PLATFORM_PROJECT_ID;
  platform environment:info --project=$PLATFORM_PROJECT_ID --environment=$DEFAULT_BRANCH parent -;
  sleep 30;
  platform environment:delete master --delete-branch --project=$PLATFORM_PROJECT_ID --yes;
fi;

composer recipes:install ibexa/${IBEXA_DXP_VERSION%:*} --force --no-interaction;
if [ '' != "$(git diff)" ]; then
  git add ./;
  git commit -m "recipes:install ibexa/${IBEXA_DXP_VERSION%:*}";
  git push;
fi;

sed -i '' 's/10.15.3/10.19.0/' .platform.app.yaml;
git add ./;
git commit -m 'Update node version

error @symfony/webpack-encore@1.1.2: The engine "node" is incompatible with this module. Expected version "^10.19.0 || ^12.0.0 || >=14.0.0". Got "10.15.3"';
git push;

sleep 60; #300; #600;
platform environment:activate --yes $DEFAULT_BRANCH;

lando init --source cwd --recipe platformsh --platformsh-site "$PLATFORM_PROJECT_NAME" --platformsh-auth $PLATFORM_TOKEN;
lando start;

if [ 1 -eq 1 ]; then
  platform environment:ssh php bin/console ibexa:install;
  platform db:dump --stdout | lando database main;
  platform mount:download --yes --mount=public/var --target=public/var;
else
  lando php bin/console ibexa:install;
  password=$(lando info --service=mysqldb | grep password | sed -E "s/.*password: '(.+)'.*/\1/");
  lando ssh --service mysqldb -c "mysqldump -uuser -p$password main" | platform sql;
  platform mount:upload --yes --source=public/var --mount=public/var;
fi;

platform environment:ssh php bin/console ibexa:graphql:generate-schema;
lando php bin/console ibexa:graphql:generate-schema;

# Seems done by deployment hooks
#platform environment:ssh composer run post-install-cmd;
#lando composer run post-install-cmd;

lando info --format=table;

exit 0;

# git checkout -b staging;
# git push --set-upstream platform staging;
# git branch -vv;