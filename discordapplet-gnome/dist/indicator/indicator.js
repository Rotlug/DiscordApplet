import GObject from "gi://GObject";
import St from "gi://St";
import * as PanelMenu from "resource:///org/gnome/shell/ui/panelMenu.js";
import DiscordSocket from "../socket.js";
import AvatarCircle from "./avatar_circle.js";
export default class Indicator extends PanelMenu.Button {
    _extension;
    _socket;
    // UI ELEMENTS
    _avatars_box;
    static {
        GObject.registerClass(this);
    }
    constructor(extension) {
        super(0.0, extension.metadata.name, false);
        this._extension = extension;
        const box = St.BoxLayout.new();
        // Make ui contents
        this._avatars_box = new St.BoxLayout({});
        box.add_child(this._avatars_box);
        this.add_child(box);
        // let item = new PopupMenu.PopupMenuItem(_("Show Notification"));
        // if (!(this.menu instanceof PopupMenu.PopupDummyMenu)) {
        //  this.menu.addMenuItem(item);
        //}
        this._socket = new DiscordSocket(this);
        // Connect new data from the socket to this indicator method
        this._socket.new_data_methods.push(this._new_data_from_backend.bind(this));
    }
    _new_data_from_backend(data) {
        this._avatars_box.remove_all_children();
        data.forEach((value) => {
            this._avatars_box.add_child(new AvatarCircle(value.avatar, this));
        });
    }
}
