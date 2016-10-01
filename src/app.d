import GApplication   = gio.Application;
import GtkApplication = gtk.Application;
import gio.ApplicationCommandLine;

import std.stdio;

import mainwindow;


class Corebird : GtkApplication.Application {


	this() {
		super("org.baedert.corebird", cast(ApplicationFlags)0);
		addOnStartup(&startup);
		addOnActivate(&activate);
	}

private:
	void startup(GApplication.Application app) {
		writeln("Startup");
	}

	void activate(GApplication.Application app) {
		auto window = new MainWindow(this);
		this.addWindow(window);
		window.showAll();
	}
}
