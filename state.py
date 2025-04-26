import asyncio
import os
from colorist import BgColorRGB
from discord import Member, VoiceState
import json

from server import notify_clients

class State:
    __state: list[Member] = [] # private class variable

    @staticmethod
    def new_state(new_state: list[Member]):
        State.__state = new_state  # fix: use __state, not state
        State.to_json()
        State.print_state()

    @staticmethod
    def print_state():
        os.system('cls' if os.name == 'nt' else 'clear')
        assert State.__state is not None  # accessing the mangled name correctly

        for member in State.__state:
            print("------------------")
            color = member.color
            terminal_output_color = BgColorRGB(color.r, color.g, color.b)

            print(f"{terminal_output_color}{member.display_name}{terminal_output_color.OFF}")
            print(member.display_avatar)

    @staticmethod
    def to_json():
        assert State.__state != None
        data: list[dict[str, str]] = []
        for member in State.__state:
            data.append({
                "name": member.display_name,
                "avatar": member.display_avatar.url
            })

        asyncio.create_task(notify_clients(data))
        return data
