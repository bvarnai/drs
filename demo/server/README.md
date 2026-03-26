# drs server

To start the server container in the background:

```bash
docker-compose up -d drs-server
```

# Update drs-demo package

```bash
# extract server package
tar -xvzf drs-demo.git.tar.gz

# clone bare repository to temporary edits
git clone drs-demo temp-drs-demo

# make you changes in temp-drs-demo than push
# ...

# compress and cleanup
tar -czvf drs-demo.git.tar.gz drs-demo
rm -rf drs-demo
```
