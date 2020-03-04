# Introduction
The purpose of this project is to containerize a PlantUML Python3 client, [PlantWeb](https://github.com/carlos-jenkins/plantweb). This project also manages a docker-compose configuration file that makes it easy to run the PlantUML client container and the [GitHub: PlantUML Server container](https://github.com/devtestlabs-xyz/plantuml-server-container) in the same network. Both these containers are used for out-of-band image generation. This image generation process is useful on a development workstation and may be run on a dedicated host server and integrated with a CI/CD pipeline.

# Getting Started
## Get the image
```
docker pull devtestlabs/plantuml-client:{{ VARIANT_TAG }}
```
*NOTE: Replace `{{ VARIANT_TAG }}` with a [valid image variant tag]()*

## Run Container
### Using Docker
#### Pre-Flight
Start PlantUML server
```
docker run -d -p 8081:8080 devtestlabs/plantuml-server
```
The server is now listing to [http://localhost:8080/plantuml](http://localhost:8081/plantuml) and to http://{{ DOCKER_HOST_IP_OR_DNS }}:8081.

#### Run with specified user, uid, and gid
```
docker run -it --rm \
  -v $(pwd)/test/.puml:/puml \
  -v $(pwd)/test/.images:/images \
  -e UID_=$(id -u) \
  -e GID_=$(id -g) \
  -e OUT_IMAGE_FILE_FORMAT_="png" \
  devtestlabs/plantuml-client
```

*NOTE: `OUT_IMAGE_FILE_FORMAT_` is optional. The default value is `png`. The value is passed into and set in `entrypoint.sh`.*
*NOTE: Instead of passing atomic environment variables on the commandline you may use an `.env` file. Use `--env-file` commandline option. Create `.env` file and put one environment per line. An example `.env` file is included in this project. You can simply replace the values with applicable values.*

### Using Docker Compose
A parameterized `docker-compose.yaml` file exists. A `.env` file is used to store all of the necessary environment variable values that are passed to Docker Compose. `docker-compose-up.sh` is a shell script that gets the environment variables from the `.env` file and then executes `docker-compose up`. This shell script is necessary because `--env-file` is not a valid option for `docker-compose` cli. Currently 

To successfully execute the bulk image generation process:
1. Create a `.env` file with applicable values
1. In Terminal, execute `./docker-compose-up.sh {{ DOT_ENV_FILE_NAME }}

*NOTE: Replace `{{ DOT_ENV_FILE_NAME }}` with the actual file name you want to use.*

#### Important notes about the .env file
Below is the contents of the `.env.example` file.

*.env.example*
```
UID=999999900
GID=999999999
PLANTUML_SERVER_HOST_PORT=8081
PLANTUML_SERVER_URI=http://plantuml-server:8080/
OUT_IMAGE_FILE_FORMAT=png
PUML_HOST_MOUNT=./test/.puml
IMAGES_HOST_MOUNT=./test/.images
```

* *UID* - the UID of your current user on the Docker host (your workstation for example). On Linux, you can get your user's UID using `echo $(id -u)`.

* *GID* - the GID of the primary group your user is part on the Docker host. On Linux, you can get your user's GID using `echo $(id -g)`.

* *PLANTUML_SERVER_HOST_PORT* - the host port side of the Docker HOST_PORT:CONTAINER_PORT map. Aclient outside of this swarm can access the PlantUML Server from http://localhost:8081 on the host or from http://{{ HOST_IP_OR_DNS }}:8081 if the firewall allows the host to listen for requests on 8081.

* *PLANTUML_SERVER_URI* - the URI for in-swarm service to service communication. 'plantuml-server' is the image alias specified in the docker-compose.yaml file. It's important to note that the container side port of the Docker HOST_PORT:CONTAINER_PORT map is used!

* *OUT_IMAGE_FILE_FORMAT* - the image file format passed to the PlantUML Server. PlantUML Server will consume the specified source `*.puml` files and generate image files of the specified image format. PlantUML Server will accept `png` (default) or `svg`. 

* *PUML_HOST_MOUNT* - the host side of the HOST_MOUNT_PATH:CONTAINER_MOUNT_PATH map. This is the root path in which all your source `*.puml` files exist. 

* *IMAGES_HOST_MOUNT* - the host side of the HOST_MOUNT_PATH:CONTAINER_MOUNT_PATH map. This is the path in which all the generated images will be persisted. 

## Evaluate use of PlantUML client container
Using Docker Compose is the recommended route to evaluate and use PlantUML to generate images. You can quickly test/evaluate this PlantUML solution. 

To test this solution, in Terminal, execute:

```
echo $(id -u)
echo $(id -g)

```

Copy the UID and GID values and replace the `UID` and `GID` environment variable values in the `.env.example` file.

Finally, execute:

```
./docker-compose-up.sh .env.example
```

The expected outcome is that all `*.puml` files in `./test/.puml` are consumed and generated the images (`test1.png`, `test2.png`, and `test3.png`) are persisted in `./test/.images`. 

If you want to advance your evaluation of this solution, open `.env.example` and change the `OUT_IMAGE_FILE_FORMAT` environment variable statement `OUT_IMAGE_FILE_FORMAT=png` to `OUT_IMAGE_FILE_FORMAT=svg`. Finally, execute `./docker-compose-up.sh .env.example` again. You should now see 3 svg format files. You can view the rendered images in Firefox or Chrome browsers.

# Build the Docker image locally

```
docker build -t devtestlabs/plantuml-client:local .
```

# External References
* https://github.com/carlos-jenkins/plantweb
* https://plantweb.readthedocs.io/#python-api
* https://github.com/dougn/python-plantuml
* https://hub.docker.com/_/python
* https://docs.docker.com/v17.09/compose/gettingstarted/#step-8-experiment-with-some-other-commands
* https://docs.docker.com/v17.09/compose/environment-variables/