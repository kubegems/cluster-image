#!/usr/bin/env bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
export readonly ARCH=${1:-amd64}
export readonly NAME=${2:-$(basename "${PWD%/*}")}
export readonly chartVersion=1.23.0
export readonly appVersion=v1.23.4

rm -rf charts/ && mkdir -p charts/
helm repo add kubegems https://charts.kubegems.io/kubegems
helm repo update kubegems
helm pull kubegems/kubegems-installer --version=${chartVersion} --untar -d charts/
#helm pull kubegems/kubegems --version=${VERSION#v} --untar -d charts/

cat <<EOF >"Kubefile"
FROM scratch
COPY registry ./registry
COPY manifest ./manifest
COPY charts ./charts
CMD ["helm upgrade -i kubegems-installer charts/kubegems-installer -n kubegems-installer --create-namespace --set installer.image.tag=${appVersion}","kubectl apply -f manifest/kubegems.yaml"]
EOF