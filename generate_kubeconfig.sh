namespace=$1
secret=$2

if [ -z "$namespace" ] || [ -z "$secret" ]
then
  echo "Usage :"
  echo "$0 <namespace> <secret>"
  exit 1
fi

readonly context=$(kubectl config current-context)
cluster=$(kubectl config view -o jsonpath="{.contexts[?(@.name == \"$context\")].context.cluster}")
sa=$(kubectl get -n $namespace secret/$secret -o jsonpath='{.metadata.annotations.kubernetes\.io/service-account\.name}')

echo "Please be sure that your kubectl context is the good one !"
echo "********"
echo "context        : $context"
echo "server         : $cluster"
echo "service-account: $sa"
echo "namespace      : $namespace"
echo "********"
echo "sure ? (<ENTER>/<CTRL+C>)"
read -r

server=$(kubectl config view -o jsonpath="{.clusters[?(@.name == \"$cluster\")].cluster.server}")
ca=$(kubectl get -n $namespace secret/$secret -o jsonpath='{.data.ca\.crt}')
token=$(kubectl get -n $namespace secret/$secret -o jsonpath='{.data.token}' | base64 --decode)
namespace=$(kubectl get -n $namespace secret/$secret -o jsonpath='{.data.namespace}' | base64 --decode)

cat > "kubeconfig_$namespace@${cluster}.config" <<EOF
apiVersion: v1
kind: Config
preferences: {}

# Define the cluster
clusters:
- name: ${cluster}
  cluster:
    certificate-authority-data: ${ca}
    server: ${server}

# Define the context: linking a user to a cluster
contexts:
- name: $namespace@${cluster}
  context:
    cluster: ${cluster}
    namespace: $namespace
    user: $sa

# Define current context
current-context: $namespace@${cluster}

# Define the user
users:
- name: $sa
  user:
    token: ${token}
EOF

echo "kubeconfig has been generated"
