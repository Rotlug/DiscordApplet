import Soup from "gi://Soup?version=3.0";
import GLib from "gi://GLib";
// TODO: Move to settings
const WEBSOCKET_URI = "ws://localhost:49152";
import * as Main from "resource:///org/gnome/shell/ui/main.js";
export default class DiscordSocket {
    _indicator;
    _uri;
    _connection;
    _session;
    new_data_methods;
    constructor(indicator) {
        this._indicator = indicator;
        this._uri = GLib.uri_parse(WEBSOCKET_URI, GLib.UriFlags.NONE);
        this._connect();
        this.new_data_methods = [];
    }
    _connect() {
        this._session = new Soup.Session();
        const message = new Soup.Message({ method: "GET", uri: this._uri });
        this._session.websocket_connect_async(message, "origin", [], 1, null, this._connect_callback.bind(this));
    }
    _connect_callback(session, res) {
        if (session == null)
            return;
        try {
            // @ts-ignore
            this._connection = session.websocket_connect_finish(res);
        }
        catch {
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
            if (string == null)
                return;
            const data = JSON.parse(string);
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
