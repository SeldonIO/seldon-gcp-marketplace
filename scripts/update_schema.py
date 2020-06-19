import yaml
from io import StringIO
import os
import sys

def dict_to_yaml(d):
    return yaml.dump(d, default_flow_style=False)

def yaml_to_dict(yaml_data):
    return yaml.load(StringIO(yaml_data))

def read_file(fpath):
    fpath = os.path.realpath(fpath)
    f = open(fpath)
    yaml_data = f.read()
    f.close()
    return yaml_data

def update_rbac(templateFile, schemaFile):
    # Extract RBAC from template
    yaml_data = read_file(templateFile)
    idx = 0
    clusterRolesRules = []
    rolesRules = []
    for doc in yaml.load_all(StringIO(yaml_data)):
        idx += 1
        if doc["kind"] == "ClusterRole":
            print("Adding cluster roles from ", doc["metadata"]["name"])
            clusterRolesRules.extend(doc["rules"])
        elif doc["kind"] == "Role":
            print("Adding roles from ", doc["metadata"]["name"])
            rolesRules.extend(doc["rules"])

    # Update schema.yaml
    yaml_data = read_file(schemaFile)
    d = yaml_to_dict(yaml_data)
    d["properties"]["serviceAccount.name"]["x-google-marketplace"]["serviceAccount"]["roles"][0]["rules"] = rolesRules
    d["properties"]["serviceAccount.name"]["x-google-marketplace"]["serviceAccount"]["roles"][1]["rules"] = clusterRolesRules
    with open(schemaFile, 'w') as f:
        f.write(dict_to_yaml(d))

def main(argv):
    TEMPLATE_FILE="template.yaml"
    SCHEMA_FILE="schema.yaml"
    update_rbac(TEMPLATE_FILE,SCHEMA_FILE)

if __name__ == "__main__":
    main(sys.argv)

