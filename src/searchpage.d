
import ipage;
import gtk.RadioButton;

class SearchPage : IPage {
public:

	override string get_title() {
		return "Search";
	}

	override RadioButton get_button(RadioButton group) {
		if (radio_button is null) {
			radio_button = new RadioButton(group, "Search");
			radio_button.setMode(false);
		}
		return radio_button;
	}

private:
	RadioButton radio_button = null;
}
