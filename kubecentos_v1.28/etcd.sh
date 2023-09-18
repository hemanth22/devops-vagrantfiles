ETCD_VER=v3.5.5
mkdir /etcd/
chmod 755 /etcd/
# choose either URL
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}

rm -f /etcd/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf /etcd/etcd-download-test && mkdir -p /etcd/etcd-download-test

curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /etcd/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /etcd/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /etcd/etcd-download-test --strip-components=1
rm -f /etcd/etcd-${ETCD_VER}-linux-amd64.tar.gz

/etcd/etcd-download-test/etcd --version
/etcd/etcd-download-test/etcdctl version
