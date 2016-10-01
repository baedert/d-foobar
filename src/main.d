import cgreport;

import std.stdio;
import std.algorithm;
import std.range;
import std.conv;
import std.string;

import gtk.Main;
import gtk.Bin;
import gtk.Container;
import gtk.Widget;
import gtk.Button;
import gtk.Grid;
import gtk.Box;
import gtk.Settings;
import gtk.Label;
import gtk.Window;
import gtk.Switch;
import gtk.Stack;


import gtkutils;

class MyBox : Box {
	static immutable string ui_data = q{
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
	mixin(generate_ui_members(ui_data));

	this() {
		//super(Orientation.HORIZONTAL, 12);
		mixin(generate_ui(ui_data));


		//writeln(generate_ui_members(ui_data));
		//writeln ("-------");
		//writeln(generate_ui(ui_data));



		// we can now here use all the widgets we gave an ID in our UI definition.
		foreach (i; 0..7) {
			Button b = new Button("X");
			top_bar.add(b);
		}
	}
}

void main(string[] args) {
	Main.init(args);
	auto w = new Window("Toplevel");

	auto b = new MyBox();

	w.add(b);
	w.showAll();
	Main.run();
}
