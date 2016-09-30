import std.stdio;
import std.file;
import std.array;
import std.string;
import std.conv;
import std.range;
import std.algorithm;


pure @nogc
bool contains(T)(T[] arr, T c) {
	foreach (ref T k; arr) {
	  if (k== c) return true;
	}
	return false;
}

pure @nogc
void next_line(R)(ref R input)
  if (isInputRange!R)
{
	while (input.front.length == 0 ||
		   input.front[0] == '#')
		input.popFront();
}

pure @nogc
bool skip(const string s) {
	return s.length == 0 || s[0] == '#';
}

pure
int parse_num (ref Cost c, string input) {
	assert(input.length > 0);
	switch(input[0]) {
		case '*':
			return c.last_added_line;
		case '+':
		case '-':
			return c.last_added_line + to!int(input);
		default:
			return to!int(input);
	}
}

//pure @nogc
void parse_spec (ref cgfile   cg,
                 const string spec,
                 bool         is_func,
                 out string   name)
{
	assert(spec.length > 0);
	assert(!spec.contains('=')); // This should be ONLY the right part

	ulong id;
	if (spec[0] == '(') {
		// With ID: spec=(ID) name
		long close_paren_index = spec.indexOf(')');
		id = to!ulong(spec[spec.indexOf('(')+1..close_paren_index]);
		if (close_paren_index+1 == spec.length) {
			// If the name is empty, we should have already seen this ID before...
			string saved_name;

			if (is_func)
				saved_name = cg.function_map[id];
			else
				saved_name = cg.file_map[id];

			name = saved_name;
			return;
		}

		assert (spec[close_paren_index + 1] == ' ');
		name = spec[close_paren_index + 2..$];
		if (is_func)
			cg.function_map[id] = name.dup;
		else
			cg.file_map[id] = name.dup;
	} else {
		// No ID: spec=name
		name = spec;
	}
}


enum  Positions {
	LINE,        // "a line number of some source file"
	INSTRUCTION, // "positions are offsets in a binary representing instructions"
}

enum Events {
	IR,   // Instruction read access
	I1MR, // Instruction L1 read cache miss
	I2MR, // Instruction L2 read cache miss
}

// TODO(completeness): This just supports Events.IR right now
struct CostInfo {
	int line;
	int cycles;
}

// cfn=some_func_name
// calls=2 16
struct FunctionCall {
	string name;
	string file;
	string obj;
	int line;

	int n_calls;
	int cycles;
}

struct Cost {
	string obj;
	string func;
	string file;

	ulong self_cost = 0;
	ulong cost = 0;

	void add_info(CostInfo info) {
		if (info.line in this.infos)
			infos[info.line].cycles =+ info.cycles;
		else {
			infos[info.line] = info;
			last_added_line = info.line;
		}
	}

	private int last_added_line = 0;
	int last_line_num () {
		return this.last_added_line;
	}
	CostInfo[int] infos; // Indexed by line number
	FunctionCall[string] func_calls;
}

/*
 * callgrind report file. ASCII only!
 */
struct cgfile {
	string filename;
	string creator;
	int cgversion;
	int pid;
	string cmd;
	ulong total_cost;
	// Positions is optional in the file and defaults to "line"
	Positions positions = Positions.LINE;
	Events events;

	Cost[] costs;
	// callgrind does name compression and refers to already seen names with an ID
	string[long] function_map;
	// Same for file names
	string[long] file_map;


	this(string filename) {
		this.filename = filename;
	}
}

void read_local_func(R) (ref cgfile cg, ref Cost c, ref R input)
  if (isInputRange!R)
{
	FunctionCall l;
	string[] parts = (cast(string)input.front).split('=');

	assert (parts[0] == "cfn" ||
	        parts[0] == "cfi" ||
	        parts[0] == "cob");

	string name;

	parse_spec (cg, parts[1], parts[0] == "cfn",  name);

	if (parts[0] == "cob") {
		l.obj = parts[1].strip().dup;
		input.popFront();
		// Parse again to get function name + ID
		parts = (cast(string)input.front).split('=');
		parse_spec (cg, parts[1], parts[0] == "cfn",  name);
	}


	// cfi is optional in case the function is in the same file
	if (parts[0] == "cfi") {
		l.file = parts[1].strip().dup;

		// Skip to next line
		input.popFront();
		// Parse again to get function name + ID
		parts = (cast(string)input.front).split('=');
		parse_spec (cg, parts[1], parts[0] == "cfn", name);
	}


	for (; !input.empty(); input.popFront()) {
		const string line = cast(string)input.front;

		if (line.skip)
			continue;

		if (!line.contains('='))
			break;

		parts = line.split('=');
		if (parts[0] == "cfn") {
			l.name = name.dup;
		} else if (parts[0] == "calls") {
			string[] parts2 = parts[1].split(' ');
			l.n_calls = to!int(parts2[0]);
			l.cycles  = to!int(parts2[1]);
		} else
		  assert (0);
	}

	// We passed the function call, now we should be at the line that
	// gives us the actual cost of the entire function call
	//writeln ("Line after: ", input.front);
	string[] p = (cast(string)input.front).split(' ');
	assert (p.length == 2);
	l.line = c.parse_num (p[0]);
	l.cycles += to!int(p[1]);

	// Makre sure we won't look at this line again
	input.popFront();


	if (l.name in c.func_calls) {
		c.func_calls[l.name].n_calls += l.n_calls;
		c.func_calls[l.name].cycles += l.cycles;
	} else {
		l.n_calls = 1;
		c.func_calls[l.name] = l;
	}

	if (l.cycles > 0)
		c.cost += l.cycles;
}

Cost read_cost(R) (ref cgfile cg, ref R input)
  if (isInputRange!R)
{
 	Cost c;

	while (!input.empty) {
	//for (; !input.empty(); input.popFront()) {
		const string line = cast(string)input.front;

		if (line.length == 0)
			break;

		// Comment
		if (line[0] == '#')
			continue;

		if (line.contains('=')) {
			// No actual cost yet
			string[] parts = line.split('=');
			assert (parts.length == 2);
			string spec = parts[0];
			string name;
			if (spec == "ob") {
				parse_spec(cg, parts[1], false, name);
				c.obj = name.dup;
			} else if (spec == "fl") {
				parse_spec(cg, parts[1], false, name);
				c.file = name.dup;
			} else if (spec == "cob" || spec == "cfn" || spec == "cfi") {
				read_local_func (cg, c, input);
				continue;
			} else if (spec == "fn") {
				parse_spec(cg, parts[1], true, name);
				assert (name[0] != ' ');
				c.func = name.dup;
			}

		} else {
			string[] parts = line.split(' ');

			CostInfo info;
			if (line[0] == '+') {
				assert (c.infos.length > 0);
				info.line = c.last_line_num + to!int(parts[0]);
			} else if (line[0] == '-') {
				assert (c.infos.length > 0);
				info.line = c.last_line_num + to!int(parts[0]);
			} else if (line[0] == '*') {
				assert (c.infos.length > 0);
				info.line = c.last_line_num;
			} else {
				info.line = to!int(parts[0]);
			}

			// TODO(completeness): the data here depends on the events/position header information
			info.cycles = to!int(parts[1]);
			assert (info.cycles >= 0);
			c.self_cost += info.cycles;
			c.cost += info.cycles;
			c.add_info(info);
		}

		input.popFront();
	}

	return c;
}

void read (ref cgfile cg) {
	auto f = File(cg.filename);
	scope(exit){f.close();}

	auto input = f.byLine();
	foreach (line; input) {
		if (line.length == 0 || line[0] == '#') {
			// Comment or empty line
			continue;
		}

		if (line.contains(':')) {
			// Header part
			string[] parts = (cast(string)line).split(':');
			const string key = parts[0];
			const string value = parts[1][1..$]; // strip leading space
			if (key == "version") {
				cg.cgversion = to!int(value);
			} else if (key == "cmd") {
				cg.cmd = value.dup;
			} else if (key == "creator") {
				cg.creator = value.dup;
			} else if (key == "pid") {
				cg.pid = to!int(value);
			} else if (key == "positions") {
				// "the value of "positions" is a list of subpositions"
				// TODO(completeness): Parse a list here
				if (value == "line") cg.positions = Positions.LINE;
				else if (value == "instr") cg.positions = Positions.INSTRUCTION;
				else assert(0);
			} else if (key == "events") {
				// "the value of "events" is a list of event type names"
				// TODO(completeness): Parse a list here
				if (value == "Ir") cg.events = Events.IR;
				else assert(0);
			} else if (key =="totals") {
				cg.total_cost = to!ulong(value);
			}
		} else if (line.contains('=')) {
			// Actual data
			cg.costs ~= read_cost(cg, input);
		} else
			assert (0);
	}
}
