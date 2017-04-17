import GApplication   = gio.Application;
import GtkApplication = gtk.Application;
import gio.ApplicationCommandLine;
import gtk.CssProvider;
import gtk.StyleContext;
import gdk.Screen;

import std.stdio;
import std.algorithm;

import mainwindow;
import account;

class Corebird : GtkApplication.Application {
public:
	this() {
		super("org.baedert.corebird", cast(ApplicationFlags)0);
		addOnStartup(&startup);
		addOnActivate(&activate);
	}

	void startAccount(Account acc) {
		if(activeAccounts.canFind(acc)) {
			writeln("account ", acc.screenName, " already active");
			return;
		}

		activeAccounts ~= acc;
		acc.initProxy();
		acc.userStream.start();
	}

private:
	Account[] activeAccounts;

	void startup(GApplication.Application app) {
		auto provider = new CssProvider();
		provider.loadFromData(appCss);
		StyleContext.addProviderForScreen(Screen.getDefault(),
		                                  provider,
		                                  600); // PRIORITY_APPLICATION
	}

	void activate(GApplication.Application app) {
		auto window = new MainWindow(this, null);
		this.addWindow(window);
		window.showAll();
	}
}

enum appCss = q{
  @define-color topbar_bg #333;

  .account-button {
	  background-image: none;
	  background-color: blue;
  }

  .topbar button image {
	-gtk-icon-shadow: none;
	color: #ddd;
  }

  .topbar button {
	border: none;
	box-shadow: none;
	background-image: none;
	border-radius: 0px;
	background-color: @topbar_bg;
	outline-color: #999;
	margin: 0px;
	-GtkWidget-window-dragging: 1;
  }

  .topbar button:hover {
	background-color: shade(@topbar_bg, 1.3);
  }


  .topbar button:checked {
	background-color: shade(@topbar_bg, 1.5);
  }

  .topbar button .badge {
	background-color: shade(blue, 1.4);
	background-image: none;
	text-shadow: 0px 1px 1px #FFF;
	border-radius: 20px;
	border: 1px solid white;
	padding: 3px 2px;
  }

  .topbar button .badge:backdrop {
	background-color: grey;
  }
};
