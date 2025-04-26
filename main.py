import asyncio
import json
import bot
import aiohttp
import threading

from aiohttp import web

from server import start_websocket_server
from state import State

async def main():
    await start_websocket_server()
    await bot.start_bot()

if __name__ == "__main__":
    asyncio.run(main())
