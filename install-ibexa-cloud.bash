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

EMPTY_LOCAL_REPO_DIR=1;
GIT_IGNORE_AUTH_JSON=1;
FILL_PSH_CONTENT_FIRST=0;


function wait_platform_activity()
{
  if [ -n "$1" ]; then
    project_option="--project=$1";
  else
    project_option='';
  fi;
  if [ -n "$2" ]; then
    environment_option="--environment=$2";
  else
    environment_option='';
  fi;
  sleep 20;
  while [ -n "$(platform activity:list --incomplete $project_option $environment_option --no-header --format=plain 2> /dev/null)" ]; do
    sleep 10;
  done
}

function sedi() {
  ## Regular
  #sed -i -e $*;
  ## MacOS
  sed -i '' -e "$1" $2;
}


platform integration:add --yes --project=$PLATFORM_PROJECT_ID --type=github --token=$GITHUB_TOKEN --repository=$GITHUB_REPO --build-pull-requests=false --build-draft-pull-requests=false --fetch-branches=true --prune-branches=true;
integration=`platform integration:list --project=$PLATFORM_PROJECT_ID --format=csv | grep $GITHUB_REPO;`;
platform integration:validate --project=$PLATFORM_PROJECT_ID ${integration%%,*};
platform integration:get --project=$PLATFORM_PROJECT_ID ${integration%%,*};

if [ 1 -eq $EMPTY_LOCAL_REPO_DIR ]; then
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
composer config http-basic.updates.ibexa.co $IBEXA_REPO_USER $IBEXA_REPO_PASS; # auth.json
#composer config repositories.ibexa composer https://updates.ibexa.co;
composer install --no-scripts;

composer ibexa:setup --platformsh;

if [ ! -f .gitignore ] && [ -f .gitignore.dist ]; then
  cp .gitignore.dist .gitignore;
fi;
if [ 1 -eq $GIT_IGNORE_AUTH_JSON ]; then
  echo 'auth.json' >> .gitignore;
  platform variable:create --project=$PLATFORM_PROJECT_ID --level=project --name=env:COMPOSER_AUTH \
    --json=true --visible-runtime=false --sensitive=true --visible-build=true \
    --value="$(tr -d '\n' < auth.json | sed -e 's/  */ /g')";
fi;

git init;
# git remote add origin git@github.com:$GITHUB_REPO; # `platform` remote added by next step is enough
platform project:set-remote $PLATFORM_PROJECT_ID;
git remote -v;

git add ./ 2>/dev/null;
git commit -m "create-project ibexa/$skeleton ./";
git branch -M $DEFAULT_BRANCH;
#git push -u origin $DEFAULT_BRANCH;
git push -u platform $DEFAULT_BRANCH;
wait_platform_activity $PLATFORM_PROJECT_ID;

if [ 'master' != "$DEFAULT_BRANCH" ]; then
  platform project:info default_branch $DEFAULT_BRANCH --project=$PLATFORM_PROJECT_ID;
  wait_platform_activity $PLATFORM_PROJECT_ID;
  platform environment:info --project=$PLATFORM_PROJECT_ID --environment=$DEFAULT_BRANCH parent -;
  platform environment:delete master --delete-branch --project=$PLATFORM_PROJECT_ID --yes;
fi;

composer recipes:install ibexa/${IBEXA_DXP_VERSION%:*} --force --no-interaction;
if [ '' != "$(git diff)" ]; then
  git add ./;
  git commit -m "recipes:install ibexa/${IBEXA_DXP_VERSION%:*}";
  git push;
  wait_platform_activity $PLATFORM_PROJECT_ID $DEFAULT_BRANCH;
fi;

sedi 's/10.15.3/10.19.0/' .platform.app.yaml;
git add ./;
git commit -m 'Update node version

error @symfony/webpack-encore@1.1.2: The engine "node" is incompatible with this module. Expected version "^10.19.0 || ^12.0.0 || >=14.0.0". Got "10.15.3"';
git push;
wait_platform_activity $PLATFORM_PROJECT_ID $DEFAULT_BRANCH;

platform environment:activate --yes --no-wait $DEFAULT_BRANCH;
wait_platform_activity $PLATFORM_PROJECT_ID $DEFAULT_BRANCH;

lando init --source cwd --recipe platformsh --platformsh-site "$PLATFORM_PROJECT_NAME" --platformsh-auth $PLATFORM_TOKEN;
lando rebuild;

if [ 1 -eq $FILL_PSH_CONTENT_FIRST ]; then
  echo "Populate P.sh current project and environment database";
  platform environment:ssh php bin/console ibexa:install;
  echo "Download/Copy content to local Lando";
  platform db:dump --stdout | lando database main;
  platform mount:download --yes --mount=public/var --target=public/var;
  #lando php bin/console ibexa:reindex;#No Solr yet
else
  echo "Populate local Lando database";
  lando php bin/console ibexa:install;
  echo "Upload/Copy content to P.sh current project and environment";
  password=$(lando info --service=mysqldb | grep password | sed -E "s/.*password: '(.+)'.*/\1/");
  lando ssh --service mysqldb -c "mysqldump -uuser -p$password main" | platform sql;
  platform mount:upload --yes --source=public/var --mount=public/var;
  #lando php bin/console ibexa:reindex;#No Solr yet
fi;

platform environment:ssh php bin/console ibexa:graphql:generate-schema;
lando php bin/console ibexa:graphql:generate-schema;


sedi 's/        composer install --no-dev --prefer-dist --no-progress --no-interaction --optimize-autoloader/        if [ "dev" = "$APP_ENV" ]; then\
            composer install --dev --no-interaction\
        else\
            composer install --no-dev --prefer-dist --no-progress --no-interaction --optimize-autoloader\
        fi/g' .platform.app.yaml

git add .platform.app.yaml;
git commit -m '.platform.app.yaml: Add APP_ENV=dev possibility';
git push;
wait_platform_activity $PLATFORM_PROJECT_ID $DEFAULT_BRANCH;


# https://docs.lando.dev/config/platformsh.html#environment-variables
echo "  overrides:
    app:
      variables:
        env:
          APP_ENV: dev" >> .lando.yml;
lando rebuild;


vendor/ezsystems/ezplatform-solr-search-engine/bin/generate-solr-config.sh;
sedi 's/#\(solr:.*\)/\1/' .platform.app.yaml;
sedi '/solrsearch/,/core: collection1/ s/^#//' .platform/services.yaml;
git add .platform/configsets/ .platform.app.yaml .platform/services.yaml;
git commit -m 'Enable Solr';
git push;
wait_platform_activity $PLATFORM_PROJECT_ID $DEFAULT_BRANCH;


# Avoid having 'http://solr.internal:8080/solr/solrsearch'
#echo '          SOLR_CORE: collection1' >> .lando.yml;
#echo '          SISO_SEARCH_SOLR_CORE: collection1' >> .lando.yml;
#lando rebuild;
sedi 's/%solr_core%/collection1/' config/packages/ezplatform_solr.yaml;
lando php bin/console cache:clear;
lando php bin/console ibexa:reindex;

platform environment:ssh php bin/console ibexa:reindex;


exit 0;
