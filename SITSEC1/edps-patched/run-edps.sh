#!/bin/bash
docker run --name edps_patched --tty --rm --cap-add=SYS_ADMIN --volume=$(realpath ./edps-output):/home/wec/edps-output edps_patched:latest $@
exit 0
