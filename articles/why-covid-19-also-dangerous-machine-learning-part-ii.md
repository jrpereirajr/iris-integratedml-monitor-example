# Why is COVID-19 also dangerous for Machine Learning? (Part II)

Following up the [previous part](https://community.intersystems.com/post/why-covid-19-also-dangerous-machine-learning-part-i), it's time to take advantages for IntegratedML VALIDATION MODEL statement, to provide information in order to monitor your ML models. You can watch it in action [here](https://www.youtube.com/watch?v=q9ORM32zPjs)

The code presented here was derived from examples provided by either [InterSystems IntegragedML Template](https://openexchange.intersystems.com/package/integratedml-demo-template) or [IRIS documentation](https://irisdocs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=GCM_healthmon), my contribution was mainly mashing up such codes. It's a simple example intended to be a start for discussions and future works.

Note: The code presented here is for explanation purpose only. If you want to try it, I developed an example application - [iris-integratedml-monitor-example](https://openexchange.intersystems.com/package/iris-integratedml-monitor-example), which is competing in the InterSystems IRIS AI Contest. Please, after read this article, you can check it out and, if you like it, [vote for me](https://openexchange.intersystems.com/contest/current)! :)

# Content
### Part I:
* [IRIS IntegratedML and ML systems](https://community.intersystems.com/post/why-covid-19-also-dangerous-machine-learning-part-i#iris_integratedml_and_ml_systems)
* [Between the old and new normal](https://community.intersystems.com/post/why-covid-19-also-dangerous-machine-learning-part-i#between_the_old_and_new_normal)
### Part II:
* [Monitoring ML performance](#monitoring_ml_performance)
* [A simple use case](#a_simple_use_case)
* [Future works](#future_works)

# Monitoring ML performance

In order to monitor your ML model, you'll need, at least, two features:

1) Performance metrics provider
2) Monitor and Notification service

Fortunately, IRIS provide us with both of such required features.

## Getting ML models performance metrics

As we saw in [previous part](https://community.intersystems.com/post/why-covid-19-also-dangerous-machine-learning-part-i), IntegratedML provides the VALIDATE MODEL statement for calculate the following performance parameters:

* Accuracy: how good your model is (values close to 1 means high correct  answer rates)
* Precision: how good your model deal with false positives (values close to 1 means high **no** false positives rates)
* Recall: how good your model deal with false negatives (values close to 1 means high **no** false negatives rates)
* F-Measure: another way to measure accuracy, used when accuracy are not performing well (values close to 1 means high correct  answer rate)

Note: these definitions are not formal, actually they are pretty shallow! I encourage you to take some time in order to [understand them](https://medium.com/analytics-vidhya/accuracy-vs-f1-score-6258237beca2).

The cool thing is that each time you call VALIDATE MODEL, IntegrateML stores its performance metric, and we can take advantages on such feature for monitoring.

## Monitoring engine

InterSystems IRIS provides the System Monitor framework to deal with monitoring task. It also let you to define custom rules in order to trigger notifications based on predicates applied on such metrics. 

By default, a bunch of metrics for disc, memory, process, network etc are provided. Furthermore, System Monitor also let you to extend monitors to cover a endless possibilities. Such custom monitor are called Application Monitor in System Monitor terminology.

You can get more information on System Monitor [here](https://irisdocs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=GCM_healthmon).

## Putting all together

So far, we have a way to get the values of performance metric of each model validation and, a tool which could trigger alerts based on custom rules applyed to custom metrics source...  Ok, it's time to mash up them.

First, we need to create a custom application monitor class, by extending %Monitor.Abstract class and implement methods *Initialize* and *GetSample* as well. 

```
Class MyMetric.IntegratedMLModelsValidation Extends %Monitor.Adaptor
{

/// Initialize the list of models validation metrics.
Method Initialize() As %Status
{
    Return $$$OK
}

/// Get routine metric sample. 
/// A return code of $$$OK indicates there is a new sample instance. 
/// Any other return code indicates there is no sample instance. 
Method GetSample() As %Status
{
    Return $$$OK
}

}
```

System monitors issues regular calls to monitor classes in order to get a set of metrics called samples. Such samples could be just monitored or used to check if alert rules must be raised. You define the structure of such samples by defining standard non-internal properties in monitior class. It's important to note here that you must specify, in parameter INDEX,  one of those properties to act like a primary key of each sample - otherwise a duplicate key error will be thrown.

```
Class MyMetric.IntegratedMLModelsValidation1 Extends %Monitor.Adaptor
{

Parameter INDEX = "ModelTrainedName";

/// Name of the model definition
Property ModelName As %Monitor.String;

/// Name of the trained model being validated
Property ModelTrainedName As %Monitor.String;

/// Validation error (if encountered)
Property StatusCode As %Monitor.String;

/// Precision
Property ModelMetricPrecision As %Monitor.Numeric;

/// Recall
Property ModelMetricRecall As %Monitor.Numeric;

/// F-Measure
Property ModelMetricFMeasure As %Monitor.Numeric;

/// Accuracy
Property ModelMetricAccuracy As %Monitor.Numeric;

...

}
```

The method *Initialize* is called once for each monitor call and, method *GetSample* is called until it return 0.

So, we could setup an SQL on IntegrateML validation history to provide metrics information to the monitor, implementing *Initialize* and *GetSample* methods:

```
/// Initialize the list of models validation metrics.
Method Initialize() As %Status
{
	// Get the latest validation for each model validated by VALIDATION MODEL statement
	Set sql = 
	"SELECT MODEL_NAME, TRAINED_MODEL_NAME, STATUS_CODE, %DLIST(pair) AS METRICS_LIST FROM ("_
		"SELECT m.*, $LISTBUILD(m.METRIC_NAME, m.METRIC_VALUE) pair, r.STATUS_CODE "_
		"FROM INFORMATION_SCHEMA.ML_VALIDATION_RUNS r "_
		"JOIN INFORMATION_SCHEMA.ML_VALIDATION_METRICS m "_
		"ON m.MODEL_NAME = r.MODEL_NAME "_
			"AND m.TRAINED_MODEL_NAME = r.TRAINED_MODEL_NAME "_
			"AND m.VALIDATION_RUN_NAME = r.VALIDATION_RUN_NAME "_
		"GROUP BY m.MODEL_NAME, m.METRIC_NAME "_
		"HAVING r.COMPLETED_TIMESTAMP = MAX(r.COMPLETED_TIMESTAMP)"_
	") "_
	"GROUP BY MODEL_NAME"
    Set stmt = ##class(%SQL.Statement).%New()
    $$$THROWONERROR(status, stmt.%Prepare(sql))
    Set ..Rspec = stmt.%Execute()
    Return $$$OK
}

/// Get routine metric sample. 
/// A return code of $$$OK indicates there is a new sample instance. 
/// Any other return code indicates there is no sample instance. 
Method GetSample() As %Status
{
    Set stat = ..Rspec.%Next(.sc)
    $$$THROWONERROR(sc, sc)

    // Quit if we have done all the datasets
    If 'stat {
        Quit 0
    }

    // populate this instance
    Set ..ModelName = ..Rspec.%Get("MODEL_NAME")
    Set ..ModelTrainedName = ..Rspec.%Get("TRAINED_MODEL_NAME")_" ["_$zdt($zts,3)_"]"
    Set ..StatusCode = ..Rspec.%Get("STATUS_CODE")
    Set metricsList = ..Rspec.%Get("METRICS_LIST")
    Set len = $LL(metricsList)
    For iMetric = 1:1:len {
	    Set metric = $LG(metricsList, iMetric)
	    Set metricName = $LG(metric, 1)
	    Set metricValue = $LG(metric, 2)
	    Set:(metricName = "PRECISION") ..ModelMetricPrecision = metricValue
	    Set:(metricName = "RECALL") ..ModelMetricRecall = metricValue
	    Set:(metricName = "F-MEASURE") ..ModelMetricFMeasure = metricValue
	    Set:(metricName = "ACCURACY") ..ModelMetricAccuracy = metricValue
    }

    // quit with return value indicating the sample data is ready
    Return $$$OK
}
```

After compiling the monitor class, you need to restart System Monitor in order to system realize that a new monitor was created and is ready to use. You could use both ^%SYSMONMGR routine or %SYS.Monitor class to do this.

# A simple use case

Ok, so far we have the necessary tools to collect, monitor and issue alerts on ML performance metrics. Now, it's time to define a custom alert rule and simulate a scenario which a deployed ML model starts to get your performance negatively affected.

First, we must configure an email alert and its trigger rule. This could be done using ^%SYSMONMGR routine. However, in order to make things easier, I created a setup method which set all e-mail configuration and alert rule. You need to replace values between &lt;&gt; with your e-mail server and account parameters.

```
ClassMethod NotificationSetup()
{
	// Set E-mail parameters
	Set sender = "<your e-mail address>"
	Set password = "<your e-mail password>"
	Set server = "<SMTP server>"
	Set port = "<SMTP server port>"
	Set sslConfig = "default"
	Set useTLS = 1
	Set recipients = $LB(<comma-separated receivers for alerts>)
	Do ##class(%Monitor.Manager).AppEmailSender(sender)
	Do ##class(%Monitor.Manager).AppSmtpServer(server, port, sslConfig, useTLS)
	Do ##class(%Monitor.Manager).AppSmtpUserName(sender)
	Do ##class(%Monitor.Manager).AppSmtpPassword(password)
	Do ##class(%Monitor.Manager).AppRecipients(recipients)
	
	// E-mail as default notification method
	Do ##class(%Monitor.Manager).AppNotify(1)
	
	// Enable e-mail notifications
	Do ##class(%Monitor.Manager).AppEnableEmail(1)
	
	Set name  = "perf-model-appointments-prediction"
	Set appname = $namespace
	Set action = 1
	Set nmethod = ""
	Set nclass = ""
	Set mclass = "MyMetric.IntegratedMLModelsValidation"
	Set prop = "ModelMetricAccuracy"
	Set expr = "%1 < .8"
	Set once = 0
	Set evalmethod = ""
	// Create an alert
	Set st = ##class(%Monitor.Alert).Create(name, appname, action, nmethod, nclass, mclass, prop, expr, once, evalmethod)
	$$$THROWONERROR(st, st)
	
	// Restart monitor
	Do ##class(MyMetric.Install).RestartMonitor()
}
```

In previous method, an alert will be issued after monitor get accuracy values less than 90%.

Now that our alert rule is setup, let's create, train and validate a show/no-show prediction model with the first 500 records and validate it through first 600 records.

Note: *seed* parameter is just for guarantee reproducibility (i.e., no random values) and normally must be avoid in production.

```
-- Creates the model
CREATE MODEL AppointmentsPredection PREDICTING (Show) FROM MedicalAppointments USING {\"seed\": 3}
-- Train it using first 500 records from dataset
TRAIN MODEL AppointmentsPredection FROM MedicalAppointments WHERE ID <= 500 USING {\"seed\": 3}
-- Show model information
SELECT * FROM INFORMATION_SCHEMA.ML_TRAINED_MODELS
```
```
|   | MODEL_NAME             | TRAINED_MODEL_NAME      | PROVIDER | TRAINED_TIMESTAMP       | MODEL_TYPE     | MODEL_INFO                                        |
|---|------------------------|-------------------------|----------|-------------------------|----------------|---------------------------------------------------|
| 0 | AppointmentsPredection | AppointmentsPredection2 | AutoML   | 2020-07-12 04:46:00.615 | classification | ModelType:Logistic Regression, Package:sklearn... |
```

Note that IntegrateML, by using AutoML as provider (PROVIDER column), infers from the dataset provided, a classification model (MODEL_TYPE column), with Logistic Regression algorithm, from scikit-learn library (MODEL_INFO column). Important to highlight here the "Garbage In, Garbage Out" rule - i.e. model quality is directly related to data quality.

Now, let's continue with model validation.

```
-- Calculate performace metrics of model using first 600 records (500 from trainning set + 100 for test)
VALIDATE MODEL AppointmentsPredection FROM MedicalAppointments WHERE ID < 600 USING {\"seed\": 3}
-- Show validation metrics
SELECT * FROM INFORMATION_SCHEMA.ML_VALIDATION_METRICS WHERE MODEL_NAME = '%s'
```
```
| METRIC_NAME              | Accuracy | F-Measure | Precision | Recall |
|--------------------------|----------|-----------|-----------|--------|
| AppointmentsPredection21 | 0.9      | 0.94      | 0.98      | 0.91   |
```

The model could be used to perform predictions by using the PREDICT statement:

```
SELECT PREDICT(AppointmentsPredection) As Predicted, Show FROM MedicalAppointments  WHERE ID <= 500
```
```
|     | Predicted | Show  |
|-----|-----------|-------|
| 0   | 0         | False |
| 1   | 0         | False |
| 2   | 0         | False |
| 3   | 0         | False |
| 4   | 0         | False |
| ... | ...       | ...   |
| 495 | 1         | True  |
| 496 | 0         | True  |
| 497 | 1         | True  |
| 498 | 1         | True  |
| 499 | 1         | True  |
```

Then, let's simulate adding 200 new records (totalling 800 records) to the model in such way its accuracy is decreased to 87%.

```
-- Calculate performace metrics of model using first 800 records
VALIDATE MODEL AppointmentsPredection FROM MedicalAppointments WHERE ID < **800** USING {\"seed\": 3}
-- Show validation metrics
SELECT * FROM INFORMATION_SCHEMA.ML_VALIDATION_METRICS WHERE MODEL_NAME = '%s'
```
```
| METRIC_NAME              | Accuracy | F-Measure | Precision | Recall |
|--------------------------|----------|-----------|-----------|--------|
| AppointmentsPredection21 | 0.9      | 0.94      | 0.98      | 0.91   |
| AppointmentsPredection22 | 0.87     | 0.93      | 0.98      | 0.88   |
```

As we setup early a rule to issue an e-mail notification if accuracy is less than 90%, System Monitor realize that it's time to trigger such alert to related e-mail(s) account(s).

<p align="center">
  <img src="https://raw.githubusercontent.com/jrpereirajr/iris-integratedml-monitor-example/master/model-validation-2.png" width="600" title="docker environment topology after installation">
</p>

In e-mail body, you could find information about the alert, such its name, application monitor and its metrics values that triggered the alert.

<p align="center">
  <img src="https://raw.githubusercontent.com/jrpereirajr/iris-integratedml-monitor-example/master/model-validation-3.png" width="600" title="docker environment topology after installation">
</p>

Thus, such situation will be notifed to people who could take some action in order to deal with it. For instance, an action could be simply retrain model, but in some cases a more elaborated approach may be necessary.

Certainly, you could elaborate more on monitor metrics and create better alerts. For example, imagine you have several ML models running with different people responsible for each of them. You could use the model name metric and setup specific alert rules, for specific e-mails receivers.

System Monitor also let you to raise a ClassMethod instead of sending an e-mail. So, you could execute complex logic when an alert is raised, like automatically retrain the model, for instance.

Note that, as System Monitor will regularly runs Initialize and GetSample method, such methods need to be carefully designed in order to don't demand so much system's resources.

# Future works

As noticed by [Benjamin Deboe](https://github.com/jrpereirajr/iris-integratedml-monitor-example/issues/1), IRIS introduces a new way to customize your monitoring task - the [SAM tool](https://docs.intersystems.com/sam/csp/docbook/Doc.View.cls?KEY=ASAM). My first impressions was very positives, SAM is integrated with market standard monitoring technologies like Grafana and Prometheus. So, why not go ahead and test how to improve this work with such new features? But this is material for a future work.... :)

Well, this is it! I hope this could be useful for you in some way.
See you!