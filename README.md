# Node-RED for Heroku

Here are some hints on how to get [Node-RED](http://nodered.org/) running on [Heroku](http://heroku.com). I am not sure all instructions are complete, or in the correct order, because I have done it all over some time, but I will try to get in the most tricky stuff.

Running Node-RED on Heroku is an alternative to running it on your own hardware. There are advantages and drawbacks with both alternatives.



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
* Set up .gitignore
* Set up Heroku
* Deploy to Heroku

The Node-RED [installation guide](http://nodered.org/docs/getting-started/installation.html) explains installing Node-RED locally perfectly, so I will not repeat that.

### Configure Node-RED

Create a separate directory for the app, where you put everything here. Create a .node-red sub-directory. Copy the original [settings.js](https://github.com/node-red/node-red/blob/master/settings.js) file here. You need the settings.js file to configure Node-RED. Take a special look at the `adminAuth` setting. This is necessary if you are going to use the node editor. Read about [Security](http://nodered.org/docs/security) in the Node-RED doc.

Use the `disableEditor: false` setting to enable (false) or disable (true) the editor.

You can run Node-RED locally to create flows, using this command:
```
node-red --settings ./.node-red/settings.js --userDir ./.node-red 
```
After installing Heroku, you can start a local app using the command `heroku local web`.

When you create flows, it will be stored in a `flows.json` file `.node-red` directory. Credentials will be stored in a `flows_cred.json` file. 

#### Keep your credentials secret

To keep the credentials safe, move them out of the `flows_cred.json` file and in to environment variables. Examples:
```
MQTT_USER=<MQTT username>
MQTT_PASSWORD=<MQTT password>
THINGSPEAK_API_KEY=<ThingSpeak API key>
```

You may create a shell script file to set them locally, and another one to set them on Heroku. 

For example, to set up local variables, create the script `local_config_var_setup.sh`:
```
export MQTT_USER=secret
export MQTT_PASSWORD=anothersecret
export THINGSPEAK_API_KEY=secretsecret
```
Run this script like this: `. local_config_var_setup.sh` The preceeding dot is important.

To set up variables on Heroku, create the script `heroku_config_var_setup.sh`:
```
heroku config:set MQTT_USER=secret
heroku config:set MQTT_PASSWORD=anothersecret
heroku config:set THINGSPEAK_API_KEY=anothersecret

```
Run this script after you have configured Heroku (see below), like this: `heroku_config_var_setup.sh`.

After creating scripts with your environment variables, move the content in the `flows_cred.json` file into another script name `postinstall.sh`. Example:

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

The code between the two EOFs is the content from your flows_cred.json file (in your local .node-red directory), but with the secrets replaced with environment variables.



#### Keeping the Heroku-app awake

There is one drawback with running Node-RED on Heroku. In order to work, Node-RED must be running all the time. That requires "dyno" time, so this app alone may tak up all your free dyno time. Of course, you can buy more time to get rid of the problem.

If you are using free dynos at Heroku, since Node-RED is running in the background, you will need some tool pingning it every 30 minutes to keep it awake. I am not sure if this is necessary if you use paied dynos. Anyway, a simple solution is to have Node-RED send an HTTP request to itself every 15 minutes. I found no way of starting a flow in a loop, so I wait for a "keepalive" message on MQTT, send the HTTP-request, wait 15 minutes, then send a new keepalive message to MQTT. It seems to work. Probably there are simpler ways to do this in Node-RED. Please let me know if you know about one.



### Set up Heroku

You can follow the [instructions on Heroku](https://devcenter.heroku.com/articles/getting-started-with-nodejs#introduction) to create the Heroku app, but before you do that, make sure you update your .gitignore file to keep your seecrets out of git. Example:

```
*.backup
.sessions.json
flows_cred.json
heroku_config_var_setup.sh
local_config_var_setup.sh
```

The `flows_cred.json` file will be created dynamically by the `postinstall.sh` script. The shell-scripts are those that keep your secrets.

For other configurations, see the code to get examples of 

* app.json
* package.json
* Procfile
* settings.js
* postintall.sh

The Procfile is used to start the app on Heroku. 






