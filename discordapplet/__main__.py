#!/usr/bin/env python3

import asyncio
from discordapplet import bot

from discordapplet.server import start_websocket_server

def main():
    asyncio.run(run())

async def run():
    await start_websocket_server()
    await bot.start_bot()

if __name__ == "__main__":
    main()
