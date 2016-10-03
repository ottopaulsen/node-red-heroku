# Node-RED for Heroku

Here are some hints on how to get [Node-RED](http://nodered.org/) running on [Heroku](http://heroku.com). I am not sure all instructions are complete, or in the correct order, because I have done it all over some time, but I will try to get in the most tricky stuff.

I don't thing I will be using this solution myself, because of the issue described in the warning below, but figuring out how to get it working was worth spending some time on documentation.

### WARNING!

There is one drawback with running Node-RED on Heroku. In order to work, Node-RED must be running all the time. That requires "dyno" time, so this app alone may tak up all your free dyno time. Of course, you can buy more time to get rid of the problem.

If you are using free dynos at Heroke, since Node-RED is running in the background, you will need some other tool pingning it every 30 minutes to keep it awake. If you use paied dynos, I think you avoid this problem, but I am not sure. I have not set up this yet.

There may be other ways to solve this, but I haven't found them yet. Please let me know if you do.


## Introduction

I am using a simple Node-RED process that is reading data from MQTT, sending some data back to MQTT and some data further to [ThingSpeak.com](https://thingspeak.com/). I will use Heroku only for running the Node-RED process, not for changing it, so I will run Node-RED without GUI, and with all the flow config uploaded from files. To create and change the flow, I use a local instance, and then deploy it to Heroku.

## All you need

* git
* Node.js
* An account on Heroku, and the Heroku toolbelt installed. This is very well documented at Heroku. Use the Node.js instructions.

In this example I have also used:

* An MQTT queue, for example at [cloudmqtt.com](https://www.cloudmqtt.com/).
* A channel at ThingSpeak.com (Not necessary for the main issue here)
* Something generating data to the MQTT



## Preparations

Make sure you have all you need (see above). Then

* Install Node-RED
* Configure Node-RED and get it working locally
* Set up Heroku
* Deploy to Heroku
* Set up .gitignore

The Node-RED [installation guide](http://nodered.org/docs/getting-started/installation.html) explains installing Node-RED locally perfectly, so I will not repeat that.

### Configure Node-RED

Create a .node-red directory. Copy the original [settings.js](https://github.com/node-red/node-red/blob/master/settings.js) file here. 

You need the settings.js file to configure Node-RED. Take a special look at the adminAuth setting. This is necessary if you are going to use the node editor. 

Use the `disableEditor: false` setting to enable (false) or disable (true) the editor.

You can run Node-RED locally to cretae flows, using this command:
```
node-red --settings ./.node-red/settings.js --userDir ./.node-red 
```
After installing Heroku, you can start a local app using the command `heroku local web`.

When you create flows, it will be stored in a flows.json file .node-red directory. Credentials will be stored in a flows_cred.json file. To keep the credentials safe, keep them in environment variables:
```
MQTT_USER=<MQTT username>
MQTT_PASSWORD=<MQTT password>
THINGSPEAK_API_KEY=<ThingSpeak API key>
```

You may create a shell script file to set them locally, and another one to set them on Heroku. To set locally, use
```
export MQTT_PASSWORD=secret
```


### Set up Heroku

To set environment variables on Heroku, use the Heroku toolbelt like this:
```
heroku config:set THINGSPEAK_API_KEY=anothersecret
```
Remember to set all your credentials this way.

In order to keep the credentials seecret, we can dynamically create the flows_cred.json file with a postinstall script. Example:

```
# Create the flows_cred.json file with credentials from environment variables

FLOWS_CRED_FILE=.node-red/flows_cred.json
cat > $FLOWS_CRED_FILE << EOF
{
    "1183f03b.fae04": {
        "user": "${MQTT_USER}",
        "password": "${MQTT_PASSWORD}"
    },
    "d56617a5.79e518": {
        "apiKey": "${THINGSPEAK_API_KEY}"
    }
}
EOF
```

The code between the two EOFs you copy from your flows_cred.json file (in your local .node-red directory). Just replace the secrets with environment variables.

You may create two more scripts to set the environment variables. One local and one for Heroku. Or find a smarter way to do this.

You can follow the instructions on Heroku to create the Heroku app, but before you do that, you should update yout .gitignore file to keep your seecrets out of git. See below.

See the code to get examples of 

* app.json
* package.json
* Procfile
* settings.js
* postintall.sh

The Procfile is used to start the app on Heroku. 

### Set up .gitignore

Make sure you keep all your seecrets out of git, as well as other ignorable files. Example:
```
*.backup
.sessions.json
flows_cred.json
heroku_config_var_setup.sh
local_config_var_setup.sh
```




