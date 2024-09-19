# Deploying an Application and Monitoring Resources <br>
## Purpose <br>
<p>This project aims to help a social media company deploy their application without using managed services like Elastic Beanstalk, which can be a costly service to use depending on the web site traffic that the servers receive. In addition to deploying the application without managed services, the resources used should be monitored to ensure the servers don’t experience any failures. 

The steps below showcase what was done to deploy the application and monitor the resources used.
</p>

## Steps <br>
1. To begin clone the repository to a personal repository on my Github account 
This step will allow customization and contributions to be made without altering the original repository.

2. Next, Create an Ubuntu EC2 instance that is specifically set to be a t3.medium. On this EC2, Jenkins will be installed using the following steps:
```
$sudo apt update && sudo apt install fontconfig openjdk-17-jre software-properties-common && sudo add-apt-repository ppa:deadsnakes/ppa && sudo apt install python3.7 python3.7-venv
$sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
$echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    $sudo apt-get update
    $sudo apt-get install jenkins
    $sudo systemctl start jenkins
    $sudo systemctl status jenkins

```

3. Following that the server needs to be configured by installing 'python3.9', 'python3.9-venv', 'python3-pip', and 'nginx'
This can be accomplished by using the following commands:
```
Sudo apt install python3.9
Sudo apt install python3.9-venv
Sudo apt install python3-pip 
Sudo apt install nginx
```

4. Afterwards, go into the personal repository created in the beginning stages and create and activate a python virtual environment using the following commands:
```
$python3.9 -m venv venv
$source venv/bin/activate

```

5. Next, while in the python environment, install the application dependencies and other packages by running these commands:
   ```
    $pip install -r requirements.txt
    $pip install gunicorn pymysql cryptography

   ```
<p> The dependencies are essential because they help additional functionality that may not be included in the core framework. Dependencies also speed up the development process and can assist in managing complex applications by implementing up-to-date libraries.</p>

6. Following that is setting the environmental variable by using the following command:
```
FLASK_APP=microblog.py
```
<p>Flask is a common web framework for Python. When using Flask, it is important to note that Flask needs to know which file it can utilize as the application's entry point. So, specifically, with the command above, Flask will use microblg.py to start the application. </p>

7. Afterwards, run the following commands:
   ```
   $flask translate compile
   $flask db upgrade
   ```
 <p>The first command is converting .po files into .mo files, ensuring that the latest translations are accessible in the application.<br>
The second application updates the database schema to match the latest version defined in migration scripts.
</p>

8. Next, Edit the NginX configuration file at "/etc/nginx/sites-enabled/default" so that "location" reads as below:
```
   location / {
proxy_pass http://127.0.0.1:5000;
proxy_set_header Host $host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```
<p>By adding this specific block of code into the configured Nginx file will proxy requests and direct traffic/requests to the backend server. The location/ and proxy_pass portion of the file indicate that the nginx file handles all requests to the root path and then forwards requests to a backend server.</p>

9. Following that, Run the following command and then put the server's public IP address into the browser address bar.
   ```
   gunicorn -b :5000 -w 4 microblog:app
   ```
After inputting the public IP address into the browser, this is the page that is viewable.






<p>The command above is used to run a Python web application with Gunicorn. It starts the Gunicorn server, specifies the binding address and the port for the server, specifies the number of worker processes that will manage requests, and specifies the application to be served by Gunicorn. Another important factor that is happening behind the scenes is logging, which includes monitoring and recording information that is being generated.</p>
