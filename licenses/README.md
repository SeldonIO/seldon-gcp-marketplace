To update licenses

Update makefile and update VERSION to current.

Remove any existing seldon-core folder

```
make update_all
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


For engine

```
show_engine_licenses
```

Screenshot the terminal.

Update spreadsheets for google with csvs and images if licenses have changed.

