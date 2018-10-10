# rpulsar
Apache Pulsar client for R

> For more details about Apache Pulsar, [click here](https://pulsar.apache.org/en/)

## Use the package

* Install the package

```
library(devtools)
install_github("bbonnin/rpulsar")
```

* Create a producer

```
producer <- Pulsar$new("localhost:8080", "persistent/public/default/my-topic")
producer$send("hello")
```

* Create a consumer

```
# Function invoked for each new message
# Do not forget to return TRUE to ack the message !!!

onMsg = function(payload) {
  cat("Received string:", rawToChar(payload), "\n")
  TRUE
}

consumer <- Pulsar$new("localhost:8080", "persistent/public/default/my-topic/my-sub",
                        onMessageFct = onMsg)
```


## Development

* Install packages you will need

```
install.packages("devtools")
library(devtools)

devtools::install_github("klutometis/roxygen")
library(roxygen2)
```

* Tests

```
devtools::load_all()

producer <- Pulsar$new("localhost:8080", "persistent/public/default/my-topic")
producer$send("hello")

onMsg = function(payload) {
  cat("Received string:", rawToChar(payload), "\n")
  TRUE
}
consumer <- Pulsar$new("localhost:8080", "persistent/public/default/my-topic/my-sub",
                        onMessageFct = onMsg)
}
```
