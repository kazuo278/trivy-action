#!/bin/sh

## キャッシュ確認 ここから

echo "du -h $GITHUB_WORKSPACE/.cache/trivy @conainer"
du -h $GITHUB_WORKSPACE/.cache/trivy
echo "env"
env

## キャッシュ確認 ここまで

# Private Registry用の認証設定
## ID、パスワードは環境変数TRIVY_USERNAME、TRIVY_PASSWORDに設定する必要がある
##　https://aquasecurity.github.io/trivy/v0.36/docs/advanced/private-registries/docker-hub/
if [ -n $INPUT_TRIVY_USERNAME ]; then
  export TRIVY_USERNAME=$INPUT_TRIVY_USERNAME
fi
if [ -n $INPUT_TRIVY_PASSWORD ]; then
  export TRIVY_PASSWORD=$INPUT_TRIVY_PASSWORD
fi

# 実行オプションの作成
OPTION=""
## --security-checks
if [ -n $INPUT_SECURITY_CHCEKS ]; then
  OPTION="$OPTION --security-checks=$INPUT_SECURITY_CHCEKS"
fi
## --exit-code
if [ -n $INPUT_EXIT_CODE ]; then
  OPTION="$OPTION --exit-code=$INPUT_EXIT_CODE"
fi
## --format
# table, json, templateを想定。
# formatにはgithubもあり、Dependency Snapshotsに登録できる形式になるが、
# GitHub側がimageスキャン結果には対応していないため本アクションでは想定しない。
if [ -n $INPUT_FORMAT ]; then
  OPTION="$OPTION --format=$INPUT_FORMAT"
fi
## --template
if [ -n $INPUT_TEMPLATE ]; then
  OPTION="$OPTION --template=$INPUT_TEMPLATE"
fi
## --output
if [ -n $INPUT_OUTPUT ]; then
  OPTION="$OPTION --output=$INPUT_OUTPUT"
fi
## --severity
if [ -n $INPUT_SEVERITY ]; then
  OPTION="$OPTION --severity=$INPUT_SEVERITY"
fi
## --timeout
if [ -n $INPUT_TIMEOUT ]; then
  OPTION="$OPTION --timeout=$INPUT_TIMEOUT"
fi
## その他オプション
if [ -n "$INPUT_OPTIONS" ]; then
  OPTION="$OPTION $INPUT_OPTIONS"
fi
## 固定値 --cache-dir
## $GITHUB_WORKSPACE(=/github/workspace)配下にキャッシュさせる。
## /github/workspaceには、Runnerの$RUNNER_WORKSPACE/アクション名がマウントされる。
OPTION="$OPTION --cache-dir=$GITHUB_WORKSPACE/.cache/trivy"

cat <<EOM
以下のコマンドを実行します
  trivy image $INPUT_IMAGE_NAME:$INPUT_IMAGE_TAG $OPTION"
EOM

trivy image $INPUT_IMAGE_NAME:$INPUT_IMAGE_TAG $OPTION
EXIT_CODE=$?

if [ $INPUT_NEEDS_DISPLAY == "true" ]; then
  echo  "検査結果を出力します"
  cat $INPUT_OUTPUT
fi

## testここから

echo "du -h $GITHUB_WORKSPACE/.cache/trivy @conainer"
du -h $GITHUB_WORKSPACE/.cache/trivy
echo "ls -la $GITHUB_WORKSPACE/.cache/trivy"
ls -la $GITHUB_WORKSPACE/.cache/trivy

## testここまで

# .cache/trivyをキャッシュさせる場合、そのままでは権限エラーでキャッシュ不可のため
# $GITHUB_WORKSPACE(=/github/workspace)ディレクトリと同様の権限にする。
echo "ls -l $GITHUB_WORKSPACE/.."
ls -l $GITHUB_WORKSPACE/..
USER_NAME=$(ls -l $GITHUB_WORKSPACE/.. | tail -n1 | awk -F' ' '{print $3}')
GROUP_NAME=$(ls -l $GITHUB_WORKSPACE/.. | tail -n1 | awk -F' ' '{print $4}')
echo "chown -R $USER_NAME:$GROUP_NAME $GITHUB_WORKSPACE/.cache"
chown -R $USER_NAME:$GROUP_NAME $GITHUB_WORKSPACE/.cache
echo "ls -la $GITHUB_WORKSPACE/.cache"
ls -la $GITHUB_WORKSPACE/.cache

exit $EXIT_CODE