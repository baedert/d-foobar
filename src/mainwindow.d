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
import gtk.Image;


import gtkutils;
import account;
import mainwidget;
import avatarwidget;


/+
  TODO: How to create GtkImage instances with an icon name?
+/

enum ui = q{
	ApplicationWindow this {
		|app = app
		HeaderBar header_bar $titlebar {
			.ShowCloseButton = true
			.Title = "Corebird"
			Button account_button {
				AvatarWidget {

				}
			}

			Separator {
				|orientation = Orientation.VERTICAL
			}

			ToggleButton compose_button {
				Image {
					.FromIconName = "list-add-symbolic", IconSize.BUTTON
				}
			}
		}

		MainWidget main_widget {
		}
	}
};

class MainWindow: ApplicationWindow {
	mixin(uiMembers(ui));

	Account account;

	this(Application app) {
		mixin(uiInit(ui));
	}
}
