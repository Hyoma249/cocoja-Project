#!/bin/bash
set -e #エラーが発生したらスクリプトを終了する

# /tmp/pids/server.pidが存在する場合、削除する
rm -f /myapp/tmp/pids/server.pid

# Docker の CMD で渡されたコマンドを実行
exec "$@"
