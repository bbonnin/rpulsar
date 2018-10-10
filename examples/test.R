devtools::install_github("bbonnin/rpulsar")

library(rpulsar)

onMsg = function(payload) {
  cat("Received string:", rawToChar(payload), "\n")
  TRUE
}

consumer <- Pulsar$new("localhost:8080", "persistent/public/default/my-topic/my-sub",
                       onMessageFct = onMsg)

producer <- Pulsar$new("localhost:8080", "persistent/public/default/my-topic")
producer$send("hello")

