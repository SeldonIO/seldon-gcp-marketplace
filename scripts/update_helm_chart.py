import yaml
from io import StringIO
import os
import sys
import argparse
import re
import shutil


def dict_to_yaml(d):
    return yaml.dump(d, default_flow_style=False)

def yaml_to_dict(yaml_data):
    return yaml.load(StringIO(yaml_data))


def update_values_yaml_file(fpath):
    fpath = os.path.realpath(fpath)
    f = open(fpath)
    yaml_data = f.read()
    f.close()

    d = yaml_to_dict(yaml_data)
    d['rbac']['create'] = False
    d['serviceAccount']['create'] = False    
    
    with open(fpath, 'w') as f:
        f.write(dict_to_yaml(d))

    print("updated {fpath}".format(**locals()))


def main(argv):
    VALUES_YAML_FILE = 'chart/seldon-core-operator/values.yaml'
    update_values_yaml_file(VALUES_YAML_FILE)

if __name__ == "__main__":
    main(sys.argv)

