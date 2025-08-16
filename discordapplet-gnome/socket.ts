import Soup from "gi://Soup?version=3.0";
import GLib from "gi://GLib";
import Indicator from "./indicator/indicator.js";

// TODO: Move to settings
const WEBSOCKET_URI = "ws://localhost:49152";

import * as Main from "resource:///org/gnome/shell/ui/main.js";
import Gio from "gi://Gio?version=2.0";
export type VCData = { name: string; avatar: string }[];

export default class DiscordSocket {
  _indicator: Indicator;
  _uri: GLib.Uri;

  _connection?: Soup.WebsocketConnection;
  _session?: Soup.Session;

  new_data_methods: ((data: VCData) => void)[];

  constructor(indicator: Indicator) {
    this._indicator = indicator;

    this._uri = GLib.uri_parse(WEBSOCKET_URI, GLib.UriFlags.NONE);

    this._connect();

    this.new_data_methods = [];
  }

  _connect() {
    this._session = new Soup.Session();
    const message = new Soup.Message({ method: "GET", uri: this._uri });

    this._session.websocket_connect_async(
      message,
      "origin",
      [],
      1,
      null,
      this._connect_callback.bind(this),
    );
  }

  _connect_callback(session: Soup.Session | null, res: Gio.AsyncResult) {
    if (session == null) return;

    try {
      // @ts-ignore
      this._connection = session.websocket_connect_finish(res);
    } catch {
      // Try reconnect when closed
      GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 5, () => {
        this._connect.bind(this)();
        return GLib.SOURCE_REMOVE;
      });
      return;
    }

    this._connection.send_text("Hello!"); // Syncs data on startup, text doesnt matter

    this._connection.connect("message", (_connection, type, bytes) => {
      const string = bytes.get_data()?.toString();

      if (string == null) return;

      const data = JSON.parse(string) as VCData;

      this.new_data_methods.forEach((fn) => fn(data));
    });

    this._connection.connect("error", (_connection, error) => {
      Main.notify(error.message);
    });

    this._connection.connect("closed", (_connection) => {
      // Retry in 5s after closure
      GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 5, () => {
        this._connect.bind(this)();
        return GLib.SOURCE_REMOVE;
      });
    });
  }
}
