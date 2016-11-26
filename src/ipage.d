import gtk.RadioButton;

interface IPage {
  abstract string get_title();
  abstract RadioButton get_button(RadioButton group);
}
