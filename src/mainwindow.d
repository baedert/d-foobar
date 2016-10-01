import gtk.Window;
import gtk.Main;
import gdk.Event;
import gtk.Widget;
import gtk.Box;
import gtk.Stack;
import gtk.Button;
import gtk.ToggleButton;
import gtk.HeaderBar;
import gtk.Separator;
import gtk.Application;
import gtk.ApplicationWindow;

import gtkutils;
import ipage;



static immutable string ui = q{
	ApplicationWindow this {
		|app = app
		HeaderBar header_bar $titlebar {
			.ShowCloseButton = true
			.Title = "Corebird"
			Button account_button {
				|label = "Hey"
			}

			Separator {
				|orientation = Orientation.VERTICAL
			}

			ToggleButton compose_button {
				|label = "Compose"
			}
		}
		Box main_box {
			|orientation = Orientation.VERTICAL
			|spacing = 0

			Box top_bar {
				|orientation = Orientation.HORIZONTAL
				|spacing = 0
				.Homogeneous = true
			}

			Stack main_stack {

			}
		}
	}
};




class MainWindow: ApplicationWindow {
	mixin(generate_ui_members(ui));

	IPage[] pages;

	this(Application app) {
		mixin(generate_ui(ui));

		foreach (i; 0..7) {
			Button b = new Button("X");
			top_bar.add(b);
		}

	}
}
