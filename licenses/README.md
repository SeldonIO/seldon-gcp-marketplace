To update licenses

Update makefile and update VERSION to current, e.g. 1.16.0

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

* [Executor Spreadsheet](https://docs.google.com/spreadsheets/d/1RFG4TqzipdV8GTpWl8O3lZfc7uvb2h3jftcBL62knrE/edit#gid=1834865489)
* [Operator Spreadsheet](https://docs.google.com/spreadsheets/d/1aRZotyw9rqdMafUhh8_YrSA7uXQyvygGP9wtFD1C1zI/edit#gid=213073333)


Do this by appending the csvs created. In Google sheets select Import and choose "Append to current sheet". Remove existing licenses and append.

You will need to update to YES the columns where the source has been included in the image, such as hashicorp-golang-lru.
