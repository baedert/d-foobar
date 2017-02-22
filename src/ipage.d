import gtk.RadioButton;
import gtk.Widget;

interface IPage {
  abstract string getTitle();
  abstract Widget getWidget();
  abstract RadioButton getButton(RadioButton group);
}
