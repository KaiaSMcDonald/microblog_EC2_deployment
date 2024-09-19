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


![Screenshot 09-19-24](https://github.com/KaiaSMcDonald/microblog_EC2_deployment/blob/main/Screenshot%202024-09-16%20at%208.52.39%20PM.png)



<p>The command above is used to run a Python web application with Gunicorn. It starts the Gunicorn server, specifies the binding address and the port for the server, specifies the number of worker processes that will manage requests, and specifies the application to be served by Gunicorn. Another important factor that is happening behind the scenes is logging, which includes monitoring and recording information that is being generated.</p>


10. Once successful with the previous steps the Jenkinsfile will need to be modified to ensure the source code is able to complete all the stages from build to the deploy stage.

a) Focuses on adding the commands used to create a virtual environment, install dependencies, setting variables, and setting up the databases to the build portion of the Jenkinsfile. 

![Screenshot 09-19-24](https://github.com/KaiaSMcDonald/microblog_EC2_deployment/blob/main/Screenshot%202024-09-18%20at%201.48.09%20PM.png)

b) Focuses on the creation of the pytest which is used to run a unit test on the application source code. 

![Screenshot 09-19-24](https://github.com/KaiaSMcDonald/microblog_EC2_deployment/blob/main/Screenshot%202024-09-18%20at%2010.20.31%20PM.png)

The breakdown of the pytest created as follows:
First is to import the pytest to allow unit tests, fixtures, and other things to be written <br>

Next part is importing the create_app() function, which is responsible for creating and configuring an instance of the Flask application <br>

The pytest.fixture is a function that provides a consistent environment for tests 
*for example, it will create an environment for creating a test client <br>

Following that would be the app. config[‘TESTING’] = True, which sets the testing mode on for a Flask application <br>

In addition to the following components of the code, the purpose of the def test_config(client) is to verify the test client creation and configuration. <br>

Lastly, the ‘assert client’ ensures that the test client was properly created and can be used to simulate HTTP requests.

c) Finally is the deploy stage that includes commands necessary to deploy the application and make it accessible to the internet.

![Screenshot 09-19-24](https://github.com/KaiaSMcDonald/microblog_EC2_deployment/blob/main/Screenshot%202024-09-18%20at%201.48.30%20PM.png)

There is also a clean and 'WASP FS SCAN' stage present in the Jenkinsfile.

<p>The role of the clean stage is to remove any artifacts or files that may interfere with the current build process. The WASP FS SCAN is a security scan that checks for any vulnerabilities in the application code or dependencies.</p>

11. Installation of the OSWAP Dependency check plug in
This plug in can be found in the available plug in section on Jenkins
This plug in must also be configured in ways that include ensuring that it is set to be installed automatically.

<p> The main purpose of this particular plug in is to assist in identifying popular vulnerabilities in project dependencies. Some of the key features of the OWASP Dependency Check is Vulnerability Detection and Report Generation. Which means it able to generate detailed reports about which dependencies have vulnerabilities. While also comparing libraries to vulnerability databases to identify anything alarming.</p>

12. Creation of the multibranch pipeline
    The pipeline will struggle to complete because specifically at the deploy the stage. In order to solve this issue a series of commands will be needed such as:
    
`sudo nano /etc/systemd/system/microblog.service`

This command is used to open and create a systemd service file called microblog.service 

```
[Unit]
Description=gunicorn service to deploy microblog
After=network.target

[Service]
User=jenkins
Group=jenkins
WorkingDirectory=/var/lib/jenkins/workspace/workload_3_main/
Environment="PATH=/var/lib/jenkins/workspace/workload_3_main/venv/bin"
ExecStart=/var/lib/jenkins/workspace/workload_3_main/venv/bin/gunicorn -w 4 -b :5000 microblog:app

[Install]
WantedBy=multi-user.target
```
The code placed above is the contents of the systemd service file which is used to define how the microblog application should begin, stop, restart, and be managed as a service on the server.

Following this is the sudo systemctl daemon-reload command which tells systemd to reload the configuration files

Lastly is starting the microblog service by using the sudo systemctl start microblog command.

These commands collectively will lead to the build completing all the stages successsfully. 

13. Installation of Prometheus and Grafana for Monitoring resources

The following commands can be used to successfully install prometheus:
```
nano install promgraf.sh
chmod +x promgraf.sh
sudo ./promgraf.sh
```
Key point- Once the promgraf file is created the contents of that file should be a script that includes instructions for the installation of prometheus and grafana

The node exporter is another key components linked to Grafana and Prometheus because it collects the metrics needed from the application which is information both of those tools rely on. 

The following commands will successfully install the node exporter:
```
nano nodex.sh
chmod +x nodex.sh
sudo ./nodex.sh
```

The node exporter must be installed on the Jenkins EC2 because that is where the application is located and that is what is being monitored.



This picture displays data on the cpu usage of the application



## System Diagram Design




## Issues and Troubleshooting

<p>An issue I encountered specifically related to the pytest was testing it before moving to the CI/CD pipeline. Every attempt to test it would result in an error saying that the module used in the code could not be found. Despite constant changes to the module's name, the error continued to appear. The solution to this problem was creating a pytest.ini file.</p>

<p>The purpose of pytest.ini  is to be a configuration which helps pytest locate both your application code and tests easily. Therefore the when the test period begins for the pytest it will complete because the location of the application code is defined.</p>




## Optimization 
There are many advantages of provisioning your own resources compared to using a managed service like Elastic Beanstalk 
1. Cost Optimization: By provisioning your own resources you can alter the resources to mirror the actual usage of the resources for the business. This essentially reduces cost tremendously. <br>

2.Security Control: Provisioning your own resources gives you full control over security configurations, patching, and compliance. <br>

3. Greater control: There is full control over configuration, scaling, and resource allocation.

Could this infrastructure be considered a good system

<p> A good system generally has characteristics like scalability, reliability, security, and cost efficiency. The use of self-provisioning covers all these things. Specifically, with scalability self-provisioning resources allow the implementation of custom scaling policies, meaning an increase or decrease in resources can be made based on the demand of the company. In regards to reliability, failover strategies can be customized to improve uptime and reduce latency. These two examples showcase some reasons, amongst many others, why self-provisioning resources can make a good system. </p>

Optimization suggestions for this infrastructure 

<p>A way I would optimize this infrastructure is to implement automation mainly to tackle changes and updates that may alter the progression of the stages essential in deploying the application. The reason I am opting for automation is because I would like to reduce the likelihood of human error interfering with the development and deployment of the application. A tool that I would use is Anisble, which can automate task, reduce errors, and manage the infrastructure. </p>

## Conclusion

