#!/usr/bin/env python3

from sys import argv
from urllib.request import urlopen 
from urllib.error import URLError

# TODO - templatize
rpcHttpEndpoint = "http://127.0.0.1:8547"

rpcPayload = '{"jsonrpc": "2.0", "method": "net_peerCount", "params": [], "id": 0}'

title = "Geth Peers"
description = "Number of connected peers"

def usage(out=print):
    out(f"Munin plugin to report {title}")
    out("")
    out("./peer_count.py config - Display munin chart params")
    out("./peer_count.py - Fetch values and print to screen")

def output_config(out=print):
    out(f"graph_title {title}")
    out(f"plugins.label {description}")

def output_values(out=print, fetch=urlopen):
    numberOfPeers = ""
    try:
        numberOfPeers = fetch(rpcHttpEndpoint, rpcPayload.encode())
    except ConnectionRefusedError:
        pass
    except URLError:
        pass
    out(f"plugins.value {numberOfPeers}")

if __name__ == "__main__":
    
    args = argv[1:]
    argslen = len(args)

    if argslen == 0:
        output_values()
    elif argslen == 1:
        if args[0] == "config":
            output_config()
        else:
            usage()
    else:
        usage()
