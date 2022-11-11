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
- pull the stego-toolkit to a container by executing `./stego-docker.sh --run`
- 
