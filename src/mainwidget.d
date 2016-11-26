
import gtk.Box;
import gtk.Stack;
import gtk.Button;
import gtk.RadioButton;

import gtkutils;
import ipage;
import hometimeline;


static immutable string ui = q{
	Box this {
		|orientation = Orientation.VERTICAL
		|spacing = 0

		Box top_bar {
			|orientation = Orientation.HORIZONTAL
			|spacing = 0
			.Homogeneous = true
		}

		Stack main_stack {

		}
	}
};
class MainWidget : Box {
public:
	this() {
		mixin(generate_ui(ui));


		pages = new IPage[1];
		pages[0] = new HomeTimeline();

		this.dummy_button = new RadioButton("Dummy");
		foreach (page; pages) {
			auto b = page.get_button(this.dummy_button);
			top_bar.add(b);
		}

		top_bar.getStyleContext().addClass("topbar");
	}

private:
	mixin(generate_ui_members(ui));
	IPage[] pages;
	RadioButton dummy_button;
}
