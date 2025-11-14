import St from "gi://St?version=17";
import Gio from "gi://Gio?version=2.0";
import Soup from "gi://Soup?version=3.0";
import GLib from "gi://GLib?version=2.0";
import Indicator from "./indicator.js";
import GObject from "gi://GObject?version=2.0";

export default class AvatarCircle extends St.Icon {
  _indicator: Indicator;

  static {
    GObject.registerClass(this);
  }

  constructor(url: string, indicator: Indicator) {
    super({ styleClass: "system-status-icon" });
    this._indicator = indicator;

    _load_image_from_url(url).then((file) => {
      if (file == null) return;
      this.set_gicon(Gio.icon_new_for_string(file));
    });
  }
}

async function _load_image_from_url(url: string) {
  const uniqueFilename = url.split("/")[url.split("/").length - 1];
  const path = GLib.build_filenamev([GLib.get_tmp_dir(), uniqueFilename]);

  if (Gio.File.new_for_path(path).query_exists(null)) return path; // Dont download if file exists

  const session = new Soup.Session();
  const message = Soup.Message.new("GET", url);

  const response = await session.send_and_read_async(
    message,
    GLib.PRIORITY_DEFAULT,
    null,
  );

  const bytes = response.get_data();

  if (bytes == null) return;
  GLib.file_set_contents(path, bytes);
  return path;
}
