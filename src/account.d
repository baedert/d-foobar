
import userstream;

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

	}

private:

}
