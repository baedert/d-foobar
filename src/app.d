import GApplication   = gio.Application;
import GtkApplication = gtk.Application;
import gio.ApplicationCommandLine;
import gtk.CssProvider;
import gtk.StyleContext;
import gdk.Screen;

import std.stdio;

import mainwindow;

static immutable string app_css = import("style.css");

class Corebird : GtkApplication.Application {
public:
	this() {
		super("org.baedert.corebird", cast(ApplicationFlags)0);
		addOnStartup(&startup);
		addOnActivate(&activate);
	}

private:
	void startup(GApplication.Application app) {
		auto provider = new CssProvider();
		provider.loadFromData(app_css);
		StyleContext.addProviderForScreen(Screen.getDefault(),
		                                  provider,
		                                  600); // PRIORITY_APPLICATION
	}

	void activate(GApplication.Application app) {
		auto window = new MainWindow(this);
		this.addWindow(window);
		window.showAll();
	}
}
