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

def update_values_yaml_file(fpath):
    yaml_data = read_file(fpath)

    d = yaml_to_dict(yaml_data)
    d['rbac']['create'] = False
    d['rbac']['configmap']['create'] = True
    d['serviceAccount']['create'] = False
    d['crd']['create'] = False
    d['managerCreateResources'] = True

    with open(fpath, 'w') as f:
        f.write(dict_to_yaml(d))

    print("updated {fpath}".format(**locals()))

def main(argv):
    VALUES_YAML_FILE = 'chart/seldon-core-operator/values.yaml'
    update_values_yaml_file(VALUES_YAML_FILE)

if __name__ == "__main__":
    main(sys.argv)

