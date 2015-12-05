# reputation_web_service
1. Client ```posts``` data to server. 
2. Server uses ```params``` to get data.
3. Server calculation the reputation.
4. Server ```posts``` result to client.
5. Client read data from ```buffer```.

## How to run code
1. You need to install ruby environment on you machine. [Here](https://www.ruby-lang.org/en/documentation/installation/) is the instruction for different OS.
2. Then you need to install rails [Here](http://guides.rubyonrails.org/getting_started.html#installing-rails) is the instruction.
3. You need to run ```bundle install``` to install all required gems.
4. After that you need to run ```rake db:migrate``` to build the DB structure.
5. Run ```rails s``` to start the server
