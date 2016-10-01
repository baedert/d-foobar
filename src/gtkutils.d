import std.stdio;
import std.string;
import std.algorithm;
import std.conv;

import gtk.Bin;

string generate_ui_members(const string ui_data) {
	return __generate_ui (ui_data, true);
}

string generate_ui(const string ui_data) {
	return __generate_ui(ui_data, false);
}


private string __generate_ui(const string ui_data, bool just_members = false) {
	immutable char EOF = cast(char)255;
	string result;
	auto input = ui_data.strip();
	int pos = 0;
	char c = input[0];
	string ident = null;
	string[string] object_ids;

	uint irrelevant_id = 0;
	string get_irrelevant_ident() {
		return "__object__" ~ to!string(irrelevant_id ++);
	}

	pure
	bool separates(char c) {
		return ['{', '}', '=', ' ', '\n', '\t', '|'].canFind(c);
	}

	pure void advance() {
		if (pos < input.length - 1) {
			pos ++;
			c = input[pos];
		} else {
			c = EOF;
		}
	}

	pure
	void skip_whitespace() {
		while (c == ' ' || c == '\t' || c == '\n') {
			advance();
		}
	}

	//pure
	void next() {
		if (pos >= input.length) {
			c = EOF;
			ident = [EOF];
			return;
		}

		skip_whitespace();
		ident = "";
		int i = 0;
		do {
			ident ~= c;
			advance();
			i ++;
		}
		while (!separates(c) && pos < input.length - 1 );

		skip_whitespace();
	}

	void expect(string e) {
		if (ident != e) {
			if (!__ctfe)
				writeln ("Expected ", e, ", but found ", ident, " at pos ", pos);
			assert(ident == e);
		}
	}

	pure
	string get_until(char _c) {
		string result;
		while (c != _c && c != EOF) {
			result ~= c;
			advance();
		}
		return result;
	}

	string parse_object (bool toplevel = false) {
		string object_type = ident;
		string object_id = null;
		next();
		if (ident != "{") {
			// Read object ID (optional!)
			object_id = ident;
			next();
			if (!toplevel)
				object_ids[object_id] = object_type;
		} else {
			object_id = get_irrelevant_ident();
		}

		if (toplevel)
			assert(object_id == "this");

		string[string] construct_props;
		string[string] non_construct_props;
		expect("{");
		next();
		while (ident[0] == '.' || ident[0] == '|') {
			bool construct = (ident[0] == '|');
			string prop_name = ident;
			next();
			expect("=");
			string prop_value = get_until('\n').strip();
			if (construct) {
				construct_props[prop_name[1..$]] = prop_value;
			} else {
				non_construct_props[prop_name[1..$]] = prop_value;
			}

			next();
		}


		if (!toplevel) {
			// Generate the declaration
			if (!just_members && object_id in object_ids)
				result ~= object_id ~ " = new " ~ object_type ~ "(";
			else
				result ~= object_type ~ " " ~ object_id ~ " = new " ~ object_type ~ "(";

			// This will leave a trailing comma but whatever
			foreach (prop_name; construct_props.keys) {
				result ~= construct_props[prop_name] ~ ", ";
			}
			result ~= ");\n";
			foreach (prop_name; non_construct_props.keys) {
				result ~= object_id ~ ".set" ~ prop_name ~ "(" ~ non_construct_props[prop_name] ~ ");\n";
			}
		} else {
			result ~= "super(";
			foreach (foo; construct_props.keys) {
				result ~= construct_props[foo] ~ ", ";
			}
			result ~= ");\n";
		}

		while (ident != "}") { // until this object ends
			string child = parse_object();
			result ~= object_id ~ ".add(" ~ child ~ ");\n";
		}

		//next();
		next();

		return object_id;
	}

	// Kick off
	next();
	// Parse toplevel obj
	parse_object(true);

	// We simply do both things in both cases...
	if (just_members) {
		string member_result;
		foreach (m; object_ids.keys) {
			if (m != "this")
				member_result ~= object_ids[m] ~ " " ~ m ~ ";\n";
		}
		return member_result;
	}

	return result;
}

unittest {
	string s = __generate_ui("Box this{}");
	//writeln(s);
	assert(s.strip == "super();"); // empty object, no properties, ...

	string s2 = __generate_ui("Box this{|spacing = 12\n|foo = \"bla\"\n}");
	//writeln(s2);
	assert(s2.strip() == "super(12, \"bla\", );");

	string s3 = __generate_ui("Box this{|spacing = 12\n|foo = _(\"bla\")\n}");
	assert(s3.strip() == "super(12, _(\"bla\"), );");
}
