docker kill gomob
docker rm gomob
docker run -d --name gomob android-gomobile /bin/bash -c "while true; do sleep 10;done"
