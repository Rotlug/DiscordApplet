import discord
from dotenv import load_dotenv
from os import getenv

from state import State

load_dotenv()
guild_id_string = getenv("GUILD_ID")
assert guild_id_string != None
GUILD_ID = int(guild_id_string)

# Get intents
intents = discord.Intents.default()
intents.voice_states = True

client = discord.Client(intents=intents)

@client.event
async def on_ready():
    print(f'We have logged in as {client.user}')
    guild = client.get_guild(GUILD_ID)
    if guild != None:
        save_voice_members(guild)

@client.event
async def on_voice_state_update(member: discord.Member, before: discord.VoiceState, after: discord.VoiceState):
    save_voice_members(member.guild)

def save_voice_members(guild: discord.Guild):
    if guild.id != GUILD_ID: return

    members: list[discord.Member] = []
    for member in guild.members:
        if member.voice == None: continue
        members.append(member)

    State.new_state(members)

async def start_bot():
    ACCESS_TOKEN = getenv("DISCORD_ACCESS_TOKEN")
    assert ACCESS_TOKEN != None
    await client.start(ACCESS_TOKEN)

