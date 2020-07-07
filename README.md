# iris-integratedml-monitor-example
This is an example of extending %Monitor.Adaptor to monitor IRIS IntegrateML models performance metrics, based on template for IntegratedML - InterSystems Github repository (https://github.com/tom-dyar/integratedml-demo-template).

(todo:)

## Contents
(todo:)
* [What is IntegratedML?](#what-is-integratedml)
* [What's IRIS System Monitor](#whats-iris-system-monitor)
* [Data and ML Application detalis](#data-and-ml-application-detalis)
* [Topology](#topology)
* [Prerequisites](#prerequisites)
* [Tested environments](#tested-environments)
* [Installation](#installation)

## What is IntegratedML?
(todo:)
IntegratedML is a feature of the InterSystems IRIS data platform that brings machine learning to SQL developers.
<p align="center">
  <img src="https://user-images.githubusercontent.com/8899513/85149599-7848f900-b21f-11ea-9b65-b5d703752de3.PNG" width="600" title="docker environment topology after installation">
</p>

IntegratedML is
- all-SQL -- Build and train machine learning models using intuitive custom SQL commands, fully integrated within the InterSystems IRIS SQL processor
- turnkey -- no packages or programming languages to learn, nothing to install
- modular -- leverages "best of breed" open source and proprietary AutoML frameworks

Learn more about InterSystems IRIS and IntegratedML at the [InterSystems Learning site](https://learning.intersystems.com/course/view.php?name=Learn%20IntegratedML)

## What's IRIS System Monitor
(todo:)

## Data and ML Application detalis
(todo:)
Data origin: https://www.kaggle.com/afflores/medical-appointment#


## Topology
(todo:)
<p align="center">
  <img src="https://user-images.githubusercontent.com/8899513/85151307-a0d1f280-b221-11ea-81d8-f0e11ca45d4c.PNG" width="600" title="docker environment topology after installation">
</p>

## Prerequisites
(todo:)
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Tested environments
(todo:)

## Installation
(todo:)

Clone/git pull the repo into any local directory

```
$ git clone https://github.com/jrpereirajr/iris-integratedml-monitor-example.git
```

Open a Docker terminal in this directory and run:

```
$ docker-compose build
```

3. Run the IRIS container, and Jupyter notebook server images:

```
$ docker-compose up -d
```

4. Open browser to access the notebooks

```
http://localhost:8896/tree
```
Note: use `docker-compose ps` to confirm tf2juyter's ports; make sure right localhost port is used if over SSL tunneling to remotehost)

5. Examine the test data with webterminal
Open terminal with: SuperUser / SYS credentials
```
http://localhost:8092/terminal/
```
Enter **/sql** mode and make SQL queries to examine data in IRIS.
![](https://user-images.githubusercontent.com/8899513/85151564-edb5c900-b221-11ea-96d4-1833a93c47eb.png?raw=true)
