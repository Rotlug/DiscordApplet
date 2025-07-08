import asyncio
import json
import websockets

connected_clients = set()
from discordapplet import state

async def notify_clients(data):
    if connected_clients:
        message = json.dumps(data)
        await asyncio.gather(*(client.send(message) for client in connected_clients))

async def handler(websocket):
    connected_clients.add(websocket)
    try:
        async for message in websocket:
            state.State.to_json()
    finally:
        connected_clients.remove(websocket)

def start_websocket_server():
    return websockets.serve(handler, "localhost", 49152)
