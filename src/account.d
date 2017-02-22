
import userstream;

class Account {
public:
	long id;
	string screen_name;
	string name;
	UserStream user_stream;

	this(long id, string screen_name, string name) {
		this.id = id;
		this.screen_name = screen_name;
		this.name = name;
	}

	void initProxy() {

	}

private:

}
