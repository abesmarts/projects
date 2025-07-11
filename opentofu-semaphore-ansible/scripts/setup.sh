#! /bin/bash
set -e

echo "Setting up OpenTofu, semaphore, Ansible, and MiniKube"

# color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color


# function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}


print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# installing homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew/shellenv)"' >> ~/.zshrc
    source ~/.zshrc
else 
    print_status "Homebrew already installed"
fi

#update homebrew 
print_status "Updating Homebrew..."
brew update


# installing req packages
print_status "Installing required packages..."
brew install opentofu ansible kubectl minikube jq git curl wget

# install Docker desktop if not present 
if ! command -v docker &> /dev/null; then
    print_error "Docker Desktop is not installed or not running."
    print_status "Please install Docker Desktop from https://www.docker.com/products/docker-desktop/"
    print_status "After installation start Docker Desktop and run this script again."
    exit 1
fi

# checking if docker is runnig 
if ! docker info &> /dev/null; then
    print_error "Docker is not running. Going to run."
    # start Docker Desktop
    open -a Docker
    exit 1
fi 



# # starting minikube
# minikube start --driver=docker --memory=4096 --cpus=2


# #verify minikube
# kubectl config use-context minikube
# kubectl get nodes

#getting ssh keys

if [ ! -f ~/.ssh/id_rsa ]; then
    print_status "Generating SSH Keys..."
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
else 
    print_status "SSH keys already exist"
fi

# Making necessary direcoties
print_status "Creating project directories..."
#mkdir -p opentofu anisble/inventory ansible/group_vars ansible/roles/common/ {tasks,handlers,defaults,templates} ansible/roles/mysql/{tasks, defaults, templates} ansible/playbooks sempahore
cd ~/projects/opentofu-semaphore-ansible/


#start semaphore ui
print_status "Starting Semaphore UI with MySQL backend..."
cd semaphore 
docker compose down -v
docker compose build --no-cache
docker compose up -d



# wait for services to start 
print_status "Waiting for services to initialize..."
sleep 30

# # create MySQL tables for state storage
print_status "Initialize MySQL database tables..."
docker exec -i semaphore-mysql-1  mysql -u semaphore -psemaphore semaphore < init-mysql.sql

# initializing OpenTofu 
print_status "Initializing OpenTofu..." 
cd ..
cd opentofu 
tofu init
cd .. 

echo "Verifying opentofu, ansible, and docker integration in the semaphore container"

echo "===================================="
echo "Verifying OpenTofu installation..."
# docker compose exec semaphore tofu version

echo "Verifying ansible installation..."
docker compose exec semaphore ansible --version

echo "Verifying docker integration (should list running containers)..."
docker compose exec semaphore docker ps


print_status "Setup Completed Successfully!"
echo ""
echo "=====Access Information ====="
echo "Sempahoore UI: https://localhost:3000"
echo "Username: admin"
echo "Password: semaphorepassword"
echo ""
echo "==== Next Steps ===="
echo "1. Access Semaphore UI and configure your project" 
echo "2. Add SSH Keys to the Key store"
echo "3. Create inventories and trask templates"
echo "4. Run your first CI/CD pipeline"
echo ""
echo "==== Useful Commands ===="
echo "Check Minikube status:minikube status"
echo "Access Minikube dashboard: minikube dashboard"
echo "View Sempahore logs: cd semaphore && docker compose logs -f"