import subprocess
import asyncio
import os
from discord import Member

from discordapplet.server import notify_clients


class State:
    __state: list[Member] = []

    @staticmethod
    def new_state(new_state: list[Member]):
        State.__state = new_state
        State.to_json()

    @staticmethod
    def print_state():
        subprocess.call("cls" if os.name == "nt" else "clear")
        assert State.__state is not None  # accessing the mangled name correctly

    @staticmethod
    def to_json():
        assert State.__state is not None
        data: list[dict[str, str]] = []
        for member in State.__state:
            data.append(
                {"name": member.display_name, "avatar": member.display_avatar.url}
            )

        asyncio.create_task(notify_clients(data))
        return data
