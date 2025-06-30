#!/bin/bash
set -e


echo "==== Cleaning up OpenTofu, Semaphore, and Minikube resources ===="

# color codes for output
RED='\O33[O;31m'
GREEN='\O33[O;32m'
YELLOW='\O33[1;33m'
NC='\O33[Om' #no color


# function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Stop and remove Semaphore Containers 
print_status "Stopping Semaphore UI and MySQL containers..."

cd ~/projects/opentofu-semaphore-ansible/
cd semaphore
docker compose down -v
cd ..

# clean up openTofu resourcer
print_status "Destroying OpenTofu resources..."
cd opentofu
if [ -f terraform.tfstate ]; then   
    tofu destroy -auto-approve
fi 
cd ..

# delete minikube cluster
print_status "Deleting minikube cluster..."
minikube delete

# clean up docker resources
print_status "Cleaning up docker resources..."
docker system prune -f 

print_status "Cleanup Completed Successfully"
echo ""
echo "==== Resource Cleaned ===="
echo "- Semaphore UI and MySQL containers stopped and removed" 
echo "- OpenTofu resources destroyed" 
echo "- Minikube cluster deleted"
echo "-Docker system cleansed" 