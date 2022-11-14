# Attribution of Steganography and hidden Communication (jpg)
## Components
- [Stego-Toolkit Reference](https://github.com/DominicBreuker/stego-toolkit) (no need to download, just for reference)
- `stego-docker.sh` is meant to manage the docker environment
- `stego-attrib.sh` is meant to perform stego testset generation, analysis and evaluation;  
  therefore it will be executed **inside** a docker container to call the stego tools
## Environment Setup (Docker)
- put `stego-docker.sh` and `stego-attrib.sh` to any directory you want to work in
- make both scripts executable using `chmod +x ./stego-docker.sh` and `chmod +x ./stego-attrib.sh`
- run `./stego-docker.sh --setup` to install and configure docker (this will also update & upgrade apt)
- make sure your docker container has stego-toolkit installed by running `./stego-docker.sh --pull`
- now you should be able to run your docker container by calling `./stego-docker.sh --run`
- you should add **jpg cover files** to your docker container (e.g. download [kaggle/alaska2 cover files](https://www.kaggle.com/competitions/alaska2-image-steganalysis/data?select=Cover)) to have something to work with
- while your docker instance is running, you can import files (**use a new terminal instance!**) to the container with `./stego-docker.sh --import ./your_cover_file_directory`
- also do not forget to import `stego-attrib.sh` by running `./stego-docker.sh --import ./stego-attrib.sh`
## Attribution Script Usage
- the following is done inside the docker container
- you will need some example cover data and the imported `stego-attrib.sh` (see above)
### Performing an analysis
- `./stego-attrib.sh -i ./your_cover_file_directory` is the most minimal call, it will generate a testset by using the first image in your cover data directory and analyse the generated stego files
- possible switches are
  - `-i` or `--input`: set input directory (path to your cover files, this argument is **mandatory**)
  - `-o` or `--output`: set output directory (default is `./out-stego-attrib`)
  - `-n` or `--size`: set the amount of cover files to analyse (default is `1`)
  - `-s` or `--shuffle`: randomize the cover image selection
  - `-c` or `--clean`: clean the output directory prior to the generation
  - `-f` or `--fast`: skip stego tool `f5` and stego analysis tool `stegoveritas`, as those are the tools need the most time doing their thing
  - `-v` or `--verbose`: print every command execution to terminal
  - `-h` or `--help`: display usage
