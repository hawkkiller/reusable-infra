echo "Bootstraping the project.."
# input to get github owner name
echo "Enter your GitHub owner name: "
read OWNER
# input to get the repository name
echo "Enter your GitHub repository name: "
read REPO
# input from user to get the token from GitHub
echo "Enter your GitHub PAT: "
read GH_PAT
# input to get cluster path
echo "Enter the cluster path, like (./clusters/staging): "
read CLUSTER_PATH

flux bootstrap github \
  --token-auth \
  --owner=$OWNER \
  --repository=$REPO \
  --branch=main \
  --path=$CLUSTER_PATH \
  --personal
