import json, sys, subprocess

def get_pods():
    result = subprocess.run(["kubectl", "get", "pods", "-n", "opoentofu-ansible", "-o", "json"],
                            capture_output=True, text=True)
    return json.loads(result.stdout)

def build_inventory():
    pods = get_pods()
    inventory = {
        "ubuntu": {
            "hosts": []
        },
        "centos": {
            "hosts": []
        },
        "_meta": {
            "hostsvars": {}
        }
    }

    for pods in pods['items']:
        pod_name = pods["metadata"]["name"]
        if "ubuntu" in pod_name:
            inventory['ubuntu']["hosts"].append(pod_name)
        elif "centos" in pod_name:
            inventory['centos']['hosts'].append(pod_name)

        inventory["_meta"]["hostvars"][pod_name] = {
            "ansible_connection": "kubectl",
            "ansible_kubectl_namespace":"opentofu-ansible",
            "ansible_kubectl_container": pod_name.split("-")[0]
        }
    return inventory

if __name__=='__main__':
    inventory = build_inventory()
    print(json.dumps(inventory,indent=2))
