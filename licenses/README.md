To update licenses

Update makefile and update VERSION to current.

Remove any existing seldon-core folder

```
make clean update_all
```

Then to capture screenshots of the licenses in the images.

Ensure all images are built.

```
cd .. && make build_all
```

For operator and executor

```
make show_operator_licenses
make show_executor_licenses
```

Screenshot the terminal and extract images for licenses and mpl library source and copy those to this folder


Update spreadsheets for google with csvs and images if licenses have changed.

Do this by appending the csvs created. In Google sheets select Import and choose "Append to current sheet". Remove existing licenses and append.

You will need to update to YES the columns where the source has been included in the image, such as hashicorp-golang-lru.
