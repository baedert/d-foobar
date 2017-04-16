
import userstream;
import rest;

class Account {
public:
	long id;
	string screenName;
	string name;
	UserStream userStream;

	this(long id, string screenName, string name) {
		this.id = id;
		this.screenName = screenName;
		this.name = name;
	}

	void initProxy() {
		this.proxy = new Proxy("https://api.twittter.com/");
	}

private:
	Proxy proxy;

}
