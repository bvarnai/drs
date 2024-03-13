# drs demo

This is docker based, pre-configured client-server setup to demonstrate `drs` features.

The server is a simple SSH server with `drs` user added. The client is just a shell to play with `drs` commands. SSH has pre-configured keys and will work out-of-box.

Networking is private to these containers. For demonstration purposes only.

## Up

1. Start the server container in the background
    ```bash
    docker-compose up -d drs-server
    ```
2. Start the interactive shell within the client container
    ```bash
    docker-compose run --rm drs-client
    ```
3. Verifing the connection the client shell
    ```bash
    ssh drs-server
    ```

## Use

1. Clone and setup `drs` repository
    ```bash
    git clone drs-server:drs-demo
    cd drs-demo
    $DRS_HOME/install.sh
    ```
3. Create the first revision with some sample content and put it to `drs`
    ```bash
    mkdir myproject
    echo "Hello World" >> myproject/file1
    git drs-put
    ```
4. Create a second revision with some sample content on a branch and put it to `drs`
    ```bash
    git drs-create myfeature
    echo "Hello World" >> myproject/file2
    git drs-put
    ```
5. Go back to  `master` branch and get the latest revision
    ```bash
    git drs-select master
    git drs-get --latest
    ```
    If you check the files in `myproject` directory, you will notice only `file1` is present. Directory `myproject` is syncronized with the last revision on this branch.

## Down

To stop all services use
```bash
docker-compose down
```
