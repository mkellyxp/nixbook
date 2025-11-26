#!/usr/bin/env python3
import gi
gi.require_version("Gtk", "3.0")
gi.require_version("Gio", "2.0")

from gi.repository import Gtk, Gio, GLib


APPS = [
    ("Google Chrome", ["flatpak", "install", "flathub", "com.google.Chrome", "-y"]),
    ("Zoom",          ["flatpak", "install", "flathub", "us.zoom.Zoom", "-y"]),
    ("LibreOffice",   ["flatpak", "install", "flathub", "org.libreoffice.LibreOffice", "-y"]),
]


class WelcomeInstaller(Gtk.Window):
    def __init__(self):
        super().__init__(title="Welcome to Nixbook")
        self.set_border_width(20)
        self.set_default_size(400, 250)

        self.stack = Gtk.Stack()
        self.add(self.stack)

        # ---- Page 1: selection ----
        self.page_select = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.stack.add_named(self.page_select, "select")

        welcome_label = Gtk.Label(
            label="<big><b>Welcome!</b></big>\n\nChoose what apps to install:",
            use_markup=True,
            xalign=0
        )
        self.page_select.pack_start(welcome_label, False, False, 0)

        self.check_buttons = []
        for name, _cmd in APPS:
            cb = Gtk.CheckButton(label=name)
            cb.set_active(True)  # default checked
            self.check_buttons.append(cb)
            self.page_select.pack_start(cb, False, False, 0)

        self.install_button = Gtk.Button(label="Install")
        self.install_button.connect("clicked", self.on_install_clicked)
        self.page_select.pack_start(self.install_button, False, False, 10)

        # ---- Page 2: installing ----
        self.page_install = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.page_install.set_border_width(10)
        self.stack.add_named(self.page_install, "install")

        self.status_label = Gtk.Label(label="Starting installation...")
        self.status_label.set_xalign(0)
        self.page_install.pack_start(self.status_label, False, False, 0)

        self.progress = Gtk.ProgressBar()
        self.progress.set_show_text(True)
        self.page_install.pack_start(self.progress, False, False, 0)

        # ---- Page 3: done ----
        self.page_done = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.page_done.set_border_width(10)
        self.stack.add_named(self.page_done, "done")

        done_label = Gtk.Label(
            label="<big><b>All done!</b></big>\n\nYou can start using your apps now.",
            use_markup=True,
            xalign=0
        )
        self.page_done.pack_start(done_label, False, False, 0)

        close_button = Gtk.Button(label="Close")
        close_button.connect("clicked", lambda _b: self.close())
        self.page_done.pack_start(close_button, False, False, 0)

        self.connect("destroy", Gtk.main_quit)
        self.show_all()

        self.selected_apps = []
        self.current_index = 0

    def on_install_clicked(self, _button):
        # Build list of selected commands
        self.selected_apps = []
        for cb, (name, cmd) in zip(self.check_buttons, APPS):
            if cb.get_active():
                self.selected_apps.append((name, cmd))

        if not self.selected_apps:
            self.show_message_dialog("Nothing selected", "Please select at least one app to install.")
            return

        # Switch to installing page
        self.stack.set_visible_child_name("install")
        self.current_index = 0
        self.run_next_install()

    def run_next_install(self):
        if self.current_index >= len(self.selected_apps):
            # Done
            self.progress.set_fraction(1.0)
            self.progress.set_text("100%")
            self.status_label.set_text("Installation complete.")
            # Small delay before switching to done page, so user sees 100%
            GLib.timeout_add(500, self.show_done_page)
            return False

        name, cmd = self.selected_apps[self.current_index]
        self.status_label.set_text(f"Installing {name}...")
        total = len(self.selected_apps)
        fraction = self.current_index / total if total else 0
        self.progress.set_fraction(fraction)
        self.progress.set_text(f"{int(fraction * 100)}%")

        # Run flatpak install as a subprocess (non-blocking)
        proc = Gio.Subprocess.new(
            cmd,
            Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE
        )
        proc.communicate_utf8_async(
            None,  # stdin
            None,  # cancellable
            self.on_command_done,
            None,
        )
        return False

    def on_command_done(self, proc, res, _user_data):
        try:
            _out, err, _status = proc.communicate_utf8_finish(res)
            success = proc.get_exit_status() == 0
        except Exception as e:
            err = str(e)
            success = False

        name, _cmd = self.selected_apps[self.current_index]

        if not success:
            # You can make this fancier (show log, etc.)
            self.show_message_dialog(
                f"Failed to install {name}",
                f"There was an error installing {name}:\n\n{err}"
            )

        self.current_index += 1
        # Schedule the next install on the main loop
        GLib.idle_add(self.run_next_install)

    def show_done_page(self):
        self.stack.set_visible_child_name("done")
        return False

    def show_message_dialog(self, title, text):
        dialog = Gtk.MessageDialog(
            transient_for=self,
            flags=0,
            message_type=Gtk.MessageType.INFO,
            buttons=Gtk.ButtonsType.OK,
            text=title,
        )
        dialog.format_secondary_text(text)
        dialog.run()
        dialog.destroy()


if __name__ == "__main__":
    win = WelcomeInstaller()
    Gtk.main()


