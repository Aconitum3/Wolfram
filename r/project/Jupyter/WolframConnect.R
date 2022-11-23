library(rzmq)
library(rjson)

context = init.context()
socket = init.socket(context,"ZMQ_PAIR")
connect.socket(socket,"tcp://wstp:9003")
wolfram_evaluate <- function(expression){
send.socket(socket,expression)
msg = rawToChar(receive.socket(socket, unserialize=FALSE, dont.wait=FALSE))
wlinput<- fromJSON(msg)$Output
return(wlinput)
}