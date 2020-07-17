# Why is COVID-19 also dangerous for Machine Learning? (Part I)

A few months ago, I read [this interesting  article from MIT Technology Review](https://www.technologyreview.com/2020/05/11/1001563/covid-pandemic-broken-ai-machine-learning-amazon-retail-fraud-humans-in-the-loop/), explaing how COVID-19 pandemic are issuing challenges to IT teams worldwide regarding their machine learning (ML) systems.

Such article inspire me to think about how to deal with performance issues after a ML model was deployed. 

I simulated a simple performance issue scenario in an Open Exchange technology example application - [iris-integratedml-monitor-example](https://openexchange.intersystems.com/package/iris-integratedml-monitor-example), which is competing in the InterSystems IRIS AI Contest. Please, after read this article, you can check it out and, if you like it, [vote for me](https://openexchange.intersystems.com/contest/current)! :)

# Content
### Part I:
* [IRIS IntegratedML and ML systems](#iris_integratedml_and_ml_systems)
* [Between the old and new normal](#between_the_old_and_new_normal)
### Part II:
* [Monitoring ML performance](#monitoring_ml_performance)
* [A simple use case](#a_simple_use_case)
* [Future works](#future_works)

# IRIS IntegratedML and ML systems

Before talking about COVID-19 and how it's affecting ML systems worldwide, let's quickly talk about InterSystems IRIS IntegratedML.

By automating task like feature selection and its integration with standard SQL data manipulation language, IntegratedML could help us with the task of develop and deploy a ML solution.

For instance, after a properly manipulation and analisys on data from medical appointments, you can setup a ML model for predicting patients show/no-show using these SQL statements:

```sql
CREATE MODEL AppointmentsPredection PREDICTING (Show) FROM MedicalAppointments
TRAIN MODEL AppointmentsPredection FROM MedicalAppointments
VALIDATE MODEL AppointmentsPredection FROM MedicalAppointments
```

AutoML provider will choose the set of features and ML algortim which best performs. In this case, AutoML provider selected Logistic Regression model using scikit-learn library, obtaining 90% of accuracy.

```
|   | MODEL_NAME             | TRAINED_MODEL_NAME      | PROVIDER | TRAINED_TIMESTAMP       | MODEL_TYPE     | MODEL_INFO                                        |
|---|------------------------|-------------------------|----------|-------------------------|----------------|---------------------------------------------------|
| 0 | AppointmentsPredection | AppointmentsPredection2 | AutoML   | 2020-07-12 04:46:00.615 | classification | ModelType:Logistic Regression, Package:sklearn... |
```

```
| METRIC_NAME              | Accuracy | F-Measure | Precision | Recall |
|--------------------------|----------|-----------|-----------|--------|
| AppointmentsPredection21 | 0.9      | 0.94      | 0.98      | 0.91   |
```

Once your ML model is already integrated to SQL, you can seamlessly integrate it to your existing booking system in order to improve its performance, by using estimations on which patient will be present and who won't:

```sql
SELECT PREDICT(AppointmentsPredection) As Predicted FROM MedicalAppointments WHERE ID = ?
```

You can learn more about IntegrateML [here](https://docs.intersystems.com/iris20202/csp/docbook/DocBook.UI.Page.cls?KEY=GIML). If you want a little bit more detail about this simple prediction model, you can refer to [here](https://github.com/jrpereirajr/iris-integratedml-monitor-example/blob/master/jupyter-samples/IntegeratedML-Monitor-Example.ipynb).

However, as AI/ML models are designed to adapt to society behaviour, directly or not, they probably will be affect a lot when such behaviour changes quickly. Recently, we (sadly) could experiment such scenario due COVID-19 pandemic.

# Between the old and new normal

As explained in the [MIT Technology Review's article](https://www.technologyreview.com/2020/05/11/1001563/covid-pandemic-broken-ai-machine-learning-amazon-retail-fraud-humans-in-the-loop/), COVID-19 pandemic has been changing remarkably and quickly society's behaviour. I ran some queries in Google Trends, for terms cited in the article, like N95 mask, toilet paper and hand sanitizer, in order to confirm an increasing on their popularity, as pandemic spread worldwide:

<p align="center">
  <img src="https://raw.githubusercontent.com/jrpereirajr/iris-integratedml-monitor-example/master/screencapture-trends-google-trends-explore-2020-07-14-23_49_23.png" width="75%">
</p>

As quoted in the article:

> "But they [changes by COVID-19] have also affected artificial intelligence, causing hiccups for the algorithms that run behind the scenes in inventory management, fraud detection, marketing, and more. Machine-learning models trained on normal human behavior are now finding that normal has changed, and some are no longer working as they should."

I.e., between the  "old normal" and the"new normal" we're experiencing a "new abnormal".  
Another interesting quote also from article:

> "Machine-learning models are designed to respond to changes. But most are also fragile; they perform badly when input data differs too much from the data they were trained on. (...) AI is a living, breathing engine."

The article goes on giving examples of AI/ML model that suddenly start to get their performance negatively affected, or need to be urgently altered. Some examples:

* Retailers companies which ran out of stock after bulk orders for unsual products;
* Skewed advices from investments recommendations services based on sentiment analysis of media posts, due their pessimist content;
* Automated phrases generators for advisements which starts to generate unsuitable content, due new context;
* Amazon changing its sellers recommendation system to choose who handle their own deliveries, in order to avoid over demand on its warehouses' logistic.

Thus, we need to monitor our AI/ML models in order to guarantee their reliability and keep helping our customers.

So far, hope I could show you that create, train and deploy your ML model isn't the whole story - you need keep track on it. In next article, I'll show you how to use IRIS %Monitor.Abstract framework to monitor your ML system's performance and, setting alerts triggers based on monitor's metrics.

*In the meanwhile, I'd love to know if you had experienced some sort of issue raised by theses pandemics times, and how are you dealing with it in the comments section!*

Stay tuned (and safe &#x1f60a;)!