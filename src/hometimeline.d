
import ipage;
import gtk.RadioButton;
import gtk.ListBox;
import gtk.ScrolledWindow;
import glib.ListSG;


class HomeTimeline : ScrolledWindow, IPage {
public:
	//this() {
		//super();
	//}

	override string get_title() {
		return "Home";
	}

	override RadioButton get_button(RadioButton group) {
		if (radio_button is null) {
			radio_button = new RadioButton(group, "Home");
			radio_button.setMode(false);
		}

		return radio_button;
	}

private:
	RadioButton radio_button;
	ListBox listbox;
}
