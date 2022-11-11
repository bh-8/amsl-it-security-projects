# Usage
## Basics
### Stego-Toolkit
- [Stego-Toolkit](https://github.com/DominicBreuker/stego-toolkit)
### Scripts
- `stego-docker.sh` is meant to manage the docker environment
- `stego-attrib.sh` is meant to perform stego testset generation, analysis and evaluation; therefore it will be executed **inside** a docker container to call the stego tools
## Environment Setup (Docker)
- put `stego-docker.sh` and `stego-attrib.sh` to any directory you want to work in
- make both scripts executable using `chmod +x ./stego-docker.sh` and `chmod +x ./stego-attrib.sh`
- run `./stego-docker.sh --setup` to install and configure docker (this will also update & upgrade apt)
- make sure your docker container has stego-toolkit installed by running `./stego-docker.sh --pull`
- now you are able to run your docker container by calling `./stego-docker.sh --run`
- you should add jpg cover files to your docker container (e.g. download [kaggle/alaska2 cover files](https://www.kaggle.com/competitions/alaska2-image-steganalysis/data?select=Cover))
