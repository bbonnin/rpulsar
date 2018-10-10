#' Pulsar class
#'
#' @param connection Pulsar host and port (format: "hostname:port")
#' @param topic Full name of the topic including persistence, tenant, namespace and pub/sub name
#' @param onMessageFct Function invoked when when receiving message
#'
#' @return a Pulsar connection object
#' @export
#'
#' @examples
#' \dontrun{
#' producer <- Pulsar$new("localhost:8080", "persistent/public/default/my-topic")
#' producer.send("hello")
#'
#' onMsg = function(payload) {
#'   cat("Received string:", rawToChar(payload), "\n")
#'   return TRUE
#' }
#' consumer <- Pulsar$new("localhost:8080", "persistent/public/default/my-topic/my-sub",
#'                        onMessageFct = onMsg)
#' }
Pulsar <- R6::R6Class("Pulsar", public = list(

  initialize = function(connection, topic, autoReconnect = TRUE, onMessageFct = NULL) {

    private$onMessageFct <- onMessageFct
    private$autoReconnect <- autoReconnect

    private$endpoint <- paste0("ws://", connection, "/ws/v2/")

    if (is.null(onMessageFct)) {
      private$endpoint <- paste0(private$endpoint, "producer/")
    }
    else {
      private$endpoint <- paste0(private$endpoint, "consumer/")
    }

    private$endpoint <- paste0(private$endpoint, topic)

    self$connect()
  },

  toString = function() {
    paste0("Pulsar: endpoint=", private$endpoint)
  },

  connect = function() {
    cat("Connecting ", private$endpoint, "...")

    private$ws <- websocket::WebSocket$new(private$endpoint, autoConnect = TRUE)

    private$ws$onOpen(function(event) {
      cat("Connection opened\n")
    })

    private$ws$onClose(function(event) {
      cat("Client disconnected with code ", event$code, " and reason ", event$reason, "\n", sep = "")

      if (event$code != 1000 && private$autoReconnect) {
        self$connect()
      }
    })

    private$ws$onError(function(event) {
      cat("Client failed to connect: ", event$message, "\n")
    })

    if (!is.null(private$onMessageFct)) {

      internalOnMsgFct <- function(event) {
        data <- jsonlite::fromJSON(event$data)
        ackMsg <- private$onMessageFct(jsonlite::base64_dec(data$payload))

        if (ackMsg) {
          private$ws$send(paste0('{ "messageId": "', data$messageId, '" }'))
        }
      }

      private$ws$onMessage(internalOnMsgFct)
    }

    #private$ws$connect()
  },

  close = function() {
    private$ws$close()
  },

  send = function(payload) {
    private$ws$send(paste0('{ "payload": "', jsonlite::base64_enc(payload), '" }'))
  }),

  private = list(
    endpoint = NULL,
    autoReconnect = TRUE,
    onMessageFct = NULL,
    ws = NULL
))

#' Print details about a Pulsar instance
#'
#' @param obj a Pulsar connection instance
#'
#' @export
print.Pulsar <- function(obj) {
  cat(obj$toString(), "\n")
}

