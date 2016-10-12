
import gtk.Box;
import gtk.Stack;
import gtk.Button;
import gtk.ToggleButton;

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

		
		this.pages = new IPage[1];
		this.pages[0] = new HomeTimeline();


		this.dummy_button = new ToggleButton();
		foreach (page; pages) {
			Button b = new ToggleButton("A");
			top_bar.add(b);
		}

		top_bar.getStyleContext().addClass("topbar");
	}

private:
	mixin(generate_ui_members(ui));
	IPage[] pages;
	ToggleButton dummy_button;

}
