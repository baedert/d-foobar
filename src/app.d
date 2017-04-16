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

static immutable string app_css = import("style.css");

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
		provider.loadFromData(app_css);
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
