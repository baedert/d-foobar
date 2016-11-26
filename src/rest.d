import std.stdio;

enum Method {
	GET,
	POST
}

struct Request {
public:
	this(string addr, Method method) {
		this.addr = addr;
		this.method = method;
	}

	void invoke() const {
		import core.thread;

		auto t = new Thread(&invoke_func);
		t.start();
	}

	pure
	void add_param(T)(string name, T value) {
		import std.conv;
		params[name] = to!string(value);
	}

private:
	string addr;
	Method method;
	string[string] params;

	void invoke_func() {
		//writeln (__FUNCTION__, " from thread");
	}
}


struct Proxy {
	this(string base_url) {
		this.base_url = base_url;
	}

	Request get(const string func) {
		return Request(base_url ~ func, Method.GET);
	}

	Request post(const string func) {
		return Request(base_url ~ func, Method.POST);
	}

private:
	string base_url;
}


unittest {
  writeln ("unittest");
  auto p = Proxy("127.0.0.1/");
  auto r = p.get("foo");
  r.add_param("s", "v");
  r.invoke();
}
