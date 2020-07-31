import sys

def main(args):
    with open("engine2.txt","r") as f:
        for line in f:
            line = line.strip()
            if line.startswith("*"):
                line = line.replace("*","").replace("(","").replace(")","").replace("-","").replace("* ","")
                parts = line.split()
                name = parts[0]
                url = parts[1]
                print(name+","+url+","+license,",,YES")
            elif len(line.strip()) > 0:
                license = line[0:-1].replace(",","")


if __name__ == "__main__":
    main(sys.argv)