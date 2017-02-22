
import gtk.Box;
import gtk.Stack;
import gtk.Button;
import gtk.RadioButton;

import gtkutils;
import ipage;
import hometimeline;


enum ui = q{
	Box this {
		|orientation = Orientation.VERTICAL
		|spacing = 0

		Box topBar {
			|orientation = Orientation.HORIZONTAL
			|spacing = 0
			.Homogeneous = true
		}

		Stack mainStack {

		}
	}
};
class MainWidget : Box {
public:
	this() {
		mixin(uiInit(ui));


		pages = new IPage[1];
		pages[0] = new HomeTimeline();

		this.dummyButton = new RadioButton("Dummy");
		foreach (page; pages) {
			auto b = page.getButton(this.dummyButton);
			auto w = page.getWidget();
			topBar.add(b);

			w.setHexpand(true);
			w.setVexpand(true);
			mainStack.add(page.getWidget());
		}

		topBar.getStyleContext().addClass("topbar");
	}

private:
	mixin(uiMembers(ui));
	IPage[] pages;
	RadioButton dummyButton;
}
