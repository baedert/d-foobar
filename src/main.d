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

import glib.MainLoop;
import glib.MainContext;
import glib.Str;
// {{{

//import gtkc.gtk;
//import gtkc.gtktypes;
//import gtkc.gdk;


//struct TAllocation {
  //int x, y, width, height;
//}


//class TWidget {
//public:
	//@property TWidget parent = null;
	//@property bool visible = true;
	//@property bool child_visible = true;
	//@property Window window = null;
	//@property ubyte alpha = 255;
	//bool toplevel = false;
	//TAllocation allocation;

	//Screen getScreen() {
			//return Screen.getDefault();
	//}

	//Display getDisplay() {
		//return this.getScreen().getDisplay();
	//}

	//void sizeAllocate(TAllocation alloc) {
		//if (this.window !is null) {
			//this.window.moveResize(alloc.x, alloc.y, alloc.width, alloc.height);
		//}
	//}
	//void draw(Context ct) {}
	//void map() {}
	//void show() { visible = true; }

//protected:
	//bool resize_needed = false;
	//bool alloc_needed = false;
	//bool alloc_needed_on_child = false;
	//bool mapped = false;

	//void queueResize() {
		//if (resize_needed)
			//return;

		//this.queueResizeOnWidget();
	//}

	//void ensureResize() {
		//if (!resize_needed)
			//return;

		//resize_needed = true;
	//}

	//void ensureAllocate() {
		//if (!needs_allocate())
			//return;

		//this.ensureResize();

		//if (alloc_needed) {

		//} else if (alloc_needed_on_child) {
			//alloc_needed_on_child = false;
			//if (cast(TContainer) this) {
				//auto c = cast(TContainer) this;
				//foreach (child; c.getChildren())
					//child.ensureAllocate();
			//}
		//}
	//}

//private:
	//pure bool needs_allocate() {
		//if (!visible || !child_visible) return false;
		//if (resize_needed || alloc_needed || alloc_needed_on_child) return true;
		//return false;
	//}

	//pure void setAllocNeeded() {
		//this.alloc_needed = true;
		//TWidget widget = this;

		//do {
			//if (widget.alloc_needed_on_child)
				//break;

			//widget.alloc_needed_on_child = true;

			//if (!widget.visible)
				//break;

			//widget = widget.parent;

			//if (widget is null)
				//break;
		//} while (true);
	//}

	//pure void queueResizeOnWidget() {
		//this.resize_needed = true;
		//this.setAllocNeeded();
	//}
//}

//class TContainer : TWidget {

//public:
	//abstract TWidget[] getChildren();

//protected:
	//void checkResize() {
		//if (this.alloc_needed) {
			//this.queueResize(); /// XXX GTK+ Implementation vastly different
		//} else {
			//this.ensureAllocate();
		//}
	//}
//}

//class TWindow : TContainer {
//public:
	//@property uint scale = 1;
	//this() {
		//toplevel = true;
		//GdkWindowAttr attr;
		//attr.x = 0;
		//attr.y = 0;
		//attr.width = 200;
		//attr.height = 200;
		//attr.windowType = GdkWindowType.CHILD;
		//int mask = GdkWindowAttributesType.X |
							 //GdkWindowAttributesType.Y;// |

		//this.window = new Window(null, &attr, mask);
		//this.frame_clock = this.window.getFrameClock();
		//assert(frame_clock !is null);

		//frame_clock.addOnUpdate(&on_frame_clock_update);
		//frame_clock.beginUpdating();
	//}

	//override void show() {
		//visible = true;
		//checkResize();
		//map();
	//}

	//override void map() {
		//auto display = this.getDisplay();
		//this.mapped = true;

		//if (child !is null && child.visible)
			//child.map();

		//auto window = this.window;
    //this.setThemeVariant();
		//window.show();
	//}

	//override void draw(Context ct) {
		//bool push_group = false;

		//if (push_group)
			//ct.pushGroup();

		//writeln ("Window allocation: ", this.allocation);
		//ct.setSourceRgba(1.0, 1.0, 1.0, 1.0);
    //ct.rectangle(0, 0, 100, 100);
		//ct.rectangle (allocation.x, allocation.y, allocation.width, allocation.height);
		//ct.fill();


		//if (child !is null)
			//child.draw (ct);

		//if (push_group)
			//ct.popGroup();
	//}

	//override void sizeAllocate(TAllocation alloc) {
		//super.sizeAllocate(alloc);
		//if (child !is null && child.visible)
			//child.sizeAllocate(alloc);
	//}

	//override TWidget[] getChildren() { return [child]; }

//private:
	//TWidget child;
	//FrameClock frame_clock;

	//void on_frame_clock_update (FrameClock clock) {
		//writeln ("Frameclock update!");
	//}
//}


//TWindow toplevel;



//void _start_main() {
	//auto loop = new MainLoop(cast(MainContext)null, true);
	//loop.run();
//}


//TWidget getEventWidget(Event event) {
	//if (event !is null) {
		//Window w = new Window(event.any.window);
		//if (event.type == EventType.DESTROY || !w.isDestroyed) {
			//void* data;
			//w.getUserData(data);
			//return cast(TWidget)data;
		//}
	//}

	//return null;
//}


//extern(C)
//void event_handler(GdkEvent *e, void *data) {
	//Event event = new Event(e);
	//writeln("EVENT: ", event.type, " - ", cast(int)(event.type));

	//if  (event.type == 33) { // SETTING
		//import gobject.ParamSpec;

		//Screen screen = event.getWindow().getScreen();
		//Settings settings = Settings.getForScreen(screen);
		//GdkEventSetting* event_setting = event.setting;
    //writeln ("Setting: ", cast(string)event_setting.name);
		//writeln ("Setting: ", Str.toString(event_setting.name));

		//return;
	//}

	//Device eventDevice = event.getDevice();


	//switch(event.type) {
		//case EventType.EXPOSE:
			//if (event.any.window !is null) {
				//writeln ("SEND EXPOSE");
				//assert(toplevel.window !is null);
				//auto context = createContext(toplevel.window);

				//toplevel.draw(context);
			//} else {
				//writeln("WARN: event window is null");
			//}
			//break;
		//case EventType.MAP:
			//break;

		//case EventType.VISIBILITY_NOTIFY:

			//break;

		//default:
			//writeln(event.type);
			//assert(0);
	//}
//}

// }}}



// TODO: Signal connections?


class MyBox : Button {
	static immutable string ui_data = q{
		Button this {
			Button {

			}
		}
	};


			//|orientation = Orientation.VERTICAL
			//|spacing = 0

			//Box top_bar {
				//|orientation = Orientation.HORIZONTAL
				//|spacing = 0
			//}

			//Stack main_stack {

			//}


	//mixin(generate_ui_members(ui_data));

	this() {
		//super(Orientation.HORIZONTAL, 12);
		//mixin(generate_ui(ui_data));
		writeln(generate_ui_members(ui_data));
		writeln(generate_ui(ui_data));
	}
}

void main(string[] args) {
	//auto default_display = Display.getDefault();
	//if (default_display is null) {
		//default_display = Display.open(null);
	//}
	//assert(default_display !is null);
	//Event.handlerSet(&event_handler, cast(void*)null, cast(GDestroyNotify)null);

	//auto window = new TWindow();
	//toplevel = window;
	//window.show();

	//_start_main();

	Main.init(args);
	auto w = new Window("Toplevel");

	auto b = new MyBox();

	w.add(b);
	w.showAll();
	Main.run();
}
