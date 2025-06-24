import json
import sys
import subprocess
import argparse
from typing import Dict, Any, List

def run_kubectl_command(args: List[str]) -> str:
    try:
        result = subprocess.run(
            ["kubectl"] + args,
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error running kubectl: {e}", file=sys.stderr)
        return "{}"


def get_pods() -> Dict[str,any]:
    output =  run_kubectl_command([
        "get", "pods",
        "-n", "opentofu-ansible",
        "-o", "json"
    ])
    try:
        return json.loads(output)
    except json.JSONDecodeError:
        return {"items": []}

def build_inventory() -> Dict[str,any]:
    pods = get_pods()
    inventory = {
        "ubuntu": {
            "hosts": [],
            "vars" : {
                "ansible_python_interpreter": "/usr/bin/python3",
                "ansible_connection": "kubectl",
                "ansible_kubectl_namespace": "opentofu-ansible"
            }
        },
        "centos": {
            "hosts": [],
             "vars" : {
                "ansible_python_interpreter": "/usr/bin/python3",
                "ansible_connection": "kubectl",
                "ansible_kubectl_namespace": "opentofu-ansible"
            }
        },
        "kubernetes": {
            "children": ["ubuntu","centos"]
        },
        "_meta": {
            "hostsvars": {}
        }
    }

    for pods in pods['items']:
        pod_name = pods["metadata"]["name"]
        pod_status = pods.get("status",{}).get("phase","Unknown")

        #only include running pods
        if pod_status != "Running":
            continue

        if "ubuntu" in pod_name:
            inventory['ubuntu']["hosts"].append(pod_name)
            container_name = "ubuntu"
        elif "centos" in pod_name:
            inventory['centos']['hosts'].append(pod_name)
            container_name = "centos" 
        else:
            continue

        inventory["_meta"]["hostvars"][pod_name] = {
            "ansible_connection": "kubectl",
            "ansible_kubectl_namespace": "opentofu-ansible",
            "ansible_kubectl_container": container_name,
            "ansible_kubectl_pod": pod_name,
            "pod_ip": pods.get("status", {}).get("podIP", ""),
            "node_name": pods.get("spec", {}).get("nodeName", "")
        }
    return inventory

def get_host_vars(hostname:str) -> Dict[str,Any]:
    inventory = build_inventory()
    return inventory['_meta']['hostvars'].get(hostname,{})

def main():
    parser = argparse.ArgumentParser(description='Kubernetes dynamic inventory')
    parser.add_argument('--list', action='store_true', help='List all hosts')
    parser.add_argument('--host', help='Get Variables for a specific host')

    args = parser.parse_args()
    if args.list:
        inventory = build_inventory()
        print(json.dumps(inventory, indent=2))
    elif args.host:
        host_vars = get_host_vars(args.host)
        print(json.dumps(host_vars, indent=2))
    else:
        parser.print_help()

if __name__=='__main__':
    main()
