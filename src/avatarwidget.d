import gtk.Widget;
import gtkc.gtk;
import gtkc.gtktypes;
import gobject.Type;
import gobject.ObjectG;

import std.stdio;

struct AvatarWidgetClass {
	GtkWidgetClass parentClass;
}

class AvatarWidget : Widget {
	public @property int size = 24;

	public this() {
		import gtkc.gobject;
		auto p = c_g_object_new(customWidgetGetType(), null);
		super(cast(GtkWidget*)p, true);
	}

	public this(GtkWidget *widget, bool ownedRef = false) {
		super(widget, ownedRef);
	}

	extern(C) {
		static GType customWidgetGetType() {
			GType type = Type.fromName("AvatarWidget");

			if (type == GType.INVALID) {
				GTypeInfo customTypeInfo = {
					AvatarWidgetClass.sizeof,                // class size
					null,                                    // base_init
					null,                                    // base_finalize
					cast(GClassInitFunc) &customClassInit,   // class init
					null,                                    // class finalize
					null,                                    // class_data
					GtkWidget.sizeof,                        // instance size
					0,                                       // n_preallocs
					cast(GInstanceInitFunc) &customInit,     // instance init
				};

				type = Type.registerStatic(gtk_widget_get_type(), "AvatarWidget",
				                           &customTypeInfo, cast(GTypeFlags)0);
			}

			return type;
		}

		static void customClassInit(GtkWidgetClass *klass) {
			klass.getPreferredWidth  = &customGetPreferredWidth;
			klass.getPreferredHeight = &customGetPreferredHeight;
			klass.draw               = &customDraw;
		}

		static void customInit(GtkWidget *widget) {
			gtk_widget_set_has_window(widget, false);
		}

		static void customGetPreferredWidth(GtkWidget *widget, int *min, int *nat) {
			auto self = ObjectG.getDObject!(AvatarWidget)(widget);
			*min = self.size;
			*nat = self.size;
		}

		static void customGetPreferredHeight(GtkWidget *widget, int *min, int *nat) {
			auto self = ObjectG.getDObject!(AvatarWidget)(widget);
			*min = self.size;
			*nat = self.size;
		}

		static int customDraw(GtkWidget *widget, cairo_t *ct) {
			return false;
		}
	}
}
