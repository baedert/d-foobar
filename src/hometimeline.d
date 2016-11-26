
import ipage;
import gtk.RadioButton;
import glib.ListSG;


class HomeTimeline : IPage {
public:
	this() {

	}

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
	RadioButton radio_button = null;
}
