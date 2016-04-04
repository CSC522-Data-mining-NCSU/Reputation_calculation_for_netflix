# Reputation Web Service

## How to run code
1. You need to install ruby environment on you machine. [Here](https://www.ruby-lang.org/en/documentation/installation/) is the instruction for different OS.
2. Then you need to install rails [Here](http://guides.rubyonrails.org/getting_started.html#installing-rails) is the instruction.
3. You need to run `bundle install` to install all required gems.
4. After that you need to run `rake db:migrate` to build the DB structure.
5. Run `rails s` to start the server

##	Web Service Structure
The reputation web service consists of three main parts, that is client side, server side and the standard transmission format. `Figure 1.1` shows the structure of the web service in general. Several client systems are communicating with reputation web service. Since each system has its unique DB schema, different data wrappers are needed to convert raw data into standard transmission format. And on the server side, another data wrapper is used to parse the request and generate adjacency matrices, which indicate what score each reviewer has given to each submission, and are the inputs to reputation algorithms. Finally, the reputation web service sends the results back to client systems.

 
Figure 1.1  The structure of the reputation web service.

##	Peer-Review Markup Language
Peer-Review Markup Language (PRML) is a generic schema for encapsulating the raw data into standard data transmission format. In this way, different client systems can communicate with the reputation web service without changing their database schemas.

This language defines some entities commonly used in different peer-review systems. The entities used in the reputation web service are a subset of the data defined in PRML, including clients, assignments, tasks, reviewers, reviewed entities and peer-review grade. `Table 1.1` explains each entity in detail.

Table 1.1 Entities needed in reputation web service
Entity name	Explanation
Client	A peer-review system  that communicates with the reputation web service.
Assignment	A unit of work that the instructor assign to students. 
Task	A task is the smallest unit in each assignment and each task includes one deadline.
Actor	A user who did one or more peer-reviews.
Artifact	The submissions for the current assignment. They can be links, files, etc. The reputation web service does not consider the content of each artifact; only the identifier of each artifact matters [4].

Answer	The number of points each reviewer gives to each artifact. Each peer-review record contains identifier of artifact, identifier of reviewer and peer-review grade.

PRML is a JSON-based format with compact structure, which has three parts. The first part is the information related to assignment(s) and task(s). `Figure 1.2` shows the first part, assignment information, with sample data. It allows data coming from multiple assignments and appointing one task for each assignment. According to the sample data, two assignments’ second-round peer-review records will be sent to reputation web service. And maximum and minimum grades of each assignment are also mentioned to help calculate the reputation values. 

 
Figure 1.2 First part of standard transmission format with sample data.

The second part of standard JSON format is the additional information. They can be initial Hamer reputation values, initial Lauw reputation values, expert grades or quiz scores. Data presented in `Figure 1.3` is used for different reputation algorithms. For instance, expert grades are extra inputs of Hamer-expert algorithm and Lauw-expert algorithm; quiz scores are additional inputs of Quiz-based algorithm. Details of each algorithm will be stated in next chapter.

 
Figure 1.3 Second part of standard transmission format with sample data.

The last part is the review records. It is the most important part because each line records how many points each peer reviewer giving to certain artifact. `Figure 1.4` presents the sample peer-review records.

 
Figure 1.4 Third part of standard transmission format with sample data.
##	Server Side Design
The server side uses Ruby on Rails framework and follows the MVC design pattern strictly. Each algorithm was implemented in a model file. And the controller focuses on parsing JSON request to adjacency matrices, building data structure, calling different algorithms and sending results back to client system. In reputation web service there is no need to create views because all messages will be transmitted via JSON format. In `Figure 1.1`, there is only one data wrapper needed for server side. It is a big advantage of reputation web service, that is using standard JSON transmission format can not only unify the interface, but also satisfy the needs of different client systems.
##	Client Side Design in Expertiza
`Figure 1.1` also presents that each peer-review system needs one specific data wrapper. It is because database structure of each system is different. However, the data wrapper is the only thing each client system need to build. So comparing with understanding the logic of reputation algorithms and implementing them, just building a data wrapper can save lots of time and effort. Currently, one data wrapper has already been built and been embedded into Expertiza with a user interface. 

 
Figure 1.5 Client side UI in Expertiza.

The basic user interface of the client side is presented in `Figure 1.5`. The instructor follows four simple steps to send the standard JSON request. The first step is to type in identifier(s) of assignment(s). These text fields only accept numerical values in order to avoid mistyping. The second assignment identifier text field is optional, which is designed for writing assignments (writing assignment 1a and 1b). Normally, in CSC 517 course, there are two writing assignments. Since they are similar to each other, I tend to merge these two assignments into one sometimes. The last text field is used to specify round number of assignment. The default round number is 2, which means to use the second-round peer-review records as inputs.  This bases the reviewer’s reputation on that reviewer’s second-round reviews only.

The second step is to choose different kinds of reputation algorithms. They are Hamer’s algorithm, Lauw’s algorithm, Hamer-expert algorithm, Lauw-expert algorithm and Quiz-based algorithm. Thirdly, instructor needs to choose some additional information. It can be expert grades, initial reputation values or quiz scores. For initial reputation values, instructor can choose either from Hamer-expert algorithm or Lauw-expert algorithm. And the final step is to click the “Send request” button.

`Figure 1.6` shows the results of writing assignment 1a using Hamer’s algorithm with second-round peer-review records. The table in `Figure 1.6` presents the request and response information with color blending.

 
Figure 1.6 Client side UI in Expertiza with partial results from Hamer’s algorithm acting on second-round peer-review records from writing assignment 1a (724).

The results of writing assignments using Hamer-expert algorithm with expert grades are shown in `Figure 1.7`. The checkbox before “Add expert grades” is gray, which means it is disabled, cannot be unchecked. The reason is that when instructor chose the Hamer-expert algorithm, the data wrapper needed to add expert grades into request information by default. If instructor unchecks the “Add expert grades” for some reason, it will lead to a conflict. So in order to avoid it, some constraints have been added to this user interface. When the instructor chooses Hamer-expert algorithm or Lauw-expert algorithm, the “Add expert grades” checkbox will be checked and disabled; when instructor chooses the Quiz-based algorithm, the “Add quiz scores” will be checked and disabled and so on.

 
Figure 1.7 Client side UI in Expertiza with partial results from Hamer-expert algorithm acting on second-round peer-review records from writing assignments (724 and 733).

`Figure 1.8` shows the results from another more complex situation. In this case, initial reputation values for Lauw’s algorithm will not be one (the default value) any more. Instead, these values came from writing assignments. This feature is designed for the third experiment, which will be explained in detail in chapter 5.
 
Figure 1.8 Client side UI in Expertiza with partial results from Lauw’s algorithm acting on peer-review records from OSS project (736) and initial reputation values from Lauw-expert algorithm acting on second-round peer-review records from writing assignments (724 and 733).
##	Security of Web Service
Security is also an important issue, since expert grades and peer-review grades are sensitive data and should not be revealed to unauthorized people. However, according to the design, the reputation web service sends the data in plaintext. In order to protect these sensitive data, encryption algorithms are needed.

The first solution is to use public-key cryptography. It is an asymmetric key encryption algorithm and cryptographic keys are paired. One is public key, which is disseminated widely and anyone with public key can encrypt messages. The other one is the private key, which can only be used by the keyholder to decrypt private messages [10]. By implementing this solution, client sides can use public key to encrypt the JSON data and server side can use corresponding private key to decrypt the encrypted data. However, there is a maximum message length restriction for public-key cryptography. Since it is possible that request data exceeds the maximum length restriction, another method is needed to apply to all situations.

The second solution is the combination asymmetric key encryption algorithm and symmetric key encryption algorithm, which does not have restriction mentioned above. Procedure of sending encrypted request is presented in `Figure 1.9`. The client side uses a newly generated symmetric key to encrypt the JSON data and then encrypts the symmetric key with the public key from the asymmetric key encryption algorithm. After that, it sends the encrypted request to the server side. Then the server side decrypts the symmetric key with the private key. Secondly, it obtains the JSON data by using the symmetric key. And sending the response back to client side is the reverse process. In practice, AES is chosen the as symmetric encryption algorithm, and RSA is chosen as the asymmetric encryption algorithm.

 
Figure 1.9 Procedure of sending encrypted request.

In summary, the “pluggable” reputation web service can make peer review systems access to multiple reputation algorithms and compare with each other. So there is no need to implement reputation algorithms locally. But each client system needs a specific data wrapper. The data wrapper can convert client system’s database schema into a standard JSON transmission format, which is the subset of PRML. After reputation web service receives the JSON request, it will do calculation and send the JSON response back to client system. What’s more, the reputation web service also uses cryptography to protect the sensitive data.


© Copyright 2016 by Zhewei Hu
All Rights Reserved.
