import ipage;
import gtk.RadioButton;
import gtk.ListBox;
import gtk.ScrolledWindow;
import glib.ListSG;
import gtk.Widget;


class HomeTimeline : IPage {
public:
	this() {
		scrolledWindow = new ScrolledWindow();
		listbox = new ListBox();

		scrolledWindow.add(listbox);
	}

	override string getTitle() {
		return "Home";
	}

	override RadioButton getButton(RadioButton group) {
		if (radioButton is null) {
			radioButton = new RadioButton(group, "Home");
			radioButton.setMode(false);
		}

		return radioButton;
	}

	override Widget getWidget() {
		return this.scrolledWindow;
	}

private:
	RadioButton radioButton;
	ScrolledWindow scrolledWindow;
	ListBox listbox;
}
