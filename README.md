# Dockerfile Debian 10 for Laravel
Create a Docker Image with Debian 10, PHP 7.4, ODBC and SQLSRV

First of all, you need to build a new docker image from this Dockerfile. On your Dockerfile directory, run: <br>

    $ docker image build -t imageName .

Then, create a new Volume. For instance, you could name it <b>debian10_php74</b> <br>

    $ docker volume create debian10_php74

Now, you should run the following command to run your container and bind it to your new volume: <br>

    $ docker container run -d -p 8080:80 --mount type=volume,src=debian10_php74,dst=/var/www imageName
