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


string __generate_ui(const string ui_data, bool just_members = false) {
	string result;
	auto input = ui_data.strip();
	int pos = 0;
	char c = input[0];
	string[string] object_ids;

	uint irrelevant_id = 0;
	string get_irrelevant_ident() {
		return "__object__" ~ to!string(irrelevant_id ++);
	}

	pure
	bool separates(char c) {
		return ['{', '}', '=', ' ', '\n', '\t'].canFind(c);
	}

	//pure
	void next() {
		do {
			if (pos < input.length - 1) {
				pos ++;
				c = input[pos];
			} else {
				c = '&';//-1;
				break;
			}
		} while (c == ' ' || c == '\t' || c == '\n'); // Not \n!

		if (!__ctfe) writeln ("c now: ", c != '\n' ? c : '_');
	}

	//pure
	void skip_whitespace() {
		while (c == ' ' || c == '\t' || c == '\n')
			next();
	}

	pure
	string get_ident() {
		assert(!separates(c));
		string ident;
		while (!separates(c)) {
			ident ~= c;
			// Don't use next() here since that skips whitespace
			pos ++;
			c = input[pos];
		}
		return ident;
	}

	pure
	string get_until(char _c) {
		string result;
		while (c != _c) {
			result ~= c;
			pos ++;
			c = input[pos];
		}
		return result;
	}

	string parse_object (bool toplevel = false) {
		skip_whitespace();
		string object_type = get_ident();
		if (!__ctfe) writeln("Object: ", object_type);
		string object_id = null;
		next();
		if (c != '{') {
			// Read object ID (optional!)
			object_id = get_ident();
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
		assert(c == '{');
		next(); // skip newline
		next(); // skip to beginning of line
		while (c == '.' || c == '|') {
			bool construct = (c == '|');
			// Parse property
			next();
			string prop_name = get_ident();
			next();
			assert(c == '=');
			next();
			string prop_value = get_until('\n');
			if (construct) {
				construct_props[prop_name] = prop_value;
			} else {
				non_construct_props[prop_name] = prop_value;
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

		// Now read child objects
		if (!__ctfe) writeln ("c before reading objects: ", c);
		while (c != '}') { // until this object ends
			string child = parse_object();
			result ~= object_id ~ ".add(" ~ child ~ ");\n";
		}

		next();
		next();

		return object_id;
	}

	// Parse toplevel obj
	parse_object(true);


	// We simply do both things in both cases...
	if (just_members) {
		string member_result;
		foreach (m; object_ids.keys) {
			//if (m != "this")
				member_result ~= object_ids[m] ~ " " ~ m ~ ";\n";
		}
		return member_result;
	} else {
		return result;
	}
	assert(0);
}
