<h2> Running docker </h2>
<ol>
<li> Start VPN service
<li> ssh login: ssh stil-id@edag05.cs.lth.se  --> Stil password
<li> Docker login: docker login registry.coursegit.cs.lth.se --username stil-id -p access-token 
<li> Docker pull: docker pull registry.coursegit.cs.lth.se/edag05/project/team3:master
<li> Docker run: docker run -d registry.coursegit.cs.lth.se/edag05/project/team3:master   #Should be configured on port 4242 already
<li> Try with curl call: curl -X GET localhost:4242/elections/02c67b09-d776-4a7c-94e3-33ca7b96ed53     #Returns empty list
<li> To leave: exit
</ol>




<strong>git commit -m "NAME1/NAME2/... : What has been done : Issues needed to complement"</strong>

<h2> Some help for the project </h2>

<strong>Do this to compile and create a jar-file, so the client can be run in the terminal</strong>
<ol>
<li>./gradlew shadowJar
<li> java -jar app/build/libs/shadow-all.jar localhost:4242
</ol>



<strong>Issue --> merge</strong>

<ol>
<li> Create a issue (On Gitlab) # Start a issue
<li> When issue is created, create merge request from within the issue (Gitlab) # Create merge request
<li> In merge request press "Check out branch" and look at Step 1 (Gitlab) # Find commands to get the new branch locally
<li> Execute commands from the former step (Terminal) # Creates the branch locally
<li> Do the changes you want to make (Locally) 
<li> git status (Terminal)# To se what files are changed 
<li> git add filename/directory (Terminal) # Adds changed files, -A instead of filename/directory adds all changed files
<li> git commit -m "comment on the commited change" (Terminal)
<li> git push (Terminal) # pushes the committed changes to remote branch
<li> Approve merge request (Gitlab) # or comment further changes and go back to step 5
<li> If you have changed/added code, wait for code review (not needed for changes in README.md etc)
<li> Merge (Gitlab) when code has been reviewed # if everything is done
<li> git checkout master (Terminal) # Change branch to master
<li> git branch -D branchname (Terminal) # Remove the branch from the merge request
<li> git remote prune origin (Terminal) # with --dry-run if you want to see the changes first
</ol>


<strong>Add pre-commit hook to your project</strong>

<ol>
<li> Go into your project folder (Locally)
<li> from there navigate to .git/hooks/ and change the name pre-commit.sample --> pre-commit (Locally)
<li> Open the file pre-commit in some text editor and replace the content with: <br>
#!/bin/sh<br>
cd server; ./gradlew verGJF; cd ..<br>
cd client; ./gradlew verGJF; cd ..<br>
<li> chmod a+x .git/hooks/pre-commit (Terminal) # From root folder of project, makes the file, pre-commit,  executable
</ol>

do .gradlew goJF for fixing all the format and then commit

<strong>Test client ??? through postman</strong><br><br>
Postman<br>
POST: http://localhost:4567/elections <br>
GET: http://localhost:4567/elections/xxxx/voters (ersätt xxxx med electionID)<br>
