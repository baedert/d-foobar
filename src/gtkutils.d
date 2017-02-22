import std.stdio;
import std.string;
import std.algorithm;
import std.conv;

import gtk.Bin;

string uiMembers(const string ui_data) {
	return __generate_ui (ui_data, true);
}

string uiInit(const string ui_data) {
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

	enum ChildType {
		NONE,
		TITLEBAR,
	}
	struct ChildInfo {
		ChildType type;
		string id;
	}

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

	void expect(string e, int line = __LINE__) {
		if (ident != e) {
			if (!__ctfe)
				  writeln ("Expected ", e, ", but found ", ident, " at pos ", pos, " from line ", line);
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

	ChildInfo parse_object (bool toplevel = false) {
		ChildInfo child_info;
		string object_type = ident;
		string object_id = null;
		next();
		if (ident != "{") {
			// Read object ID (optional!)
			child_info.id = ident;
			next();
			if (!toplevel)
				object_ids[child_info.id] = object_type;
		} else {
			child_info.id = get_irrelevant_ident();
		}

		if (ident != "{") {
			// child type
			string child_type = ident[1..$];
			//writeln(child_type);
			if (child_type == "titlebar")
				child_info.type = ChildType.TITLEBAR;
			else
				assert(0);
			next();
		}

		if (toplevel)
			assert(child_info.id == "this");

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
			if (!just_members && child_info.id in object_ids)
				result ~= child_info.id ~ " = new " ~ object_type ~ "(";
			else
				result ~= object_type ~ " " ~ child_info.id ~ " = new " ~ object_type ~ "(";

			// This will leave a trailing comma but whatever
			foreach (prop_name; construct_props.keys) {
				result ~= construct_props[prop_name] ~ ", ";
			}
			result ~= ");\n";
			foreach (prop_name; non_construct_props.keys) {
				result ~= child_info.id ~ ".set" ~ prop_name ~ "(" ~ non_construct_props[prop_name] ~ ");\n";
			}
		} else {
			result ~= "super(";
			foreach (foo; construct_props.keys) {
				result ~= construct_props[foo] ~ ", ";
			}
			result ~= ");\n";
		}

		while (ident != "}") { // until this object ends
			auto child = parse_object();
			if (child.type == ChildType.TITLEBAR)
				result ~= child_info.id ~ ".setTitlebar(" ~ child.id ~ ");\n";
			else
				result ~= child_info.id ~ ".add(" ~ child.id ~ ");\n";
		}

		//next();
		next();

		return child_info;
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

	// child with type
	string s4 = __generate_ui("Box this{|spacing = 12\n|foo = _(\"bla\")\nButton btn $titlebar {\n.l = 4\n}\n}");

}
