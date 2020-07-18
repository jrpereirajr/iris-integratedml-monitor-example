Class MyMetric.Install Extends %RegisteredObject
{

Property LocalClassName As %String;

ClassMethod Install(
	pClassName As %String,
	pSourceCodeLocal As %String)
{
	Do START^%SYSMONMGR
	Do RegSysClass^%MONAPPMGR
	
	Do $SYSTEM.OBJ.Load(pSourceCodeLocal, "ck")
	Set inst = ..%New()
	Set inst.LocalClassName = pClassName
	Do inst.RegisterMe()
	
	Do inst.RestartMonitor()
}

ClassMethod Uninstall(pClassName As %String)
{
	Set inst = ..%New()
	Set inst.LocalClassName = pClassName
	Do inst.UnRegisterMe()
	Do $SYSTEM.OBJ.Delete(pClassName)
	Do inst.RestartMonitor()
}

ClassMethod RestartMonitor()
{
	Do STOP^%SYSMONMGR
	Write !,"Wating 5 seconds to start monitor..."
	Hang 5
	Do START^%SYSMONMGR
}

Method RegisterMe()
{
	s Classname=..LocalClassName
	Do $SYSTEM.OBJ.Compile(Classname)
	s id=""
	d ##class(%Monitor.ItemGroup).MetricsClassItemGroup(Classname,.id)
	s class=##class(%Monitor.ItemGroup).%OpenId(id)
	i '$IsObject(class) w !,"ERROR: Class '"_Classname_"' does not exist",! goto End
	i 'class.Activated s class.Activated = 1
	s status = class.%Save()
	If ('status) Do DecomposeStatus^%apiOBJ(status,.err,"-d") For i=1:1:err Write err(i),!
	k class
	q
 
End
}

Method UnRegisterMe()
{
	s Classname=..LocalClassName
	s id=""
	d ##class(%Monitor.ItemGroup).MetricsClassItemGroup(Classname,.id)
	i id="" w !,"ERROR: Class '"_Classname_"' does not exist",! goto End
	s status=##class(%Monitor.ItemGroup).%DeleteId(id)
	If ('status) Do DecomposeStatus^%apiOBJ(status,.err,"-d") For i=1:1:err Write err(i),!
	s sc=##class(%Monitor.Manager).Purge(Classname)
	i sc'=1 w !,"Error: "_sc,!
	q

End
}

ClassMethod GetSamples(pClassName As %String)
{
	Set mclass=pClassName
	Set col=##class(%Monitor.SampleAgent).%New(mclass)
	Do col.Collect()
	
	Set dev = "/tmp/"_$HOROLOG_".txt"
	OPEN dev:("ARW"):5
	USE dev
	$$$THROWONERROR(st, ##class(%Monitor.View).Display(mclass))
	CLOSE dev
	
	Set f = ##class(%File).%New(dev)
	Do f.Open()
	Set log = f.Read()
	While 'f.AtEnd { 
		Set log = log_f.ReadLine()_$C(13,10)
	}
	Do f.Close()
	
	Do f.Delete(dev)
	
	Return log
}

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
	
	// Check metric every 10s
	Set time = 10
	Do ##class(%SYS.Monitor).Interval(time)
	Do ##class(%Monitor.Manager).AppInterval(time)
	
	Set name  = "perf-model-appointments-prediction"
	Set appname = $namespace
	Set action = 1
	Set nmethod = ""
	Set nclass = ""
	Set mclass = "MyMetric.IntegratedMLModelsValidation"
	Set prop = "ModelMetricAccuracy"
	Set expr = "%1 < .9"
	Set once = 0
	Set evalmethod = ""
	// Delete previous alert if exists
	Set exists = ##class(%Monitor.Alert).GetId(name,.id)
	Set:(exists) st = ##class(%Monitor.Alert).Delete(name, appname)
	// Create an alert
	Set st = ##class(%Monitor.Alert).Create(name, appname, action, nmethod, nclass, mclass, prop, expr, once, evalmethod)
	$$$THROWONERROR(st, st)
	
	// Restart monitor
	Do ##class(MyMetric.Install).RestartMonitor()
}

}