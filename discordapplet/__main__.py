#!/usr/bin/env python3

import asyncio
import json
from discordapplet import bot
import aiohttp
import threading

from aiohttp import web

from discordapplet.server import start_websocket_server
from discordapplet.state import State

def main():
    asyncio.run(run())

async def run():
    await start_websocket_server()
    await bot.start_bot()

if __name__ == "__main__":
    main()
