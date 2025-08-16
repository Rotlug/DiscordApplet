import * as Main from "resource:///org/gnome/shell/ui/main.js";

import { Extension } from "resource:///org/gnome/shell/extensions/extension.js";
import Indicator from "./indicator/indicator.js";
import DiscordSocket from "./socket.js";

export default class DiscordAppletExtension extends Extension {
  _indicator?: Indicator | null;

  enable() {
    this._indicator = new Indicator(this);
    Main.panel.addToStatusArea(this.uuid, this._indicator);
  }

  disable() {
    if (this._indicator) {
      this._indicator.destroy();
      this._indicator = null;
    }
  }
}
