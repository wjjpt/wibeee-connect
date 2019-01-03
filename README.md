# wibeee

Service that receive events from wibeee sensor, decode and inject into WDP data pipeline (kafka based).

More info for wibeee: http://wibeee.circutor.com

More info for WDP: https://wizzie.io

# BUILDING

- Build docker image:
  * git clone https://github.com/wjjpt/wibeee-connect.git
  * cd src/
  * docker build -t wjjpt/wibeee .

# EXECUTING

- Execute app using docker image:

`docker run --env KAFKA_BROKER=X.X.X.X --env KAFKA_PORT=9092 --env WIBEEE_PORT=8080 -ti wjjpt/wibeee`

