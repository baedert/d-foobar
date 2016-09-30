
import gtk.Window;
import gtk.Main;
import gdk.Event;
import gtk.Widget;

class MainWindow: Window {

	this() {
		super("Main Window");
		this.addOnDelete(&on_delete);
	}

	private bool on_delete(Event e, Widget w) {
		Main.quit();
		return false;
	}
}
