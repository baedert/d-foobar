import cgreport;

import std.stdio;
import std.algorithm;
import std.range;
import std.conv;
import std.string;

import app;
import mainwindow;

void main(string[] args) {
	//Main.init(args);
	//auto w = new MainWindow();
	//w.showAll();
	//Main.run();

	auto cb = new Corebird();
  cb.run(args);
}
