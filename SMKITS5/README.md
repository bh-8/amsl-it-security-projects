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
### Generating a testset
- `./stego-attrib.sh --generate-testset ./your_cover_file_directory` will generate a testset by using the first image in your cover data directory
  - switch `-c` will clean the output directory prior to the generation
  - switch `-s` will randomize the cover image selection
  - switch `-n <int>` will set the size of your testset (if you need more than one image, which will commonly be the case)
  - generated stego images will be stored in `/data/out-stego-attrib/testset` inside your docker container
### Perform stego test for your testset
- `./stego-attrib.sh --testset ./out-stego-attrib/testset` will run stego tests for the first image in your testset directory
  - switch `-s` will randomize the stego image selection
  - switch `-n <int>` will set the amount of files to test (if you need more than one image, which will commonly be the case)
  - do **not** use switch `-c` as you would wipe your testset resulting in an error
