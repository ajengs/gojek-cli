DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ruby -r "$DIR/../lib/app" -e "GoCLI::App.run"
