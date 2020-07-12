Class MyMetric.IntegratedMLModelsValidation Extends %Monitor.Adaptor
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

/// Result Set
Property Rspec As %SQL.StatementResult [ Internal ];

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

ClassMethod Setup()
{
	Do ##class(MyMetric.Install).Install("MyMetric.IntegratedMLModelsValidation", "/data/src-post-install/MyMetric.IntegratedMLModelsValidation.cls")
}

}
