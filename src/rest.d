import std.stdio;
import std.parallelism;

enum Method {
	GET,
	POST
}

class Request {
public:
	this(string addr, Method method) {
		this.addr = addr;
		this.method = method;
	}

	void invoke() const {
	}

	pure
	Request param(T)(string name, T value) {
		import std.conv;
		params[name] = to!string(value);

		return this;
	}

private:
	string addr;
	Method method;
	string[string] params;
}


class Proxy {
	this(string base_url) {
		this.base_url = base_url;
	}

	Request get(const string func) {
		return new Request(base_url ~ func, Method.GET);
	}

	Request post(const string func) {
		return new Request(base_url ~ func, Method.POST);
	}

private:
	string base_url;
}


unittest {
  auto p = new Proxy("127.0.0.1/");
  auto r = p.get("foo");
  r.param("s", "v");
  r.invoke();
}
